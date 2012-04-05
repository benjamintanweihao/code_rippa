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
	# dir_path			- The directory path
	# syntax				- The syntax to perform parsing/syntax highlighting. 
	#									Note the the syntax should be supported by code_rippa.
	# excluded_exts - An Array of extensions to ignore during parsing. 
	# 
	# Examples
	#
	#		parse("~/code/ruby/some_folder_or_file", "space_cadet", "ruby")
	#
	# Returns nothing 
	def self.parse(path, theme)
	  output = ""
	  begin
	    if FileTest.file?(path)
  	    output = parse_file(path, theme)
      else
        pbar		 = Progressbar.new("Rippin'", Dir["**/*"].length)
        counter	 = 0					

        Find.find path do |p|		  
      		depth = p.to_s.count('/')

      		if File.basename(p)[0] == ?.
    				Find.prune
    			else    			  
  					output << bookmark(p, depth, counter) if bookmarkable?(p, source_syntax(p))
  			    output << parse_file(p, theme)
    		  end
    		  counter += 1
  				pbar.inc
    		end
    		pbar.finish
  	  end
      
  	  outfile = File.open('out.tex', 'w')  	  
  	  output  = preamble(theme) << output << postscript
  	  outfile.write output

  	  puts completed_message(path, File.expand_path(outfile))
  		
	  rescue Exception => e
	    puts e.backtrace
	  end
	end
	
	
	# Parses the given file, and writes the output file (out.tex)
	# into the current directory.
	# 
	# path					- The file path
	# syntax				- The syntax to perform parsing/syntax highlighting. 
	#									Note the the syntax should be supported by code_rippa.
	# excluded_exts - An Array of extensions to ignore during parsing. 
	# 
	# Examples
	#
	#		parse_file("~/code/ruby/some_folder/some_file.rb", "space_cadet", "ruby")
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
	
	def self.wrap_file(path, width)
	  wrapped_output = ""
	  IO.readlines(path).each { |line| wrapped_output << wrap(line, width) }
	  wrapped_output
	end

	def self.wrap(text, width) 
    text.gsub(/(.{1,#{width}})( +|$\n?)|(.{1,#{width}})/, "\\1\\3\n")
  end
	
	def self.max_width(path)
    IO.readlines(path).collect { |x| x.length }.max	 
	end
	
	def self.source_syntax(path)
	  syntax = ""
	  if FileTest.file?(path) and not File.binary?(path)
	    language = LanguageSniffer.detect(path).language
      syntax   = language.name.downcase if language
    end
    syntax
	end
	
	def self.syntax_path
		Uv.syntax_path
	end
	
	# Returns an Array of supported syntaxes. This is done by parsing 
	# all the file names in the syntax folder.
	#
	# Examples
	#
	#		supported_syntax 
	#		# => ['ruby','prolog'] 
	#
	# Returns an Array of supported syntaxes 
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
	
	# Returns an Array of supported languages. This is done by parsing 
	# all the file names in the syntax folder.
	#
	# Examples
	#
	#		supported_langs 
	#		# => ['Ruby','Prolog'] 
	#
	# Returns an Array of supported languages
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
	
	# Returns an Array of file extensions that is supported by code_rippa 
	#
	# Examples
	#
	#		supported_langs 
	#		# => ['rb', 'Gemfile', 'erb'] 
	#
	# Returns an Array of supported extensions.
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
	
	def self.bookmark(path, depth, counter)
	  "\\pdfbookmark[#{depth-2}]{#{File.basename(path).gsub('_','\_').gsub('%','\%')}}{#{counter}}\n"
	end

	# Returns True if path should be bookmarked in the output TEX/PDF document.
	#
	# path					- The file/directory path
	# syntax				- The syntax to perform parsing/syntax highlighting. 
	#									Note the the syntax should be supported by code_rippa.
	# excluded_exts - An Array of extensions to ignore during parsing.
	#
	#
	# Examples
	#
	#		bookmarkable?("hello.rb", "ruby", []) 
	#		# => true 
	#
	#		bookmarkable?("hello.rb", "ruby", ["rb", "html"]) 
	#		# => false
	#
	#		bookmarkable?("hello.klingon", "klingon", []) 
	#		# => false
	#
	# Returns True if path should be bookmarked.
	def self.bookmarkable?(path, syntax, excluded_exts=[])
		if FileTest.directory?(path)
			true
		else
			src_ext = File.extname(path)[1..-1]
			if File.basename(path) == "out.tex"
				false
			elsif excluded_exts.include?(src_ext)
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
	# path					- The file. (directories will return false.)
	# syntax				- The syntax to perform parsing/syntax highlighting. 
	#									Note the the syntax should be supported by code_rippa.
	# excluded_exts - An Array of extensions to ignore during parsing.
	#
	#
	# Examples
	#
	#		rippable?("hello.rb", "ruby", []) 
	#		# => true 
	#
	#		rippable?("~/code/", "ruby", []) 
	#		# => false
	#
	#		rippable?("hello.rb", "ruby", ["rb", "html"]) 
	#		# => false
	#
	#		rippable?("hello.klingon", "klingon", []) 
	#		# => false
	#
	# Returns true if path should be ripped.
	def self.rippable?(path, syntax, excluded_exts=[])
		if FileTest.directory?(path)
			false
		else
			src_ext = File.extname(path)[1..-1]
			if excluded_exts.include? src_ext
				false
			elsif supported_exts.include?(src_ext)
				true
			else
				false
			end
		end
	end

	# Returns the hex color code of the page color. This is done by looking at
	# the *.render file of the selected theme.
	#
	# theme - The selected theme.
	# 
	# Examples
	#
	#		page_color('made_of_code') 
	#		# => "E8E8E8"
	#
	# Returns an String containing the hex color code of the page.
  def self.page_color(theme)
    f = YAML.load(File.read("#{Uv.render_path}/latex/#{theme}.render"))           
    /([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})/.match(f['listing']['begin'].split('\\')[3]).to_s
  end
  
  # Heading of each new file
  #
  def self.heading(path)
    "\\textcolor{headingcolor}{\\textbf{\\texttt{#{path.gsub('_','\_').gsub('%','\%')}}}}\\\\\n" + 
		"\\textcolor{headingcolor}{\\rule{\\linewidth}{1.0mm}}\\\\\n"
  end

	# Returns the hex color code of the heading. This is done by looking at
	# the *.render file of the selected theme, and then inverting the page color.
	# The heading is present at the top of each new document in the output 
	# TEX/PDF file.
	#
	# theme - The selected theme.
	# 
	# Examples
	#
	#		heading_color('made_of_code') 
	#		# => "E8E8E8"
	#
	# Returns an String containing the hex color code of the heading.
  def self.heading_color(theme)
    c = Color::RGB.from_html(page_color(theme))
    Color::RGB.new(255-c.red, 255-c.green, 255- c.blue).html.gsub("#","").upcase   
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
	 	msg =	 "Completed successfully.\n".color(:green)
		msg << "Output file written to: "
		msg << "#{out_path}\n".color(:yellow)
		msg << "Now run "
		msg << "pdflatex -interaction=batchmode #{out_path}".color(:red)
		msg << " ** TWICE ** " if FileTest.directory?(in_path)
	  msg << "to generate PDF."
	end
	
end

# Sanity check
# CodeRippa.parse("/Users/rambo/code/ruby/code_rippa", "succulent")
# CodeRippa.parse("/Users/rambo/code/ruby/code_rippa/lib/code_rippa.rb", "amy")
