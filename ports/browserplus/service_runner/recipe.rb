{
  :url => {
    :Windows => 'http://github.com/downloads/browserplus/platform/bpsdk_2.10.6-Win32-i386.zip',
    :MacOSX => 'http://github.com/downloads/browserplus/platform/bpsdk_2.10.6-Darwin-i386.tgz',
    :Linux => 'http://github.com/downloads/browserplus/platform/bpsdk_2.10.2-Linux-x86_64.tgz'
  },
  :md5 => {
    :Windows => '1c1bab8616496f80354e44aec8b2a2ad',
    :MacOSX => 'ce59efb736830339c840704b8c50585d',
    :Linux => 'f51e373781c2d4fe93f9cf4bb4b9bd68'
  },
  :install => lambda { |c|
    ext = (c[:platform] == :Windows ? ".exe" : "")
    FileUtils.cp(File.join(c[:src_dir], "bin", "ServiceRunner#{ext}"),
                 c[:output_bin_dir],
                 { :verbose => true, :preserve => true })
  }
}
