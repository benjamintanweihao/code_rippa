# CodeRippa

[![Build Status](https://secure.travis-ci.org/benjamintanweihao/code_rippa.png)](http://travis-ci.org/benjamintanweihao/code_rippa)

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
    	-s, --syntax SYNTAX              Selected syntax
    	-x, --excluded-exts E1,E2,EN     Exclude these extensions when processing
    	-h, --help                       Display this screen

### List all available themes (84 and counting!)
		
	$ code_rippa -l
	
	active4d
	all_hallows_eve
	amy
	made_of_code
	twilight
	zenburnesque
	... more themes omitted
	
### Themes Preview

Many of the themes found in CodeRippa can be found [here](http://wiki.macromates.com/Themes/UserSubmittedThemes)	
	
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

	$ code_rippa -s java -t rubyblue path_to_directory

Note that the output file is saved as _out.tex_ in the current directory where _code_rippa_ was called from. 

Then, you'll need to run _pdflatex_ __twice__. This is because LaTeX needs to generate the bookmarks.

	$ pdflatex out.tex			# Saved as out.pdf
	$ pdflatex out.tex			# Remember to run this twice!

## Credits

None of this would be possible without the awesome [ultraviolet](https://github.com/giom/ultraviolet) [spox-ultraviolet](https://github.com/spox/ultraviolet) and [language_sniffer](https://github.com/grosser/language_sniffer) gems. Props to [__lwheng__](https://github.com/lwheng) for providing most of the LaTeX help.

## Contributing

Currently this gem is in its infancy. Any bug reports and feature requests are very welcomed.

## Changelog

### 0.0.7.pre

- Using [language_sniffer](https://github.com/grosser/language_sniffer) in place of Linguist for automated source code language detection
- Themes! Glorious themes! 84 themes to choose from! Props to [filmgirl](https://github.com/filmgirl/TextMate-Themes), and the rest of the wonderful TM users who submitted their themes.
- Wrap lines of troublesome files such as minified javascript and parser generator outputs.

#### TODO

- Sensible defaults, remove the need for inputting the syntax optional
- Generate warnings when syntax is not supported.

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

