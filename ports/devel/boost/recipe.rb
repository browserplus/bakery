{
  :url => "http://downloads.sourceforge.net/boost/boost_1_45_0.tar.bz2",
  :md5 => "d405c606354789d0426bc07bea617e58",
  :configure => lambda { |c|
    # for the configure step we'll run bootstrap, which builds bjam
    rpToBuildDir = Pathname.new(c[:build_dir]).relative_path_from(Pathname.pwd).to_s
    baseCmd = c[:platform] == :Windows ? ".\\bootstrap.bat" : "./bootstrap.sh"
    baseCmd += " --prefix=#{rpToBuildDir} "
    Dir.chdir(c[:src_dir]) { 
      puts "running bootstrap"
      system(baseCmd)
    }
  },
  :build => lambda { |c|
    # now build via bjam built by configure phase
    # run the build from the src_dir
    Dir.chdir(c[:src_dir]) { 
      toolset=""
      if c[:platform] == :MacOSX
        toolset="darwin"
        # add a user-config.jam for Darwin to allow 10.5 compatibility
        uconfig = File.new("user-config.jam", "w")
        uconfig.write("# Boost.Build Configuration\n")
        uconfig.write("# Allow Darwin to build with 10.5 compatibility\n")
        uconfig.write("\n")
        uconfig.write("# Compiler configuration\n")
        uconfig.write("using darwin : 4.0 : g++-4.0 -arch i386 : ")
        uconfig.write("<compileflags>\"#{c[:os_compile_flags]}\" ")
        uconfig.write("<architecture>\"x86\" ")
        uconfig.write("<linkflags>\"#{c[:os_link_flags]}\" ;\n")
        uconfig.close
      elsif c[:platform] == :Windows
        toolset="msvc"
        if c[:cmake_generator] == "Visual Studio 8 2005"
          toolset="msvc-8.0"
        elsif c[:cmake_generator] == "Visual Studio 9 2008"
          toolset="msvc-9.0"
        elsif c[:cmake_generator] == "Visual Studio 10"
          toolset="msvc-10.0"
        end
      elsif c[:platform] == :Linux
        toolset="gcc"
      else
        throw "Unsupported platform #{c[:platform].to_s}"
      end

      # now use bjam to build 
      baseCmd = c[:platform] == :Windows ? ".\\bjam" : "./bjam"
      baseCmd += " toolset=#{toolset} "
      baseCmd += " link=static threading=multi runtime-link=static"
      if c[:platform] == :Linux
        baseCmd += " cflags=-fPIC cxxflags=-fPIC"
      end
      rpToBuildDir = Pathname.new(c[:build_dir]).relative_path_from(Pathname.pwd).to_s
      baseCmd += " --abbreviate-paths --build-dir=#{rpToBuildDir} stage"
      if c[:platform] == :MacOSX
        baseCmd += " --user-config=user-config.jam"
      end

      buildType = c[:build_type].to_s
      buildLibs = %w(system filesystem)
      buildLibs.insert(-1, "regex") if c[:platform] != :Windows
      buildLibs.each() do |l|
        puts "building #{buildType} #{l}..."
        buildCmd = baseCmd + " variant=#{buildType} --with-#{l}"
        puts buildCmd
        system(buildCmd)
      end
    }
  },
  :install => lambda { |c|
    puts "copying headers..."
    Dir.glob(File.join(c[:src_dir], "boost", "*")).each { |h|
      FileUtils.cp_r(h, c[:output_inc_dir], :verbose => true)
    }

    # copy static libs
    buildType = c[:build_type].to_s.gsub(/[aeiou]/, "")
    puts "copying #{buildType} libraries..."

    libSuffix = ((c[:platform] == :Windows) ? "lib" : "a")
    
    Dir.glob("**/#{buildType}/**/libboost*.#{libSuffix}").each do |l|
      FileUtils.cp(l, c[:output_lib_dir], :verbose => true)
    end
  }
}
