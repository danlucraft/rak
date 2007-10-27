



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
   3|foo foo foo *Capric*a foo foo foo
   4|foo *Capsic*um foo foo foo foo foo

END
  end
  
  it "prints all matches correctly" do
    strip_ansi(%x{rack foo}).should == t=<<END
foo.rb
   3|foo foo foo Caprica foo foo foo
   4|foo Capsicum foo foo foo foo foo
   6|foo foo foo foo foo Pikon foo foo
   8|foo Pikon foo foo foo foo foo foo
  10|foo foo Six foo foo foo Six foo
  11|foo foo foo foo Six foo foo foo
  13|foo foo foo Gemenon foo foo foo

END
  end

  it "prints all matches from files in subdirectories" do
    asterize_ansi(%x{rack  Pikon}).should == t=<<END
*dir1/bar.rb*
   2|bar bar bar bar *Pikon* bar
   9|bar bar *Pikon* bar bar bar

*foo.rb*
   6|foo foo foo foo foo *Pikon* foo foo
   8|foo *Pikon* foo foo foo foo foo foo

END
  end
  
  it "prints multiple matches in a line" do
    asterize_ansi(%x{rack Six}).should == t=<<END
*foo.rb*
  10|foo foo *Six* foo foo foo *Six* foo
  11|foo foo foo foo *Six* foo foo foo

END
  end
  
  it "skips VC dirs" do
    %x{rack Aerelon}.should == ""
  end
  
  it "does not follow symlinks" do
    %x{rack Sagitarron}.should == ""
  end
end

describe "Rack", "with FILE arguments" do
  it "should only search in given files or directories" do
    asterize_ansi(%x{rack Pikon foo.rb}).should == t=<<END
   6|foo foo foo foo foo *Pikon* foo foo
   8|foo *Pikon* foo foo foo foo foo foo
END
    strip_ansi(%x{rack Pikon dir1/}).should == t=<<END
dir1/bar.rb
   2|bar bar bar bar Pikon bar
   9|bar bar Pikon bar bar bar

END
  end
end

describe "Rack", "options" do
  it "prints only files with --files" do
    %x{rack -f}.should == t=<<END
quux.py
dir1/bar.rb
foo.rb
END
  end
  
  it "prints a maximum number of matches if --max-count=x is specified" do
    strip_ansi(%x{rack Cap.ic -m 1}).should == t=<<END
foo.rb
   3|foo foo foo Caprica foo foo foo

END
  end
  
  it "prints the evaluated output for --output" do
    strip_ansi(%x{rack Cap --output='$&'}).should == t=<<END
Cap
Cap
END
  end
  
  
  it "-c prints only the number of matches found per file" do
    strip_ansi(%x{rack Pik -c}).should == t=<<END
quux.py:0
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
  10|foo foo Six foo foo foo Six foo
  11|foo foo foo foo Six foo foo foo

END
  end
  
  it "inverts the match with -v" do
    strip_ansi(%x{rack foo -v}).should == t=<<END
quux.py
   1|quux quux quux quux Virgon quux quux
dir1/bar.rb
   1|
   2|bar bar bar bar Pikon bar
   3| 
   4|
   5|
   6|
   7|
   8|
   9|bar bar Pikon bar bar bar
foo.rb
   1|
   2|
   5|
   7|
   9|
  12|

END
  end
  
  it "doesn't descend into subdirs with -n" do
    strip_ansi(%x{rack Pikon -n}).should == t=<<END
foo.rb
   6|foo foo foo foo foo Pikon foo foo
   8|foo Pikon foo foo foo foo foo foo

END
  end
  
  it "quotes meta-characters with -Q" do
    strip_ansi(%x{rack Cap. -Q}).should == ""
  end
  
  it "prints only the matching portion with -o" do
    strip_ansi(%x{rack Cap -o}).should == t=<<END
Cap
Cap
END
  end
  
  it "matches whole words only with -w" do
    strip_ansi(%x{rack Cap -w}).should == ""
  end
  
   it "prints the file on each line with --nogroup" do
    asterize_ansi(%x{rack Cap --nogroup}).should == t=<<END
*foo.rb*    3|foo foo foo *Cap*rica foo foo foo
*foo.rb*    4|foo *Cap*sicum foo foo foo foo foo
END
  end
  
  it "-l means only print filenames with matches" do
    asterize_ansi(%x{rack Caprica -l}).should == t=<<END
foo.rb
END
  end
  
  it "-L means only print filenames without matches" do
    asterize_ansi(%x{rack Caprica -L}).should == t=<<END
quux.py
dir1/bar.rb
END
  end
  
  it "--passthru means print all lines whether matching or not" do
    asterize_ansi(%x{rack Caprica --passthru -n}).should == t=<<END
quux quux quux quux Virgon quux quux


*foo.rb*
   3|foo foo foo *Caprica* foo foo foo
foo Capsicum foo foo foo foo foo

foo foo foo foo foo Pikon foo foo

foo Pikon foo foo foo foo foo foo

foo foo Six foo foo foo Six foo
foo foo foo foo Six foo foo foo

foo foo foo Gemenon foo foo foo

END
  end
  
  it "--nocolour means do not colourize the output" do
    asterize_ansi(%x{rack Cap --nocolour}).should == t=<<END
foo.rb
   3|foo foo foo Caprica foo foo foo
   4|foo Capsicum foo foo foo foo foo

END
  end
  
  it "-a means to search every file" do
    asterize_ansi(%x{rack Libris -a}).should == t=<<END
*qux*
   1|qux qux qux *Libris* qux qux qux

END
    
  end
  
  it "--ruby means only ruby files" do
    asterize_ansi(%x{rack Virgon --ruby}).should == ""
  end
  
  it "--python means only python files" do
    asterize_ansi(%x{rack Cap --python}).should == ""
  end
  
  it "--noruby means exclude ruby files" do
    asterize_ansi(%x{rack Cap --noruby}).should == ""
  end
  
  it "--type=ruby means only ruby files" do
    asterize_ansi(%x{rack Virgon --type=ruby}).should == ""
  end
  
  it "--type=python means only python files" do
    asterize_ansi(%x{rack Cap --type=python}).should == ""
  end
  
  it "--type=noruby means exclude ruby files" do
    asterize_ansi(%x{rack Cap --type=noruby}).should == ""
  end
  
  it "--sort-files" do
    %x{rack -f --sort-files}.should == t=<<END
dir1/bar.rb
foo.rb
quux.py
END
  end
  
  it "--follow means follow symlinks" do 
    strip_ansi(%x{rack Sagitarron --follow}).should == t=<<END
corge.rb
   1|corge corge corge Sagitarron corge

ln_dir/corge.rb
   1|corge corge corge Sagitarron corge

END
  end
  
  it "-A NUM means show NUM lines after" do 
    strip_ansi(%x{rack Caps -A 2}).should == t=<<END
foo.rb
   4|foo Capsicum foo foo foo foo foo
   5|
   6|foo foo foo foo foo Pikon foo foo

END
  end
  
  it "-A should work when there are matches close together" do 
    strip_ansi(%x{rack foo -A 2}).should == t=<<END
foo.rb
   3|foo foo foo Caprica foo foo foo
   4|foo Capsicum foo foo foo foo foo
   5|
   6|foo foo foo foo foo Pikon foo foo
   7|
   8|foo Pikon foo foo foo foo foo foo
   9|
  10|foo foo Six foo foo foo Six foo
  11|foo foo foo foo Six foo foo foo
  12|
  13|foo foo foo Gemenon foo foo foo

END
  end
  
  it "-B NUM means show NUM lines before" do 
    strip_ansi(%x{rack Caps -B 2}).should == t=<<END
foo.rb
   2|
   3|foo foo foo Caprica foo foo foo
   4|foo Capsicum foo foo foo foo foo

END
  end
  
  it "-C means show 2 lines before and after" do 
    strip_ansi(%x{rack Caps -C}).should == t=<<END
foo.rb
   2|
   3|foo foo foo Caprica foo foo foo
   4|foo Capsicum foo foo foo foo foo
   5|
   6|foo foo foo foo foo Pikon foo foo

END
  end
  
  it "-C 1means show 1 lines before and after" do 
    strip_ansi(%x{rack Caps -C 1}).should == t=<<END
foo.rb
   3|foo foo foo Caprica foo foo foo
   4|foo Capsicum foo foo foo foo foo
   5|

END
  end
  
end

describe "Rack", "with combinations of options" do
  it "should process -c -v " do
    strip_ansi(%x{rack Pikon -c -v}).should == t=<<END
quux.py:1
dir1/bar.rb:7
foo.rb:11
END
  end
end

describe "Rack", "help and errors" do
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
end
