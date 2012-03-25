$: << File.expand_path(File.dirname(__FILE__))
require 'uv'
require 'optparse'
require 'find'
require 'linguist'
require 'lib/code_rippa/uv_overrides.rb'


YAML::ENGINE.yamler= 'syck'

class CodeRippa
			
	def self.rip_file(path, theme, syntax, excluded_exts = [])
		outfile = File.open('out.tex', 'w') 
		
		begin	
			srcfile = File.read(path)
			src_ext = File.extname(path)[1..-1]
            
      if not excluded_exts.include? src_ext
  	    outfile.write preamble theme
  			outfile.write "\\textcolor{headingcolor}{\\textbf{\\texttt{#{path.gsub('_','\_').gsub('%','\%')}}}}\\\\\n"
  			outfile.write "\\textcolor{headingcolor}{\\rule{\\linewidth}{1.0mm}}\\\\\n"
  	    outfile.write Uv.parse(srcfile, 'latex', syntax, true, theme)	
  			outfile.write endtag
			  outfile.close
      else
        puts "Warning: #{path} not processed. Check arguments.".background(:red).foreground(:yellow)
      end       
			
		rescue Exception => e
			print e.backtrace.join('\n').background(:red).foreground(:white)
		end
	end
	
	
	def self.rip(outfile, theme, directory)
			
		f = File.new(outfile, 'w')
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

###################
# Options Parsing #
###################

options = {}
option_parser = OptionParser.new do |opts|

  opts.banner = CodeRippa.usage

  opts.on('-l', '--list-themes', 'List all available themes') do
    puts Uv.themes.join("\n")
    exit
  end
  
  opts.on('-t', '--theme THEME', 'Selected theme') do |theme|
    if Uv.themes.include? theme
      options[:theme] = theme  
    else  
      raise ArgumentError, "#{theme} theme not found. Use -l to see the list of available themes."
    end
  end
  
  opts.on('-n', '--list-syntax', 'List all available syntax') do
    puts CodeRippa.supported_syntax.join("\n")
    exit
  end
  
  opts.on('-s', '--syntax SYNTAX', 'Selected syntax') do |syntax|
    if CodeRippa.supported_syntax.include? syntax
      options[:syntax] = syntax        
    else  
      raise ArgumentError, "syntax for #{syntax} not found. Use -s to see the list of available syntax."
    end
  end
      
        
  options[:excluded_exts] = []
  opts.on('-x', '--excluded-exts E1,E2,EN', Array, 'Exclude these extensions when processing') do |exts|
    
    options[:excluded_exts] = exts.sort!
    valid_exts = exts & CodeRippa.supported_exts
    
    if valid_exts != exts
      invalid_exts = exts - valid_exts
      raise ArgumentError, "These extensions are not supported: #{invalid_exts.join(" ")}. Aborting."
    else
      options[:ex_extensions] = valid_exts
    end
  end
    
  opts.on('-h', '--help', 'Display this screen') do
    puts opts
    exit
  end  
end

begin
  option_parser.parse!  
  
  if options[:theme] and options[:syntax] and ARGV.size == 1
    CodeRippa.rip_file(ARGV[0], options[:theme], options[:syntax], options[:excluded_exts])
  else
    raise ArgumentError, "Missing arguments. Aborting.\n" + CodeRippa.usage
  end
  
rescue ArgumentError => e
  puts e
  exit
end



  

# infile = File.new 'out.tex', 'w'

# CodeRippa.rip_file infile, options[:theme], 

# CodeRippa.rip_file infile, ARGV[0]
# infile.close

