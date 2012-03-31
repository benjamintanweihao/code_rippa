require 'minitest/autorun'
require 'code_rippa'

describe CodeRippa do 
  
  def fixtures_path
    File.join(File.expand_path(File.open(".")), "test", "fixtures")
  end
  
  before do
    Dir.chdir("#{fixtures_path}") 
  end
  
  after do
    File.delete(File.expand_path("out.tex"))
    Dir.chdir("../..") 
  end
  
  describe ".rip_file" do
    it "should rip a file that is supported" do
      puts File.expand_path(File.open("."))
      CodeRippa.rip_file(File.join("#{File.expand_path(File.open("."))}", "hello.rb"), "moc", "ruby")
      f1 = File.open("out.tex")
      f2 = File.open("rip_file.tex")
      assert (f1.size - f2.size).abs < 300
    end
  end
  
  describe ".rip_dir" do
    it "should rip a directory that is supported" do
      CodeRippa.rip_dir("ruby_proj/", "moc", "ruby")
      f1 = File.open("out.tex")
      f2 = File.open("rip_dir.tex")
      assert (f1.size - f2.size).abs < 300
    end
  end
  
end