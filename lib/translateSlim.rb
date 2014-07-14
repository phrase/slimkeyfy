require './console'
require './file_utils'
require './parser'

class TranslateSlim

  def initialize(file, output=nil, diff_mode)
    @tempfile = create_tempfile(output, file)
    @file = FileUtils.abs_path(file)
    @content = FileReader.read(@file).split("\n")
    @key_base = translation_key_base
    @new_content = []
  end

  def unix_diff_mode

  end

  def stream_mode
    FileWriter.rename_to_bak(@file)
    FileWriter.overwrite(@tempfile)

    @content.each_with_index do |old_line, idx|

      word = Word.new(old_line, idx, @key_base)
      matcher = Matcher.match(word)

      if not matcher.empty? then

        new_line, translations = Transformer.new(word).transform

        if translations_are_invalid?(translations)
          update_with(idx, old_line)
        else
          process_new_line(idx, old_line, new_line, translations)
        end

      else update_with(idx, old_line) end

      FileWriter.append(@tempfile, @new_content[idx])

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
    dirname = FileWriter.subdir_name(@file)
    fname = FileWriter.file_basename(@file)
    "#{dirname}.#{fname}"
  end

  def create_tempfile(output, file)
    if (output.nil? or not File.file?(output)) then
      file
    else
      FileUtils.abs_path(output) 
    end
  end
end

CommandLine.new(ARGV).main








