#!/usr/bin/env ruby

require "../ports/bakery"
require 'pp'

packages = []
ARGV.each { |a|
  packages.push(a)
}

if packages.length == 0
  puts "usage: ruby build_ports port1 ... portn"
  exit -1
end

$order = {
  :output_dir => File.join(File.dirname(__FILE__), "build"),
  :packages => packages,
  :verbose => true
}

b = Bakery.new $order
b.build
