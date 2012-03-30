require 'uv'
require 'find'
require 'code_rippa/uv_overrides'
require 'code_rippa/version'
require 'ansi/progressbar'
require 'rainbow'
include ANSI


YAML::ENGINE.yamler = 'syck'

module CodeRippa
  
  @@supported_syntax = nil
  @@supported_ext = nil
  
  # Parses the given file, and writes the output file (out.tex)
  # into the current directory.
  # 
  # path          - The file path
  # syntax        - The syntax to perform parsing/syntax highlighting. 
  #                 Note the the syntax should be supported by code_rippa.
  # excluded_exts - An Array of extensions to ignore during parsing. 
  # 
  # Examples
	#
	#   rip_dir("~/code/ruby/some_folder/some_file.rb", "space_cadet", "ruby", [])
	#
  # Returns nothing.
	def self.rip_file(path, theme, syntax)
		begin 
			srcfile = File.read(path)
			src_ext = File.extname(path)[1..-1]					
		  outfile = File.open('out.tex', 'w') 
			outfile.write preamble theme
			outfile.write "\\textcolor{headingcolor}{\\textbf{\\texttt{#{path.gsub('_','\_').gsub('%','\%')}}}}\\\\\n"
			outfile.write "\\textcolor{headingcolor}{\\rule{\\linewidth}{1.0mm}}\\\\\n"
			outfile.write Uv.parse(srcfile, 'latex', syntax, true, theme) 
			outfile.write endtag
			
			msg =  "Completed successfully.\n".color(:green)
  		msg << "Output file written to: "
  		msg << "#{File.expand_path(outfile)}\n".color(:yellow)
  		msg << "Now run "
      msg << "pdflatex #{File.expand_path(outfile)} ".color(:red)
      msg << "** TWICE ** to generate PDF."
      puts msg
      outfile.close
		rescue Exception => e
			puts e
		end
	end

  # Parses the given directory, and writes the output file (out.tex)
  # into the current directory.
  # 
  # dir_path      - The directory path
  # syntax        - The syntax to perform parsing/syntax highlighting. 
  #                 Note the the syntax should be supported by code_rippa.
  # excluded_exts - An Array of extensions to ignore during parsing. 
  # 
  # Examples
	#
	#   rip_dir("~/code/ruby/some_folder", "space_cadet", "ruby", [])
	#
  # Returns nothing.
	def self.rip_dir(dir_path, theme, syntax, excluded_exts = [])
	  pbar     = Progressbar.new("Rippin'".color(:blue), Dir["**/*"].length)
		counter  = 0					
		outfile  = File.open('out.tex', 'w') 
		
		outfile.write preamble theme
		 Find.find dir_path do |path|
			depth = path.to_s.count('/')
			if File.basename(path)[0] == ?. or File.basename(path) == "out.tex"
				Find.prune
			else
				begin
					is_rippable = rippable?(path, syntax, excluded_exts)
					if is_rippable
						outfile.write "\\textcolor{white}{\\textbf{\\texttt{#{path.gsub('_','\_').gsub('%','\%')}}}}\\\\\n"
						outfile.write "\\textcolor{white}{\\rule{\\linewidth}{1.0mm}}\\\\\n"
					end
					
					if bookmarkable?(path, syntax, excluded_exts)		
						outfile.write "\\pdfbookmark[#{depth-2}]{#{File.basename(path).gsub('_','\_').gsub('%','\%')}}{#{counter}}\n"
					end
					
					if is_rippable
						outfile.write Uv.parse(File.read(path), 'latex', syntax, true, theme) 
						outfile.write "\\clearpage\n"
					end
				rescue Exception => e
					puts e
				end
				counter += 1
			end
			pbar.inc
		end
		
		outfile.write endtag
		pbar.finish
		
		msg =  "Completed successfully.\n".color(:green)
		msg << "Output file written to: "
		msg << "#{File.expand_path(outfile)}\n".color(:yellow)
		msg << "Now run "
    msg << "pdflatex #{File.expand_path(outfile)} ".color(:red)
    msg << "** TWICE ** to generate PDF."
    puts msg
		
		outfile.close
	end
															
	private	
		def self.syntax_path
			Uv.syntax_path
		end
		
		# Returns an Array of supported syntaxes. This is done by parsing 
		# all the file names in the syntax folder.
		#
		# Examples
		#
		#   supported_syntax 
		#   # => ['ruby','prolog'] 
		#
		# Returns an Array of supported languages	
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
		#   supported_langs 
		#   # => ['Ruby','Prolog'] 
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
		#   supported_langs 
		#   # => ['rb', 'Gemfile', 'erb'] 
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

    # Returns True if path should be bookmarked in the output TEX/PDF document.
    #
    # path          - The file/directory path
    # syntax        - The syntax to perform parsing/syntax highlighting. 
    #                 Note the the syntax should be supported by code_rippa.
    # excluded_exts - An Array of extensions to ignore during parsing.
    #
    #
    # Examples
		#
		#   bookmarkable?("hello.rb", "ruby", []) 
		#   # => true 
		#
		#   bookmarkable?("hello.rb", "ruby", ["rb", "html"]) 
		#   # => false
		#
		#   bookmarkable?("hello.klingon", "klingon", []) 
		#   # => false
		#
    # Returns True if path should be bookmarked.
		def self.bookmarkable?(path, syntax, excluded_exts)
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
    # path          - The file. (directories will return false.)
    # syntax        - The syntax to perform parsing/syntax highlighting. 
    #                 Note the the syntax should be supported by code_rippa.
    # excluded_exts - An Array of extensions to ignore during parsing.
    #
    #
    # Examples
		#
		#   rippable?("hello.rb", "ruby", []) 
		#   # => true 
		#
		#   rippable?("~/code/", "ruby", []) 
		#   # => false
		#
		#   rippable?("hello.rb", "ruby", ["rb", "html"]) 
		#   # => false
		#
		#   rippable?("hello.klingon", "klingon", []) 
		#   # => false
		#
    # Returns true if path should be ripped.
		def self.rippable?(path, syntax, excluded_exts)
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
		#   page_color('moc') 
		#   # => "E8E8E8"
		#
    # Returns an String containing the hex color code of the page.
		def self.page_color(theme)
			f = YAML.load(File.read("#{Uv.render_path}/latex/#{theme}.render"))						
			/([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})/.match(f['listing']['begin'].split('\\')[3]).to_s
		end
	
	  # Returns the hex color code of the heading. This is done by looking at
    # the *.render file of the selected theme. The heading is present at 
    # the top of each new document in the output TEX/PDF file.
    #
    # theme - The selected theme.
    # 
    # Examples
		#
		#   heading_color('moc') 
		#   # => "E8E8E8"
		#
    # Returns an String containing the hex color code of the heading.
		def self.heading_color(theme)
			f = YAML.load(File.read("#{Uv.render_path}/latex/#{theme}.render"))						
			/([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})/.match(f['listing']['begin'].split('\\')[2]).to_s
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
	
		def self.endtag
			"\\end{document}\n"
		end
end