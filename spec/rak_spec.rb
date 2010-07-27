
require 'fileutils'
require 'rbconfig'

require File.dirname(__FILE__) + "/spec_helpers"

describe "Rak", "with no options" do 
  it "prints all matches from files in the current directory" do
    asterize_ansi(rak "Cap.ic").should == t=<<END
*foo.rb*
   3|foo foo foo *Capric*a foo foo foo
   4|foo *Capsic*um foo foo foo foo foo
END
  end
  
  it "prints all matches correctly" do
    strip_ansi(rak "foo").should == t=<<END
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
    asterize_ansi(rak "Pikon").should == t=<<END
*dir1/bar.rb*
   2|bar bar bar bar *Pikon* bar
   9|bar bar *Pikon* bar bar bar

*foo.rb*
   6|foo foo foo foo foo *Pikon* foo foo
   8|foo *Pikon* foo foo foo foo foo foo
END
  end
  
  it "prints multiple matches in a line" do
    asterize_ansi(rak "Six").should == t=<<END
*foo.rb*
  10|foo foo *Six* foo foo foo *Six* foo
  11|foo foo foo foo *Six* foo foo foo
END
  end
  
  it "skips VC dirs" do
    rak("Aerelon").should == ""
  end
  
  it "does not follow symlinks" do
    rak("Sagitarron").should == ""
  end
  
  it "changes defaults when redirected" do
    asterize_ansi(rak("Six | cat", :test_mode => false)).should == t=<<END
foo.rb:10:foo foo Six foo foo foo Six foo
foo.rb:11:foo foo foo foo Six foo foo foo
END
  end

  it "searches shebangs for valid inputs" do
    asterize_ansi(rak "Aquaria").should == t=<<END
*shebang*
   3|goo goo goo *Aquaria* goo goo
END
  end
  
  it "recognizes Makefiles and Rakefiles" do
    asterize_ansi(rak "Canceron").should == t=<<END
*Rakefile*
   1|rakefile rakefile *Canceron* rakefile
END
  end
end

describe "Rak", "with FILE or STDIN inputs" do
  it "should only search in given files or directories" do
    asterize_ansi(rak "Pikon foo.rb").should == t=<<END
   6|foo foo foo foo foo *Pikon* foo foo
   8|foo *Pikon* foo foo foo foo foo foo
END
    strip_ansi(rak "Pikon dir1/").should == t=<<END
dir1/bar.rb
   2|bar bar bar bar Pikon bar
   9|bar bar Pikon bar bar bar
END
  end
  
  it "should search in STDIN by default if no files are specified" do
    asterize_ansi(rak "Aere", :pipe => "cat _darcs/baz.rb").should == t=<<END
   2|baz baz baz *Aere*lon baz baz baz
END
  end
  
  it "only searches STDIN when piped to" do
    asterize_ansi(rak "Cap", :pipe => "echo asdfCapasdf").should == t=<<END
   1|asdf*Cap*asdf
END
  end

  it "should either match on rax x or rak -v x" do
    (rak('"\A.{0,100}\Z" dir1/bar.rb').length + rak('-v "\A.{0,100}\Z" dir1/bar.rb').length).should > 0
  end
end

describe "Rak", "options" do
  it "prints only files with --files" do
    t=<<END
Rakefile
quux.py
dir1/bar.rb
foo.rb
shebang
END
    sort_lines(rak "-f").should == sort_lines(t)
  end
  
  it "prints a maximum number of matches if --max-count=x is specified" do
    strip_ansi(rak "Cap.ic -m 1").should == t=<<END
foo.rb
   3|foo foo foo Caprica foo foo foo
END
  end
  
  it "prints the evaluated output for --output" do
    strip_ansi(rak "Cap --output='$&'").should == t=<<END
Cap
Cap
END
  end
  
  it "-c prints only the number of matches found per file" do
    t=<<END
dir1/bar.rb:2
foo.rb:2
END
    sort_lines(strip_ansi(rak "Pik -c")).should == sort_lines(t)
  end
  
  it "-h suppresses filename and line number printing" do
    asterize_ansi(rak "Pik -h").should == t=<<END
bar bar bar bar *Pik*on bar
bar bar *Pik*on bar bar bar
foo foo foo foo foo *Pik*on foo foo
foo *Pik*on foo foo foo foo foo foo
END
  end
  
  it "ignores case with -i" do
    strip_ansi(rak "six -i").should == t=<<END
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
    t4=<<END
Rakefile
   1|rakefile rakefile Canceron rakefile
END
    r = strip_ansi(rak "foo -v")
    r.include?(t1).should be_true
    r.include?(t12).should be_true
    r.include?(t2).should be_true
    r.include?(t3).should be_true
    r.include?(t4).should be_true
    r.split("\n").length.should == 29
  end
  
  it "doesn't descend into subdirs with -n" do
    strip_ansi(rak "Pikon -n").should == t=<<END
foo.rb
   6|foo foo foo foo foo Pikon foo foo
   8|foo Pikon foo foo foo foo foo foo
END
  end
  
  it "quotes meta-characters with -Q" do
    strip_ansi(rak "Cap. -Q").should == ""
  end
  
  it "prints only the matching portion with -o" do
    strip_ansi(rak "Cap -o").should == t=<<END
Cap
Cap
END
  end
  
  it "matches whole words only with -w" do
    strip_ansi(rak "'Cap|Hat' -w").should == ""
  end
  
   it "prints the file on each line with --nogroup" do
    asterize_ansi(rak "Cap --nogroup").should == t=<<END
*foo.rb*:3:foo foo foo *Cap*rica foo foo foo
*foo.rb*:4:foo *Cap*sicum foo foo foo foo foo
END
  end
  
  it "-l means only print filenames with matches" do
    asterize_ansi(rak "Caprica -l").should == t=<<END
foo.rb
END
  end
  
  it "-L means only print filenames without matches" do
      t=<<END
quux.py
dir1/bar.rb
shebang
Rakefile
END
    sort_lines(asterize_ansi(rak "Caprica -L")).should == sort_lines(t)
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
    r = asterize_ansi(rak "Caprica --passthru -n")
    r.include?(t1).should be_true
    r.include?(t2).should be_true
    r.include?(t3).should be_true
    r.split("\n").length.should < (t1+t2+t3).split("\n").length+5
  end
  
  it "--nocolour means do not colourize the output" do
    asterize_ansi(rak "Cap --nocolour").should == t=<<END
foo.rb
   3|foo foo foo Caprica foo foo foo
   4|foo Capsicum foo foo foo foo foo
END
  end
  
  it "-a means to search every file" do
    asterize_ansi(rak "Libris -a").should == t=<<END
*qux*
   1|qux qux qux *Libris* qux qux qux
END
    
  end
  
  it "--ruby means only ruby files" do
    asterize_ansi(rak "Virgon --ruby").should == ""
  end
  
  it "--python means only python files" do
    asterize_ansi(rak "Cap --python").should == ""
  end
  
  it "--noruby means exclude ruby files" do
    asterize_ansi(rak "Cap --noruby").should == ""
  end
  
  it "--type=ruby means only ruby files" do
    asterize_ansi(rak "Virgon --type=ruby").should == ""
  end
  
  it "--type=python means only python files" do
    asterize_ansi(rak "Cap --type=python").should == ""
  end
  
  it "--type=noruby means exclude ruby files" do
    asterize_ansi(rak "Cap --type=noruby").should == ""
  end
  
  it "--sort-files" do
    (rak "-f --sort-files").should == t=<<END
dir1/bar.rb
foo.rb
quux.py
Rakefile
shebang
END
  end
  
  it "--follow means follow symlinks" do 
    strip_ansi(rak "Sagitarron --follow").should == t=<<END
corge.rb
   1|corge corge corge Sagitarron corge

ln_dir/corge.rb
   1|corge corge corge Sagitarron corge
END
  end
  
  it "-A NUM means show NUM lines after" do 
    strip_ansi(rak "Caps -A 2").should == t=<<END
foo.rb
   4|foo Capsicum foo foo foo foo foo
   5|
   6|foo foo foo foo foo Pikon foo foo
END
  end
  
  it "-A should work when there are matches close together" do 
    strip_ansi(rak "foo -A 2").should == t=<<END
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
    strip_ansi(rak "Caps -B 2").should == t=<<END
foo.rb
   2|
   3|foo foo foo Caprica foo foo foo
   4|foo Capsicum foo foo foo foo foo
END
  end
  
  it "-C means show 2 lines before and after" do 
    strip_ansi(rak "Caps -C").should == t=<<END
foo.rb
   2|
   3|foo foo foo Caprica foo foo foo
   4|foo Capsicum foo foo foo foo foo
   5|
   6|foo foo foo foo foo Pikon foo foo
END
  end
  
  it "-C 1 means show 1 lines before and after" do 
    strip_ansi(rak "Caps -C 1").should == t=<<END
foo.rb
   3|foo foo foo Caprica foo foo foo
   4|foo Capsicum foo foo foo foo foo
   5|
END
  end
  
  it "-C works correctly for nearby results" do
    strip_ansi(rak "Pik -g foo -C").should == t=<<END
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
    asterize_ansi(rak "Pikon -g f.o").should == t=<<END
*foo.rb*
   6|foo foo foo foo foo *Pikon* foo foo
   8|foo *Pikon* foo foo foo foo foo foo
END

  end

  it "-k REGEX only searches in files not matching REGEX" do
    asterize_ansi(rak "Pikon -k f.o").should == t=<<END
*dir1/bar.rb*
   2|bar bar bar bar *Pikon* bar
   9|bar bar *Pikon* bar bar bar
END
  end
  
  it "-x means match only whole lines" do
    asterize_ansi(rak "Cap -x").should == ""
    asterize_ansi(rak '"foo|goo" -x').should == ""
    asterize_ansi(rak '"(foo )+Cap\w+( foo)+" -x').should == t=<<END
*foo.rb*
   3|*foo foo foo Caprica foo foo foo*
   4|*foo Capsicum foo foo foo foo foo*
END
  end

  it "-s means match only at the start of a line" do
    asterize_ansi(rak '-s "foo Cap|Aquaria"').should == t=<<END
*foo.rb*
   4|*foo Cap*sicum foo foo foo foo foo
END
  end

  it "-e means match only at the end of a line" do
    asterize_ansi(rak '-e "Aquaria|kon foo foo"').should == t=<<END
*foo.rb*
   6|foo foo foo foo foo Pi*kon foo foo*
END
  end
  
  it "should not recurse down '..' when used with . " do
    asterize_ansi(rak("foo .", :dir=>HERE+"example/dir1")).should == t=<<END
END
  end
end

describe "Rak", "with combinations of options" do
  it "should process -c -v " do
    t1=<<END
quux.py:1
dir1/bar.rb:7
foo.rb:11
shebang:3
Rakefile:1
END
    sort_lines(strip_ansi(rak "Pikon -c -v")).should == sort_lines(t1)
  end

  it "-h and redirection" do
    (rak("Pik -h | cat", :test_mode => false)).should == t=<<END
bar bar bar bar Pikon bar
bar bar Pikon bar bar bar
foo foo foo foo foo Pikon foo foo
foo Pikon foo foo foo foo foo foo
END
  end
end

describe "Rak", "with --eval" do 
  it "should support next" do
    rak(%Q[--eval 'next unless $. == $_.split.size'], :ansi => '*').should == t=<<END
*foo.rb*
   8|*foo Pikon foo foo foo foo foo foo*
END
  end

  it "should support break" do
    rak(%Q[--eval 'break if $. == 2'], :ansi => '*').should == t=<<END
*dir1/bar.rb*
   1|*

*foo.rb*
   1|*

*quux.py*
   1|*quux quux quux quux Virgon quux quux*

*Rakefile*
   1|*rakefile rakefile Canceron rakefile*

*shebang*
   1|*#!/usr/bin/env ruby*
END
  end

  it "should support highlighting" do
    rak(%Q[--eval 'next unless $_ =~ /Caprica/'], :ansi => '*').should == t=<<END
*foo.rb*
   3|foo foo foo *Caprica* foo foo foo
END
  end

  it "should support ranges" do
    rak(%Q[--eval 'next unless $_[/Capsicum/]..$_[/Pikon/]'], :ansi => '*').should == t=<<END
*foo.rb*
   4|*foo Capsicum foo foo foo foo foo*
   5|*
   6|foo foo foo foo foo *Pikon* foo foo
END
  end

  it "should support next and contexts" do
    rak(%Q[-C 2 --eval 'next unless $_ =~ /Pikon/'], :ansi => '*').should == t=<<END
*dir1/bar.rb*
   1|
   2|bar bar bar bar *Pikon* bar
   3| 
   4|
   7|
   8|
   9|bar bar *Pikon* bar bar bar

*foo.rb*
   4|foo Capsicum foo foo foo foo foo
   5|
   6|foo foo foo foo foo *Pikon* foo foo
   7|
   8|foo *Pikon* foo foo foo foo foo foo
   9|
  10|foo foo Six foo foo foo Six foo
END
  end

  it "should support break and contexts (and matches past break should get no highlighting)" do
    rak(%Q[-C 2 --eval 'next unless $_[/Pikon/]...(break; nil)'], :ansi => '*').should == t=<<END
*dir1/bar.rb*
   1|
   2|bar bar bar bar *Pikon* bar
   3| 
   4|

*foo.rb*
   4|foo Capsicum foo foo foo foo foo
   5|
   6|foo foo foo foo foo *Pikon* foo foo
   7|
   8|foo Pikon foo foo foo foo foo foo
END
  end

  it "should support $_ transformations" do
    rak(%Q[--eval '$_=$_.reverse; next unless $_ =~ /oof/'], :ansi => '*').should == t=<<END
*foo.rb*
   3|*oof* oof oof acirpaC oof oof oof
   4|*oof* oof oof oof oof mucispaC oof
   6|*oof* oof nokiP oof oof oof oof oof
   8|*oof* oof oof oof oof oof nokiP oof
  10|*oof* xiS oof oof oof xiS oof oof
  11|*oof* oof oof xiS oof oof oof oof
  13|*oof* oof oof nonemeG oof oof oof
END
  end

  it "should support multiple matches" do
    rak(%Q[--eval 'next unless $_ =~ /Pikon/; $_.scan(/\\b\\w{3}\\b/){ matches << $~ }'], :ansi => '*').should == t=<<END
*dir1/bar.rb*
   2|*bar* *bar* *bar* *bar* Pikon *bar*
   9|*bar* *bar* Pikon *bar* *bar* *bar*

*foo.rb*
   6|*foo* *foo* *foo* *foo* *foo* Pikon *foo* *foo*
   8|*foo* Pikon *foo* *foo* *foo* *foo* *foo* *foo*
END
  end
end

## Other things --eval could support:
# * per file   BEGIN{} END{}
# * global     BEGIN{} END{}
# * better way to highlight multiple matches
# 
# There's also redo but I cannot think of any sensible use
# (especially if $_ won't persist between runs)
# (also redo in -nl/-pl is broken)
