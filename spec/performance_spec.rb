

require File.dirname(__FILE__) + "/spec_helpers"

def time_command(n, command)
  times = []
  n.times do
    s = Time.now
    %x{#{command}}
    e = Time.now
    times << e-s
  end
  times.inject{|m, o| m+o}.to_f/n.to_f
end

describe "Rak", "performance (includes slow tests)" do 
  it "should search through a large body of text quickly" do
    av = time_command(2, "rak foo /usr/local/lib/ruby/gems/1.8/gems/")
    puts "  time:#{av}"
  end
  
  it "should start up quickly" do
    av = time_command(20, "rak foo")
    puts "  time:#{av}"
  end
end

describe "Ack", "performance (includes slow tests)" do 
  it "should search through a large body of text quickly" do
    av = time_command(2, "ack foo /usr/local/lib/ruby/gems/1.8/gems/")
    puts "  time:#{av}"
  end
  
  it "should start up quickly" do
    av = time_command(20, "ack foo")
    puts "  time:#{av}"
  end
end
