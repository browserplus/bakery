{
  :url => "http://www.python.org/ftp/python/2.6.7/Python-2.6.7rc1.tar.bz2",
  :md5 => "a170d3a3a96e6c3000a541c737ff0075",
  :post_patch => {
    :Windows => lambda { |c|
      Dir.chdir(c[:src_dir]) do
        devenvOut = File.join(c[:log_dir], "devenv_upgrade.txt")
        system("devenv PCbuild\\pcbuild.sln /upgrade > #{devenvOut}")
      end
    }
  },
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
      configstr = "#{configScript} --enable-shared --enable-universalsdk --prefix=#{c[:output_dir]} "
      puts "running configure: #{configstr}"
      system(configstr)
    }
  },
  :build => {
    [ :Linux, :MacOSX ] => "make",
    :Windows => lambda { |c|
      Dir.chdir(c[:src_dir]) do
        # this sequence is stolen from Tools\buildbot.bat
        configStr = "#{c[:build_type].to_s.capitalize}"
        system("Tools\\buildbot\\external.bat")
        # Python pulls down the source of its own deps from their svn repo
        # as part of the build process.  So it's too late for the normal
        # patching mechanism we would use.  Instead we do poor-man's version.
        FileUtils.copy(File.join(c[:recipe_dir], "bzip2-1.0.5", "makefile.msc"),
                       File.join(c[:src_dir], "..\\bzip2-1.0.5"),
                       :preserve => true)
        ENV['OLD_PATH'] = "#{ENV['PATH']}"
        ENV['PATH'] = "#{ENV['PATH']};#{c[:wintools_dir].gsub('/', '\\')}\\nasmw"
        devenvOut = File.join(c[:log_dir], "devenv_#{c[:build_type]}.txt")
        system("devenv PCbuild\\pcbuild.sln /build #{configStr} > #{devenvOut}")
        ENV['PATH'] = "#{ENV['OLD_PATH']}"
      end
    }
  },
  :install => {
    [ :Linux, :MacOSX ] => lambda { |c|
      system("make install")
    },
    [ :Windows ] => lambda { |c|
      # install binaries
      binfiles = %w[kill_python.exe python.exe pythonw.exe]
      binfiles.each { |i|
        py26SrcFile = File.join(c[:src_dir], "PCBuild", i.to_s)
        py26DstFile = File.join(c[:output_bin_dir], i.to_s)
        if c[:build_type] == :debug
          py26SrcFile = py26SrcFile.sub(".exe", "_d.exe")
          py26DstFile = py26DstFile.sub(".exe", "_d.exe")
        end
        FileUtils.cp(py26SrcFile, py26DstFile,
                     :preserve => true, :verbose => true)
      }
      # install python interpreter and support libs
      binfiles = %w[python26 sqlite3]
      binfiles.each { |i|
        exts = %w[dll lib]
        exts.each { |j|
          py26SrcFile = File.join(c[:src_dir], "PCBuild", i.to_s + "." + j.to_s)
          py26DstFile = File.join(c[:output_lib_dir], i.to_s + "." + j.to_s)
          if c[:build_type] == :debug
            py26SrcFile = py26SrcFile.sub("." + j.to_s, "_d." + j.to_s)
            py26DstFile = py26DstFile.sub("." + j.to_s, "_d." + j.to_s)
          end
          FileUtils.cp(py26SrcFile, py26DstFile,
                       :preserve => true, :verbose => true)
        }
      }
      # install python C libs
      binfiles = %w[_bsddb _ctypes _ctypes_test _elementtree _hashlib _msi _multiprocessing _socket _sqlite3 _ssl _testcapi _tkinter bz2 pyexpat select unicodedata winsound]
      binfiles.each { |i|
        exts = %w[pyd lib]
        exts.each { |j|
          py26SrcFile = File.join(c[:src_dir], "PCBuild", i.to_s + "." + j.to_s)
          py26DstFile = File.join(c[:output_lib_dir], i.to_s + "." + j.to_s)
          if c[:build_type] == :debug
            py26SrcFile = py26SrcFile.sub("." + j.to_s, "_d." + j.to_s)
            py26DstFile = py26DstFile.sub("." + j.to_s, "_d." + j.to_s)
          end
          FileUtils.cp(py26SrcFile, py26DstFile,
                       :preserve => true, :verbose => true)
        }
      }
      # install python stdlib libs
      FileUtils.mkdir_p(File.join(c[:output_lib_dir], "lib"))
      Dir.glob(File.join(c[:src_dir], "Lib", "*.*")).each { |l|
        tgtBasename = File.basename(l)
        tgt = File.join(c[:output_lib_dir], "lib", tgtBasename)
        FileUtils.cp(l, tgt, :preserve => true, :verbose => true)
      }
      FileUtils.mkdir_p(File.join(c[:output_lib_dir], "lib", "lib-tk"))
      Dir.glob(File.join(c[:src_dir], "Lib", "lib-tk", "*.*")).each { |l|
        tgtBasename = File.basename(l)
        tgt = File.join(c[:output_lib_dir], "lib", "lib-tk", tgtBasename)
        FileUtils.cp(l, tgt, :preserve => true, :verbose => true)
      }
      FileUtils.mkdir_p(File.join(c[:output_lib_dir], "lib", "site-packages"))
      Dir.glob(File.join(c[:src_dir], "Lib", "site-packages", "*.*")).each { |l|
        tgtBasename = File.basename(l)
        tgt = File.join(c[:output_lib_dir], "lib", "site-packages", tgtBasename)
        FileUtils.cp(l, tgt, :preserve => true, :verbose => true)
      }
    }
  },
  :post_install_common => {
    [ :Linux, :MacOSX ] => lambda { |c|
      py26dir = File.join(c[:output_dir], "include", "python2.6")
      Dir.glob(File.join(py26dir, "*")).each { |h|
        FileUtils.mv(h, c[:output_inc_dir], :verbose => true)
      }
      FileUtils.rmdir(py26dir)
    },
    [ :Windows ] => lambda { |c|
      py26dir = File.join(c[:src_dir], "Include")
      Dir.glob(File.join(py26dir, "*")).each { |h|
        FileUtils.cp(h, c[:output_inc_dir],
                     :preserve => true, verbose => true)
      }
      py26File = File.join(c[:src_dir], "PC", "pyconfig.h")
      FileUtils.cp(py26File, c[:output_inc_dir],
                   :preserve => true, :verbose => true)
    }
  }
}
