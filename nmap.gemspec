## nmap.gemspec
#

Gem::Specification::new do |spec|
  spec.name = "nmap"
  spec.version = "1.1.0"
  spec.platform = Gem::Platform::RUBY
  spec.summary = "nmap"
  spec.description = "narray + mmap = wicked fast persistent numerical arrays" 

  spec.files = ["extconf.rb", "gemspec.rb", "install.rb", "lib", "lib/nmap.rb", "na_str.c", "nmap.gemspec", "Rakefile", "README", "samples", "samples/a.rb", "samples/b.rb", "samples/b.rb.data", "samples/c.rb"]
  spec.executables = []
  
  spec.require_path = "lib"

  spec.has_rdoc = true
  spec.test_files = nil
  spec.add_dependency 'narray'
  spec.add_dependency 'mmap'

  spec.extensions.push(*["extconf.rb"])

  spec.rubyforge_project = "codeforpeople"
  spec.author = "Ara T. Howard"
  spec.email = "ara.t.howard@gmail.com"
  spec.homepage = "http://github.com/ahoward/nmap/tree/master"
end
