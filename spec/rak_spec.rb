

require File.dirname(__FILE__) + "/spec_helpers"

describe "Rak", "with no options" do 
  before(:all) do
    ENV['RAK_TEST'] = "true"
  end
  after(:all) do
    ENV['RAK_TEST'] = "false"
  end
  it "prints all matches from files in the current directory" do
    asterize_ansi(%x{rak Cap.ic}).should == t=<<END
*foo.rb*
   3|foo foo foo *Capric*a foo foo foo
   4|foo *Capsic*um foo foo foo foo foo

END
  end
  
  it "prints all matches correctly" do
    strip_ansi(%x{rak foo}).should == t=<<END
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
    asterize_ansi(%x{rak  Pikon}).should == t=<<END
*dir1/bar.rb*
   2|bar bar bar bar *Pikon* bar
   9|bar bar *Pikon* bar bar bar

*foo.rb*
   6|foo foo foo foo foo *Pikon* foo foo
   8|foo *Pikon* foo foo foo foo foo foo

END
  end
  
  it "prints multiple matches in a line" do
    asterize_ansi(%x{rak Six}).should == t=<<END
*foo.rb*
  10|foo foo *Six* foo foo foo *Six* foo
  11|foo foo foo foo *Six* foo foo foo

END
  end
  
  it "skips VC dirs" do
    %x{rak Aerelon}.should == ""
  end
  
  it "does not follow symlinks" do
    %x{rak Sagitarron}.should == ""
  end
  
  it "changes defaults when redirected" do
    ENV['RAK_TEST'] = "false"
    asterize_ansi(%x{rak Six | cat}).should == t=<<END
foo.rb   10|foo foo Six foo foo foo Six foo
foo.rb   11|foo foo foo foo Six foo foo foo
END
    ENV['RAK_TEST'] = "true"
  end

  it "searches shebangs for valid inputs" do
    asterize_ansi(%x{rak Aquaria}).should == t=<<END
*shebang*
   3|goo goo goo *Aquaria* goo goo

END
  end
  
  it "recognizes Makefiles and Rakefiles"
end

describe "Rak", "with FILE or STDIN inputs" do
  before(:all) do
    ENV['RAK_TEST'] = "true"
  end
  after(:all) do
    ENV['RAK_TEST'] = "false"
  end
  it "should only search in given files or directories" do
    asterize_ansi(%x{rak Pikon foo.rb}).should == t=<<END
   6|foo foo foo foo foo *Pikon* foo foo
   8|foo *Pikon* foo foo foo foo foo foo
END
    strip_ansi(%x{rak Pikon dir1/}).should == t=<<END
dir1/bar.rb
   2|bar bar bar bar Pikon bar
   9|bar bar Pikon bar bar bar

END
  end
  
  it "should search in STDIN by default if no files are specified" do
    asterize_ansi(%x{cat _darcs/baz.rb | rak Aere}).should == t=<<END
   2|baz baz baz *Aere*lon baz baz baz
END
  end
  
  it "only searches STDIN when piped to" do
    asterize_ansi(%x{echo asdfCapasdf | rak Cap}).should == t=<<END
   1|asdf*Cap*asdf
END
  end
end

describe "Rak", "options" do
  before(:all) do
    ENV['RAK_TEST'] = "true"
  end
  after(:all) do
    ENV['RAK_TEST'] = "false"
  end
  it "prints only files with --files" do
    t=<<END
quux.py
dir1/bar.rb
foo.rb
shebang
END
    sort_lines(%x{rak -f}).should == sort_lines(t)
  end
  
  it "prints a maximum number of matches if --max-count=x is specified" do
    strip_ansi(%x{rak Cap.ic -m 1}).should == t=<<END
foo.rb
   3|foo foo foo Caprica foo foo foo

END
  end
  
  it "prints the evaluated output for --output" do
    strip_ansi(%x{rak Cap --output='$&'}).should == t=<<END
Cap
Cap
END
  end
  
  
  it "-c prints only the number of matches found per file" do
    t=<<END
quux.py:0
dir1/bar.rb:2
foo.rb:2
shebang:0
END
    sort_lines(strip_ansi(%x{rak Pik -c})).should == sort_lines(t)
  end
  
  it "-h suppresses filename and line number printing" do
    asterize_ansi(%x{rak Pik -h}).should == t=<<END
bar bar bar bar *Pik*on bar
bar bar *Pik*on bar bar bar
foo foo foo foo foo *Pik*on foo foo
foo *Pik*on foo foo foo foo foo foo
END
  end
  
  it "ignores case with -i" do
    strip_ansi(%x{rak six -i}).should == t=<<END
foo.rb
  10|foo foo Six foo foo foo Six foo
  11|foo foo foo foo Six foo foo foo

END
  end
  
  it "inverts the match with -v" do
    t1=<<END
quux.py
   1|quux quux quux quux Virgon quux quux
END
    t12=<<END
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
END
    t2=<<END
foo.rb
   1|
   2|
   5|
   7|
   9|
  12|
END
    t3=<<END
shebang
   1|#!/usr/bin/env ruby
   2|
   3|goo goo goo Aquaria goo goo
END
    r = strip_ansi(%x{rak foo -v})
    r.include?(t1).should be_true
    r.include?(t12).should be_true
    r.include?(t2).should be_true
    r.include?(t3).should be_true
    r.split("\n").length.should == 24
  end
  
  it "doesn't descend into subdirs with -n" do
    strip_ansi(%x{rak Pikon -n}).should == t=<<END
foo.rb
   6|foo foo foo foo foo Pikon foo foo
   8|foo Pikon foo foo foo foo foo foo

END
  end
  
  it "quotes meta-characters with -Q" do
    strip_ansi(%x{rak Cap. -Q}).should == ""
  end
  
  it "prints only the matching portion with -o" do
    strip_ansi(%x{rak Cap -o}).should == t=<<END
Cap
Cap
END
  end
  
  it "matches whole words only with -w" do
    strip_ansi(%x{rak Cap -w}).should == ""
  end
  
   it "prints the file on each line with --nogroup" do
    asterize_ansi(%x{rak Cap --nogroup}).should == t=<<END
*foo.rb*    3|foo foo foo *Cap*rica foo foo foo
*foo.rb*    4|foo *Cap*sicum foo foo foo foo foo
END
  end
  
  it "-l means only print filenames with matches" do
    asterize_ansi(%x{rak Caprica -l}).should == t=<<END
foo.rb
END
  end
  
  it "-L means only print filenames without matches" do
      t=<<END
quux.py
dir1/bar.rb
shebang
END
    sort_lines(asterize_ansi(%x{rak Caprica -L})).should == sort_lines(t)
  end
  
  it "--passthru means print all lines whether matching or not" do
     t1=<<END
quux quux quux quux Virgon quux quux
END

    t2=<<END
*foo.rb*
   3|foo foo foo *Caprica* foo foo foo
foo Capsicum foo foo foo foo foo

foo foo foo foo foo Pikon foo foo

foo Pikon foo foo foo foo foo foo

foo foo Six foo foo foo Six foo
foo foo foo foo Six foo foo foo

foo foo foo Gemenon foo foo foo
END
    t3=<<END
#!/usr/bin/env ruby

goo goo goo Aquaria goo goo
END
    r = asterize_ansi(%x{rak Caprica --passthru -n})
    r.include?(t1).should be_true
    r.include?(t2).should be_true
    r.include?(t3).should be_true
    r.split("\n").length.should < (t1+t2+t3).split("\n").length+5
  end
  
  it "--nocolour means do not colourize the output" do
    asterize_ansi(%x{rak Cap --nocolour}).should == t=<<END
foo.rb
   3|foo foo foo Caprica foo foo foo
   4|foo Capsicum foo foo foo foo foo

END
  end
  
  it "-a means to search every file" do
    asterize_ansi(%x{rak Libris -a}).should == t=<<END
*qux*
   1|qux qux qux *Libris* qux qux qux

END
    
  end
  
  it "--ruby means only ruby files" do
    asterize_ansi(%x{rak Virgon --ruby}).should == ""
  end
  
  it "--python means only python files" do
    asterize_ansi(%x{rak Cap --python}).should == ""
  end
  
  it "--noruby means exclude ruby files" do
    asterize_ansi(%x{rak Cap --noruby}).should == ""
  end
  
  it "--type=ruby means only ruby files" do
    asterize_ansi(%x{rak Virgon --type=ruby}).should == ""
  end
  
  it "--type=python means only python files" do
    asterize_ansi(%x{rak Cap --type=python}).should == ""
  end
  
  it "--type=noruby means exclude ruby files" do
    asterize_ansi(%x{rak Cap --type=noruby}).should == ""
  end
  
  it "--sort-files" do
    %x{rak -f --sort-files}.should == t=<<END
dir1/bar.rb
foo.rb
quux.py
shebang
END
  end
  
  it "--follow means follow symlinks" do 
    strip_ansi(%x{rak Sagitarron --follow}).should == t=<<END
corge.rb
   1|corge corge corge Sagitarron corge

ln_dir/corge.rb
   1|corge corge corge Sagitarron corge

END
  end
  
  it "-A NUM means show NUM lines after" do 
    strip_ansi(%x{rak Caps -A 2}).should == t=<<END
foo.rb
   4|foo Capsicum foo foo foo foo foo
   5|
   6|foo foo foo foo foo Pikon foo foo

END
  end
  
  it "-A should work when there are matches close together" do 
    strip_ansi(%x{rak foo -A 2}).should == t=<<END
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
    strip_ansi(%x{rak Caps -B 2}).should == t=<<END
foo.rb
   2|
   3|foo foo foo Caprica foo foo foo
   4|foo Capsicum foo foo foo foo foo

END
  end
  
  it "-C means show 2 lines before and after" do 
    strip_ansi(%x{rak Caps -C}).should == t=<<END
foo.rb
   2|
   3|foo foo foo Caprica foo foo foo
   4|foo Capsicum foo foo foo foo foo
   5|
   6|foo foo foo foo foo Pikon foo foo

END
  end
  
  it "-C 1 means show 1 lines before and after" do 
    strip_ansi(%x{rak Caps -C 1}).should == t=<<END
foo.rb
   3|foo foo foo Caprica foo foo foo
   4|foo Capsicum foo foo foo foo foo
   5|

END
  end
  
  it "-C works correctly for nearby results" do
    strip_ansi(%x{rak Pik -g foo -C}).should == t=<<END
foo.rb
   4|foo Capsicum foo foo foo foo foo
   5|
   6|foo foo foo foo foo Pikon foo foo
   7|
   8|foo Pikon foo foo foo foo foo foo
   9|
  10|foo foo Six foo foo foo Six foo

END
  end
  it "-g REGEX only searches in files matching REGEX" do
    asterize_ansi(%x{rak Pikon -g f.o}).should == t=<<END
*foo.rb*
   6|foo foo foo foo foo *Pikon* foo foo
   8|foo *Pikon* foo foo foo foo foo foo

END
  end
  
  it "-x means match only whole lines" do
    asterize_ansi(%x{rak Cap -x}).should == ""
    asterize_ansi(%x{rak "(foo )+Cap\\w+( foo)+" -x}).should == t=<<END
*foo.rb*
   3|*foo foo foo Caprica foo foo foo*
   4|*foo Capsicum foo foo foo foo foo*

END
  end
end

describe "Rak", "with combinations of options" do
  before(:all) do
    ENV['RAK_TEST'] = "true"
  end
  after(:all) do
    ENV['RAK_TEST'] = "false"
  end
  
  it "should process -c -v " do
    t1=<<END
quux.py:1
dir1/bar.rb:7
foo.rb:11
shebang:3
END
    sort_lines(strip_ansi(%x{rak Pikon -c -v})).should == sort_lines(t1)
  end
end





