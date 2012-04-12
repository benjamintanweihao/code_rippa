require 'find'
require 'code_rippa/uv_overrides'
require 'code_rippa/version'
require 'ansi/progressbar'
require 'language_sniffer'
require 'rainbow'
require 'color'
require 'ptools'

include ANSI

YAML::ENGINE.yamler = 'syck'

module CodeRippa
  
  MAX_WIDTH          = 120
  @@supported_syntax = nil
  @@supported_ext    = nil
    
  # main entry point:
  # Parses the given directory/file, and writes the output file (out.tex)
  # into the current directory.
  # 
  # path          - The directory path
  # theme         - The selected theme
  # 
  # Examples
  #
  #   parse("~/code/ruby/some_folder_or_file", "space_cadet")
  #
  # Returns nothing 
  def self.parse(path, theme)
    # logfile = File.open('code_rippa.log', 'w')
    output  = ""
    
    if FileTest.file?(path)
      output = parse_file(path, theme)
    else
      pbar     = Progressbar.new("Rippin'", Dir["**/*"].length)
      counter  = 0          

      Find.find path do |p|     
        # logfile << "Parsing: #{p}\n"
        depth = p.to_s.count('/')

        if File.basename(p)[0] == ?.
          Find.prune
        else            
          output << bookmark(p, depth, counter) if bookmarkable?(p, source_syntax(p))
          begin
            output << parse_file(p, theme)
          rescue Exception => e
            # logfile << "* Failed: #{p}\n"
          end
        end
        counter += 1
        pbar.inc
      end
      pbar.finish
    end
    
    outfile = File.open('out.tex', 'w')     
    output  = preamble(theme) << output << postscript
    outfile.write output
    
    outfile.close
        
    # Run the 'pdflatex' command
    puts "=================================================="
    if pdflatex_installed?
      puts "pdflatex found!. Converting TeX -> PDF".color(:green)
      puts "Compiling [1/2]" 
      `pdflatex -interaction=batchmode #{File.expand_path(outfile)}`
      puts "Compiling [2/2]" 
      `pdflatex -interaction=batchmode #{File.expand_path(outfile)}` 

      # Cleanup
      %w[aux log out tex].each do |ext|  
        path = File.expand_path(outfile).gsub!('tex', ext) 
        FileUtils.rm path
      end
      puts completed_message(path, File.expand_path(outfile))
    else
      puts install_pdflatex_message "#{File.expand_path(outfile)}"
    end
    puts "=================================================="

  end
  
  
  # Parses the given file, and writes the output file (out.tex)
  # into the current directory.
  # 
  # path          - The file path
  # theme         - The selected theme
  # 
  # Examples
  #
  #   parse_file("~/code/ruby/some_folder/some_file.rb", "space_cadet")
  #
  # Returns a String of TeX output.
  def self.parse_file(path, theme)
    content = ""
    syntax  = source_syntax(path)
    
    if rippable?(path, syntax)
      content << heading(path)
      output  =  (max_width(path) <= MAX_WIDTH) ? File.read(path) : wrap_file(path, MAX_WIDTH)      
      content << Uv.parse(output, 'latex', syntax, true, theme)
      content << "\\clearpage\n"  
    end
    content
  end

                              
private 

  # Returns True if path should be bookmarked in the output TEX/PDF document.
  #
  # path          - The file/directory path
  # syntax        - The syntax to perform parsing/syntax highlighting. 
  #                 Note the the syntax should be supported by code_rippa.
  #
  # Examples
  #
  #   bookmarkable?("hello.rb", "ruby") 
  #   # => true 
  #
  #   bookmarkable?("hello.klingon", "klingon") 
  #   # => false
  #
  # Returns True if path should be bookmarked.
  def self.bookmarkable?(path, syntax)
    if FileTest.directory?(path)
      true
    else
      src_ext = File.extname(path)[1..-1]
      if File.basename(path) == "out.tex"
        false
      elsif supported_exts.include?(src_ext)
        true
      else
        false
      end
    end
  end

  # Returns True if path should be ripped as part of the output TEX file. 
  #
  # path          - The file. (directories will return false.)
  # syntax        - The syntax to perform parsing/syntax highlighting. 
  #                 Note the the syntax should be supported by code_rippa.
  #
  # Examples
  #
  #   rippable?("hello.rb", "ruby") 
  #   # => true 
  #
  #   rippable?("~/code/", "ruby") 
  #   # => false
  #
  #   rippable?("hello.klingon", "klingon") 
  #   # => false
  #
  # Returns true if path should be ripped.
  def self.rippable?(path, syntax)
    if FileTest.directory?(path)
      false
    else
      if supported_exts.include?(File.extname(path)[1..-1])
        true
      else
        false
      end
    end
  end
  
  # Places a PDF bookmark
  def self.bookmark(path, depth, counter)
    "\\pdfbookmark[#{depth-2}]{#{File.basename(path).gsub('_','\_').gsub('%','\%')}}{#{counter}}\n"
  end
  
  # Returns the maximum width (number of characters) in a given file
  def self.max_width(path)
    IO.readlines(path).collect { |x| x.length }.max  
  end
  
  # Returns the String of the wrapped text
  def self.wrap(text, width) 
    text.gsub(/(.{1,#{width}})( +|$\n?)|(.{1,#{width}})/, "\\1\\3\n")
  end
  
  # Returns the String of the wrapped file
  def self.wrap_file(path, width)
    wrapped_output = ""
    IO.readlines(path).each { |line| wrapped_output << wrap(line, width) }
    wrapped_output
  end
  
  # Returns the String of the source file. If not found, a blank String is returned.
  def self.source_syntax(path)
    syntax = ""
    language = ""
    if FileTest.file?(path) and not File.binary?(path)
      begin
        language = LanguageSniffer.detect(path).language
        syntax = language.name.downcase if language
      rescue Exception => e
      end
    end
    syntax
  end
  
  def self.syntax_path
    Uv.syntax_path
  end
  
  # Returns an Array of supported file extensions
  def self.supported_exts
    if @@supported_ext
      @@supported_ext
    else
      @@supported_ext = []
      Dir.foreach(syntax_path) do |f|
        if File.extname(f) == ".syntax"
          y = YAML.load(File.read "#{syntax_path}/#{f}")
          @@supported_ext += y["fileTypes"] if y["fileTypes"]
        end
      end
      @@supported_ext       
    end
  end
  
  # Returns an Array of supported languages.
  def self.supported_langs
    langs = []
    Dir.foreach(syntax_path) do |f|
      if File.extname(f) == ".syntax"
        y = YAML.load(File.read "#{syntax_path}/#{f}")
        langs << y["name"] if y["name"]
      end
    end
    langs
  end
  
  # Returns an Array of supported syntaxes. 
  def self.supported_syntax     
    if @@supported_syntax
      @@supported_syntax
    else  
      @@supported_syntax = []
      Dir.foreach(syntax_path) do |f|
        if File.extname(f) == ".syntax"
          @@supported_syntax << File.basename(f, '.*') 
        end
      end
    @@supported_syntax
    end
  end
  
  # Returns a String containing the heading of the parsed file.
  def self.heading(path)
    "\\textcolor{headingcolor}{\\textbf{\\texttt{#{path.gsub('_','\_').gsub('%','\%')}}}}\\\\\n" + 
    "\\textcolor{headingcolor}{\\rule{\\linewidth}{1.0mm}}\\\\\n"
  end

  # Returns the hex color code of the heading, which is the inverse of page color.
  def self.heading_color(theme)
    c = Color::RGB.from_html(page_color(theme))
    Color::RGB.new(255-c.red, 255-c.green, 255- c.blue).html.gsub("#","").upcase   
  end

  # Returns a String containing the hex color code of the page.
  def self.page_color(theme)
    f = YAML.load(File.read("#{Uv.render_path}/latex/#{theme}.render"))           
    /([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})/.match(f['listing']['begin'].split('\\')[3]).to_s
  end
  
  def self.preamble(theme)
    preamble = ''
    preamble << "\\documentclass[a4paper,landscape]{article}\n"
    preamble << "\\pagestyle{empty}\n"
    preamble << "\\usepackage{xcolor}\n"
    preamble << "\\usepackage{colortbl}\n"
    preamble << "\\usepackage{longtable}\n"
    preamble << "\\usepackage[left=0cm,top=0.2cm,right=0cm,bottom=0.2cm,nohead,nofoot]{geometry}\n"
    preamble << "\\usepackage[T1]{fontenc}\n"
    preamble << "\\usepackage[scaled]{beramono}\n"
    preamble << "\\usepackage[bookmarksopen,bookmarksdepth=20]{hyperref}\n"
    preamble << "\\definecolor{pgcolor}{HTML}{#{page_color(theme)}}\n"
    preamble << "\\definecolor{headingcolor}{HTML}{#{heading_color(theme)}}\n"
    preamble << "\\pagecolor{pgcolor}\n"
    preamble << "\\begin{document}\n"
    preamble << "\\setlength\\LTleft\\parindent\n"
    preamble << "\\setlength\\LTright\\fill\n"
    preamble << "\\setlength{\\LTpre}{-10pt}\n"
    preamble
  end

  def self.postscript
    "\\end{document}\n"
  end
  
  def self.completed_message(in_path, out_path)
    msg =  "Success!. ".color(:green)
    msg << "Output file written to: "
    msg << "#{out_path.gsub!('tex', 'pdf')}".color(:green)
  end

  def self.install_pdflatex_message(out_path)
    msg = "You do not have 'pdflatex' installed!\n".color(:red)
    msg << "Please install it at "
    msg << "http://www.tug.org/texlive'\n".color(:yellow)
    msg << "Output TEX file written to: "
    msg << "#{out_path}\n".color(:yellow)
  end

  def self.pdflatex_installed?
    cmd  = 'pdflatex'
    exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
    ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
      exts.each do |ext|
        exe = "#{path}/#{cmd}#{ext}"
        exe if File.executable? exe
        return exe
      end
    end
    nil  
  end
  
end

# Sanity check
# CodeRippa.parse("/Users/rambo/code/ruby/code_rippa", "succulent")
# CodeRippa.parse("/Users/rambo/code/ruby/code_rippa/lib/code_rippa.rb", "amy")
