{
  :url => 'http://curl.haxx.se/download/curl-7.21.3.tar.gz',
  :md5 => '25e01bd051533f320c05ccbb0c52b246',
  :post_patch => {
    :Windows => lambda { |c|
      Dir.chdir(File.join(c[:src_dir], "lib")) do
        devenvOut = File.join(c[:log_dir], "devenv_upgrade.txt")
        system("devenv libcurl.vcproj /upgrade > #{devenvOut}")
      end
    }
  },
  :configure => {
    [ :Linux, :MacOSX ] => lambda { |c|
      ENV['CFLAGS'] = "#{c[:os_compile_flags]} #{ENV['CFLAGS']}"
      ENV['CFLAGS'] += ' -g -O0 ' if c[:build_type] == :debug
      ENV['LDFLAGS'] = "#{c[:os_link_flags]} #{ENV['LDFLAGS']}"
      puts "CFLAGS = #{ENV['CFLAGS']}"
      puts "LDFLAGS = #{ENV['LDFLAGS']}"

      Dir.chdir(c[:src_dir]) {
          system("./configure --build=i386-apple-darwin10.4.0 --host=i386-apple-darwin10.4.0 --prefix=#{c[:output_dir]} --without-ssl --without-ca-bundle --without-zlib --disable-ldap --disable-ldaps")
      }
    }
  },
  :build => {
    [ :Linux, :MacOSX ] => lambda { |c|
      Dir.chdir(c[:src_dir]) {
          system("make")
      }
    },
    :Windows => lambda { |c|
      Dir.chdir(c[:src_dir]) do
        configStr = "#{c[:build_type].to_s.capitalize}"
        devenvOut = File.join(c[:log_dir], "devenv_#{c[:build_type]}.txt")
        if c[:toolchain] == "vs10"
          system("devenv lib\\libcurl.vcxproj /build \"#{configStr}\" > #{devenvOut}")
        else 
          system("devenv lib\\libcurl.vcproj /build \"#{configStr}\" > #{devenvOut}")
        end
      end
    }
  },
  :install => {
    [ :MacOSX, :Linux ] => lambda { |c|
      Dir.chdir(c[:src_dir]) {
        system("make install")
        FileUtils.cp(File.join(c[:output_dir], "lib", "libcurl.a"),
                     File.join(c[:output_lib_dir], "libcurl_s.a"), 
                     :preserve => true)
        FileUtils.cp(File.join(c[:output_dir], "lib", "libcurl.la"),
                     File.join(c[:output_lib_dir], "libcurl_s.la"),
                     :preserve => true)
        FileUtils.cp(File.join(c[:output_dir], "lib", "libcurl.4.dylib"),
                     File.join(c[:output_lib_dir], "libcurl.4.dylib"),
                     :preserve => true)
        FileUtils.cp(File.join(c[:output_dir], "lib", "libcurl.dylib"),
                     File.join(c[:output_lib_dir], "libcurl.dylib"),
                     :preserve => true)
        FileUtils.cp_r(File.join(c[:output_dir], "lib", "pkgconfig"),
                       File.join(c[:output_lib_dir]),
                       :preserve => true)
        FileUtils.rm(File.join(c[:output_dir], "lib", "libcurl.a"))
        FileUtils.rm(File.join(c[:output_dir], "lib", "libcurl.la"))
        FileUtils.rm(File.join(c[:output_dir], "lib", "libcurl.4.dylib"))
        FileUtils.rm(File.join(c[:output_dir], "lib", "libcurl.dylib"))
        FileUtils.rm_rf(File.join(c[:output_dir], "lib", "pkgconfig"))
      }
    },
    :Windows => lambda { |c|
      # install static lib
      buildType = c[:build_type].to_s
      libFile = File.join(c[:src_dir], "lib", buildType, "libcurl.lib")
      puts "installing #{c[:build_type].to_s} static library..."
      FileUtils.cp(libFile, File.join(c[:output_lib_dir], "libcurl_s.lib"),
                   :preserve => true, :verbose => true)
      # install headers
      puts "installing headers..."
      Dir.glob(File.join(File.join(c[:src_dir], "include", "curl", "*.h"))).each { |h|
        FileUtils.cp_r(h, c[:output_inc_dir],
                       :preserve => true, :verbose => true)
      }
    }
  },
}
