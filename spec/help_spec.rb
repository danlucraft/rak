require File.dirname(__FILE__) + "/spec_helpers"

def extract_options_from_help_message(msg)
  msg.scan(/\B--?(?:\[no\]|no)?([a-zA-Z0-9\-]+)/).flatten.sort.uniq
end

describe "Rak", "help and errors" do
  it "--version prints version information" do
    rak("--version", :ansi => '').should == <<-END.unindent(6)
      rak #{Rak::VERSION}
      
      Copyright 2008-#{Time.now.year} Daniel Lucraft, all rights reserved. 
      Based on the perl tool 'ack' by Andy Lester.
      
      This program is free software; you can redistribute it and/or modify it
      under the same terms as Ruby.
    END
  end
  
  it "prints unknown type errors" do
    rak("Virg --type=pyth").should == <<-END.unindent(6)
      rak: Unknown --type "pyth"
      rak: See rak --help types
    END
  end
  
  it "--help prints help information" do
    rak("Virg --help").split("\n")[0].should == "Usage: rak [OPTION]... PATTERN [FILES]"
  end
  
  it "--help types prints type information" do
    rak("--help types").split("\n")[2].should == "The following is the list of filetypes supported by rak.  You can"
  end
  
  it "no options or patterns prints the usage info" do
    rak.split("\n")[0].should == "Usage: rak [OPTION]... PATTERN [FILES]"
  end

  it "prints a nice message for unknown options" do
    rak("foo --asfdasfd 2>/dev/null").should include <<-END.unindent(6)
      rak: see rak --help for usage.
    END
  end

  it "should mention every option it supports in help" do
    expected = extract_options_from_help_message(File.readlines(bin_rak).grep(/GetoptLong/).join) - ['color']
    actual   = extract_options_from_help_message(rak()) - ['ruby']
    actual.should == expected
  end
end
