

require File.dirname(__FILE__) + "/spec_helpers"

describe "Rak", "help and errors" do
  before(:all) do
    ENV['RAK_TEST'] = "true"
  end
  after(:all) do
    ENV['RAK_TEST'] = "false"
  end
  
  it "--version prints version information" do
    strip_ansi(%x{rak --version}).should == t=<<END
rak 0.9

Copyright 2008 Daniel Lucraft, all rights reserved. 
Based on the perl tool 'ack' by Andy Lester.

This program is free software; you can redistribute it and/or modify it
under the same terms as Ruby.
END
  end
  
  it "prints unknown type errors" do
    %x{rak Virg --type=pyth}.should == t=<<END
rak: Unknown --type "pyth"
rak: See rak --help types
END
  end
  
  it "--help prints help information" do
    %x{rak Virg --help}.split("\n")[0].should == "Usage: rak [OPTION]... PATTERN [FILES]"
  end
  
  it "--help types prints type information" do
    %x{rak --help types}.split("\n")[2].should == "The following is the list of filetypes supported by rak.  You can"
  end
  
  it "no options or patterns prints the usage info" do
    %x{rak}.split("\n")[0].should == "Usage: rak [OPTION]... PATTERN [FILES]"
  end

  it "prints a nice message for unknown options" do
    t=<<END
rak: see rak --help for usage.
END
    %x{rak foo --asfdasfd}.include?(t).should be_true
  end
end
