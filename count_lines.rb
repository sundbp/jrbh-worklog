#!/usr/bin/ruby
total = 0
print "Ruby code in application:\n"
t = Dir['app/**/*.rb'].inject(0) {|sum, f| sum += IO.readlines(f).size}
print "#{t} lines\n"
total += t

print "Haml code in application:\n"
t = Dir['app/**/*.haml'].inject(0) {|sum, f| sum += IO.readlines(f).size}
print "#{t} lines\n"
total += t

print "Config in application:\n"
t = Dir['config/*.rb'].inject(0) {|sum, f| sum += IO.readlines(f).size}
t += Dir['config/**/*.rb'].inject(0) {|sum, f| sum += IO.readlines(f).size}
print "#{t} lines\n"
total += t

print "\nTotal number of lines: #{total}\n"
