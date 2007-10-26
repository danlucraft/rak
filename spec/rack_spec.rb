



def strip_ansi(str)
  str.gsub /\033\[\d+m/, ""
end

def asterize_ansi(str)
  str.gsub /(\033\[\d+m)+/, "*"
end

FileUtils.cd("spec/example")

describe "Rack", "with no options" do 
  it "prints all matches from files in the current directory" do
    asterize_ansi(%x{rack Cap.ic}).should == t=<<END
*foo.rb*
3: foo foo foo *Capric*a foo foo foo
4: foo *Capsic*um foo foo foo foo foo

END
  end
  
  it "prints all matches from files in subdirectories" do
    asterize_ansi(%x{rack  Pikon}).should == t=<<END
*dir1/bar.rb*
2: bar bar bar bar *Pikon* bar
9: bar bar *Pikon* bar bar bar

*foo.rb*
6: foo foo foo foo foo *Pikon* foo foo
8: foo *Pikon* foo foo foo foo foo foo

END
  end
  
  it "prints multiple matches in a line" do
    asterize_ansi(%x{rack Six}).should == t=<<END
*foo.rb*
10: foo foo *Six* foo foo foo *Six* foo
11: foo foo foo foo *Six* foo foo foo

END
  end
end

describe "Rack", "options" do
  it "prints only files with --files" do
    %x{rack -f}.should == t=<<END
dir1/bar.rb
foo.rb
END
  end
  
  it "prints a maximum number of matches if --max-count=x is specified" do
    strip_ansi(%x{rack Cap.ic -m 1}).should == t=<<END
foo.rb
3: foo foo foo Caprica foo foo foo

END
  end
  
  it "prints the evaluated output for --output" do
    strip_ansi(%x{rack Cap --output='$&'}).should == t=<<END
Cap
Cap
END
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
  
  it "-c prints only the number of matches found per file" do
    strip_ansi(%x{rack Pik -c}).should == t=<<END
dir1/bar.rb:2
foo.rb:2
END
  end
  
  it "-h suppresses filename and line number printing" do
    asterize_ansi(%x{rack Pik -h}).should == t=<<END
bar bar bar bar *Pik*on bar
bar bar *Pik*on bar bar bar
foo foo foo foo foo *Pik*on foo foo
foo *Pik*on foo foo foo foo foo foo
END
  end
  
  it "ignores case with -i" do
    strip_ansi(%x{rack six -i}).should == t=<<END
foo.rb
10: foo foo Six foo foo foo Six foo
11: foo foo foo foo Six foo foo foo

END
  end
  
  it "inverts the match with -v" do
    strip_ansi(%x{rack foo -v}).should == t=<<END
dir1/bar.rb
1: 
2: bar bar bar bar Pikon bar
3:  
4: 
5: 
6: 
7: 
8: 
9: bar bar Pikon bar bar bar
foo.rb
1: 
2: 
5: 
7: 
9: 

END
  end
  
  it "doesn't descend into subdirs with -n" do
    strip_ansi(%x{rack Pikon -n}).should == t=<<END
foo.rb
6: foo foo foo foo foo Pikon foo foo
8: foo Pikon foo foo foo foo foo foo

END
  end
  
  describe "Rack", "with combinations of options" do
    it "should process -c -v " do
      strip_ansi(%x{rack Pikon -c -v}).should == t=<<END
dir1/bar.rb:7
foo.rb:9
END
    end
  end
end
