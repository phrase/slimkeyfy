require './console'
require './file_utils'
require './parser'

class TranslateSlim

  def initialize(options={})
    @options = options
    @bak_path, @file_path, @content = create_backup(@options)
    @key_base = translation_key_base
    @new_content = []
  end

  def unix_diff_mode
    @content.each do |old_line|
      word = Word.new(old_line, @key_base)
      matcher = Matcher.match(word)
      if not matcher.empty? then
        new_line, translations = Transformer.new(word).transform
        if translations_are_invalid?(translations)
          @new_content << old_line
        else
          @new_content << new_line
        end
      else @new_content << old_line end
    end
    process_unix_diff
  end

  def process_unix_diff
    FileWriter.write(@file_path, @new_content.join("\n"))
    ConsolePrinter.unix_diff(@bak_path, @file_path)
    if IOAction.yes_or_no?("Do you like what you see?") then
      puts "Have a nice day!"
    else
      FileWriter.write(@file_path, @content.join("\n"))
    end
  end

  def stream_mode
    @content.each_with_index do |old_line, idx|

      word = Word.new(old_line, @key_base)
      matcher = Matcher.match(word)

      if not matcher.empty? then

        new_line, translations = Transformer.new(word).transform

        if translations_are_invalid?(translations)
          update_with(idx, old_line)
        else
          process_new_line(idx, old_line, new_line, translations)
        end

      else update_with(idx, old_line) end

      FileWriter.append(@file_path, @new_content[idx])
    end
  end

  def process_new_line(idx, old_line, new_line, translations)
    ConsolePrinter.difference(old_line, new_line, translations)
    if IOAction.yes_or_no?("Changes wanted?") then
      update_with(idx, new_line)
    else update_with(idx, old_line) end
  end

  def update_with(idx, line)
    @new_content[idx] = line
  end

  def translations_are_invalid?(translations)
    translations.nil? or translations.empty?
  end

  def translation_key_base
    dirname = FileWriter.subdir_name(@file_path)
    fname = FileWriter.file_basename(@file_path)
    "#{dirname}.#{fname}"
  end

  def create_backup(options)
    original_file_path = FileUtils.abs_path(options[:input])
    content = FileReader.read(original_file_path)
    bak_path = "#{original_file_path}.bak"
    File.open(bak_path, "w"){|f| f.write(content)}
    new_file_path = build_new_file_path(options)
    FileWriter.overwrite(new_file_path)
    [bak_path, new_file_path, content.split("\n")]
  end

  def build_new_file_path(options)
    out = options[:output]
    if out and File.file?(out) then
      FileUtils.abs_path(out)
    else
      FileUtils.abs_path(options[:input])
    end
  end
end

CommandLine.new.main








