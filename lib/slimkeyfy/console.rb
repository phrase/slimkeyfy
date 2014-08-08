require 'optparse'

class ConsolePrinter
  def self.difference(old_line, new_line, translations)
    puts "#{'-'.red} #{normalize(old_line).red}"
    puts "#{'+'.green} #{normalize(new_line).green} => #{translations.to_s.yellow}"
    puts "-"*40
  end
  def self.unix_diff(bak_path, file_path)
    result = "Please install colordiff or diff (brew install colordiff)"
    colordiff, diff = `which colordiff`, `which diff`
    if not colordiff.empty? then
      result = `colordiff #{bak_path} #{file_path}`
    elsif not diff.empty? then
      result =`diff #{bak_path} #{file_path}`
    end
    puts "#{result}"
  end
  def self.normalize(line)
    line.sub(/^\s*/, " ")
  end
end

class String
  def colorize(color_code)
    "\e[#{color_code}m#{self}\e[0m"
  end
  def red
    colorize(31)
  end
  def green
    colorize(32)
  end
  def yellow
    colorize(34)
  end
end

class IOAction
  def self.yes_or_no?(msg)
    puts "#{msg} (y|n)"
    arg = STDIN.gets.chomp
    if arg =~ /[yY](es)?/ then
      true
    elsif arg =~ /[nN]o?/ then
      false
    else
      puts "Provide either (y)es or (n)o!"
      self.yes_or_no?(msg)
    end
  end
  def self.choose(msg)
    puts "#{msg} (y|n) (x for tagging | (a)bort)"
    arg = STDIN.gets.chomp
    if arg =~ /[yY](es)?/ then
      "y"
    elsif arg =~ /[nN]o?/ then
      "n"
    elsif arg =~ /x/ then
      "x"
    elsif arg =~ /a/ then
      "a"
    else
      puts "Either (y)es, (n)o, (x) for tagging or (a) to abort"
      self.choose(msg)
    end
  end
end


class CommandLine
  def initialize(args)
    helpful_exit if ARGV.size < 1
    @options = {}
    @args = args
    OptionParser.new(&method(:opt_scan)).parse!(@args)
  end

  def helpful_exit
    puts "Please provide a path to .slims and a locale name. See -h for more information."
    exit
  end

  def opt_scan(opts)
    opts.banner = 
"Usage: slimkeyfy #{"INPUT_FILENAME_OR_DIRECTORY".green} #{"LOCALE".red} #{"[YAML_FILE]".yellow} [Options]
  e.g. slimkeyfy #{"app/views/users/".green} #{"en".red} #{"phrase/locales/en.yml".yellow} [Options]

Description: Extract plain Strings from .slim views and Rails controllers to 
  replace them with I18n's t() method. Keys with it's translations will be streamed 
  to a YAML file.

  the following options are available:

"
    opts.on_tail('-h', '--help', 'Show this message') do
      puts opts
      exit
    end
    opts.on_tail('-r', '--recursive', 'If a directory is given all subdirectories will be walked either. 
                                      Without -r and a directory just the files within the first level are walked.') do
      @options[:recursive] = true
    end
  end

  def main
    @options[:input] = input = @args.shift
    @options[:locale] = @args.shift
    @options[:yaml_output] = @args.shift

    helpful_exit if input.nil?

    if File.directory?(input) then
      directory_translate(input)
    elsif File.file?(input) then
      translate
    else
      raise "Please provide a file or directory!"
      exit
    end
  end

  def directory_translate(input)
    rec = @options.fetch(:recursive, false)
    MFileUtils.walk(input, rec).each do |rec_input|
      if File.file?(rec_input) and is_valid_ext?(rec_input) then
        @options[:input] = rec_input
        translate
      end
    end
  end
  
  def is_valid_ext?(ext)
    (ext.end_with?("slim") or ext.end_with?("rb"))
  end

  def translate
    @options[:ext] = ext = MFileUtils.file_extension(@options[:input])
    unless is_valid_ext?(ext) then
      puts "invalid Input with extension #{ext}"
      return
    end

    puts "file=#{@options[:input]}"
    translate_slim = Translate.new(@options)
    begin
      translate_slim.stream_mode
    rescue Interrupt
      MFileUtils.restore(translate_slim.bak_path, translate_slim.original_file_path)
    end
  end
end