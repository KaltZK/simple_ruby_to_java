require './helpers'
ns = TSNamespace.new
ns.run(File.read 'foo.rb')
puts ns.render