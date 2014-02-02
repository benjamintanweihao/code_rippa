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
  
    
  # describe ".rippable?" do
    
  #   it "should parse a file with an extension that is supported" do
  #     assert_equal true, CodeRippa.rippable?("#{fixtures_path}/hello.rb",  'rubyblue')
  #     assert_equal true, CodeRippa.rippable?("#{fixtures_path}/hello.c",   'rubyblue')
  #     assert_equal true, CodeRippa.rippable?("#{fixtures_path}/hello.cpp", 'rubyblue')
  #     assert_equal true, CodeRippa.rippable?("#{fixtures_path}/hello.m",   'rubyblue')
  #     assert_equal true, CodeRippa.rippable?("#{fixtures_path}/hello.s",   'rubyblue')
  #     assert_equal true, CodeRippa.rippable?("#{fixtures_path}/hello.txt", 'rubyblue')
  #     assert_equal true, CodeRippa.rippable?("#{fixtures_path}/hello.haml", 'rubyblue')
  #     assert_equal true, CodeRippa.rippable?("#{fixtures_path}/hello.json", 'rubyblue')
  #     assert_equal true, CodeRippa.rippable?("#{fixtures_path}/hello.py",     'rubyblue')
  #     assert_equal true, CodeRippa.rippable?("#{fixtures_path}/hello.sh",     'rubyblue')
  #     assert_equal true, CodeRippa.rippable?("#{fixtures_path}/hello.groovy", 'rubyblue')
  #     assert_equal true, CodeRippa.rippable?("#{fixtures_path}/hello.php", 'rubyblue')
  #   end
  
  #   it "should not parse a file with an extension that isn't supported" do
  #     assert_equal false, CodeRippa.rippable?("#{fixtures_path}/hello.vark",   'rubyblue')    
  #     assert_equal false, CodeRippa.rippable?("#{fixtures_path}/hello.psd",  'rubyblue')    
  #     assert_equal false, CodeRippa.rippable?("#{fixtures_path}/hello.ai",   'rubyblue')    
  #     assert_equal false, CodeRippa.rippable?("#{fixtures_path}/hello.scala", 'rubyblue')
  #   end
  
  #   it "should not parse a directory" do
  #     assert_equal false, CodeRippa.rippable?("#{fixtures_path}/", 'rubyblue')    
  #   end
    
  #   it "should not parse a file that has an excluded extension" do
  #     assert_equal false, CodeRippa.rippable?("#{fixtures_path}/hello.rb", 'rubyblue')
  #     assert_equal false, CodeRippa.rippable?("#{fixtures_path}/hello.c",  'rubyblue')
  #     assert_equal true, CodeRippa.rippable?("#{fixtures_path}/hello.cpp", 'rubyblue')
  #   end
    
  # end
  
  
  # describe ".bookmarkable?" do
    
  #   it "should bookmark a directory" do
  #     assert_equal true, CodeRippa.bookmarkable?("#{fixtures_path}/", 'rubyblue')    
  #   end
  
  #   it "should not bookmark a file that has an excluded extension" do
  #     assert_equal false, CodeRippa.bookmarkable?("#{fixtures_path}/hello.rb",  'rubyblue', ['rb'])
  #     assert_equal false, CodeRippa.bookmarkable?("#{fixtures_path}/hello.c",   'rubyblue', ['c'])
  #     assert_equal true,  CodeRippa.bookmarkable?("#{fixtures_path}/hello.cpp", 'rubyblue', ['rb'])
  #   end
    
  # end

end