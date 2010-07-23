require "mkmf"

begin
  require "rubygems"
rescue LoadError
  nil
end

narray_dir = File.dirname(Gem.find_files("narray.h").first) rescue $sitearchdir
dir_config('narray', narray_dir, narray_dir)

if ( ! ( have_header("narray.h") && have_header("narray_config.h") ) ) then
   print <<-EOS
   ** configure error **  
   Header narray.h or narray_config.h is not found. If you have these files in 
   /narraydir/include, try the following:

   % ruby extconf.rb --with-narray-include=/narraydir/include

EOS
   exit(-1)
end

if /cygwin|mingw/ =~ RUBY_PLATFORM
   have_library("narray") || raise("ERROR: narray library is not found")
end

create_makefile("na_str")



__END__

require "mkmf"
require "rbconfig"

sitearchdir = Config::CONFIG["sitearchdir"]

$CFLAGS += " -I #{ sitearchdir } "
$LDFLAGS += " #{ sitearchdir }/narray.so " # force a link so narray.so symbols will be resolved

create_makefile "na_str"
