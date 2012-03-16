$: << File.expand_path(File.dirname(__FILE__))
require 'lib/code_rippa/uv_overrides.rb'
require 'rubygems'
require 'find'
require 'linguist'
require 'uv'

# Link to the theme file
# /Users/rambo/.rvm/rubies/ruby-1.9.3-p0/lib/ruby/1.9.1/psych.rb:154:in `parse': 
# (/Users/rambo/.rvm/rubies/ruby-1.9.3-p0/lib/ruby/gems/1.9.1/gems/
# spox-ultraviolet-0.10.5/lib/../render/latex/moc.render

YAML::ENGINE.yamler= 'syck'

@@preamble = <<END
\\documentclass[a4paper,landscape]{article}
\\usepackage{xcolor}
\\usepackage{colortbl}
\\usepackage{longtable}
\\usepackage[left=0cm,top=0.2cm,right=0cm,bottom=0.2cm,nohead,nofoot]{geometry}
\\usepackage[T1]{fontenc}
\\usepackage[scaled]{beramono}
\\usepackage[bookmarksopen,bookmarksdepth=30]{hyperref}
\\definecolor{mycolor}{HTML}{090A1B}
\\pagecolor{mycolor}
\\begin{document}
\\setlength\\LTleft\\parindent
\\setlength\\LTright\\fill
\\setlength{\\LTpre}{-10pt}
END

@@endtag = <<END
\\end{document}
END

class CodeRippa
	
	def self.rip(directory)
			
		f = File.new("out.tex", "w")
		counter = 0		
		
		f.write @@preamble
		Find.find(directory) do |path|
			depth = path.to_s.count("/")
			if File.basename(path)[0] == ?.
				Find.prune
			else
				begin
					unless FileTest.directory?(path) or Linguist::FileBlob.new(path).binary?
						f.write "\\textcolor{white}{\\textbf{\\texttt{#{path.gsub('_','\_').gsub('%','\%')}}}}\\\\"
						f.write "\\textcolor{white}{\\rule{\\linewidth}{1.0mm}}\\\\"
					end
					 	f.write "\\pdfbookmark[#{depth-2}]{#{File.basename(path).gsub('_','\_').gsub('%','\%')}}{#{counter}}"
					unless FileTest.directory? path or Linguist::FileBlob.new(path).binary?
						lang = Linguist::FileBlob.new(path).language.name.downcase
						f.write Uv.parse(File.read(path),"latex",lang, true)
					end					
					f.write "\\clearpage"
				rescue Exception => e
					# ignore if something nasty happens
				end
				counter += 1
			end
		end
		f.write @@endtag
		f.close
	end
	
end

CodeRippa.rip(ARGV[0])

