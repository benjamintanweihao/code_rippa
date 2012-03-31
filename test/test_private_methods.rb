require 'minitest/autorun'
require 'code_rippa'

describe CodeRippa do 
  
  def fixtures_path
    File.expand_path("../fixtures", __FILE__)
  end

  it "should return a heading color for every syntax file" do
    Uv.themes.each do |theme|
      assert_equal 6, CodeRippa.heading_color(theme).length 
    end
  end
  
  it "should return a page color for every syntax file" do
    Uv.themes.each do |theme|
      assert_equal 6, CodeRippa.page_color(theme).length 
    end
  end
  
  it "page color should not be the same as the heading color" do
    Uv.themes.each do |theme|
      refute_equal CodeRippa.heading_color(theme), CodeRippa.page_color(theme)
    end
  end
  
    
  describe ".rippable?" do
    
    it "should parse a file with an extension that is supported" do
      assert_equal true, CodeRippa.rippable?("#{fixtures_path}/hello.rb",  'moc', [])
      assert_equal true, CodeRippa.rippable?("#{fixtures_path}/hello.c",   'moc', [])
      assert_equal true, CodeRippa.rippable?("#{fixtures_path}/hello.cpp", 'moc', [])
      assert_equal true, CodeRippa.rippable?("#{fixtures_path}/hello.m",   'moc', [])
      assert_equal true, CodeRippa.rippable?("#{fixtures_path}/hello.s",   'moc', [])
      assert_equal true, CodeRippa.rippable?("#{fixtures_path}/hello.txt", 'moc', [])
      assert_equal true, CodeRippa.rippable?("#{fixtures_path}/hello.haml", 'moc', [])
      assert_equal true, CodeRippa.rippable?("#{fixtures_path}/hello.json", 'moc', [])
      assert_equal true, CodeRippa.rippable?("#{fixtures_path}/hello.py",     'moc', [])
      assert_equal true, CodeRippa.rippable?("#{fixtures_path}/hello.sh",     'moc', [])
      assert_equal true, CodeRippa.rippable?("#{fixtures_path}/hello.groovy", 'moc', [])
      assert_equal true, CodeRippa.rippable?("#{fixtures_path}/hello.php", 'moc', [])
    end
  
    it "should not parse a file with an extension that isn't supported" do
      assert_equal false, CodeRippa.rippable?("#{fixtures_path}/hello.vark",   'moc', [])    
      assert_equal false, CodeRippa.rippable?("#{fixtures_path}/hello.psd",  'moc', [])    
      assert_equal false, CodeRippa.rippable?("#{fixtures_path}/hello.ai",   'moc', [])    
      assert_equal false, CodeRippa.rippable?("#{fixtures_path}/hello.scala", 'moc', [])
    end
  
    it "should not parse a directory" do
      assert_equal false, CodeRippa.rippable?("#{fixtures_path}/", 'moc', [])    
    end
    
    it "should not parse a file that has an excluded extension" do
      assert_equal false, CodeRippa.rippable?("#{fixtures_path}/hello.rb", 'moc', ['rb'])
      assert_equal false, CodeRippa.rippable?("#{fixtures_path}/hello.c",  'moc', ['c'])
      assert_equal true, CodeRippa.rippable?("#{fixtures_path}/hello.cpp", 'moc', ['rb'])
    end
    
  end
  
  
  describe ".bookmarkable?" do
    
    it "should bookmark a directory" do
      assert_equal true, CodeRippa.bookmarkable?("#{fixtures_path}/", 'moc', [])    
    end
  
    it "should not bookmark a file that has an excluded extension" do
      assert_equal false, CodeRippa.bookmarkable?("#{fixtures_path}/hello.rb",  'moc', ['rb'])
      assert_equal false, CodeRippa.bookmarkable?("#{fixtures_path}/hello.c",   'moc', ['c'])
      assert_equal true,  CodeRippa.bookmarkable?("#{fixtures_path}/hello.cpp", 'moc', ['rb'])
    end
    
  end

end