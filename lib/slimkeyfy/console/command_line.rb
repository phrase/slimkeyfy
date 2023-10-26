require 'optparse'

class SlimKeyfy::Console::Commandline
  def initialize(args)
    @options = { translator: {} }
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
    opts.on_tail('-t', '--translator-api-key [API_KEY]', 'API key for Deepl') do |value|
      @options[:translator][:api] = value || ENV['DEEPL_AUTH_KEY']

      DeepL.configure do |config|
        config.auth_key = value
        config.host = 'https://api-free.deepl.com' 
        config.version = 'v2'
      end
    end

    #
    opts.on_tail('-l', '--keys-from-locale LOCALE', 'translate keys from locale') do |from_locale|
      @options[:translator][:from_locale] = from_locale
    end

    opts.on_tail('-h', '--help', 'Show this message') do
      puts opts
      exit
    end
    opts.on_tail('-v', '--version', 'Show current version') do
      puts "0.1"
      exit
    end
    opts.on_tail('-R', '--recursive', 'If a directory is given all subdirectories will be walked either.
                                      Without -r and a directory just the files within the first level are walked.
                                      ') do
      @options[:recursive] = true
    end
    opts.on_tail('-b', '--no-backup', 'No Backups - for safety reasons - are created. For minimum safety we
                                      recommend a version control like git. Backups will still be created for
                                      comparison but deleted right after you agree to the changes.
                                ') do
      @options[:no_backup] = true
    end
  end

  def run
    @options[:input] = input = @args.shift
    @options[:locale] = locale = @args.shift
    @options[:yaml_output] = @args.shift

    SlimKeyfy::Slimutils::TranslationKeyGenerator.translator_options = @options[:translator]

    wrong_usage if (input.nil? or locale.nil?)

    if File.directory?(input)
      directory_translate(input)
    elsif File.file?(input)
      translate
    else
      raise "Please provide a file or directory!"
      exit
    end
  end

  def directory_translate(input)
    rec = @options.fetch(:recursive, false)
    SlimKeyfy::Slimutils::MFileUtils.walk(input, rec).each do |rec_input|
      if File.file?(rec_input) and SlimKeyfy::Slimutils::MFileUtils.is_valid_extension?(rec_input)
        @options[:input] = rec_input
        translate
      end
    end
  end

  def translate
    unless SlimKeyfy::Slimutils::MFileUtils.is_valid_extension?(@options[:input])
      puts "invalid extension!"
      return
    end
    @options[:ext] = SlimKeyfy::Slimutils::MFileUtils.file_extension(@options[:input])

    puts "file=#{@options[:input]}"
    translate_slim = SlimKeyfy::Console::Translate.new(@options)
    begin
      translate_slim.stream_mode
    rescue Interrupt
      SlimKeyfy::Slimutils::MFileUtils.restore(translate_slim.bak_path, translate_slim.original_file_path)
    end
  end
end
