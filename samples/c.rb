%w( ./lib ../lib . ..).each{|d| $:.unshift d}
#
# be sure to run this a few times in a row - wait a second or two between runs
# - notice that the data will automagically persist between calls!
#
require 'tmpdir'
require 'nmap'

ipath = File.join Dir.tmpdir, 'i.na'

nmap = NMap.int ipath, 3,4 
na = nmap.na
p na

na[0,true] = Time.now.to_i
na[2,true] = 1 
na[1,1..2] = 42
p na
