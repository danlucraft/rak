#encoding: utf-8
require "spec_helper"

describe "Rak", "with no options" do 
  it "prints all matches from files in the current directory" do
    rak("Cap.ic").should == <<-END
      *foo.rb*
         3|foo foo foo *Capric*a foo foo foo
         4|foo *Capsic*um foo foo foo foo foo
    END
  end
  
  it "prints all matches correctly" do
    rak("foo", :ansi => '').should == <<-END
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
    rak("Pikon").should == <<-END
      *dir1/bar.rb*
         2|bar bar bar bar *Pikon* bar
         9|bar bar *Pikon* bar bar bar

      *foo.rb*
         6|foo foo foo foo foo *Pikon* foo foo
         8|foo *Pikon* foo foo foo foo foo foo
    END
  end
  
  it "prints multiple matches in a line" do
    rak("Six").should == <<-END
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
    rak("Six | cat", :test_mode => false).should == <<-END
      foo.rb:10:foo foo Six foo foo foo Six foo
      foo.rb:11:foo foo foo foo Six foo foo foo
    END
  end

  it "searches shebangs for valid inputs" do
    rak("Aquaria").should == <<-END
      *shebang*
         3|goo goo goo *Aquaria* goo goo
    END
  end
  
  it "recognizes Makefiles and Rakefiles" do
    rak("Canceron").should == <<-END
      *Rakefile*
         1|rakefile rakefile *Canceron* rakefile
    END
  end
  
  it "matches unicode snowmen" do
    rak("☃", :dir => "example2").should == <<-END
      *snowman.txt*
         2|# *☃* 
    END
  end
end

describe "Rak", "with FILE or STDIN inputs" do
  it "should only search in given files or directories" do
    rak("Pikon foo.rb").should == <<-END
         6|foo foo foo foo foo *Pikon* foo foo
         8|foo *Pikon* foo foo foo foo foo foo
    END
    rak("Pikon dir1/", :ansi => '').should == <<-END
      dir1/bar.rb
         2|bar bar bar bar Pikon bar
         9|bar bar Pikon bar bar bar
    END
  end
  
  it "should search in STDIN by default if no files are specified" do
    rak("Aere", :pipe => "cat _darcs/baz.rb").should == <<-END
         2|baz baz baz *Aere*lon baz baz baz
    END
  end
  
  it "only searches STDIN when piped to" do
    rak("Cap", :pipe => "echo asdfCapasdf").should == <<-END
         1|asdf*Cap*asdf
    END
  end

  it "should either match on rax x or rak -v x" do
    (rak('"\A.{0,100}\Z" dir1/bar.rb').length + rak('-v "\A.{0,100}\Z" dir1/bar.rb').length).should > 0
  end
end

describe "Rak", "options" do
  it "prints only files with --files" do
    t = <<-END
      Rakefile
      quux.py
      dir1/bar.rb
      foo.rb
      shebang
    END
    rak("-f").lines.sort.should == t.lines.sort
  end
  
  it "prints a maximum number of matches if --max-count=x is specified" do
    rak("Cap.ic -m 1").should == <<-END
      *foo.rb*
         3|foo foo foo *Capric*a foo foo foo
    END
  end

  it "prints context of all matches if -m and -C are both specified, without further highlighting" do
    rak("Cap.ic -C2 -m 1").should == <<-END
      *foo.rb*
         1|
         2|
         3|foo foo foo *Capric*a foo foo foo
         4|foo Capsicum foo foo foo foo foo
         5|
    END
  end
  
  it "prints the evaluated output for --output" do
    rak("Cap --output='$&'", :ansi => '').should == <<-END
      Cap
      Cap
    END
  end

  it "-v -c displays correct counts even with multiple matches per line" do
    rak("-v -c bar").lines.sort.join.should == <<-END
      Rakefile:1
      dir1/bar.rb:7
      foo.rb:13
      quux.py:1
      shebang:3
    END
  end
  
  it "-c prints only the number of matches found per file" do
    rak("Pik -c").lines.sort.join.should  == <<-END
      dir1/bar.rb:2
      foo.rb:2
    END
  end
  
  it "-h suppresses filename and line number printing" do
    rak("Pik -h").should == <<-END
      bar bar bar bar *Pik*on bar
      bar bar *Pik*on bar bar bar
      foo foo foo foo foo *Pik*on foo foo
      foo *Pik*on foo foo foo foo foo foo
    END
  end
  
  it "ignores case with -i" do
    rak("six -i").should == <<-END
      *foo.rb*
        10|foo foo *Six* foo foo foo *Six* foo
        11|foo foo foo foo *Six* foo foo foo
    END
  end
  
  it "inverts the match with -v" do
    t1 = <<-END
      quux.py
         1|quux quux quux quux Virgon quux quux
    END
    t12 = <<-END
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
    t2 = <<-END
      foo.rb
         1|
         2|
         5|
         7|
         9|
        12|
    END
    t3 = <<-END
      shebang
         1|#!/usr/bin/env ruby
         2|
         3|goo goo goo Aquaria goo goo
    END
    t4 = <<-END
      Rakefile
         1|rakefile rakefile Canceron rakefile
    END
    r = rak("foo -v", :ansi => '')
    r.should include t1
    r.should include t12
    r.should include t2
    r.should include t3
    r.should include t4
    r.lines.length.should == 29
  end
  
  it "doesn't descend into subdirs with -n" do
    rak("Pikon -n", :ansi => '').should == <<-END
      foo.rb
         6|foo foo foo foo foo Pikon foo foo
         8|foo Pikon foo foo foo foo foo foo
    END
  end
  
  it "quotes meta-characters with -Q" do
    rak("Cap. -Q").should == ""
  end
  
  it "prints only the matching portion with -o" do
    rak("Cap -o", :ansi => '').should == <<-END
      Cap
      Cap
    END
  end
  
  it "matches whole words only with -w" do
    rak("'Cap|Hat' -w").should == ""
  end
  
   it "prints the file on each line with --nogroup" do
    rak("Cap --nogroup").should == <<-END
      *foo.rb*:3:foo foo foo *Cap*rica foo foo foo
      *foo.rb*:4:foo *Cap*sicum foo foo foo foo foo
    END
  end
  
  it "-l means only print filenames with matches" do
    rak("Caprica -l").should == <<-END
      foo.rb
    END
  end
  
  it "-L means only print filenames without matches" do
    t = <<-END
      quux.py
      dir1/bar.rb
      shebang
      Rakefile
    END
    rak("Caprica -L", :ansi => '').lines.sort.should == t.lines.sort
  end
  
  it "--passthru means print all lines whether matching or not" do
     t1 = <<-END
      quux quux quux quux Virgon quux quux
    END

    t2 = <<-END
      *foo.rb*
         3|foo foo foo *Caprica* foo foo foo
      foo Capsicum foo foo foo foo foo

      foo foo foo foo foo Pikon foo foo

      foo Pikon foo foo foo foo foo foo

      foo foo Six foo foo foo Six foo
      foo foo foo foo Six foo foo foo

      foo foo foo Gemenon foo foo foo
    END
    t3 = <<-END
      #!/usr/bin/env ruby

      goo goo goo Aquaria goo goo
    END
    r = rak("Caprica --passthru -n")
    r.should include t1
    r.should include t2
    r.should include t3
    r.lines.length.should < (t1+t2+t3).lines.length+5
  end
  
  it "--nocolour means do not colourize the output" do
    rak("Cap --nocolour").should == <<-END
      foo.rb
         3|foo foo foo Caprica foo foo foo
         4|foo Capsicum foo foo foo foo foo
    END
  end
  
  it "-a means to search every file" do
    rak("Libris -a").should == <<-END
      *qux*
         1|qux qux qux *Libris* qux qux qux
    END
  end
  
  it "--ruby means only ruby files" do
    rak("Virgon --ruby").should == ""
  end
  
  it "--python means only python files" do
    rak("Cap --python").should == ""
  end
  
  it "--noruby means exclude ruby files" do
    rak("Cap --noruby").should == ""
  end
  
  it "--type=ruby means only ruby files" do
    rak("Virgon --type=ruby").should == ""
  end
  
  it "--type=python means only python files" do
    rak("Cap --type=python").should == ""
  end
  
  it "--type=noruby means exclude ruby files" do
    rak("Cap --type=noruby").should == ""
  end
  
  it "--sort-files" do
    rak("-f --sort-files").should == <<-END
      dir1/bar.rb
      foo.rb
      quux.py
      Rakefile
      shebang
    END
  end
  
  it "--follow means follow symlinks" do 
    rak("Sagitarron --follow", :ansi => '').should == <<-END
      corge.rb
         1|corge corge corge Sagitarron corge

      ln_dir/corge.rb
         1|corge corge corge Sagitarron corge
    END
  end
  
  it "-A NUM means show NUM lines after" do 
    rak("Caps -A 2", :ansi => '').should == <<-END
      foo.rb
         4|foo Capsicum foo foo foo foo foo
         5|
         6|foo foo foo foo foo Pikon foo foo
    END
  end
  
  it "-A should work when there are matches close together" do 
    rak("foo -A 2", :ansi => '').should == <<-END
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
    rak("Caps -B 2", :ansi => '').should == <<-END
      foo.rb
         2|
         3|foo foo foo Caprica foo foo foo
         4|foo Capsicum foo foo foo foo foo
    END
  end
  
  it "-C means show 2 lines before and after" do 
    rak("Caps -C", :ansi => '').should == <<-END
      foo.rb
         2|
         3|foo foo foo Caprica foo foo foo
         4|foo Capsicum foo foo foo foo foo
         5|
         6|foo foo foo foo foo Pikon foo foo
    END
  end
  
  it "-C 1 means show 1 lines before and after" do 
    rak("Caps -C 1", :ansi => '').should == <<-END
      foo.rb
         3|foo foo foo Caprica foo foo foo
         4|foo Capsicum foo foo foo foo foo
         5|
    END
  end
  
  it "-C works correctly for nearby results" do
    rak("Pik -g foo -C", :ansi => '').should == <<-END
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
    rak("Pikon -g f.o").should == <<-END
      *foo.rb*
         6|foo foo foo foo foo *Pikon* foo foo
         8|foo *Pikon* foo foo foo foo foo foo
    END
  end

  it "-k REGEX only searches in files not matching REGEX" do
    rak("Pikon -k f.o").should == <<-END
      *dir1/bar.rb*
         2|bar bar bar bar *Pikon* bar
         9|bar bar *Pikon* bar bar bar
    END
  end
  
  it "-x means match only whole lines" do
    rak("Cap -x").should == ""
    rak('"foo|goo" -x').should == ""
    rak('"(foo )+Cap\w+( foo)+" -x').should == <<-END
      *foo.rb*
         3|*foo foo foo Caprica foo foo foo*
         4|*foo Capsicum foo foo foo foo foo*
    END
  end

  it "-s means match only at the start of a line" do
    rak('-s "foo Cap|Aquaria"').should == <<-END
      *foo.rb*
         4|*foo Cap*sicum foo foo foo foo foo
    END
  end

  it "-e means match only at the end of a line" do
    rak('-e "Aquaria|kon foo foo"').should == <<-END
      *foo.rb*
         6|foo foo foo foo foo Pi*kon foo foo*
    END
  end
  
  it "should not recurse down '..' when used with . " do
    rak("foo .", :dir=>HERE+"example/dir1").should == ""
  end
end

describe "Rak", "with combinations of options" do
  it "should process -c -v " do
    t1=<<-END
      quux.py:1
      dir1/bar.rb:7
      foo.rb:11
      shebang:3
      Rakefile:1
    END
    rak("Pikon -c -v", :ansi => '').lines.sort.should == t1.lines.sort
  end

  it "-h and redirection" do
    rak("Pik -h | cat", :test_mode => false).should == <<-END
      bar bar bar bar Pikon bar
      bar bar Pikon bar bar bar
      foo foo foo foo foo Pikon foo foo
      foo Pikon foo foo foo foo foo foo
    END
  end
end

describe "Rak", "with --eval" do 
  it "should support next" do
    rak(%Q[--eval 'next unless $. == $_.split.size']).should == <<-END
      *foo.rb*
         8|*foo Pikon foo foo foo foo foo foo*
    END
  end

  it "should support break" do
    rak(%Q[--eval 'break if $. == 2']).should == <<-END
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
    rak(%Q[--eval 'next unless $_ =~ /Caprica/']).should == <<-END
      *foo.rb*
         3|foo foo foo *Caprica* foo foo foo
    END
  end

  it "should support ranges" do
    rak(%Q[--eval 'next unless $_[/Capsicum/]..$_[/Pikon/]']).should == <<-END
      *foo.rb*
         4|*foo Capsicum foo foo foo foo foo*
         5|*
         6|foo foo foo foo foo *Pikon* foo foo
    END
  end

  it "should support next and contexts" do
    rak(%Q[-C 2 --eval 'next unless $_ =~ /Pikon/']).should == <<-END
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
    rak(%Q[-C 2 --eval 'next unless $_[/Pikon/]...(break; nil)']).should == <<-END
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
    rak(%Q[--eval '$_=$_.reverse; next unless $_ =~ /oof/']).should == <<-END
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
    rak(%Q[--eval 'next unless $_ =~ /Pikon/; $_.scan(/\\b\\w{3}\\b/){ matches << $~ }']).should == <<-END
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
