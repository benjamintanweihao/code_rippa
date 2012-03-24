$: << File.expand_path(File.dirname(__FILE__))
require 'uv'
require 'find'
require 'linguist'
require 'lib/code_rippa/uv_overrides.rb'


YAML::ENGINE.yamler= 'syck'

class CodeRippa
	
	THEME = "twilight"
	OUTFILE = "out.tex"
		
	def self.rip_file(infile, path, include_premable_endtags=false)
		begin
			infile.write preamble THEME
			infile.write "\\textcolor{headingcolor}{\\textbf{\\texttt{#{path.gsub('_','\_').gsub('%','\%')}}}}\\\\\n"
			infile.write "\\textcolor{headingcolor}{\\rule{\\linewidth}{1.0mm}}\\\\\n" 	
			infile.write Uv.parse(File.read(path), "latex", "ruby", true, THEME)	
			infile.write endtag
		rescue Exception => e
			print e.backtrace.join("\n")
		end
	end
	
	
	def self.rip(directory)
			
		f = File.new(OUTFILE, "w")
		counter = 0		
		
		f.write preamble(THEME)
		
		Find.find(directory) do |path|
			depth = path.to_s.count("/")
			if File.basename(path)[0] == ?.
				Find.prune
			else
				begin
					unless FileTest.directory?(path) or Linguist::FileBlob.new(path).binary?
						f.write "\\textcolor{white}{\\textbf{\\texttt{#{path.gsub('_','\_').gsub('%','\%')}}}}\\\\\n"
						f.write "\\textcolor{white}{\\rule{\\linewidth}{1.0mm}}\\\\\n"
					end
					 	
					f.write "\\pdfbookmark[#{depth-2}]{#{File.basename(path).gsub('_','\_').gsub('%','\%')}}{#{counter}}\n"
					
					unless FileTest.directory? path or Linguist::FileBlob.new(path).binary?
						if Linguist::FileBlob.new(path).language.name == "Ruby"
							# lang = Linguist::FileBlob.new(path).language.name.downcase
							f.write Uv.parse(File.read(path), "latex", "ruby", THEME)
						end
					end						
					f.write "\\clearpage\n"
				rescue Exception => e
					# ignore if something nasty happens
				end
				counter += 1
			end
		end
		f.write endtag
		f.close
	end
	
	private 
	
		def self.page_color(theme)
			f = YAML.load(File.read("#{Uv.render_path}/latex/#{theme}.render"))						
			/([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})/.match(f["listing"]["begin"].split("\\")[3]).to_s
		end
	
		def self.heading_color(theme)
			f = YAML.load(File.read("#{Uv.render_path}/latex/#{theme}.render"))						
			/([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})/.match(f["listing"]["begin"].split("\\")[2]).to_s
		end
	
		def self.preamble(theme)
			"\\documentclass[a4paper,landscape]{article}\n" +
			"\\pagestyle{empty}\n" +
			"\\usepackage{xcolor}\n" +
		  "\\usepackage{colortbl}\n" + 
			"\\usepackage{longtable}\n" +
			"\\usepackage[left=0cm,top=0.2cm,right=0cm,bottom=0.2cm,nohead,nofoot]{geometry}\n" +
			"\\usepackage[T1]{fontenc}\n" +
			"\\usepackage[scaled]{beramono}\n" +
			"\\usepackage[bookmarksopen,bookmarksdepth=20]{hyperref}\n" +
			"\\definecolor{pgcolor}{HTML}{#{page_color(theme)}}\n" +
			"\\definecolor{headingcolor}{HTML}{#{heading_color(theme)}}\n" +
			"\\pagecolor{pgcolor}\n" +
			"\\begin{document}\n" +
			"\\setlength\\LTleft\\parindent\n" +
			"\\setlength\\LTright\\fill\n" +
			"\\setlength{\\LTpre}{-10pt}\n"
		end
	
		def self.endtag
			"\\end{document}\n"
		end
	
end

# CodeRippa.rip(ARGV[0])

infile = File.new 'out.tex', 'w'
CodeRippa.rip_file infile, ARGV[0]
infile.close

