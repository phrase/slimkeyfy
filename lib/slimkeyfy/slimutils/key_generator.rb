require 'yandex-translator'

class SlimKeyfy::Slimutils::BaseKeyGenerator
  def self.generate_key_base_from_path(file_path, file_extension)
    key_name = case file_extension
      when "slim" then
        [subdir_name(file_path), filename(file_path)].join(".")
      when "rb" then
        sub = subdir_name(file_path, "controllers")
        fname = filename(file_path)
        if sub != nil and !sub.strip.empty? then
          "#{sub}.#{fname}"
        else
          fname
        end
      else nil end
    key_name
  end
  def self.filename(file_path)
    return "" if file_path.nil?
    if file_path.end_with?(".html.slim") then
      fname = File.basename(file_path, ".html.slim")
    elsif file_path.end_with?(".slim") then
      fname = File.basename(file_path, ".slim")
    elsif file_path.end_with?(".rb") then
      fname = File.basename(file_path, ".rb")
    else return "" end
    fname = fname[1..-1] if fname.start_with?("_")
    fname
  end
  def self.subdir_name(file_path, delim="views")
    return "" if file_path.nil?
    dirs = file_path.split("/").drop_while{|e| e != delim }
    return "" if dirs.empty?
    strip_dirs_and_file = dirs.pop(dirs.size-1)
    strip_dirs_and_file[0..-2].join(".")
  end
end

class SlimKeyfy::Slimutils::TranslationKeyGenerator
  VALID = /[^0-9a-z]/i
  DEFAULT_KEY_NAME = "default_key"

  def initialize(translation)
    @translation = translation
    @text_utils = SlimKeyfy::Slimutils::TextUtils.new
    @translator = Yandex::Translator.new('trnsl.1.1.20150619T111244Z.5b5dcf9dda6502b6.d9759685e888531c571cbd2d2fefa4aa34ca569e')
  end

  def generate_key_name
    normalized_translation = ""
    if not (@translation.nil? or @translation.empty?) then
      truncated_text         = @text_utils.prepare_string(@translation)
      translated             = @translator.translate truncated_text, from: 'cs', to: 'en'
      normalized_translation = @text_utils.parameterize(translated, '_')
    end
    return DEFAULT_KEY_NAME if is_not_valid?(normalized_translation.strip)
    add_html_postfix(strip_underscores(normalized_translation))
  end

  def is_not_valid?(normalized_translation)
    (normalized_translation.strip == "_" or normalized_translation.empty?)
  end

  def add_html_postfix(s)
     @text_utils.is_plain_text?(@translation) ? s : "#{s}_html"
  end

  def strip_underscores(s)
    if s.start_with?("_") then
      s = s[1..-1]
    end
    if s.end_with?("_") then
      s = s[0..-2]
    end
    s
  end
end
