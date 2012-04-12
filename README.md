# CodeRippa

[![Build Status](https://secure.travis-ci.org/benjamintanweihao/code_rippa.png)](http://travis-ci.org/benjamintanweihao/code_rippa)

[![endorse](http://api.coderwall.com/benjamintanweihao/endorsecount.png)](http://coderwall.com/benjamintanweihao)

_CodeRippa_ takes your source code and turns it into a beautiful PDF file. Currently, it supports 150 languages and 84 themes, all of which are available in TextMate. 

## Prerequisites

You will definitely need a TeX distribution installed. To check, simply type `pdflatex`.
In case your system doesn't have `pdflatex`, you should install a [LaTeX](http://www.tug.org/texlive/) distribution.

## Installation

	$ gem install code_rippa

## Usage

### Command line options
	 
	Usage: code_rippa [options] file_or_directory
    	-l, --list-themes                List all available themes
    	-t, --theme THEME                Selected theme
    	-n, --list-syntax                List all available syntax
    	-h, --help                       Display this screen

### List all available themes (84 and counting!)

Many of the themes found in CodeRippa can be found [here](http://textmatetheme.com/)	
		
	$ code_rippa -l
	
	active4d
	all_hallows_eve
	amy
	made_of_code
	twilight
	zenburnesque
	... more themes omitted
		
### Producing PDF from a single file

Example:

Without theme specified (defaults to: _made_of_code_):

	$ code_rippa path_to_single_file.rb

With theme specified:

	$ code_rippa -t zenburnesque path_to_single_file.rb

Note that the output file is saved as _out.pdf_ in the current directory where _code_rippa_ was called from. 

### Producing PDF from a directory
	
Example:

Without theme specified (defaults to: _made_of_code_):
	
	$ code_rippa path_to_directory

With theme specified:

	$ code_rippa -t rubyblue path_to_directory

Note that the output file is saved as _out.pdf_ in the current directory where _code_rippa_ was called from. 

## Credits

None of this would be possible without the awesome [ultraviolet](https://github.com/giom/ultraviolet) [spox-ultraviolet](https://github.com/spox/ultraviolet) and [language_sniffer](https://github.com/grosser/language_sniffer) gems. Props to [__lwheng__](https://github.com/lwheng) for providing most of the LaTeX help.

## Contributing

Currently this gem is in its infancy. Any bug reports and feature requests are very welcomed.

## Changelog

### 0.0.7

- Using [language_sniffer](https://github.com/grosser/language_sniffer) in place of Linguist for automated source code language detection
- Themes! Glorious themes! 84 themes to choose from! Props to [filmgirl](https://github.com/filmgirl/TextMate-Themes), and the rest of the wonderful TM users who submitted their themes.
- Wrap lines of troublesome files such as minified javascript and parser generator outputs.
- Sensible defaults, removed the need for specifying the syntax 
- Detects if pdflatex is installed, and automatically runs pdflatex if so
- Proper cleanup after LaTeX successfully completes

### 0.0.6

- Include MiniTest specs

### 0.0.5

- Better performance when parsing.
- Code documentation.

### 0.0.4

- Removed dependency on Linguist.
- Tidier code.
	
### 0.0.1 - 0.0.3

- Initial gem push
- Fixed many stupid bugs along the way

