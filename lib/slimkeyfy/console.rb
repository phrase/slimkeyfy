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
end


class CommandLine
  def initialize(args)
    helpful_exit if ARGV.size < 1
    @options = {}
    @args = args
    OptionParser.new(&method(:opt_scan)).parse!(@args)
  end

  def helpful_exit
    puts "Please provide at least a path. See -h for more information."
    exit
  end

  def opt_scan(opts)
    opts.banner = "Usage: slimkeyfy INPUT_FILENAME_OR_DIRECTORY [OUTPUT_FILENAME_OR_DIRECTORY] [Options]"
    opts.on_tail('-h', '--help', 'Show this message') do
      puts opts
      exit
    end
    opts.on_tail('-d', '--diff', 'Uses unix diff or colordiff for full file comparison') do
      @options[:diff] = true
    end
  end

  def main
    @options[:input] = input = @args.shift
    @options[:output] = output = @args.shift

    helpful_exit if input.nil?

    if File.directory?(input) then
      FileUtils.walk(input).each do |inp|
        translate
      end
    elsif File.file?(input) then
      translate
    else
      raise "Please provide a file or directory!"
      exit
    end
  end

  def translate
    puts "file=#{@options[:input]} diff=#{@options[:diff]}"
    translate_slim = TranslateSlim.new(@options)
    if @options[:diff] then
      translate_slim.unix_diff_mode
    else
      translate_slim.stream_mode
    end
  end
end




