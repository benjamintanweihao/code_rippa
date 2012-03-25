require 'uv'
require 'find'
require 'linguist'
require '../lib/code_rippa/uv_overrides'

YAML::ENGINE.yamler= 'syck'

module CodeRippa
			
	def self.rip_file(path, theme, syntax, excluded_exts = [])
		outfile = File.open('out.tex', 'w') 
		
		begin 
			srcfile = File.read(path)
			src_ext = File.extname(path)[1..-1]
						
			unless excluded_exts.include? src_ext
				outfile.write preamble theme
				outfile.write "\\textcolor{headingcolor}{\\textbf{\\texttt{#{path.gsub('_','\_').gsub('%','\%')}}}}\\\\\n"
				outfile.write "\\textcolor{headingcolor}{\\rule{\\linewidth}{1.0mm}}\\\\\n"
				outfile.write Uv.parse(srcfile, 'latex', syntax, true, theme) 
				outfile.write endtag
				outfile.close
			else
				puts "Warning: #{path} not processed. Check arguments."
			end				
			
		rescue Exception => e
			puts e
		end
	end

	

	def self.rip_dir(dir_path, theme, syntax, excluded_exts = [])
			
		outfile = File.open('out.tex', 'w') 
		counter = 0		
		
		outfile.write preamble(theme)
		
		Find.find(dir_path) do |path|
			depth = path.to_s.count('/')
			if File.basename(path)[0] == ?.
				Find.prune
			else
				begin
					puts ">> #{path}"
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
		end
		outfile.write endtag
		outfile.close
	end
															
	private
	
		def self.usage
		 "Usage: code_rippa [options] file_or_directory"
		end
	
		def self.syntax_path
			Uv.syntax_path
		end
		
		def self.supported_syntax
			syntax = []
			
			Dir.foreach(syntax_path) do |f|
				if File.extname(f) == ".syntax"
					y = YAML.load(File.read "#{syntax_path}/#{f}")
					syntax << File.basename(f, '.*') 
				end
			end
			syntax
		end
		
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

	
		def self.supported_exts
			filetypes = []

			Dir.foreach(syntax_path) do |f|
				if File.extname(f) == ".syntax"
					y = YAML.load(File.read "#{syntax_path}/#{f}")
					filetypes += y["fileTypes"] if y["fileTypes"]
				end
			end
			filetypes
		end
	

		def self.bookmarkable?(path, syntax, excluded_exts)
			if FileTest.directory?(path)
				true
			else
				src_ext = File.extname(path)[1..-1]
				lang = Linguist::FileBlob.new(path).language
				lang = lang ? lang.name.downcase : ""

				if Linguist::FileBlob.new(path).binary?
					false
				elsif excluded_exts.include?(src_ext)
					false
				elsif supported_syntax.include? lang
					true
				else
					false
				end
			end
		end
	

		def self.rippable?(path, syntax, excluded_exts)
			if FileTest.directory?(path)
				false
			else
				src_ext = File.extname(path)[1..-1]
				lang = Linguist::FileBlob.new(path).language
				lang = lang ? lang.name.downcase : ""
				if Linguist::FileBlob.new(path).binary?
					false
				elsif excluded_exts.include? src_ext
					false
				elsif supported_syntax.include? lang
					true
				else
					false
				end
			end
		end


		def self.page_color(theme)
			f = YAML.load(File.read("#{Uv.render_path}/latex/#{theme}.render"))						
			/([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})/.match(f['listing']['begin'].split('\\')[3]).to_s
		end
	

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