class Translate

  def initialize(options={})
    @extension = options[:ext]
    @transformer = transformer
    @original_file_path = options[:input]
    @bak_path = MFileUtils.backup(@original_file_path)
    @content = FileReader.read(@bak_path).split("\n")
    @file_path = MFileUtils.create_new_file(@original_file_path)
    @yaml_processor = create_yaml_processor(options)
    @key_base = generate_key_base
    @new_content = []
    @changes = false
  end

  def transformer
    if @extension == "slim" then
      SlimTransformer
    elsif @extension == "rb" then
      ModelControllerTransformer
    else
      puts "Unknown extension type!"
      exit
    end
  end

  def create_yaml_processor(options)
    options[:yaml_file] ? YamlProcessor.new(options[:yaml_file], options[:locale]) : nil
  end

  def stream_mode
    @content.each_with_index do |old_line, idx|
      word = Word.new(old_line, @key_base, @extension)
      new_line, translations = @transformer.new(word, @yaml_processor).transform
      if translations_are_invalid?(translations)
        delete_translations(translations)
        update_with(idx, old_line)
      else
        process_new_line(idx, old_line, new_line, translations)
        @changes = true
      end
    end
    FileWriter.write(@file_path, @new_content.join("\n"))
    finalize!
  end

  def process_new_line(idx, old_line, new_line, translations)
    ConsolePrinter.difference(old_line, new_line, translations)
    case IOAction.choose("Changes wanted?")
      when "y" then update_with(idx, new_line)
      when "n" then 
        update_with(idx, old_line)
        delete_translations(translations)
      when "x" then 
        update_with(idx, tag(old_line, translations))
        delete_translations(translations)
      when "a" then
        MFileUtils.restore(@bak_path, @original_file_path)
        puts "Aborted!"
        exit
    end
  end

  def tag(old_line, translations)
    delim = "<#{"="*50}>"
    temp = translations.map{ |k, v| 
      dir, file, name = k.split(".")
      "#{dir}.#{file} | #{name}: #{v} | t('.#{name}')\n"
    }
    "#{delim}\n#{old_line}\n#{temp}\n#{delim}"
  end

  def finalize!
    begin
      if @changes then
        if IOAction.yes_or_no?("Do you like what you see?") then
          @yaml_processor.store! unless @yaml_processor.nil?
          puts "Processed!"
        else
          MFileUtils.restore(@bak_path, @original_file_path)
          @yaml_processor.restore unless @yaml_processor.nil?
          puts "Restored!"
        end
      else 
        MFileUtils.restore(@bak_path, @original_file_path)
        puts "Nothing was changed!" 
      end
    rescue SystemExit, Interrupt
      MFileUtils.restore(@bak_path, @original_file_path)
      yaml_processor.restore
    end
  end

  def update_with(idx, line)
    @new_content[idx] = line
  end

  def translations_are_invalid?(translations)
    translations.nil? or translations.empty?
  end

  def generate_key_base
    KeyGenerator.generate_key_base_from_file(@original_file_path, @extension)
  end

  def delete_translations(translations)
    return if @yaml_processor.nil?
    @yaml_processor.delete_translations(translations)
  end

## not advised to use
  def unix_diff_mode
    @content.each do |old_line|
      word = Word.new(old_line, @key_base, @extension)
      new_line, translations = @transformer.new(word, @yaml_processor).transform
      if translations_are_invalid?(translations)
        delete_translations(translations)
        @new_content << old_line
      else
        @new_content << new_line
        @changes = true
      end
    end
    process_unix_diff
  end

  def process_unix_diff
    FileWriter.write(@file_path, @new_content.join("\n"))
    ConsolePrinter.unix_diff(@bak_path, @file_path)
    finalize!
  end
end




