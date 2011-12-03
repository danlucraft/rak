require "spec_helper"

def extract_options_from_help_message(msg)
  msg.scan(/\B--?(?:\[no\]|no)?([a-zA-Z0-9\-]+)/).flatten.sort.uniq
end

describe "Rak", "help and errors" do
  it "--version prints version information" do
    rak("--version").should == <<-END
      rak #{Rak::VERSION}

      Copyright 2008-#{Time.now.year} Daniel Lucraft, all rights reserved. 
      Based on the perl tool 'ack' by Andy Lester.

      This program is free software; you can redistribute it and/or modify it
      under the same terms as Ruby.
    END
  end
  
  it "prints unknown type errors" do
    rak("Virg --type=pyth").should == <<-END
      rak: Unknown --type "pyth"
      rak: See rak --help types
    END
  end
  
  it "--help prints help information" do
    rak("Virg --help").lines[0].should == <<-END
      Usage: rak [OPTION]... PATTERN [FILES]
    END
  end
  
  it "--help types prints type information" do
    rak("--help types").lines[2].should == <<-END
      The following is the list of filetypes supported by rak.  You can
    END
  end
  
  it "no options or patterns prints the usage info" do
    rak.lines[0].should == <<-END
      Usage: rak [OPTION]... PATTERN [FILES]
    END
  end

  it "prints a nice message for unknown options" do
    rak("foo --asfdasfd 2>/dev/null").should include <<-END
      rak: see rak --help for usage.
    END
  end

  it "should mention every option it supports in help" do
    expected = extract_options_from_help_message(File.readlines(bin_rak).grep(/GetoptLong/).join) - ['color']
    actual   = extract_options_from_help_message(rak()) - ['ruby']
    actual.should == expected
  end
end
