require 'rubygems'
require 'find'
require 'uv'

YAML::ENGINE.yamler= 'syck'

module Uv

end


preamble = <<END
\\documentclass[a4paper,landscape]{article}
\\usepackage{xcolor}
\\usepackage{colortbl}
\\usepackage{longtable}
\\usepackage[left=0cm,top=0cm,right=0cm,bottom=0cm,nohead,nofoot]{geometry}
\\usepackage[T1]{fontenc}
\\usepackage[scaled]{beramono}
\\usepackage[bookmarksopen,bookmarksdepth=30]{hyperref}
\\definecolor{mycolor}{HTML}{090A1B}
\\pagecolor{mycolor}
\\begin{document}
\\setlength\\LTleft\\parindent
\\setlength\\LTright\\fill
END

endtag = <<END
\\end{document}
END


counter = 0

# path = "trivial.rb"
# 
# puts preamble
# puts Uv.parse(File.read(path),"latex","ruby", true, "moc") if path.match(/\.rb\Z/)
# puts endtag

puts preamble
Find.find('../ror/rails') do |path|
	depth = path.to_s.count("/")
	if File.basename(path)[0] == ?.
	      Find.prune
	elsif FileTest.directory?(path) or path.match(/\.rb\Z/)
		begin
			puts "\\pdfbookmark[#{depth-2}]{#{File.basename(path).gsub('_','\_').gsub('%','\%')}}{#{counter}}"					
			puts Uv.parse(File.read(path),"latex","ruby", true, "moc") if path.match(/\.rb\Z/)
		rescue Exception => e
			# ignore if something funky happens
		end
		counter += 1
	end
end
puts endtag