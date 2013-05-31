
Gem::Specification.new do |s|
  s.name = %q{rak}
  s.version = "1.5"

  s.authors = ["Eugene Ching"]
  s.date = %q{2012-01-15}
  s.default_executable = %q{rak}
  s.description = <<-END
    Grep replacement, recursively scans directories to match a given Ruby regular expression. Prints highlighted results.
    Based on the Perl tool 'ack' by Andy Lester.  
  END
  s.email = %q{eugene@enegue.com}
  s.executables = ["rak"]
  s.files = ["History.txt", "Manifest.txt", "README.txt", "bin/rak", "lib/rak.rb", "spec/rak_spec.rb", "spec/help_spec.rb"]
  s.homepage = %q{http://rak.rubyforge.org}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{rak}
  s.rubygems_version = %q{1.5.0}
  s.summary = %q{A grep replacement in Ruby, type "rak pattern".}
end
