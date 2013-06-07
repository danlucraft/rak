require 'fileutils'
require 'rbconfig'
require "pathname"

HERE = Pathname(__FILE__).parent.expand_path
require HERE.join("../lib/rak").to_s

# Symlinks can't be shipped in the gem
if not File.symlink?('spec/example/ln_dir')
  File.symlink('_darcs/', 'spec/example/ln_dir')
end
if not File.symlink?('spec/example/corge.rb')
  File.symlink('_darcs/corge.rb', 'spec/example/corge.rb')
end

class String
  def shell_escape
    return "''" if empty?
    return dup unless self =~ /[^0-9A-Za-z+,.\/:=@_-]/
    gsub(/(')|[^']+/) { $1 ? "\\'" : "'#{$&}'"}
  end

  def lines
    result = []
    each_line do |line|
      result << line
    end
    result
  end
end

def ruby_bin
  File.join(
    Config::CONFIG["bindir"],
    Config::CONFIG["ruby_install_name"] + Config::CONFIG["EXEEXT"]
  )
end

def bin_rak
  HERE.parent.join("bin/rak")
end

def rak(args="", opts={})
  begin
    unless args.is_a?(String)
      args = args.map{|str| str.shell_escape}.join(" ")
    end
    cmd = "#{ruby_bin} #{bin_rak} #{args}"
    cmd = "#{opts[:pipe]} | #{cmd}" if opts[:pipe]
    ENV['RAK_TEST'] = "true" unless opts[:test_mode] == false
    if opts[:dir]
      dir = HERE + opts[:dir]
    else
      dir = HERE + "example"
    end
    output = Dir.chdir(dir) do
      %x{#{cmd}}
    end
    output = output.gsub(/(?:\033\[(?:\d;)?\d+m)+/, opts[:ansi]||'*')
    output.gsub(/^(?!$)/, "      ")
  ensure
    ENV.delete('RAK_TEST')
  end
end
