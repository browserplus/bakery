{
  :url => {
    :Windows => 'http://github.com/downloads/browserplus/platform/bpsdk_2.10.8-Win32-i386.zip',
    :MacOSX => 'http://github.com/downloads/browserplus/platform/bpsdk_2.10.8-Darwin-i386.tgz',
    :Linux => 'http://github.com/downloads/browserplus/platform/bpsdk_2.10.2-Linux-x86_64.tgz'
  },
  :md5 => {
    :Windows => 'c5fc02d9a11f112c3b18d205a10b5b08',
    :MacOSX => 'b65ca4794d522f9622a4cab02ba2de8f',
    :Linux => 'f51e373781c2d4fe93f9cf4bb4b9bd68'
  },
  :install => lambda { |c|
    ext = (c[:platform] == :Windows ? ".exe" : "")
    int = (c[:platform] == :Windows ? "bpsdk" : "")
    FileUtils.cp(File.join(c[:src_dir], "#{int}", "bin", "ServiceRunner#{ext}"),
                 c[:output_bin_dir],
                 { :verbose => true, :preserve => true })
    FileUtils.cp(File.join(c[:src_dir], "#{int}", "bin", "BrowserPlus.crt"),
                 c[:output_bin_dir],
                 { :verbose => true, :preserve => true })
  }
}
