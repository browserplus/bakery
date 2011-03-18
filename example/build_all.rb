#!/usr/bin/env ruby
#
# This script tries to build all ports within the bakery.

require "../ports/bakery"
require 'pp'

# find all recipes
allRecipes = []
Dir.glob(File.join("..", "ports", "**", "recipe.rb")).each {  |r|
  d = File.dirname(r)
  b = File.basename(d)
  allRecipes.push(b)
}

# now remove know broken/incomplete ones
[ "curl_ssl", "python26", "python31", "ruby19" ].each { |b| 
  allRecipes.delete(b)
}

# now remove ones which don't work on a platform 
if CONFIG['arch'] =~ /mswin|mingw/
  allRecipes.delete("nodejs")
end

# build 'em
$order = {
  :output_dir => File.join(File.dirname(__FILE__), "all_build"),
  :packages => allRecipes,
  :verbose => true
}

b = Bakery.new $order
b.build