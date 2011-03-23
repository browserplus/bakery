#!/usr/bin/env ruby

require "../ports/bakery"
require 'pp'

packages = []
ARGV.each { |a|
  packages.push(a)
}

if packages.length == 0
  puts "Building ALL ports!"
  # find all recipes
  Dir.glob(File.join("..", "ports", "**", "recipe.rb")).each {  |r|
    d = File.dirname(r)
    b = File.basename(d)
    packages.push(b)
  }
  # now remove known broken/incomplete ones
  #   portaudio uses 10.4 sdk
  #   nodejs depends on some ENV vars, haven't dug into it
  [ "portaudio", "nodejs" ].each { |b| 
    packages.delete(b)
  }
end

# build 'em
packages.each {|r|
  puts ""
  puts "Building #{r}..."
  buildDir = File.join(File.dirname(__FILE__), "build", r)
  FileUtils.rm_rf(buildDir)
  $order = {
    :output_dir => buildDir,
    :packages => [ r ],
    :verbose => true
  }

  b = Bakery.new $order
  b.build
}
