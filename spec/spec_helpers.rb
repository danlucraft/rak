require 'fileutils'
require "pathname"

class String
  def shell_escape
    return "''" if empty?
    return dup unless self =~ /[^0-9A-Za-z+,.\/:=@_-]/
    gsub(/(')|[^']+/) { $1 ? "\\'" : "'#{$&}'"}
  end
end

HERE = Pathname(__FILE__).parent.expand_path
require(HERE.join("../lib/rak"))

def ruby_bin
  File.join(
    Config::CONFIG["bindir"],
    Config::CONFIG["ruby_install_name"] + Config::CONFIG["EXEEXT"]
  )
end

def replace_ansi(str, replacement)
  if replacement
    str.gsub(/(?:\033\[(?:\d;)?\d+m)+/, replacement)
  else
    str
  end
end

def strip_ansi(str)
  replace_ansi(str, '')
end

def asterize_ansi(str)
  replace_ansi(str, '*')
end

def rak(args="", opts={})
  begin
    unless args.is_a?(String)
      args = args.map{|str| str.shell_escape}.join(" ")
    end
    bin_rak = HERE.parent.join("bin/rak")
    cmd = "#{ruby_bin} #{bin_rak} #{args}"
    cmd = "#{opts[:pipe]} | #{cmd}" if opts[:pipe]
    ENV['RAK_TEST'] = "true" unless opts[:test_mode] == false
    dir = opts[:dir] || HERE+"example"
    output = Dir.chdir(dir) do
      %x{#{cmd}}
    end
    replace_ansi(output, opts[:ansi])
  ensure
    ENV.delete('RAK_TEST')
  end
end

def sort_lines(str)
  str.split("\n").sort.join("\n")
end
