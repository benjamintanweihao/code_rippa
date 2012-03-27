# CodeRippa

CodeRippa takes your source code and turns it into a beautiful PDF file. Currently, it supports 150 languages and 15 themes, all of which are available in TextMate. More syntaxes and themes will be available soon.

## Installation

Add this line to your application's Gemfile:

	$ gem 'code_rippa'

And then execute:

	$ bundle

Or install it yourself as:

	$ gem install code_rippa

## Usage

### Command line options
	 
	Usage: code_rippa [options] file_or_directory
    	-l, --list-themes                List all available themes
    	-t, --theme THEME                Selected theme
    	-n, --list-syntax                List all available syntax
    	-s, --syntax SYNTAX              Selected syntax
    	-x, --excluded-exts E1,E2,EN     Exclude these extensions when processing
    	-h, --help                       Display this screen

### List all available themes
		
	$ code_rippa -l
	
	active4d
	all_hallows_eve
	amy
	moc
	twilight
	zenburnesque
	... more themes omitted
	
### List all supported syntax

	$ code_rippa -n
	
	actionscript
	erlang
	java
	javascript
	prolog
	ruby
	yaml
	... more syntaxes omitted
	
### Producing PDF from a single file

Example:
	
	$ code_rippa -s ruby -t zenburnesque path_to_single_file.rb

Note that the output file is saved as _out.tex_ in the current directory where _code_rippa_ was called from. 

	$ pdflatex out.tex			# Saved as out.pdf

		
### Producing PDF from a directory
	
Example:

	$ code_rippa -s java -t moc path_to_directory

Note that the output file is saved as _out.tex_ in the current directory where _code_rippa_ was called from. 

Then, you'll need to run _pdflatex_ __twice__. This is because LaTeX needs to generate the bookmarks.

	$ pdflatex out.tex			# Saved as out.pdf
	$ pdflatex out.tex			# Remember to run this twice!
	
Note: In case your system doesn't have `pdflatex`, you can get a [LaTeX](http://www.tug.org/texlive/) distribution.

## Credits

None of this would be possible without the awesome [ultraviolet](https://github.com/giom/ultraviolet) and [spox-ultraviolet](https://github.com/spox/ultraviolet) gems. Props to [__lwheng__](https://github.com/lwheng) for providing most of the LaTeX help.

## Contributing

Currently this gem is in its infancy. Any bug reports and feature requests are very welcomed.
