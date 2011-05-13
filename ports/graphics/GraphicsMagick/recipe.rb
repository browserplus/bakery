{
  :url => { :Linux => 'http://sourceforge.net/projects/graphicsmagick/files/graphicsmagick/1.3.12/GraphicsMagick-1.3.12.tar.gz', 
            :MacOSX => 'http://sourceforge.net/projects/graphicsmagick/files/graphicsmagick/1.3.12/GraphicsMagick-1.3.12.tar.gz', 
            :Windows => 'http://sourceforge.net/projects/graphicsmagick/files/graphicsmagick/1.3.12/GraphicsMagick-1.3.12-windows-source.7z' },
  :md5 => { :Linux => '2cf6e2eea0d7af3019c9a89b81aad624',
            :MacOSX => '2cf6e2eea0d7af3019c9a89b81aad624',
            :Windows => '18db4ccafbde714c95d9c870fffcbc8f' },
  :deps => [ 'jpeg', 'libpng', 'zlib' ],
  
  :post_patch => {
    :Windows => lambda { |c| 
      puts "Running post-patch"

      # Now ladies and gentlemen, we'll go through all vcproj files and
      # replace a couple paths with their actual path
      inc_dir = File.join(c[:output_dir], "include")
      actualPaths = {
        /ZLIB_INCLUDE_PATH/ => File.join(inc_dir, "zlib"),
        /JPEG_INCLUDE_PATH/ => File.join(inc_dir, "jpeg"),
        /LIBPNG_INCLUDE_PATH/ => File.join(inc_dir, "libpng")
      }

      # massage pathery
      actualPaths.each{ |k,v|
        actualPaths[k] = File.expand_path(v).gsub(/\//,"\\")
      }
        
      Dir.glob(File.join(c[:src_dir], "VisualMagick", "**", "*.vcproj")).each { |p|
        puts "subbing '#{p}'"
        # read the whole thing
        contents = File.read(p)

        # sub in the proper paths
        actualPaths.each { |k,v| contents.gsub!(k, v) }
        
        # write the whole thing
        File.open(p, "w") { |f| f.write contents }
      }

      Dir.chdir(File.join(c[:src_dir])) do
        devenvOut = File.join(c[:log_dir], "devenv_upgrade.txt")
        system("devenv VisualMagick\\VisualStaticMT.sln /upgrade > #{devenvOut}")
      end

    }
  },
  :configure => {
    [ :Linux, :MacOSX ] => lambda { |c|
      zlib_hdrs = File.join(c[:output_dir], "include", "zlib")
      jpg_hdrs = File.join(c[:output_dir], "include", "jpeg")
      png_hdrs = File.join(c[:output_dir], "include", "libpng")
      bt = c[:build_type].to_s
      ENV['CFLAGS'] = "-I#{zlib_hdrs} -I#{jpg_hdrs} -I#{png_hdrs} #{ENV['CFLAGS']}" 
      ENV['CFLAGS'] += " #{c[:os_compile_flags]}"
      if c[:build_type] == :debug
        ENV['CFLAGS'] += " -g -O0"
      end
      ENV['LDFLAGS'] = " -L#{c[:output_lib_dir]} #{c[:os_link_flags]} #{ENV['LDFLAGS']}"
      cfgOpts = "--enable-static --disable-shared --without-bzlib " +
                "--without-dps --without-jp2 --without-lcms --without-tiff " +
                "--without-trio --without-ttf --without-xml --without-x " +
                "--disable-openmp --disable-installed --prefix=#{c[:output_dir]}" 
      cfgScript = File.join(c[:src_dir], "configure")
      puts("LDFLAGS=\"#{ENV['LDFLAGS']}\" #{cfgScript} #{cfgOpts}")      
      system("LDFLAGS=\"#{ENV['LDFLAGS']}\" #{cfgScript} #{cfgOpts}")
    }
  },
  :build => {
    [ :Linux, :MacOSX ] => "make",
    :Windows => lambda { |c|
      Dir.chdir(File.join(c[:src_dir])) do
        bt = c[:build_type].to_s.capitalize
        devenvOut = File.join(c[:log_dir], "devenv_#{c[:build_type]}.txt")
        system("devenv VisualMagick\\VisualStaticMT.sln /build #{bt} > #{devenvOut}")
      end
    }
  },
  :install => {
    [ :Linux, :MacOSX ] => lambda { |c|
      system("make install")
      # rename static lib (append _s and move to buildtype dir)
      Dir.glob(File.join(c[:output_dir], "lib", "libGraphics*")).each { |l|
        newFname = File.basename(l).sub(/\.a$/, "_s.a")
        FileUtils.mv(l, File.join(c[:output_lib_dir], newFname),
                     :verbose => true)
      }
    },
    :Windows => lambda { |c|
      puts "installing #{c[:build_type].to_s} static libraries..."
      bt = (c[:build_type] == :debug) ? "DB" : "RL"
      {
        "_coders_"  => "GraphicsMagickCoders_s.lib",
        "_filters_" => "GraphicsMagickFilters_s.lib",
        "_Magick++_" => "GraphicsMagick++_s.lib",
        "_wand_" => "GraphicsMagickWand_s.lib",
        "_magick_" => "GraphicsMagick_s.lib"
      }.each { |k,v|
        fname = "CORE_#{bt}#{k}.lib"
        FileUtils.cp(File.join(c[:src_dir], "VisualMagick", "lib", fname),
                     File.join(c[:output_lib_dir], v),
                     :preserve => true, :verbose => true)
      }

      if (c[:build_type] == :release) 
        puts "installing headers..."
        [ "wand", "magick" ].each { |d|
          tgt = File.join(c[:output_inc_dir], d)
          FileUtils.mkdir_p(tgt)
          Dir.glob(File.join(c[:src_dir], d, "*.h")).each { |h|
            FileUtils.cp(h, tgt, :preserve => true, :verbose => true)
          }
        }

        # now let's install Magick++ headers which live in a different place
        tgt = File.join(c[:output_inc_dir], "Magick++")
        FileUtils.mkdir_p(tgt)
        Dir.glob(File.join(c[:src_dir], "Magick++", "lib", "Magick++", "*.h")).each { |h|
          FileUtils.cp(h, tgt, :preserve => true, :verbose => true)
        }
        FileUtils.cp(File.join(c[:src_dir], "Magick++", "lib", "Magick++.h"),
                     c[:output_inc_dir], :preserve => true, :verbose => true)

        # finally the magic.mgk file, an xml document which enumerates
        # supported formats
        magicMgkHome = File.join(c[:output_share_dir], "GraphicsMagick-1.3.7",
                                 "config")
        FileUtils.mkdir_p(magicMgkHome) 
        FileUtils.cp(File.join(c[:src_dir], "VisualMagick", "bin", "magic.mgk"),
                     magicMgkHome, :preserve => true, :verbose => true)
      end
    }
  }
}
