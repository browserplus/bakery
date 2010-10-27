{
  :url => {
    :Windows => 'http://github.com/downloads/browserplus/platform/bpsdk_2.10.7X-Win32-i386.zip',
    :MacOSX => 'http://github.com/downloads/browserplus/platform/bpsdk_2.10.7X-Darwin-i386.tgz',
    :Linux => 'http://github.com/downloads/browserplus/platform/bpsdk_2.10.2-Linux-x86_64.tgz'
  },
  :md5 => {
    :Windows => 'a4d7438b5f0df4e0c88305154feebfe3',
    :MacOSX => 'eef92f8ba4fe248ab4d9fa55147a0586',
    :Linux => 'f51e373781c2d4fe93f9cf4bb4b9bd68'
  },
  :install => lambda { |c|
    ext = (c[:platform] == :Windows ? ".exe" : "")
    FileUtils.cp(File.join(c[:src_dir], "bin", "ServiceRunner#{ext}"),
                 c[:output_bin_dir],
                 { :verbose => true, :preserve => true })
  }
}
