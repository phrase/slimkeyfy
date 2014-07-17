class TranslateSlim

  def initialize(options={})
    @options = options
    @original_file_path = @options[:input]
    @bak_path = MFileUtils.backup(@original_file_path)
    @content = FileReader.read(@bak_path).split("\n")
    @file_path = MFileUtils.create_new_file(@options)
    @yaml_processor = YamlProcessor.new(options[:yaml_file])
    @new_content = []
    @translation_hash = @yaml_processor.yaml_hash
    @changes = false
  end

  def unix_diff_mode
    @content.each do |old_line|
      word = Word.new(old_line)
      @translation_hash, new_line, translations = Transformer.new(word, @translation_hash).transform
      if translations_are_invalid?(translations)
        delete_invalid_translations(translations)
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

  def stream_mode
    @content.each_with_index do |old_line, idx|
      word = Word.new(old_line)
      @translation_hash, new_line, translations = Transformer.new(word, @translation_hash).transform
      if translations_are_invalid?(translations)
        delete_invalid_translations(translations)
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
    if IOAction.yes_or_no?("Changes wanted?") then
      update_with(idx, new_line)
    else update_with(idx, old_line) end
  end

  def finalize!
    begin
      if @changes then
        if IOAction.yes_or_no?("Do you like what you see?") then
          @yaml_processor.store!(@translation_hash)
          puts "Processed!"
        else
          MFileUtils.restore(@bak_path, @original_file_path)
          @yaml_processor.restore
          puts "Restored!"
        end
      else 
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

  def delete_invalid_translations(translations)
    return if translations.nil?
    translations.keys.each{|k| @translation_hash.delete(k)}
  end
end




