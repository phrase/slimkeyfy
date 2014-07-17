
class Transformer

  HTML_TAGS = /^(\||[a-z]+[0-9]?)/
  STARTING_EQUALS = /([a-z]+[0-9]?[\._]?[a-z]+)/
  HTML_STRING_PARAMETERS = /(label|hint|[a-z]\.input|[a-z]\.button|link_to|submit)/

  def initialize(word, translation_hash)
    @word = word
    @translation_hash = translation_hash
  end

  def transform
    tokens = @word.as_list
    return nil_elem if tokens.nil? or tokens.size < 2

    result = case tokens[0]
      when HTML_TAGS then
        tagged_with_equals = to_equals_tag(tokens[0])
        translation = match_string(@word.slice(1, -1)).gsub("&nbsp;", " ")
        @translation_hash, _, translation_key = update_hashes(translation)
        normalize_translation(tagged_with_equals, translation_key)
      when "=" then
        if tokens[1].match(STARTING_EQUALS) then
          translated_arguments = html_argument_list(tokens[1..-1].join(" "))
          normalize_translation("=", translated_arguments)
        else nil_elem end
      else nil_elem end

    result
  end

  def nil_elem
    [@translation_hash, nil, nil]
  end

  def html_argument_list(arguments)
    raw_args = arguments.split(", ")
    raw_arg_tokens = raw_args.map{|tokens| tokens.split(" ") }

    translated = raw_arg_tokens.map{ |tokens| 
      m = tokens[0].match(HTML_STRING_PARAMETERS)
      if m.nil? then
        tokens.join(" ")
      else
        translation = tokens[1..-1].join(" ")
        if matches_string?(translation) then
          translation = match_string(translation).gsub("&nbsp;", " ")
          @translation_hash, _, translation_key = update_hashes(translation)
          tokens.join(" ").gsub(/"(.*)"/, "#{translation_key}")
        else
          tokens.join(" ")
        end
      end
    }.join(", ")
    translated
  end

  def to_equals_tag(s)
    s = s.gsub("|", "=")
    m = s.match(HTML_TAGS)
    unless m.nil?
      fst = m.captures.first
      return "#{fst}=" if fst == s
    end
    s
  end

  def matches_string?(translation)
    translation.match(/"(.*)"/) != nil
  end

  def match_string(translation)
    translation.match(/"(.*)"/) ? $1 : translation
  end

  def normalize_translation(before_translation, translation)
    [@translation_hash, "#{@word.indentation}#{before_translation} #{translation}", @word.translations]
  end

  def update_hashes(translation)
    @word.update_translation_key_hash(@translation_hash, translation)
  end
end


class Word
  attr_reader :line, :tokens, :indentation
  attr_accessor :translations

  def initialize(line, key_base)
    @line = escape(line)
    @indentation = " " * (@line.size - unindented_line.size)
    @translations = {}
    @key_base = key_base
  end

  def as_list(delim=" ")
    @line.split(delim)
  end

  def unindented_line
    @line.sub(/^\s*/, "")
  end

  def match(regex)
    unindented_line.match(regex)
  end

  def slice(sidx=0, eidx=-1)
    as_list[sidx..eidx].join(" ")
  end

  def escape(line)
    line.gsub(/\'/, '"')
  end

  def i18nString(translation_key)
    "t('#{translation_key}')"
  end

  def update_translation_key_hash(all_translations, translation)
    translation_key = TranslationKeyBuilder.new(@key_base, translation).build
    all_translations, translation_key, translation = Merger.merge_single_translation(all_translations, translation_key, translation)
    @translations.merge!({translation_key => translation})
    [all_translations, translation, i18nString(translation_key)]
  end
end

class TranslationKeyBuilder
  VALID = /[^0-9a-z]/i
  DEFAULT_KEY_NAME = "default_key"

  def initialize(key_base, translation)
    @key_base = key_base
    @translation = translation
  end

  def build
    "#{@key_base}.#{generate_key_name}"
  end

  def generate_key_name
    normalized_translation = ""
    if not (@translation.nil? or @translation.empty?) then
      normalized_translation = @translation.gsub(VALID, "_").gsub(/[_]+/, "_").downcase
      normalized_translation = normalized_translation.split("_")[0..3].join("_")
    end
    return DEFAULT_KEY_NAME if is_not_valid?(normalized_translation.strip)
    strip_underscores(normalized_translation)
  end

  def is_not_valid?(normalized_translation)
    (normalized_translation.strip == "_" or normalized_translation.empty?)
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

