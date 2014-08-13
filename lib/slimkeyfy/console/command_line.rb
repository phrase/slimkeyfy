require 'optparse'

class SlimKeyfy::Console::Commandline
  def initialize(args)
    @options = {}
    @args = args
    OptionParser.new(&method(:opt_scan)).parse!(@args)
  end

  def wrong_usage
    puts "Please provide a path to .slims and a locale name. See -h for more information."
    exit
  end

  def opt_scan(opts)
    opts.banner = "
#{"Usage".white}: slimkeyfy #{"INPUT_FILENAME_OR_DIRECTORY".green} #{"LOCALE".red} #{"[YAML_FILE]".yellow} [Options]
  e.g. slimkeyfy #{"app/views/users/".green} #{"en".red} #{"phrase/locales/en.yml".yellow} [Options]

#{"Description".white}: Extract plain Strings from .slim views and Rails controllers to 
  replace them with I18n's t() method. Keys with it's translations will be streamed 
  to a YAML file.

  the following options are available:

"
    opts.on_tail('-h', '--help', 'Show this message') do
      puts opts
      exit
    end
    opts.on_tail('-v', '--version', 'Show current version') do
      puts "Slimkeyfy 0.0.6 (beta)"
      exit
    end
    opts.on_tail('-r', '--recursive', 'If a directory is given all subdirectories will be walked either. 
                                      Without -r and a directory just the files within the first level are walked.
                                      ') do
      @options[:recursive] = true
    end
  end

  def main
    @options[:input] = input = @args.shift
    @options[:locale] = locale = @args.shift
    @options[:yaml_output] = @args.shift

    wrong_usage if (input.nil? or locale.nil?)

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
    file_util.walk(input, rec).each do |rec_input|
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
    @options[:ext] = ext = file_util.file_extension(@options[:input])
    unless is_valid_ext?(ext) then
      puts "invalid Input with extension #{ext}"
      return
    end

    puts "file=#{@options[:input]}"
    translate_slim = SlimKeyfy::Console::Translate.new(@options)
    begin
      translate_slim.stream_mode
    rescue Interrupt
      file_util.restore(translate_slim.bak_path, translate_slim.original_file_path)
    end
  end

  def file_util
    SlimKeyfy::Slimutils::MFileUtils
  end
end