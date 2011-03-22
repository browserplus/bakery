{
  :url => "http://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.2-p180.tar.bz2", 
  :md5 => "68510eeb7511c403b91fe5476f250538",
  :deps => [ 'zlib', 'openssl' ],
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
      configstr = "#{configScript} --enable-shared --prefix=#{c[:output_dir]} "
      configstr = configstr + "--disable-install-doc "
      configstr = configstr + "--without-openssl --disable-openssl --without-zlib --disable-zlib"
      puts "running configure: #{configstr}"
      system(configstr)
    }, 
    [ :Windows ] => lambda { |c|
      ENV['RUNTIMEFLAG'] = '-MT'
      # XXX: add openssl and zlib
      ENV['EXTS'] = "bigdecimal,continuation,coverage,digest,digest/md5,digest/rmd160,digest/sha1,digest/sha2,dl,fcntl,fiber,json,mathn,nkf,racc/cparse,ripper,sdbm,socket,stringio,strscan,syck,win32ole" 
      # grrr.  make a copy
      Dir.glob(File.join(c[:src_dir], "*")).each { |f|
        FileUtils.cp_r(f, ".", :preserve => true)
      }
      configScript = File.join(c[:src_dir], "win32\\configure.bat")
      configstr = "#{configScript} --prefix=#{c[:output_dir].gsub('/', '\\')} "
      configstr = configstr + "--disable-install-doc"
      puts "running configure: #{configstr}"
      system(configstr)
    }
  },
  :build => {
    [ :Linux, :MacOSX ] => "make",
    [ :Windows ] => lambda { |c|
      ENV['OLD_PATH'] = "#{ENV['PATH']}"
      ENV['PATH'] = "#{ENV['PATH'].gsub('C:\\Program Files\\Git\\bin', '')}"
      ENV['PATH'] = "#{ENV['PATH']};#{c[:wintools_dir].gsub('/', '\\')}\\bin"
      system("nmake")
      ENV['PATH'] = "#{ENV['OLD_PATH']}"
    }
  },
  :install => {
    [ :Linux, :MacOSX ] => lambda { |c|
      system("make install")
      # now move output in lib dir into build config dir
      # Make two passes because Ruby 1.9 does not allow
      # symlinks to be moved
      Dir.glob(File.join(c[:output_dir], "lib", "*ruby*")).each { |l|
        if !File.symlink?(l)
          FileUtils.mv(l, File.join(c[:output_lib_dir], File.basename(l)),
                       :verbose => true)
        end
      }
      Dir.glob(File.join(c[:output_dir], "lib", "*ruby*")).each { |l|
        if File.symlink?(l)
          FileUtils.safe_unlink(File.join(c[:output_lib_dir], File.basename(l))) if File.exist?(File.join(c[:output_lib_dir], File.basename(l)))
          FileUtils.symlink(File.join(c[:output_lib_dir], File.readlink(l)), File.join(c[:output_lib_dir], File.basename(l)))
          FileUtils.safe_unlink(l)
        end
      }
    },
    [ :Windows ] => lambda { |c|
      ENV['OLD_PATH'] = "#{ENV['PATH']}"
      ENV['PATH'] = "#{ENV['PATH']};#{c[:wintools_dir].gsub('/', '\\')}\\bin"
      system("nmake install")
      ENV['PATH'] = "#{ENV['OLD_PATH']}"
      # now move output in lib dir into build config dir
      Dir.glob(File.join(c[:output_dir], "lib", "*ruby*")).each { |l|
        FileUtils.mv(l, File.join(c[:output_lib_dir], File.basename(l)), :verbose => true)
      }
    }
  },
  :post_install_common => {
    [ :Linux, :MacOSX ] => lambda { |c|
      rb19dir = File.join(c[:output_dir], "include", "ruby-1.9.1")
      # Make two passes because Ruby 1.9 does not allow
      # symlinks to be moved
      Dir.glob(File.join(rb19dir, "*")).each { |h|
        if !File.symlink?(h)
          FileUtils.mv(h, c[:output_inc_dir], :verbose => true)
        end
      }
      Dir.glob(File.join(rb19dir, "*")).each { |h|
        if File.symlink?(h)
          FileUtils.safe_unlink(File.join(c[:output_inc_dir], File.basename(h))) if File.exist?(File.join(c[:output_inc_dir], File.basename(h)))
          FileUtils.symlink(File.join(c[:output_inc_dir], File.readlink(h)), File.join(c[:output_inc_dir], File.basename(h)))
          FileUtils.safe_unlink(h)
        end
      }
      FileUtils.rmdir(rb19dir)
    },
    [ :Windows ] => lambda { |c|
      rb19dir = File.join(c[:output_dir], "include", "ruby-1.9.1")
      Dir.glob(File.join(rb19dir, "*")).each { |h|
        FileUtils.mv(h, c[:output_inc_dir], :verbose => true)
      }
      FileUtils.rmdir(rb19dir)
    }
  }
}
