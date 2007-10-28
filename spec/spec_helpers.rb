
def strip_ansi(str)
  str.gsub /\033\[\d+m/, ""
end

def asterize_ansi(str)
  str.gsub /(\033\[\d+m)+/, "*"
end

def exe(str)
  sys(str+">tmp")
  File.read("tmp")
end

FileUtils.cd("spec/example")
