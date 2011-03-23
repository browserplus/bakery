{
  :url => 'http://github.com/downloads/lloyd/yajl/yajl-1.0.9.tar.gz',
  :md5 => '8643ff2fef762029e51c86882a4d0fc6',
  :configure => lambda { |c|
    btstr = c[:build_type].to_s.capitalize
    cmakeGen = nil
    # on windows we must specify a generator, we'll get that from the
    # passed in configuration
    cmakeGen = "-G \"#{c[:cmake_generator]}\"" if c[:cmake_generator]
    cmLine = "cmake -DCMAKE_BUILD_TYPE=\"#{btstr}\" " +
                   "-DCMAKE_INSTALL_PREFIX=\"#{c[:output_dir]}\" " +
                   " #{c[:cmake_args]} " +
                   " #{cmakeGen} \"#{c[:src_dir]}\"" 
    puts cmLine
    system(cmLine)
  },
  :build => {
    :Windows => lambda { |c|
      buildStr = c[:build_type].to_s.capitalize
      devenvOut = File.join(c[:log_dir], "devenv_#{c[:build_type]}.txt")
      system("devenv YetAnotherJSONParser.sln /Build #{buildStr} > #{devenvOut}")
    },
    [ :MacOSX, :Linux ] => "make" 
  },
  :install => {
    :Windows => lambda { |c|
      Dir.glob(File.join(c[:build_dir], "yajl-1.0.9", "*")).each { |d|
        FileUtils.cp_r(d , c[:output_dir], :preserve => true)
      }
    },
    [ :Linux, :MacOSX ] => "make install"
  },
  :post_install => {
    [ :Linux, :MacOSX ] => lambda { |c|
      system("make install")

      # now let's move output to the appropriate place
      # i.e. move from lib/libfoo.a to lib/debug/foo.a
      # Make two passes because Ruby 1.9 does not allow
      # symlinks to be moved
      Dir.glob(File.join(c[:output_dir], "lib", "libyajl*")).each { |f|
        if !File.directory?(f) && !File.symlink?(f)
          FileUtils.mv(f, c[:output_lib_dir])
        end
      }
      Dir.glob(File.join(c[:output_dir], "lib", "libyajl*")).each { |f|
        # FileUtils.mv does not handle symlinks in Ruby 1.9
        if !File.directory?(f) && File.symlink?(f)
          FileUtils.safe_unlink(File.join(c[:output_lib_dir], File.basename(f))) if File.exist?(File.join(c[:output_lib_dir], File.basename(f)))
          FileUtils.symlink(File.join(c[:output_lib_dir], File.readlink(f)), File.join(c[:output_lib_dir], File.basename(f)))
          FileUtils.safe_unlink(f)
        end
      }
    }
  },
  :post_install_common => lambda { |c|
    Dir.glob(File.join("src", "api", "*")).each { |f|
      FileUtils.cp(f, c[:output_inc_dir], :preserve => true)
    }
  }
}
