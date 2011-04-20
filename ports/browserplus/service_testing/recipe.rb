{
  :deps => [ "service_runner" ], 
  :url => 'github://browserplus/service-testing/c9f9bdcfc1e329eed3091662a1527dedb224149f',
  :install => lambda { |c|
    tgtDir = File.join(c[:output_dir], "share", "service_testing")
    FileUtils.mkdir_p(tgtDir)
    FileUtils.cp(File.join(c[:src_dir], "ruby", "bp_assert.rb"),
                 tgtDir,
                 { :verbose => true, :preserve => true })
    FileUtils.cp(File.join(c[:src_dir], "ruby", "bp_service_runner.rb"),
                 tgtDir,
                 { :verbose => true, :preserve => true })
    FileUtils.cp(File.join(c[:src_dir], "ruby", "ruby18_cppunit_runner.rb"),
                 tgtDir,
                 { :verbose => true, :preserve => true })
    FileUtils.cp(File.join(c[:src_dir], "ruby", "ruby19_cppunit_runner.rb"),
                 tgtDir,
                 { :verbose => true, :preserve => true })
    FileUtils.cp(File.join(c[:src_dir], "ruby", "ruby19_error.rb"),
                 tgtDir,
                 { :verbose => true, :preserve => true })
    FileUtils.cp(File.join(c[:src_dir], "ruby", "ruby19_failure.rb"),
                 tgtDir,
                 { :verbose => true, :preserve => true })
    FileUtils.cp(File.join(c[:src_dir], "ruby", "ruby19_success.rb"),
                 tgtDir,
                 { :verbose => true, :preserve => true })
    FileUtils.cp_r(File.join(c[:src_dir], "ruby", "json"),
                   tgtDir,
                   { :verbose => true, :preserve => true })
  }
}
