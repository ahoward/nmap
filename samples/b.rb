%w( ./lib ../lib . ..).each{|d| $:.unshift d}
require "na_str"
require "mmap"
require "yaml"

#
# setup
#
  sizeof_int = [42].pack("i").size

#
# setup an empty data file big enough to hold four ints if one doesn"t already
# exist
#
  data = __FILE__ + ".data"
  open(data, File::CREAT|File::EXCL|File::RDWR){|f| f.write(0.chr * 4 * sizeof_int)} rescue nil

#
# show the orginal data - run the script more than once to see that the data
# persists between invocations
#
  y "before" => IO::read(data).unpack("i*")

#
# mmap data in
#
  m = Mmap::new data, "rw", Mmap::MAP_SHARED

#
# overlay an narray over the memory map and manipulate it.  note that any
# changes to the narray changes the memory map, which in turn changes the
# file!
#
  na = NArray::str m, NArray::INT, 4
  na[0] = 42 
  na[-1] = Time.now.to_i.abs

#
# sync, and unmap the data
#
  m.msync
  m.munmap

#
# show that the underlying data has been transparently changed!
#
  y "after" => IO::read(data).unpack("i*")
