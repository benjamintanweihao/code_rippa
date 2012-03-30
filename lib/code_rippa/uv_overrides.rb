require 'uv'

# These module monkey patches the original Spox's Ultraviolet, in order 
# to override defaults.
module Uv
	@@set_table_columns = true
	
	Uv.syntax_path   = File.join(File.dirname(__FILE__), 'syntax')
  Uv.render_path   = File.join(File.dirname(__FILE__), 'render')
  Uv.theme_path    = File.join(File.dirname(__FILE__), 'render', 'latex')
  Uv.default_style ||= 'moc'
				
	def Uv.themes
    Dir.glob( File.join(@theme_path, '*.render') ).collect do |f| 
      File.basename(f, '.render')
    end
  end
	
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