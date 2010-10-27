{
  :url => {
    :Windows => 'http://github.com/downloads/browserplus/platform/bpsdk_2.10.7-Win32-i386.zip',
    :MacOSX => 'http://github.com/downloads/browserplus/platform/bpsdk_2.10.7-Darwin-i386.tgz',
    :Linux => 'http://github.com/downloads/browserplus/platform/bpsdk_2.10.2-Linux-x86_64.tgz'
  },
  :md5 => {
    :Windows => '8ead2bcd0bc32acd418399803a42c1ad',
    :MacOSX => '16166ae5731d187af65a95f688dee298',
    :Linux => 'f51e373781c2d4fe93f9cf4bb4b9bd68'
  },
  :install => lambda { |c|
    ext = (c[:platform] == :Windows ? ".exe" : "")
    FileUtils.cp(File.join(c[:src_dir], "bin", "ServiceRunner#{ext}"),
                 c[:output_bin_dir],
                 { :verbose => true, :preserve => true })
  }
}
