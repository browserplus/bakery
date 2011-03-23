# use nmake on windows, faster than vs.  however, vs can 
# be handy for debugging
useNMake = true

def setupEnv(c) 
  if c[:platform] != :Windows
    ENV['CFLAGS'] = ENV['CFLAGS'].to_s + c[:os_compile_flags]
    if c[:build_type] == :debug
      ENV['CFLAGS'] = ENV['CFLAGS'].to_s + " -g -O0"
    end
    ENV['LDFLAGS'] = ENV['LDFLAGS'].to_s + c[:os_link_flags]
  end
end

{
  :url => 'http://libarchive.googlecode.com/files/libarchive-2.8.0.tar.gz',
  :md5 => '400fd9ba51fffe6c65c75387fffba9d9',
  :deps => [ 'openssl', 'zlib', 'bzip2' ],

  :configure => lambda { |c|
    realSrcDir = c[:src_dir]
    installDir = File.join(c[:build_dir], "install")
    zlibIncDir = File.join(File.dirname(c[:output_inc_dir]), "zlib")
    bzip2IncDir = File.join(File.dirname(c[:output_inc_dir]), "bzip2")
    opensslIncDir = File.dirname(c[:output_inc_dir])
    if c[:platform] == :Windows
      realSrcDir = File.expand_path(realSrcDir).gsub(/\//, "\\")
      installDir = File.expand_path(installDir).gsub(/\//, "\\")
      zlibIncDir = File.expand_path(zlibIncDir).gsub(/\//, "\\")
      bzip2IncDir = File.expand_path(bzip2IncDir).gsub(/\//, "\\")
    end

    # setup compile/link flags
    setupEnv(c)

    # add env vars to allow cmake to find zlib/bzip2
    ENV['ZLIB_INC_DIR'] = zlibIncDir
    ENV['EXT_LIB_DIR'] = c[:output_lib_dir]
    ENV['BZIP2_INC_DIR'] = bzip2IncDir

    if c[:platform] == :Windows    
      openssl_libs = "libeay32_s.lib;ssleay32_s.lib"
    else 
      openssl_libs = "ssl_s;crypto_s"
    end
      
    cmakeGen = nil
    if useNMake
      cmakeGen = "-G \"NMake Makefiles\"" if c[:platform] == :Windows
    else
      cmakeGen = "-G \"#{c[:cmake_generator]}\"" if c[:cmake_generator]
    end
    buildType = "-DCMAKE_BUILD_TYPE:STRING=#{c[:build_type].to_s.capitalize}"
    cmakeVars = "-DCMAKE_INSTALL_PREFIX:PATH=#{installDir} "
    cmakeVars += "-DENABLE_ACL:BOOL=OFF -DENABLE_XATTR:BOOL=OFF "
    cmakeVars += "-DENABLE_XML:BOOL=OFF -DENABLE_LZMA:BOOL=OFF "
    cmakeVars += "-DOPENSSL_INCLUDE_DIR:String=#{opensslIncDir} "
    cmakeVars += "-DOPENSSL_LIBRARIES:String=\"#{openssl_libs}\" "
    cmakeVars += "-DENABLE_TAR_SHARED:BOOL=OFF "
    cmakeVars += "-DENABLE_CPIO_SHARED:BOOL=OFF "
    cmakeVars += "-DADDITIONAL_LINK_DIRS:String=#{c[:output_lib_dir]}"
    
    # XXX, test_write_compress_program fails on doze, causes devenv to fail
    if c[:platform] == :Windows
      cmakeVars += " -DENABLE_TEST:BOOL=OFF"
    end

    cmLine = "cmake #{cmakeGen} #{buildType} #{c[:cmake_args]} #{cmakeVars} " + " \"#{realSrcDir}\"" 
    puts "config cmd: #{cmLine}"
    system(cmLine)
  },

  :build => lambda { |c|
    # setup compile/link flags
    setupEnv(c)
    
    if c[:platform] == :Windows && !useNMake
      buildType = c[:build_type].to_s.capitalize
      devenvOut = File.join(c[:log_dir], "devenv_#{c[:build_type]}.txt")
      system("devenv libarchive.sln /build #{buildType} > #{devenvOut}")
      system("devenv libarchive.sln /build #{buildType} /project INSTALL >> #{devenvOut}")
    else
      makeCmd = c[:platform] == :Windows ? "nmake" : "make"
      system("#{makeCmd} -e")
      system("#{makeCmd} -e install")
    end
  },

  :install => lambda { |c|
    puts "Installing libs..."
    src = File.join(c[:build_dir], "install", "lib")
    if c[:platform] == :Windows
      src = File.join(src, "archive_static.lib")
      dst = File.join(c[:output_lib_dir], "archive_s.lib")
    else 
      src = File.join(src, "libarchive.a")
      dst = File.join(c[:output_lib_dir], "libarchive_s.a")
    end
    puts "copying from #{src} to #{dst}"
    FileUtils.cp(src, dst, :preserve => true, :verbose => true)

    puts "Installing headers..."
    [ "archive.h", "archive_entry.h" ].each do |h|
        FileUtils.cp(File.join(c[:build_dir], "install", "include", h),
                     c[:output_inc_dir], :preserve => true, :verbose => true)
      end
  }
}

