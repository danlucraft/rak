rak
http://rubyforge.org/projects/rak
Daniel Lucraft (http://danlucraft.com/blog/)

== DESCRIPTION:

Replacement for grep. Recursively scans directories to match a given
Ruby regular expression. Prints highlighted results.

Based on the Perl tool 'ack' by Andy Lester.

Examples with similar grep:
 
  $ rak pattern
  $ grep pattern $(find . | grep -v .svn)

  $ rak --ruby pattern
  $ grep pattern $(find . -name '*.rb' | grep -v .svn)

== FEATURES/PROBLEMS:
  
* Ruby regular expression syntax (uses oniguruma gem if installed).
* Highlighted output.
* Automatically recurses down the current directory or any given
  directories.
* Skips version control directories, backups like '~' and '#' and your
* ruby project's pkg directory.
* Allows inclusion and exclusion of files based on types.
* Many options similar to grep.

== SYNOPSIS:

See 'rak --help' for usage information.

== REQUIREMENTS:

* Ruby

== INSTALL:

* gem install rak

== LICENSE:

(The MIT License)

Copyright (c) 2007 Daniel Lucraft

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
