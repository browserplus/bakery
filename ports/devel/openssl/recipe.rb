# Windows needs to use ActiveState perl.  If the
# perl we find isn't ActiveState, we assume that 
# ActiveState is installed in c:\Perl (the default).
# MSys perl will hang the build.  Sigh.
def setupEnv(c)
  if c[:platform] == :Windows
    if `perl --version`.include?("ActiveState") == false
      if `C:\\Perl\\bin\\perl --version`.include?("ActiveState") == false
        raise "Unable to find ActiveState perl in c:\\Perl"
      end
      ENV['PATH'] = "C:\\Perl\\bin;" + ENV['PATH'].to_s
    end
  end
end

{
  :url => "http://openssl.org/source/openssl-1.0.0d.tar.gz",
  :md5 => "40b6ea380cc8a5bf9734c2f8bf7e701e",
  :configure => lambda { |c|
    Dir.chdir(c[:src_dir]) {
      setupEnv(c)
      if c[:platform] == :Windows
        if c[:build_type] == :debug
          configureCmd = "perl Configure debug-VC-WIN32"
        else
          configureCmd = "perl Configure VC-WIN32"
        end
      else
        configureCmd = "sh ./config"
      end

      if c[:platform] != :Windows
        includeDir = File.join(c[:src_dir], "include")
        libDir = c[:src_dir]
        extraCFlags = "-I#{includeDir} -L#{libDir} #{c[:os_compile_flags]}"
        extraCFlags += " -g -O0" if c[:build_type] == :debug
        ENV['BP_EXTRA_CFLAGS'] = extraCFlags
        ENV['LDFLAGS'] = ENV['LDFLAGS'].to_s + c[:os_link_flags]
      end

      # XXX: would this hurt on all unicies?
      fPICFlag = (c[:platform] == :Linux) ? "-fPIC" : ""

      # - Disable assembler routines (requires a different assembler on doze)
      # - Disable crypto hardware support
      # - Disable the gost engine, which is apparently fairly new to openssl, 
      #   since it causes link errors.  We don't need it, so flush it.
      system("#{configureCmd} no-hw no-asm no-shared no-gost --prefix=#{c[:build_dir]} #{fPICFlag}")
    }
  },

  :build => lambda { |c|
    setupEnv(c)
    Dir.chdir(c[:src_dir]) {
      makeCmd = c[:platform] == :Windows ? "nmake -f ms\\nt.mak" : "make"

      system("ms\\do_ms.bat") if c[:platform] == :Windows
      system("#{makeCmd}")
      system("#{makeCmd} test")
      system("#{makeCmd} install")
    }
  },

  :install => lambda { |c|
    Dir.chdir(c[:build_dir]) {
      # install static libs
      puts "Installing libs..."
      if c[:platform] == :Windows
        ["ssleay32", "libeay32"].each() do |l|
          src = File.join("lib", "#{l}.lib")
          dst = File.join(c[:output_lib_dir], "#{l}_s.lib")
          puts "copying from #{src} to #{dst}"
          FileUtils.cp(src, dst, :preserve => true, :verbose => true)
        end
      else
        ["libssl", "libcrypto"].each() do |l|
          src = File.join("lib", "#{l}.a")
          src = File.join("lib64", "#{l}.a") if !File.exist? src
          dst = File.join(c[:output_lib_dir], "#{l}_s.a")
          puts "copying from #{src} to #{dst}"
          FileUtils.cp(src, dst, :preserve => true, :verbose => true)
        end
      end

      puts "Installing openssl binary..."
      exeSuffix = c[:platform] == :Windows ? ".exe" : ""
      FileUtils.cp(File.join("bin", "openssl#{exeSuffix}"),
                   File.join(c[:output_bin_dir], "openssl#{exeSuffix}"),
                   :preserve => true, :verbose => true)
    }
  },

  :post_install_common => lambda { |c|
    Dir.chdir(c[:build_dir]) {
      puts "Installing headers..."
      Dir.glob(File.join("include", "openssl", "*.h")).each { |h|
        FileUtils.cp(h, c[:output_inc_dir], :preserve => true, :verbose => true)
      }
      
      puts "Installing openssl.cnf..."
      src = File.join("ssl", "openssl.cnf")
      dest = File.join(c[:output_dir], "ssl")
      FileUtils.mkdir_p(dest)
      FileUtils.cp_r(src, dest, :preserve => true, :verbose => true)
    }
  }
}

