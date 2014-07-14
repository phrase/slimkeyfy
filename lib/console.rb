require 'optparse'

class ConsolePrinter
  def self.difference(old_line, new_line, translations)
    puts "#{'-'.red} #{normalize(old_line).red}"
    puts "#{'+'.green} #{normalize(new_line).green} => #{translations.to_s.yellow}"
    puts "-"*40
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
    @usage = "Usage: translateSlim INPUT_FILENAME_OR_DIRECTORY [OUTPUT_FILENAME_OR_DIRECTORY] [Options]"
    if args.size < 1 then
      puts @usage
      exit
    end
    @args = args
    @opts = OptionParser.new(&method(:opt_scan))
  end

  def opt_scan(opts)
    opts.banner = @usage
    opts.on_tail('-h', '--help', 'Show this message') do
      puts opts
      exit
    end
    opts.on_tail('-d', '--diff', 'Uses unix diff or colordiff for full file comparison') do
      puts opts
      exit
    end
  end

  def main
    @opts.parse!(@args)
    input = @args.shift
    output = @args.shift
    unix_diff_mode = false

    if File.directory?(input) then
      FileUtils.walk(input).each do |inp|
        translate(intput, nil, unix_diff_mode)
      end
    elsif File.file?(input) then
      translate(input, output, unix_diff_mode)
    else
      raise "Please provide a file or directory!"
      exit
    end
  end

  def translate(input, output=nil, unix_diff_mode=false)
    puts "file=#{input} diff=#{unix_diff_mode}"
    TranslateSlim.new(input, output, unix_diff_mode).stream_mode
  end
end



