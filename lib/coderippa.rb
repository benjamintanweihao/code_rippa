require 'rubygems'
require 'find'
require 'uv'

YAML::ENGINE.yamler= 'syck'

module Uv
	@@set_table_columns = false
	def start_parsing name
    @stack       = [name]
    @string      = ""
    @line        = nil
    @line_number = 0
		if @@set_table_columns
    	print @render_options["document"]["begin"] if @headers
    	print @render_options["listing"]["begin"]
		end
  end

	def end_parsing name
    if @line
      print escape(@line[@position..-1].gsub(/\n|\r/, '')) 
      while @stack.size > 1
        opt = options @stack
        print opt["end"] if opt
        @stack.pop
      end
      print @render_options["line"]["end"]
      print "\n"
    end

    @stack.pop

		if @@set_table_columns 
    	print @render_options["listing"]["end"]
    	print @render_options["document"]["end"] if @headers
		else
			@@set_table_columns = false
		end
  end

end


preamble = <<END
\\documentclass[a4paper,landscape]{article}
\\usepackage{xcolor}
\\usepackage{colortbl}
\\usepackage{longtable}
\\usepackage[left=0cm,top=0cm,right=0cm,bottom=0.2cm,nohead,nofoot]{geometry}
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
path = "/Users/rambo/code/ruby/trivial.rb"

# puts preamble
# puts Uv.parse(File.read(path),"latex","ruby", true, "moc") if path.match(/\.rb\Z/)
# puts endtag

puts preamble
Find.find('/Users/rambo/code/ruby/ultraviolet') do |path|
	depth = path.to_s.count("/")
	if File.basename(path)[0] == ?.
	      Find.prune
	elsif FileTest.directory?(path) or path.match(/\.rb\Z/)
		begin
			puts "\\pdfbookmark[#{depth-2}]{#{File.basename(path).gsub('_','\_').gsub('%','\%')}}{#{counter}}"					
			puts Uv.parse(File.read(path),"latex","ruby", true, "moc") if path.match(/\.rb\Z/)
			puts "\\clearpage"
		rescue Exception => e
			# ignore if something funky happens
		end
		counter += 1
	end
end
puts endtag