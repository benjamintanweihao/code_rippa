require 'yaml'
require 'syck'
require 'fileutils'

if ARGV.empty?
  $stderr.puts "! Must pass one or more filenames to convert from Syck output to Psych output."
  exit 1
end

bad_files = ARGV.select{ |f| ! File.exists?(f) }
if bad_files.any?
  $stderr.puts "! Aborting because the following files do not exist:"
  $stderr.puts bad_files
  exit 1
end

def use_syck
  YAML::ENGINE.yamler = 'syck'
  raise "Oops! Something went horribly wrong." unless YAML == Syck
end

def use_psych
  YAML::ENGINE.yamler = 'psych'
  raise "Oops! Something went horribly wrong." unless YAML == Psych
end

ARGV.each do |filename|
  $stdout.print "Converting #{filename} from Syck to Psych..."

  use_syck
  hash = YAML.load(File.read filename)
  FileUtils.cp filename, "#{filename}.bak"
  use_psych
  File.open(filename, 'w'){ |file| file.write(YAML.dump(hash)) }

  $stdout.puts " done."
end
