

require File.dirname(__FILE__) + "/spec_helpers"

describe "Rak", "help and errors" do
  before(:all) do
    ENV['RAK_TEST'] = "true"
  end
  after(:all) do
    ENV['RAK_TEST'] = "false"
  end
  
  it "--version prints version information" do
    strip_ansi(rak "--version").should == t=<<END
rak #{Rak::VERSION}

Copyright 2008-#{Time.now.year} Daniel Lucraft, all rights reserved. 
Based on the perl tool 'ack' by Andy Lester.

This program is free software; you can redistribute it and/or modify it
under the same terms as Ruby.
END
  end
  
  it "prints unknown type errors" do
    rak("Virg --type=pyth").should == t=<<END
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
    t=<<END
rak: see rak --help for usage.
END
    rak("foo --asfdasfd 2>/dev/null").include?(t).should be_true
  end
end
