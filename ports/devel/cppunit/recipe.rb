{
  :url => "http://prdownloads.sourceforge.net/cppunit/cppunit-1.12.1.tar.gz",
  :md5 => "bd30e9cf5523cdfc019b94f5e1d7fd19",
  :post_patch => {
    :Windows => lambda { |c|
      Dir.chdir(File.join(c[:src_dir], "src")) do
        devenvOut = File.join(c[:log_dir], "devenv_upgrade.txt")
        system("devenv CppUnitLibraries.sln /upgrade >#{devenvOut}")
      end
    }
  },
  :configure => {
    [ :Linux, :MacOSX ] => lambda { |c|
      puts "Configuring #{c[:build_type].to_s} bits..."
      ldflags = ""
      cxxflags = c[:build_type] == :debug ? "-g -O0" : ""
      if c[:platform] == :MacOSX
        cxxflags += c[:os_compile_flags]
      end
      cfgScript = File.join(c[:src_dir], "configure")
      configCmd = "#{cfgScript} --enable-static --disable-shared"
      configCmd += " --prefix=#{c[:output_dir]} --disable-doxygen"
      configCmd += " CXXFLAGS=\"#{cxxflags}\""
      if c[:platform] == :MacOSX
        configCmd += " LDFLAGS=\"#{c[:os_link_flags]}\""
      end
      # the '|| echo' prevents termination since configCmd fails.  nice
      system("#{configCmd} || echo")
    }
  },

  :build => {
    [ :Linux, :MacOSX ] => lambda { |c|
      system("make")
    },
    :Windows => lambda { |c|
      buildType = c[:build_type].to_s
      Dir.chdir(File.join(c[:src_dir], "src")) do
        devenvOut = File.join(c[:log_dir], "devenv_#{c[:build_type]}.txt")
        system("devenv CppUnitLibraries.sln /project cppunit /build \"#{buildType} static\" >#{devenvOut}")
      end
    }
  },

  :install => {
    [ :Linux, :MacOSX ] => lambda { |c|
      system("make install")
      Dir.glob(File.join(c[:output_dir], "lib", "*cppunit*")).each { |f|
        FileUtils.mv(f, c[:output_lib_dir], :verbose => true)
      }
    },

    :Windows => lambda { |c|
      # install static lib
      buildType = c[:build_type].to_s
      libTrailer = (c[:build_type] == :debug) ? "d" : ""
      libFile = File.join(c[:src_dir], "src", "cppunit", buildType, "cppunit#{libTrailer}.lib")
      puts "installing #{c[:build_type].to_s} static library..."
      FileUtils.cp(libFile, File.join(c[:output_lib_dir], "cppunit.lib"),
                   :preserve => true, :verbose => true)
    }
  },

  :post_install_common => {
    :Windows => lambda { |c|
      # install headers 
      puts "installing headers..."
      Dir.glob(File.join(File.join(c[:src_dir], "include", "cppunit", "*"))).each { |h| 
        FileUtils.cp_r(h, c[:output_inc_dir],
                       :preserve => true, :verbose => true)
      }
    }
  }
}

