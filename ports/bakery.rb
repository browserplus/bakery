# The top level include file for the bakery 

require File.join(File.dirname(__FILE__), 'Impl', 'builder')
require File.join(File.dirname(__FILE__), 'Impl', 'build_timer')
require File.join(File.dirname(__FILE__), 'Impl', 'fast_md5')

require 'tsort'

# implement combination(2) inline for support for ruby < 1.8.7
def mycombinations arr
  combs = Array.new
  i = 0
  while i < arr.length - 1
    arr[i+1,arr.length].each { |j| combs.push [arr[i], j ] }
    i += 1
  end
  combs
end

class Hash
  include TSort
  alias tsort_each_node each_key
  def tsort_each_child(node, &block)
    fetch(node).each(&block)
  end
end


class Bakery
  @@distfiles_dir = File.join(File.dirname(__FILE__), "distfiles")
  @@work_dir = File.join(File.dirname(__FILE__), "work")

  def initialize order
    throw "improper order passed to Bakery.new!" if !order
    @build_types = [ :debug, :release ]
    @verbose = (order && order[:verbose])
    @output_dir = File.join(File.dirname(__FILE__), "dist")
    @output_dir = order[:output_dir] if (order && order[:output_dir])
    @output_dir = File.expand_path(@output_dir)
    @wintools_dir = File.join(File.dirname(__FILE__), "WinTools")
    @wintools_dir = order[:wintools_dir] if (order && order[:wintools_dir])
    @wintools_dir = File.expand_path(@wintools_dir)
    @packages = order.has_key?(:packages) ? order[:packages] : Array.new
    @cmake_generator = (order && order[:cmake_generator])
    @use_source = order[:use_source]
    @use_recipe = order[:use_recipe]
    @cache_dir = File.join(ENV['HOME'], ".bakery_pkgcache")

    # now handle dependencies...
    fullDeps = Hash.new

    # first track down all dependencies
    stack = @packages
    while stack.length > 0
      p = stack.pop
      next if fullDeps.has_key? p
      recipe = nil
      recipe = @use_recipe[p] if @use_recipe && @use_recipe.has_key?(p) 
      b = Builder.new(p, @verbose, @output_dir, @cmake_generator,
                      @cache_dir, @wintools_dir, recipe)      
      fullDeps[p] = b.deps
      b.deps.each { |d| stack.push d }
    end
    # topological sort
    @packages = fullDeps.tsort
  end

  
  def build
    log_with_time "building #{@packages.length} packages:" if @verbose
    @packages.each { |p|
      recipe = nil
      recipe = @use_recipe[p] if @use_recipe && @use_recipe.has_key?(p) 
      log_with_time "--- building #{p}#{recipe ? (" (" + recipe + ")") : ""} ---" if @verbose      
      b = Builder.new(p, @verbose, @output_dir, @cmake_generator,
                      @cache_dir, @wintools_dir, recipe)
      if !b.needsBuild
        log_with_time "  - skipping #{p}, already built!" if @verbose
        next
      end

      log_with_time "  - cleaning #{p}" if @verbose      
      b.clean

      # if we've got the built bits in the cache, then let's use em
      # and call it a day!
      log_with_time "  - checking cache for built pkg" if @verbose
      if b.install_from_cache
        log_with_time "      Installed from cache!  all done." if @verbose
        next
      end

      # if use_source is specified for this package it short circuts
      # fetch and unpack
      useSourcePath = nil
      if @use_source && @use_source.has_key?(p)
        if @use_source[p].kind_of?(Hash) && @use_source[p].has_key?(b.platform)
          useSourcePath = @use_source[p][b.platform]
        elsif @use_source[p].kind_of?(String)
          useSourcePath = @use_source[p]
        end
      end
      if useSourcePath
        log_with_time "  - copying local source for #{p} (#{useSourcePath})" if @verbose      
        b.use_source useSourcePath
      else 
        log_with_time "  - fetching #{p}" if @verbose      
        b.fetch
        log_with_time "  - unpacking #{p}" if @verbose      
        b.unpack
      end
      log_with_time "  - post-fetch #{p}" if @verbose      
      b.post_fetch

      log_with_time "  - patching #{p}" if @verbose      
      b.patch
      log_with_time "  - post-patch #{p}" if @verbose      
      b.post_patch

      @build_types.each { |bt|
        log_with_time "  - pre_build step for #{p} (#{bt})" if @verbose      
        b.pre_build bt
        log_with_time "  - configuring #{p} (#{bt})" if @verbose      
        b.configure
        log_with_time "  - building #{p} (#{bt})" if @verbose      
        b.build
        log_with_time "  - installing #{p} (#{bt})" if @verbose      
        b.install
        log_with_time "  - running post_install for #{p} (#{bt})" if @verbose
        b.post_install
      }
      log_with_time "  - running post_install_common for #{p}" if @verbose  
      b.post_install_common
      log_with_time "  - cleaning up #{p}" if @verbose      
      b.dist_clean
      log_with_time "  - Writing receipt for #{p}" if @verbose      
      b.write_receipt
      log_with_time "  - Saving #{p} build output to cache (#{b.cache_dir})" if @verbose      
      b.save_to_cache
    }
  end


  def check
    # an array populated with warnings as we check the bakery 
    state = {
      :info => Array.new,
      :warn => Array.new,
      :error => Array.new
    }

    # we want to catch several cases:
    # 0. out of date ports
    # 1. files "owned" by multiple receipts
    # 2. files in the output dir which are not noted in a receipt
    # 3. files in a reciept that are not in the output dir
    # 4. files in output dir that are different than their md5s.

    # read the full contents of the output dir and calculate md5s (expensive)
    contents = __output_contents

    # check all pkgs for out of date
    receipts = Hash.new

    Dir.glob(File.join(@output_dir, "receipts", "*.yaml")).each { |rp|
      pkg = File.basename(rp, ".yaml")
      recipe = nil
      recipe = @use_recipe[pkg] if @use_recipe && @use_recipe.has_key?(pkg)  
      b = Builder.new(pkg, @verbose, @output_dir, @cmake_generator,
                      @cache_dir, @wintools_dir, recipe)
      state[:info].push "#{pkg} is out of date, and needs to be built" if b.needsBuild

      # now load up the receipts
      receipts[pkg] = File.open( rp ) { |yf| YAML::load( yf ) }
    }

    # first let's ensure there's no files owned by multiple ports 
    # while we build up a set of all owned files
    allOwnedFiles = Hash.new
    mycombinations(receipts.collect{ |pkg, rcpt|
      rcpt[:files].each { |a| allOwnedFiles[a[0]] = a[1] }
      fset = Set.new(rcpt[:files].map { |arr| arr[0] }) 
      [pkg, fset]
    }).each { |a, b|
      c = a[1] & b[1]
      state[:error].push "#{a[0]} & #{b[0]} both think they own certain files (vewy, vewy, bad): #{c.to_a.join(', ')}" if c.size > 0
    }

    # iterate through all files in output dir, make sure they're
    # owned by a pkg and the md5 matches
    contents.each { |f, md5|
      if !allOwnedFiles.has_key? f
        state[:error].push "file '#{f}' is not owned by any package!"
      elsif md5 != allOwnedFiles[f]
        state[:error].push "file '#{f}' has been altered since build!"
      end
      allOwnedFiles.delete f      
    }
    if allOwnedFiles.size > 0
      state[:error].push "#{allOwnedFiles.size} files are missing from output dir: #{allOwnedFiles.map { |k,v| k }.join(', ')}"
    end

    state
  end


  def __output_contents
    oc = Hash.new
    Dir.glob(File.join(@output_dir, "*")).each { |p|
      prefix = File.basename(p)
      # skip receipts dir
      next if prefix == 'receipts'
      if File.directory? p
        Dir.chdir(p) {
          Dir.glob("**/*").each { |f|
            next if File.directory?(f)
            oc[File.join(prefix, f)] = __fastMD5(f)
          }
        }
      else
        oc[prefix] = __fastMD5(p)
      end
    }
    oc
  end

end
