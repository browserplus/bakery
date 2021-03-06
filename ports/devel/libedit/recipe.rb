{
  :url => "http://www.thrysoee.dk/editline/libedit-20110227-3.0.tar.gz",
  :md5 => "411e0a79c36a2e8d64b160b4ca2fcf53",
  :configure => {
    [ :Linux, :MacOSX ] => lambda { |c|
      if c[:platform] == :MacOSX
        ENV['CFLAGS'] = "#{c[:os_compile_flags]} #{ENV['CFLAGS']}"
        ENV['LDFLAGS'] = "#{c[:os_link_flags]} #{ENV['LDFLAGS']}"
      end

      if c[:build_type] == :debug
        ENV['CFLAGS'] = "-g -O0 #{ENV['CFLAGS']}"
      end

      configScript = File.join(c[:src_dir], "configure")
      configstr = "#{configScript} --disable-shared --prefix=#{c[:output_dir]}"
      puts "running configure: #{configstr}"
      system(configstr)
    }
  },
  :build => {
    [ :Linux, :MacOSX ] => "make"
  },
  :install => {
    [ :Linux, :MacOSX ] => lambda { |c|
      system("make install")

      # XXX: consider installing to build dir then copying into output?
      # (less cruft)
      # rename static lib (append _s and move to buildtype dir)
      FileUtils.mv(File.join(c[:output_dir], "lib", "libedit.a"),
                   File.join(c[:output_lib_dir], "libedit_s.a"),
                   :verbose => true)
      FileUtils.mv(File.join(c[:output_dir], "lib", "libedit.la"),
                   File.join(c[:output_lib_dir], "libedit_s.la"),
                   :verbose => true)

      # mv headers
      FileUtils.mv(File.join(c[:output_dir], "include", "histedit.h"),
                   c[:output_inc_dir], :verbose => $verbose)
      FileUtils.mv(File.join(c[:output_dir], "include", "editline", "readline.h"),
                   c[:output_inc_dir], :verbose => $verbose)
      FileUtils.rmdir(File.join(c[:output_dir], "include", "editline"))
    }
  }
}
