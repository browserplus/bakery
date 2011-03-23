{
  :url => "http://prdownloads.sourceforge.net/libpng/zlib-1.2.5.tar.bz2?download",
  :md5 => "be1e89810e66150f5b0327984d8625a0",
  :post_patch => {
    :Windows => lambda { |c|
      pathToSLN = File.join(c[:src_dir], "projects", "visualc6", "zlib.sln")
      devenvOut = File.join(c[:log_dir], "devenv_upgrade.txt")
      devenvCmd = "devenv #{pathToSLN} /upgrade > #{devenvOut}"
      puts "issuing: #{devenvCmd}"
      system(devenvCmd)
    }
  },
  :configure => {
    [ :Linux, :MacOSX ] => lambda { |c|
      ENV['CFLAGS'] = "#{c[:os_compile_flags]} #{ENV['CFLAGS']}"
      ENV['CFLAGS'] += ' -g -O0 ' if c[:build_type] == :debug
      ENV['LDFLAGS'] = "#{c[:os_link_flags]} #{ENV['LDFLAGS']}"

      # zlib doesn't like out of source builds
      Dir.chdir(c[:src_dir]) {
        system("./configure")
      }
    }
  },
  :build => {
    [ :Linux, :MacOSX ] => lambda { |c|
      # zlib doesn't like out of source builds
      Dir.chdir(c[:src_dir]) {
        system("make")
      }
    },
    :Windows => lambda { |c|
      pathToSLN = File.join(c[:src_dir], "projects", "visualc6", "zlib.sln")
      bt = c[:build_type].to_s.capitalize
      devenvOut = File.join(c[:log_dir], "devenv_#{c[:build_type]}.txt")
      devenvCmd = "devenv #{pathToSLN} /build \"LIB #{bt}\" /project zlib > #{devenvOut}"
      puts "issuing: #{devenvCmd}"
      system(devenvCmd)
    }
  },
  :install => {
    [ :Linux, :MacOSX ] => lambda { |c|
      puts "installing static library..."
      FileUtils.cp(File.join(c[:src_dir], "libz.a"),
                   File.join(c[:output_lib_dir], "libzlib_s.a"),
                   :preserve => true, :verbose => true)
    },
    :Windows => lambda { |c|
      bt = c[:build_type].to_s.capitalize      
      suffix = (bt == "Debug") ? "d" : ""
      FileUtils.install(File.join(c[:src_dir], "projects", "visualc6",
                                  "Win32_LIB_#{bt}", "zlib#{suffix}.lib"),
                        File.join(c[:output_lib_dir], "zlib_s.lib"),
                        :preserve => true, :verbose => true)
    }
  },
  :post_install => lambda { |c|
    if c[:build_type] == :release
      puts "installing headers..."
      ["zconf.h", "zlib.h"].each { |h|
        FileUtils.cp(File.join(c[:src_dir], h),
                     c[:output_inc_dir],
                     :preserve => true, :verbose => true)
      }
    end
  }
}
