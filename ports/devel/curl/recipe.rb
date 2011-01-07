{
  :url => 'http://curl.haxx.se/download/curl-7.21.3.tar.gz',
  :md5 => '25e01bd051533f320c05ccbb0c52b246',
  :deps => [ 'openssl' ],
  :configure => {
    [ :Linux, :MacOSX ] => lambda { |c|
      if $platform == :MacOSX
        ENV['CFLAGS'] = "#{c[:os_compile_flags]} #{ENV['CFLAGS']}"
        ENV['LDFLAGS'] = "#{c[:os_link_flags]} #{ENV['LDFLAGS']}"
      end
      if c[:build_type] == :debug
        ENV['CFLAGS'] = "-g -O0 #{ENV['CFLAGS']}"
      end
      configScript = File.join(c[:src_dir], "configure")
      configstr = "#{configScript} --enable-static --enable-universalsdk --with-ssl=#{c[:output_dir]} --prefix=#{c[:output_dir]}"
      puts "running configure: #{configstr}"
      system(configstr)
    }
  },
  :build => {
    [ :Linux, :MacOSX ] => "make"
    #[ :Windows ] => lambda { |c|
    #  Dir.chdir(c[:src_dir]) do
    #    # this sequence is stolen from Tools\buildbot.bat
    #    configStr = "#{c[:build_type].to_s.capitalize}"
    #    system("Tools\\buildbot\\external.bat")
    #    # Python pulls down the source of its own deps from their svn repo
    #    # as part of the build process.  So it's too late for the normal
    #    # patching mechanism we would use.  Instead we do poor-man's version.
    #    FileUtils.copy(File.join(c[:recipe_dir], "bzip2-1.0.5", "makefile.msc"), File.join(c[:src_dir], "..\\bzip2-1.0.5"))
    #    ENV['OLD_PATH'] = "#{ENV['PATH']}"
    #    ENV['PATH'] = "#{ENV['PATH']};#{c[:wintools_dir].gsub('/', '\\')}\\nasmw"
    #    devenvOut = File.join(c[:log_dir], "devenv_#{c[:build_type]}.txt")
    #    system("vcbuild /M1 PCbuild\\pcbuild.sln \"#{configStr}|Win32\" > #{devenvOut}")
    #    ENV['PATH'] = "#{ENV['OLD_PATH']}"
    #  end
    #}
  },
  :install => {
    [ :MacOSX, :Linux ] => lambda { |c|
      system("make install")
      FileUtils.mv(File.join(c[:output_dir], "lib", "libcurl.4.dylib"), File.join(c[:output_lib_dir]))
      FileUtils.mv(File.join(c[:output_dir], "lib", "libcurl.a"), File.join(c[:output_lib_dir]))
      FileUtils.mv(File.join(c[:output_dir], "lib", "libcurl.dylib"), File.join(c[:output_lib_dir]))
      FileUtils.mv(File.join(c[:output_dir], "lib", "libcurl.la"), File.join(c[:output_lib_dir]))
      FileUtils.mv(File.join(c[:output_dir], "lib", "pkgconfig"), File.join(c[:output_lib_dir]))
    }
  #  :Windows => lambda { |c|
  #    FileUtils.cp("mongoose_s.lib", c[:output_lib_dir])
  #  }
  },
}
