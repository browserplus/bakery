{
  :deps => [ "service_runner" ], 
  :url => 'github://browserplus/service-testing/348d7a31dc926bb90c789a480a6097eefebb7cc4',
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
    FileUtils.cp_r(File.join(c[:src_dir], "ruby", "json"),
                   tgtDir,
                   { :verbose => true, :preserve => true })
  }
}
