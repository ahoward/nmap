%w( ./lib ../lib . ..).each{|d| $:.unshift d}
require 'na_str'

#
# na_str allows you to share memory with any object that responds to to_s or
# to_str.  the object whose memory is shared is frozen and cannot be modified
# and a reference to the object is kept so it is not gc'd.  the object's
# memory can be modified using this 'view' of the data.
#

buf = [0,0,0,0].pack 'i*'

na = NArray::str buf, NArray::INT, 4
na[0] = 42
na[-1] = 42

p buf.unpack('i*')
p buf
