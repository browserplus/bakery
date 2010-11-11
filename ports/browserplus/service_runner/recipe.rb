{
  :url => {
    :Windows => 'http://github.com/downloads/browserplus/platform/bpsdk_2.10.9-Win32-i386.zip',
    :MacOSX => 'http://github.com/downloads/browserplus/platform/bpsdk_2.10.9-Darwin-i386.tgz',
    :Linux => 'http://github.com/downloads/browserplus/platform/bpsdk_2.10.2-Linux-x86_64.tgz'
  },
  :md5 => {
    :Windows => 'a9bf008a33a7a50db3670a958e8ec674',
    :MacOSX => '4e616bf238b12eb6b0fb2d548581b194',
    :Linux => 'f51e373781c2d4fe93f9cf4bb4b9bd68'
  },
  :install => lambda { |c|
    ext = (c[:platform] == :Windows ? ".exe" : "")
    FileUtils.cp(File.join(c[:src_dir], "bin", "ServiceRunner#{ext}"),
                 c[:output_bin_dir],
                 { :verbose => true, :preserve => true })
    FileUtils.cp(File.join(c[:src_dir], "bin", "BrowserPlus.crt"),
                 c[:output_bin_dir],
                 { :verbose => true, :preserve => true })
  }
}
