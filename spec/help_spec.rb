

require File.dirname(__FILE__) + "/spec_helpers"

describe "Rack", "help and errors" do
  before(:all) do
    ENV['RACK_TEST'] = "true"
  end
  after(:all) do
    ENV['RACK_TEST'] = "false"
  end
  
  it "--version prints version information" do
    strip_ansi(%x{rack --version}).should == t=<<END
rack 0.0.1

Copyright 2007 Daniel Lucraft, all rights reserved. 
Based on the perl tool 'ack' by Andy Lester.

This program is free software; you can redistribute it and/or modify it
under the same terms as Ruby.
END
  end
  
  it "prints unknown type errors" do
    %x{rack Virg --type=pyth}.should == t=<<END
rack: Unknown --type "pyth"
rack: See rack --help types
END
  end
  
  it "--help prints help information" do
    %x{rack Virg --help}.split("\n")[0].should == "Usage: rack [OPTION]... PATTERN [FILES]"
  end
  
  it "--help types prints type information" do
    %x{rack --help types}.split("\n")[2].should == "The following is the list of filetypes supported by ack.  You can"
  end
  
  it "no options or patterns prints the usage info" do
    %x{rack}.split("\n")[0].should == "Usage: rack [OPTION]... PATTERN [FILES]"
  end
end
