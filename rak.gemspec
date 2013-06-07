
Gem::Specification.new do |s|
  s.name = %q{rak}
  s.version = "1.4"

  s.authors = ["Daniel Lucraft"]
  s.date = %q{2012-01-15}
  s.default_executable = %q{rak}
  s.description = <<-END
    Grep replacement, recursively scans directories to match a given Ruby regular expression. Prints highlighted results.
    Based on the Perl tool 'ack' by Andy Lester.  
  END
  s.email = %q{dan@fluentradical.com}
  s.executables = ["rak"]
  s.files = ["History.txt", "Manifest.txt", "README.txt", "bin/rak", "lib/rak.rb"]
  s.files += Dir["spec/**/*"].select { |f| not File.symlink?(f) }
  s.homepage = %q{http://rak.rubyforge.org}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{rak}
  s.rubygems_version = %q{1.4.0}
  s.summary = %q{A grep replacement in Ruby, type "rak pattern".}
end
