require 'fileutils'
require "pathname"

HERE = Pathname(__FILE__).parent.expand_path
require(HERE.join("../lib/rak"))

def strip_ansi(str)
  str.gsub /\033\[(\d;)?\d+m/, ""
end

def asterize_ansi(str)
  str.gsub /(\033\[(\d;)?\d+m)+/, "*"
end

def ruby_bin
  File.join(
    Config::CONFIG["bindir"],
    Config::CONFIG["ruby_install_name"] + Config::CONFIG["EXEEXT"]
  )
end

def rak(argstring="", opts={})
  begin
    bin_rak = HERE.parent.join("bin/rak")
    cmd = "#{ruby_bin} #{bin_rak} #{argstring}"
    cmd = "#{opts[:pipe]} | #{cmd}" if opts[:pipe]
    ENV['RAK_TEST'] = "true" unless opts[:test_mode] == false
    dir = opts[:dir] || HERE+"example"
    Dir.chdir(dir) do
      %x{#{cmd}}
    end    
  ensure
    ENV.delete('RAK_TEST')
  end
end

def sort_lines(str)
  str.split("\n").sort.join("\n")
end
