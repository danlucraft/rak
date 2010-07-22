
require 'fileutils'

HERE = File.expand_path(File.dirname(__FILE__))

def strip_ansi(str)
  str.gsub /\033\[(\d;)?\d+m/, ""
end

def asterize_ansi(str)
  str.gsub /(\033\[(\d;)?\d+m)+/, "*"
end

def exe(str)
  sys(str+">tmp")
  File.read("tmp")
end

def rak_bin
  Config::CONFIG["bindir"] + "/ruby #{File.dirname(__FILE__) + "/../bin/rak"}"
end

def rak(argstring)
  cmd = "#{rak_bin} #{argstring}"
  result = %x{#{cmd}}
 # p [:result, result]
  result
end

FileUtils.cd("spec/example")

def sort_lines(str)
  str.split("\n").sort.join("\n")
end
