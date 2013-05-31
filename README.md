### What is Rak

Rak is a grep replacement in pure Ruby. It accepts Ruby syntax regular 
expressions and automatically recurses directories, skipping .svn/, .cvs/, 
pkg/ and more things you don't care about. It is based on the Perl tool 
ack by Andy Lester.

### Original credits

Rak was originally implemented by Daniel Lucraft, whose blog may be found
at http://danlucraft.com/blog/. Full credits to the original version to
him. His project may be found at https://github.com/danlucraft/rak.

### This version of Rak

This is my improvement of the original implementation of Rak, for
stability, as well as UI improvements. I also added column handling so
that editors interacting with Rak, or otherwise, may point directly to
the line and word that was Rak'ed for. Column is only shown for the first
matching word, if there are multiple, for a given line. Finally, 
ignore-case mode is default, as I feel that such a case is more common.

### Gem and Installation

This is released as a Gem under rak-eugeneching. Hence, the easiest
way to install this fork of Rak is to do a:

    gem install rak-eugeneching

Alternatively, you may clone this Github project, and do a

    gem build rak.gemspec
    gem install rak-eugeneching-1.5.gem

to use the Gem by builing and installing it locally.

### Features
  
From original Rak:
  * Ruby regular expression syntax (uses oniguruma gem if installed).
  * Highlighted output.
  * Automatically recurses down the current directory or any given
    directories.
  * Skips version control directories, backups like '~' and '#' and your
  * ruby project's pkg directory.
  * Allows inclusion and exclusion of files based on types.
  * Many options similar to grep.

Added features:
  * Ignore case mode is default behaviour.
  * UI improvements, in terms of display, alignment and coloring
  * Detects and displays column of match
  * Various fixes

### Author

Eugene Ching (codejury)  
Email:   eugene@enegue.com  
Web:     www.codejury.com  
Twitter: @eugeneching  

### Licence

Note that the original Rak was released under the MIT license. This
version of Rak follows.

(The MIT License)

Copyright (c) 2013 Eugene Ching

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


