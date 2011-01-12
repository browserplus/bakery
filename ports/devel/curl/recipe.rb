{
  :url => 'http://curl.haxx.se/download/curl-7.21.3.tar.gz',
  :md5 => '25e01bd051533f320c05ccbb0c52b246',
  :deps => [ 'openssl' ],
  :deps => [ ],
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
      configstr = "#{configScript} --build=i386-apple-darwin10.4.0 --prefix=#{c[:output_dir]} --with-ssl=#{c[:output_dir]} --without-ca-bundle --without-zlib --disable-ldap --disable-ldaps"
      puts "running configure: #{configstr}"
      system(configstr)
    }
  },
  :build => {
    [ :Linux, :MacOSX ] => "make",
    [ :Windows ] => lambda { |c|
      Dir.chdir(c[:src_dir]) do
        configStr = "#{c[:build_type].to_s.capitalize}"
        devenvOut1 = File.join(c[:log_dir], "devenv_upgrade_#{c[:build_type]}.txt")
        devenvOut2 = File.join(c[:log_dir], "devenv_#{c[:build_type]}.txt")
        system("vcbuild /upgrade /M1 lib\\libcurl.vcproj \"#{configStr}|Win32\" > #{devenvOut1}")
        system("vcbuild /M1 lib\\libcurl.vcproj \"#{configStr}|Win32\" > #{devenvOut2}")
      end
    }
  },
  :install => {
    [ :MacOSX, :Linux ] => lambda { |c|
      system("make install")
      FileUtils.cp(File.join(c[:output_dir], "lib", "libcurl.a"), File.join(c[:output_lib_dir], "libcurl_s.a"))
      FileUtils.cp(File.join(c[:output_dir], "lib", "libcurl.la"), File.join(c[:output_lib_dir], "libcurl_s.la"))
      FileUtils.cp(File.join(c[:output_dir], "lib", "libcurl.4.dylib"), File.join(c[:output_lib_dir], "libcurl.4.dylib"))
      FileUtils.cp(File.join(c[:output_dir], "lib", "libcurl.dylib"), File.join(c[:output_lib_dir], "libcurl.dylib"))
      FileUtils.cp_r(File.join(c[:output_dir], "lib", "pkgconfig"), File.join(c[:output_lib_dir]))
      FileUtils.rm(File.join(c[:output_dir], "lib", "libcurl.a"))
      FileUtils.rm(File.join(c[:output_dir], "lib", "libcurl.la"))
      FileUtils.rm(File.join(c[:output_dir], "lib", "libcurl.4.dylib"))
      FileUtils.rm(File.join(c[:output_dir], "lib", "libcurl.dylib"))
      FileUtils.rm_rf(File.join(c[:output_dir], "lib", "pkgconfig"))
    },
    :Windows => lambda { |c|
      # install static lib
      buildType = c[:build_type].to_s
      libFile = File.join(c[:src_dir], "lib", buildType, "libcurl.lib")
      puts "installing #{c[:build_type].to_s} static library..."
      FileUtils.cp(libFile, File.join(c[:output_lib_dir], "libcurl_s.a"), :verbose => true)
      # install headers
      puts "installing headers..."
      Dir.glob(File.join(File.join(c[:src_dir], "include", "curl", "*.h"))).each { |h|
        FileUtils.cp_r(h, c[:output_inc_dir], :verbose => true)
      }
    }
  },
}
