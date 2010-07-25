begin
  require 'rubygems'
rescue LoadError
  nil
end

#
# built-in
#
  require "yaml"
#
# rubyforge.org/raa.ruby-lang.org
#
  require "mmap"
  require "narray"
#
# homegrown/ext
#
  require "na_str" unless ENV['RUBY_NO_NA_STR']
#
# here we creates a little convenience class for working with memory mapped
# numerical grids
#
  class NMap
    def NMap.version() '1.0.0' end

    module Util
      def string_of(obj)
        obj.to_str
      rescue
        raise ArgumentError, "cannot convert <#{ obj.inspect }> to string"
      end

      def int_of(obj)
        Float(obj).to_i
      rescue
        raise ArgumentError, "cannot convert <#{ obj.inspect }> to int"
      end

      def int_list_of(obj)
        [*obj].flatten.map{|elem| int_of(elem)}
      rescue
        raise ArgumentError, "cannot convert <#{ obj.inspect }> to int list"
      end
    end

    class Header < ::Hash
      include Util

      def initialize(path, *args)
        @path = string_of(path)

        self.na_type = args.shift
        self.shape = args

        self.na_type = int_of na_type if na_type 
        self.shape = int_list_of shape if shape

        init! if na_type and shape

        load!
      end

      def init!
        open(@path, "w"){|f| ::YAML::dump(({}.update(self)), f)}
      end

      def load!
        self.update(open(@path){|f| ::YAML::load(f)})
      end

      def na_type
        self["na_type"]
      end

      def na_type=(val)
        self["na_type"] = val
      end

      def shape
        self["shape"]
      end

      def shape=(val)
        self["shape"] = val
      end

      def Header.init(*args, &block)
        new(*args, &block)
      end
    end

    include Util

    attr "path"
    attr "na_type"
    attr "shape"
    attr "lockfile"
    attr "header"
    attr "na"
    attr "closed"

    def initialize path, *args 
      @path = string_of(path)

      @na_type = args.shift
      @shape = args

      @na_type = int_of(@na_type) if @na_type 
      @shape = int_list_of(@shape) if @shape

      @lockfile = @path + '.lock'
      
      locked do
        init! unless test(?s, @path)
        load_header!
        load!
      end

      @closed = false

      if block_given?
        begin
          yield(self)
        ensure
          close
        end
      end
    end

    def init!
      raise(ArgumentError, "no na_type") unless @na_type
      raise(ArgumentError, "no shape") unless @shape
      sizeof_type = NArray::new(@na_type, 1).to_s.size
      size = @shape.inject(1){|product, dim| product *= dim}
      pos = sizeof_type * size
      File.unlink(@path) rescue nil
      open(@path, File::CREAT|File::EXCL|File::RDWR){|f| f.truncate pos}
      Header::init(@path + '.yml', @na_type, @shape)
    end

    def load_header!
      @header = Header::new(@path + '.yml')
      @na_type = @header.na_type
      @shape = @header.shape
    end

    def load!
      @mmap = ::Mmap::new(@path, "rw", Mmap::MAP_SHARED)
      @na = ::NArray::str(@mmap, @na_type, *@shape)
    end

    def locked
      f = open(@lockfile, 'a+')
      f.flock(File::LOCK_EX)
      yield
    ensure
      if f
        f.flock(File::LOCK_UN) rescue nil
        f.close rescue nil
      end
    end

    def sync
      @mmap.msync
    end

    def close
      return if @closed
      sync
      @mmap.munmap
      @mmap = nil
      @na = nil
      @closed = true
    end

    class << NMap
      def init(*a, &b)
        new(*a, &b)
      end

      narray_constructors = ::NArray.constants.select{|c| ::NArray.respond_to?(c.downcase)}

      narray_constructors.each do |constructor|
        code = <<-__
          def #{ constructor.downcase }(path, *args, &block)
            new(path, NArray::#{ constructor }, *args, &block)
          end
        __
        module_eval(code)
      end
    end
  end

  Nmap = NMap




 
# sample usage - be sure to run more than once!!
#
  if $0 == __FILE__
    require 'tmpdir'
    require 'yaml'

    ipath = File.join(Dir.tmpdir, 'i.na')

    t, f = true, false

    nmap = NMap.int(ipath, 3,4)
    na = nmap.na
    p na
    na[t,0] = 42
    na[0,t] = Time.now.to_i
    p na
  end
