{
  :url => "http://portaudio.com/archives/pa_stable_v19_20071207.tar.gz",
  :md5 => "d2943e4469834b25afe62cc51adc025f",
  :configure => {
    [ :Linux, :MacOSX ] => lambda { |c|
      ENV['CFLAGS'] = "#{c[:os_compile_flags]} #{ENV['CFLAGS']}"
      ENV['CFLAGS'] += ' -g -O0 ' if c[:build_type] == :debug
      ENV['LDFLAGS'] = "#{c[:os_link_flags]} #{ENV['LDFLAGS']}"
      cfgScript = File.join(c[:src_dir], "configure")
      cfgOpts = "--prefix=\"#{c[:output_dir]}\" --enable-static"
      system("#{cfgScript} #{cfgOpts}")
    },
    :Windows => "echo no configuration required on windows"
  },
  :build => {
    [ :Linux, :MacOSX ] => "make",
    :Windows => "echo no build required on windows"
  },
  :install => {
    [ :Linux, :MacOSX ] => "make install",
    :Windows => "echo no install required on windows"
  }
}
