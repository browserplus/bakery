require 'yaml'
require 'set'
require 'uri'
require 'rbconfig'
require 'fileutils'
require 'open-uri'
require 'openssl'
require 'digest/md5'
require 'pathname'
include Config

require File.join(File.dirname(__FILE__), 'build_timer')
require File.join(File.dirname(__FILE__), 'fast_md5')

# WORKAROUND
# This is a workaround, we open the OpenURI class and redefine the
# redirectable? method so that we can redirect from http:// -> https://
# This should be safe, but is not allowed in the current implementation.
# The reason for the redirect is related to Sidejack exploit that allows
# existing sessions to be hijacked from other computers by sniffing a
# few cookies.
if OpenSSL::SSL::VERIFY_PEER != OpenSSL::SSL::VERIFY_NONE
  OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
end
def OpenURI.redirectable?(uri1, uri2) # :nodoc:
  # This test is intended to forbid a redirection from http://... to
  # file:///etc/passwd.
  # However this is ad hoc.  It should be extensible/configurable.
  uri1.scheme.downcase == uri2.scheme.downcase ||
  (/\A(?:http|ftp|https)\z/i =~ uri1.scheme && /\A(?:http|ftp|https)\z/i =~ uri2.scheme)
end

alias actual_system system

def system *args
  rv = actual_system(*args)
  raise "system invocation failed (#{args.join(' ')})" if !rv
  raise "system call returned non success: #{$?}" if $? != 0
  return rv
end

class Builder
  attr_reader(:platform, :cache_dir, :toolchain)

  def __checkSym map, sym
    if !map || !map.has_key?(sym)
      throw "recipe for #{@pkg} is incomplete: missing ':#{sym}' key"
    end
  end

  def initialize pkg, verbose, output_dir, cmake_gen, cache_dir,
      wintools_dir, recipe_location = nil
    # capture the top level portDir
    @port_dir = File.expand_path(File.dirname(File.dirname(__FILE__)))

    # try to locate the pkg
    locations = [
                 recipe_location,
                 File.join(@port_dir, pkg, "recipe.rb")
                ] +
      Dir.glob(File.join(@port_dir, "*", pkg, "recipe.rb"))

    @recipe_path = nil
    locations.each { |x|
      next if @recipe_path != nil || x == nil || !File.readable?(x)
      @recipe_path = File.expand_path(x)
      break
    }
    throw "unknown package: #{pkg}" if !@recipe_path

    @recipe_dir = File.expand_path(File.dirname(@recipe_path))

    # now let's read and parse the recipe
    @recipe = eval(File.read(@recipe_path))
#    [ :url, :md5 ].each { |sym|
#      __checkSym @recipe, sym
#    }

    @deps = (@recipe.has_key? :deps) ? @recipe[:deps] : Array.new

    @pkg = pkg
    @verbose = verbose

    @distfiles_path = File.join(cache_dir, "distfiles") # not @cache_dir
    FileUtils.mkdir_p(@distfiles_path)

    @workdir_path = File.join(@port_dir, "work", @pkg)
    FileUtils.mkdir_p(@workdir_path)

    @logdir_path = File.join(@workdir_path, "logs")

    # create and define directories where ports should put stuff
    @wintools_dir = wintools_dir ? wintools_dir : File.join(@port_dir,
                                                            "WinTools")

    # create and define directories where ports should put stuff
    @output_dir = output_dir ? output_dir : File.join(@port_dir, "dist")
    FileUtils.mkdir_p(@output_dir)    

    @output_inc_dir = File.join(@output_dir, "include", @pkg)
    FileUtils.mkdir_p(@output_inc_dir)    

    @output_bin_dir = File.join(@output_dir, "bin")
    FileUtils.mkdir_p(@output_bin_dir)    

    @output_doc_dir = File.join(@output_dir, "doc", @pkg)
    @output_share_dir = File.join(@output_dir, "share")
    

    # lib dir will be updated at _pre_build_ time (once per build type)

    # initialize OS specific compile/link flags to the empty string
    @os_compile_flags = ""
    @os_link_flags = ""

    # let's determine the platform
    @toolchain = nil
    @patch_cmd = "patch"
    @toolchain = nil
    if CONFIG['arch'] =~ /mswin|mingw/
      @platform = :Windows
      @platlookup = [ @platform, :All ]
      @sevenZCmd = File.expand_path(File.join(@port_dir, "WinTools", "7z.exe"))
      # on windows, patch is called ptch since an exe named "patch" will
      # cause a UAC on Vista
      @patch_cmd = File.expand_path(File.join(@port_dir, "WinTools",
                                              "ptch.exe"))

      # determine what Visual Studio we are using
      foo=`devenv.com /?`
      if foo.index("Visual Studio Version 10.")
        @toolchain = "vs10"
        @cmake_generator = "Visual Studio 10"
      elsif foo.index("Visual Studio Version 9.")
        @toolchain = "vs9"
        @cmake_generator = "Visual Studio 9 2008"
      elsif foo.index("Visual Studio Version 8.")
        @toolchain = "vs8"
        @cmake_generator = "Visual Studio 8 2005"
      else 
        raise "Unknown visual studio version"
      end
    elsif CONFIG['arch'] =~ /darwin/
      @platform = :MacOSX
      @platlookup = [ @platform, :Unix, :All ]

      # Compiler/linker flags needed for backward compatibility.  
      # The surrounding spaces are important, don't be tempted to remove them.
      #
      # Backward compatibility is painful, see 
      # http://developer.apple.com/releasenotes/Darwin/SymbolVariantsRelNotes/index
      # In general, we must get these flags to the compiler and linker 
      # to tell it what sdk to use.  In addition, source which defines
      # any of the preprocessor symbols mentioned in the above article
      # will be problematic.
      #

      # Kinda skanky, switch on an env var for 10.4 builds.
      # When 10.4 goes away, only the else clause remains.  
      if (ENV['BP_OSX_TARGET'] == '10.4')
        @os_compile_flags = " -isysroot /Developer/SDKs/MacOSX10.4u.sdk "
        @os_compile_flags += " -mmacosx-version-min=10.4 "
        @os_link_flags = @os_compile_flags
        if CONFIG['arch'] !~ /darwin8/
          # this flag only exists on 10.5 and later
          @os_link_flags += " -syslibroot,/Developer/SDKs/MacOSX10.4u.sdk "
        end
        @cmake_args = "-DCMAKE_OSX_DEPLOYMENT_TARGET=10.4 "
        ENV['CC'] = 'gcc-4.0'
        ENV['CXX'] = 'g++-4.0'
      else
        @os_compile_flags = " -mmacosx-version-min=10.5 "
        @os_link_flags = @os_compile_flags
        @cmake_args = "-DCMAKE_OSX_DEPLOYMENT_TARGET=10.5 "
        # XXX llvm doesn't support code coverage!
        #ENV['CC'] = '/Developer/usr/bin/llvm-gcc-4.2'
        #ENV['CXX'] = '/Developer/usr/bin/llvm-g++-4.2'
        ENV['CC'] = 'gcc-4.2'
        ENV['CXX'] = 'g++-4.2'
      end
      @os_compile_flags += " -arch i386 "

      @toolchain = File.basename(ENV['CC'])

      @cmake_args += "-DCMAKE_OSX_COMPILE_TARGET_FLAGS=\"#{@os_compile_flags}\" "
      @cmake_args += "-DCMAKE_OSX_LINK_TARGET_FLAGS=\"#{@os_link_flags}\" "
    elsif CONFIG['arch'] =~ /linux/
      @platform = :Linux
      @platlookup = [ @platform, :Unix, :All ]
      @os_compile_flags = " -fPIC "
    end

    # now set @cache_dir, which includes a subdir for build toolset
    @cache_dir = cache_dir
    @cache_dir = File.join(@cache_dir, @toolchain) if @toolchain

    # determine the URL for this platform
    @url = nil
    if @recipe.has_key?(:url)
      if @recipe[:url].kind_of?(Hash) 
        @url = @recipe[:url][@platform] if @recipe[:url].has_key?(@platform) 
      elsif @recipe[:url].kind_of?(String)
        @url = @recipe[:url]
      else
        throw "invalid url: #{@recipe[:url].inspect}"
      end
    end

    # 'github' urls are handled specially. 
    if @url != nil 
      @orig_url = @url
      uri = URI.parse(@url) 
      require 'pp'
      if uri.scheme == "github"
        x,project,sha256  = uri.path.split('/')
        user = uri.host
        # it's time to build a url
        @url = "http://github.com/#{user}/#{project}/tarball/#{sha256}"
        @tarball = File.expand_path(
                       File.join(@distfiles_path,
                                 "#{user}-#{project}-#{sha256}.tgz"))
      else 
        tarball = File.basename(uri.path)
        @tarball = File.expand_path(File.join(@distfiles_path, tarball))
      end
    end

    # set cmake_generator if passed
    if cmake_gen
      @cmake_generator = cmake_gen
    end
    # Strips out unnecessary quotes, if they were given
    if @cmake_generator != nil
      @cmake_generator.strip!
      if @cmake_generator.start_with?("\"") && @cmake_generator.end_with?("\"")
        xyzzy = @cmake_generator.slice(1, (@cmake_generator.length - 2))
        @cmake_generator = xyzzy
      end
    end

    
    #build up the configuration object that will be passed into build functions
    @conf = {
      :platform => @platform,
      :output_dir => @output_dir,
      :wintools_dir => @wintools_dir,
      :toolchain => @toolchain,
      :output_inc_dir => @output_inc_dir,
      :output_bin_dir => @output_bin_dir,
      :output_doc_dir => @output_doc_dir,
      :output_share_dir => @output_share_dir,
      :cmake_generator => @cmake_generator,
      :os_compile_flags => @os_compile_flags,
      :os_link_flags => @os_link_flags,
      :cmake_args => @cmake_args,
      :recipe_dir => @recipe_dir,
      :log_dir => @logdir_path
    }

    # where shall our manifest live?
    @receipts_dir = File.join(@output_dir, "receipts")
    FileUtils.mkdir_p(@receipts_dir)
    @receipt_path = File.join(@receipts_dir, "#{@pkg}.yaml")

    # port md5 calculation is expensive.  we only calculate it once per
    # invocation using this member as a cache
    @port_md5 = nil
  end

  def deps
    @deps
  end

  # fetch the current contents of one of the subdirs of output_dir
  # (like lib/ include/ share/ or bin/)
  def __output_contents
    oc = Set.new
    Dir.glob(File.join(@output_dir, "*")).each { |p|
      prefix = File.basename(p)
      # skip receipts dir
      next if prefix == 'receipts'
      if File.directory? p
        oc.merge(Dir.chdir(p) {
                   Dir.glob("**/*").reject { |f|
                     File.directory?(f) }.collect { |f|
                     File.join(prefix, f)
                   }
                 })
      else
        oc.add(prefix)
      end
    }
    oc
  end

  # a "port md5" is a single md5 that captures the state of all files in the
  # ports directory.  if any of them changes, then the port md5 changes too
  # and a rebuild is triggered.  Because a recipe includes the md5 of the
  # contents of the source tarball, this "port md5" is really an md5 over the
  # entire input to the build process, sans environmental factors (env vars,
  # compiler version, etc).  
  def __getPortMD5
    return @port_md5 if @port_md5 != nil

    md5s = Array.new

    Dir.glob(File.join(@recipe_dir, "**", "*")).each{ |f|
      md5s.push __fastMD5(f) if File.file? f
    }

    # now include md5s of the bakery's implementation.  this means port md5s
    # will be invalidated as the bakery's implementation changes, which is
    # conservative, but intended to avoid some hard-to-chase-down bugs.
    md5s.push(__fastMD5(File.join(@port_dir, "bakery.rb")))
    Dir.glob(File.join(@port_dir, "Impl", "**", "*")).each{ |f|
      md5s.push __fastMD5(f) if File.file? f    
    }
    
    @port_md5 = Digest::MD5::hexdigest(md5s.sort.join)
    return @port_md5
  end
  
  def needsBuild
    return true if !File.exist?(@receipt_path)
    
    r = File.open( @receipt_path ) { |yf| YAML::load( yf ) }

    # first, if the recipe contents have changed, or any of the contents inside
    # the port directory (patches, etc), then we need a rebuild.
    # (and we don't care if they've moved, really, it's about contents)
    return true if r[:recipe] != __getPortMD5()

    return false
  end

  def clean
    log_with_time "      removing previous build artifacts (#{@workdir_path})..."
    FileUtils.rm_rf(@workdir_path)
    FileUtils.mkdir_p(@workdir_path)

    if File.exist?(@receipt_path)
      log_with_time "      removing previous build output..."
      __redirectOutput("clean") do
        # now remove installed artifacts if needed
        r = File.open( @receipt_path ) { |yf| YAML::load( yf ) }
        r[:files].each { |p,md5|
          FileUtils.rm_f(File.join(@output_dir, p), :verbose => true )
        }
        FileUtils.rm_f( @receipt_path, :verbose => true )
        
        # for good measure, let's remove and re-create the header directory
        # (handles nested directories)
        FileUtils.rm_rf( @output_inc_dir, :verbose => true )
        FileUtils.mkdir_p( @output_inc_dir, :verbose => true )      
      end
    end

    # for purposes of receipts, let's take a snapshot of the lib directory
    @output_dir_before = __output_contents

    # the total set of files that were installed, populated during
    # write_receipts phase.
    @files_installed = Array.new
  end

  def checkMD5 
    match = false
    if File.readable? @tarball
      want_md5 = nil
      if @recipe[:md5].kind_of?(Hash) 
        want_md5 = @recipe[:md5][@platform]
      elsif @recipe[:md5].kind_of?(String)
        want_md5 = @recipe[:md5]
      end
      if (!want_md5)
        return true if (URI.parse(@orig_url).scheme  == "github")
        throw "unintelligible md5 in recipe"
      end

      # now let's check the md5 sum
      calculated_md5 = __fastMD5 @tarball
      match = (calculated_md5 == want_md5)
    end
    match
  end

  def fetch
    # is fetch a lamda?
    if @recipe[:fetch].kind_of?(Proc)
      @build_dir = File.join(@workdir_path, "src")
      @conf[:src_dir] = @build_dir
      FileUtils.mkdir_p(@build_dir)
      invokeLambda(:fetch, @recipe, :fetch)
      return
    end

    if @url == nil
      log_with_time "      nothing to fetch for this port"
      return
    end

    if !checkMD5
      log_with_time "      #{@url}"
      perms = @platform == :Windows ? "wb" : "w"
      totalSize = 0
      lastPercent = 0
      interval = 5
      f = File.new(@tarball, perms)
      f.write(open(
          @url,
          :content_length_proc => lambda {|t|
              if (t && t > 0)
                totalSize = t
                log_with_time "      reading #{totalSize} bytes..."
                STDOUT.printf log_get_time
                STDOUT.printf("       %% down: ")
                STDOUT.flush
              else
                STDOUT.print("      downloading tarball of unknown size")
              end
           },
           :progress_proc => lambda {|s|
              if (totalSize > 0)
                percent = ((s.to_f / totalSize) * 100).to_i
                if (percent/interval > lastPercent/interval)
                  lastPercent = percent
                  STDOUT.printf("%d ", percent)
                  STDOUT.printf("\n") if (percent == 100)
                end
              else
                STDOUT.printf(".")
              end
              STDOUT.flush
            }).read)
            f.close()
            s = File.size(@tarball)
            if (s == 0 || (totalSize > 0 && s != totalSize))
              FileUtils.rm_f(@tarball)
              throw "download failed (#{@url})"
            end
      throw "md5 mismatch on #{@tarball} downloaded from #{@url}" if !checkMD5
    else
      log_with_time "      #{File.basename(@tarball)} already in distfiles/ no download required"
    end
  end

  def install_from_cache
    ext = ((@platform == :Windows) ? "7z" : "tgz")
    fname = File.join(@cache_dir, "#{@pkg}-#{__getPortMD5()}.#{ext}")
    if File.exist? fname
      __redirectOutput("install_from_cache") do
        Dir.chdir(@output_dir) do
          if @platform == :Windows
            system("\"#{@sevenZCmd}\" x -y \"#{fname}\"")
          else
            system("tar xvzf \"#{fname}\"")
          end
          return true
        end
      end
    end
    return false
  end

  def unpack
    if !@tarball
      log_with_time "      nothing to unpack for this port"
      return
    end
    
    srcPath = File.join(@workdir_path, "src")
    FileUtils.mkdir_p srcPath
    Dir.chdir(srcPath) do
      __redirectOutput("unpack") do
        path = @tarball
        puts "      unpacking #{path}..."
        if path =~ /\.tar\./
          if @platform == :Windows
            system("\"#{@sevenZCmd}\" x \"#{path}\"")
            tarPath = File.basename(path, ".*")
            system("\"#{@sevenZCmd}\" x \"#{tarPath}\"")
            FileUtils.rm_f(tarPath)
          else
            if File.extname(path) == ".bz2"
              system("tar xvjf \"#{path}\"")
            elsif File.extname(path) == ".gz"
              system("tar xvzf \"#{path}\"")
            else
              throw "unrecognized format for #{path}"
            end
          end
        elsif path =~ /.tgz/
          if @platform == :Windows
            system("\"#{@sevenZCmd}\" x \"#{path}\"")
            tarPath = File.basename(path, ".*") + ".tar"
            puts "untarring #{tarPath}..."
            system("\"#{@sevenZCmd}\" x \"#{tarPath}\"")
            FileUtils.rm_f(tarPath)
          else
            system("tar xvzf \"#{path}\"")
          end
        elsif path =~ /.zip/ || path =~ /.7z/
          if @platform == :Windows
            system("\"#{@sevenZCmd}\" x \"#{path}\"")
          else
            system("unzip \"#{path}\"")
          end
        else
          throw "unrecognized format for #{path}"
        end
      end
    end

    # now we have what we need to determine the unpack dirname
    @unpack_dir = srcPath
    Dir.glob(File.join(srcPath, "*")).each { |d|
      @unpack_dir = d if File.directory? d
    }
    log_with_time "      unpacked to #{@unpack_dir}"

    @src_dir = File.expand_path(@unpack_dir)
    @conf[:src_dir] = @src_dir
  end

  def use_source p
    # if path provided is a tarball, we'll set @tarball and pop over
    # into the unpack code.  otherwise if it's a directory we'll
    # copy in the contents.
    if p =~ /\.tar\./ || p =~ /zip$/ || p =~ /tgz$/ 
      @tarball = p
      unpack
    elsif File.directory?(p)
      srcPath = File.join(@workdir_path, "src")
      FileUtils.mkdir_p srcPath

      Dir.glob(File.join(p, "*")).each { |f|
        # skip toplevel dotfiles
        next if f =~ /^\./
        FileUtils.cp_r(f, srcPath, :preserve => true)
      }
      
      @src_dir = srcPath
      @conf[:src_dir] = @src_dir
    else
      raise "I don't know how to \"use\" this: #{p}"
    end
  end

  def patch
    FileUtils.rm_f(__getLogPath("patch"))
    portDir = File.dirname(@recipe_path)
    
    # first we'll find patches!
    patches = Array.new

    @platlookup.each do |p|
      if p == :MacOSX
        if @toolchain == 'gcc-4.0'
          patches += Dir.glob(File.join(portDir, "*_#{p.to_s}_10_4.patch"))
        else
          patches += Dir.glob(File.join(portDir, "*_#{p.to_s}_10_5.patch"))
        end
      end
      patches += Dir.glob(File.join(portDir, "*_#{p.to_s}.patch"))
    end
    patches.sort!
    log_with_time "      Found #{patches.length} patch(es)!"
    patches.each do |p|
      p = File.expand_path(p)
      log_with_time "      Applying #{File.basename(p, ".patch")}"
      __redirectOutput("patch", true) do
        # now let's apply p  
        Dir.chdir(@src_dir) {
          pline = "\"#{@patch_cmd}\" -p1 < \"#{p}\""
          puts "executing patch cmd: #{pline}" 
          system(pline)
        }
      end
    end
  end

  def post_fetch
    @build_dir = @src_dir # yes martha, that's a hack
    invokeLambda(:post_fetch, @recipe, :post_fetch)
  end

  def post_patch
    @build_dir = @src_dir # yes martha, that's a hack
    invokeLambda(:post_patch, @recipe, :post_patch)
  end

  def pre_build buildType
    # make the build directory and set up our conf
    @conf[:build_type] = buildType
    @build_dir = File.join(@workdir_path, "build_" + buildType.to_s)
    FileUtils.mkdir_p(@build_dir)    
    @conf[:build_dir] = @build_dir

    # update lib dir
    @output_lib_dir = File.join(@output_dir, "lib", buildType.to_s.capitalize)
    FileUtils.mkdir_p(@output_lib_dir)
    @conf[:output_lib_dir] = @output_lib_dir
  end

  def __getLogPath phase
    File.join(@logdir_path, "#{phase}.log") 
  end

  def __redirectOutput phase, append = false
    FileUtils.mkdir_p(@logdir_path)
    if @conf.has_key? :build_type
      phase = phase + "_" + @conf[:build_type].to_s
    end

    fName = __getLogPath(phase)

    File.open(fName, (append ? "a" : "w")) { |f|    
      # redirect stderr and stdout
      old_stdout = $stdout.dup
      old_stderr = $stderr.dup
      $stdout.reopen(f)
      $stderr.reopen(f)
      begin
        yield
      ensure
        $stdout.reopen(old_stdout)
        $stderr.reopen(old_stderr)
      end
    }
  end

  def runBuildPhase2 phase
    # execute in the build dir
    Dir.chdir(@build_dir) {
      __redirectOutput("#{phase}") { yield }
    }
  end

  # the ampersand syntax effectively relays our callers block/closure
  # to runBuildPhaseTwo
  def runBuildPhase phase, &b
    # fork doesn't exist on windows, but likewise on windows it's less
    # common to actually use the environment, so there's less of a need
    # for the isolation that forking provides us.  If the fork raises
    # NotImplementedError we'll just fallback to non-forking mode
    fork do
      begin
        runBuildPhase2 phase, &b 
      rescue => e
        STDERR.puts "CAUGHT EXCEPTION during #{phase.to_s} phase: #{e.to_s}"
        exit 1
      end
    end
    Process.wait
    raise "build failed" if $?.exitstatus != 0
  rescue NotImplementedError
    runBuildPhase2 phase, &b    
  end
    
  def invokeLambda step, obj, sym
    # support arrays as keys in recipes for user conveneince, i.e.:
    #  [:Linux, :MacOSX] => "make"
    # essentially what we do is iterate through all recipe
    if obj && !obj.has_key?(sym)
      obj.each { |k,v|
        sym = k if (k.kind_of?(Array) && k.include?(sym))
      }
    end      

    if obj && obj.has_key?(sym)
      if obj[sym] == nil
        log_with_time "      (not required on this platform)"
      elsif obj[sym].kind_of?(Hash)
        invokeLambda(step, obj[sym], @platform)
      elsif obj[sym].kind_of?(String)
        runBuildPhase(step.to_s) {
          system(obj[sym])
        }
      elsif obj[sym].kind_of?(Proc)
        runBuildPhase(step.to_s) { obj[sym].call @conf }
      else
        throw "invalid recipe file (handling #{sym})"
      end
    else 
      log_with_time "      WARNING: #{step} step not supplied!"
    end
  end

  def configure
    invokeLambda(:configure, @recipe, :configure)
  end

  def build
    invokeLambda(:build, @recipe, :build)
  end

  def install
    invokeLambda(:install, @recipe, :install)
  end

  def post_install
    invokeLambda(:post_install, @recipe, :post_install)
    @conf.delete :build_type
  end

  def post_install_common
    @build_dir = @src_dir # yes martha, that's a hack
    invokeLambda(:post_install_common, @recipe, :post_install_common)
  end

  def dist_clean
  end

  def write_receipt
    sigs = Hash.new
    @files_installed = __output_contents.subtract(@output_dir_before)

    Dir.chdir(@output_dir) { 
      @files_installed.each { |l|
        sigs[l] = __fastMD5(File.join(@output_dir, l))
      }
    }

    rf = {
      :recipe => __getPortMD5(),
      :files => sigs.sort
    }
    File.open(@receipt_path, "w") { |r| YAML.dump(rf, r) }
  end

  def save_to_cache
    FileUtils.mkdir_p(@cache_dir)
    ext = ((@platform == :Windows) ? "7z" : "tgz")
    fname = File.join(@cache_dir, "#{@pkg}-#{__getPortMD5()}.#{ext}")
    FileUtils.rm_f(fname)
    __redirectOutput("save_to_cache") do
      Dir.chdir(@output_dir) {
        # lets' add the reciepts file to file_installed
        @files_installed.add Pathname.new(@receipt_path).relative_path_from(Pathname.new(@output_dir)).to_s

        filelist = File.join(@workdir_path, "filelist.txt")
        File.open(filelist, "w+") { |f|
          @files_installed.each { |fi|
            f.puts fi
          }
        }
        if @platform == :Windows
          system("\"#{@sevenZCmd}\" a -y \"#{fname}\" @\"#{filelist}\"")
        else
          system("tar -T \"#{filelist}\" -czf \"#{fname}\"")
        end
      }
    end
    log_with_time "      #{File.size(fname) / 1024}kb saved to #{File.basename(fname)}"
  end
end
