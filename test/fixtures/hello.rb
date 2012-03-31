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

	# Parses the given directory, and writes the output file (out.tex)
	# into the current directory.
	# 
	# dir_path			- The directory path
	# syntax				- The syntax to perform parsing/syntax highlighting. 
	#									Note the the syntax should be supported by code_rippa.
	# excluded_exts - An Array of extensions to ignore during parsing. 
	# 
	# Examples
	#
	#		rip_dir("~/code/ruby/some_folder", "space_cadet", "ruby", [])
	#
	# Returns nothing.
	def self.rip_dir(dir_path, theme, syntax, excluded_exts = [])
		pbar		 = Progressbar.new("Rippin'".color(:blue), Dir["**/*"].length)
		counter	 = 0					
		outfile	 = File.open('out.tex', 'w') 
		
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
		
		msg =	 "Completed successfully.\n".color(:green)
		msg << "Output file written to: "
		msg << "#{File.expand_path(outfile)}\n".color(:yellow)
		msg << "Now run "
		msg << "pdflatex #{File.expand_path(outfile)} ".color(:red)
		msg << "** TWICE ** to generate PDF."
		puts msg
		
		outfile.close
	end
															
	private 
		
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

		def self.heading_color(theme)
			f = YAML.load(File.read("#{Uv.render_path}/latex/#{theme}.render"))						
			/([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})/.match(f['listing']['begin'].split('\\')[2]).to_s
		end

end