$: << File.expand_path(File.dirname(__FILE__))
require 'uv'
require 'optparse'
require 'find'
require 'linguist'
require 'lib/code_rippa/uv_overrides.rb'


YAML::ENGINE.yamler= 'syck'

class CodeRippa
	
	THEME = 'moc'
	OUTFILE = 'out.tex'
		
	def self.rip_file(infile, path, theme, include_premable_endtags = false)
		begin
			infile.write preamble theme
			infile.write "\\textcolor{headingcolor}{\\textbf{\\texttt{#{path.gsub('_','\_').gsub('%','\%')}}}}\\\\\n"
			infile.write "\\textcolor{headingcolor}{\\rule{\\linewidth}{1.0mm}}\\\\\n"
			infile.write Uv.parse(File.read(path), 'latex', 'ruby', true, THEME)	
			infile.write endtag
		rescue Exception => e
			print e.backtrace.join('\n')
		end
	end
	
	
	def self.rip(theme, directory)
			
		f = File.new(OUTFILE, 'w')
		counter = 0		
		
		f.write preamble(theme)
		
		Find.find(directory) do |path|
			depth = path.to_s.count('/')
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
						if Linguist::FileBlob.new(path).language.name == 'Ruby'
							# lang = Linguist::FileBlob.new(path).language.name.downcase
							f.write Uv.parse(File.read(path), 'latex', 'ruby', theme)
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

# CodeRippa.rip(ARGV[0])

options = {}
option_parser = OptionParser.new do |opts|

  opts.banner = "Usage: code_rippa [options] file_or_directory"

  opts.on('-l', '--list-themes', 'List all available themes') do
    puts Uv.themes
  end

  opts.on('-t THEME', '--theme THEME', 'Selected theme') do |theme|
    options[:theme] = theme  
    unless Uv.themes.include? theme
      raise ArgumentError, "Theme not found. Use -l to see the list of available themes."
    end
  end
    
  options[:extensions] = []
  opts.on('-e EXTS', '--extensions EXTS', Array, 'Include only these extensions when processing') do |exts|
    options[:extensions] = exts
  end
  
  options[:ex_extensions] = []
  opts.on('-x EXTS', '--excluded-extensions EXTS', Array, 'Exclude these extensions when processing') do |exts|
    options[:ex_extensions] = exts
  end
    
  opts.on('-h', '--help', 'Display this screen') do
    puts opts
    exit
  end  
end

begin
  option_parser.parse!  
rescue ArgumentError => e
  # color me red.
  puts e
end


ARGV.each do|f|
  puts "Processing #{f}..."
end  
  

Uv.themes.include? options[:theme]

infile = File.new 'out.tex', 'w'

# CodeRippa.rip_file infile, options[:theme], ARGV[0]

# CodeRippa.rip_file infile, ARGV[0]
# infile.close

