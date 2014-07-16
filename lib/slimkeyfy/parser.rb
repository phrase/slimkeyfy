
class Transformer

  HTML_TAGS = /^(\||[a-z]+[0-9]?)/
  STARTING_EQUALS = /([a-z]+[0-9]?[\._]?[a-z]+)/
  HTML_STRING_PARAMETERS = /(label|hint|[a-z]\.input|[a-z]\.button|link_to|submit)/

  def initialize(word)
    @word = word
  end

  def transform
    tokens = @word.as_list
    return nil if tokens.nil? or tokens.size < 2

    result = case tokens[0]
      when HTML_TAGS then
        normalize_parted_translations(to_equals_tag(tokens[0]), @word.slice(1, -1))
      when "=" then
        if tokens[1].match(STARTING_EQUALS) then
          args = tokens[1..-1].join(" ")
          normalize_full_translation(param_list("=", args))
        else nil end
      else nil end

    result
  end

  def param_list(before, arguments)
    r1 = arguments.split(", ")
    r2 = r1.map{|tokens| tokens.split(" ") }

    translated = r2.map{ |tokens| 
      m = tokens[0].match(HTML_STRING_PARAMETERS)
      if m.nil? then
        tokens.join(" ")
      else
        translation = tokens[1..-1].join(" ")
        if matches_string?(translation) then
          translation = match_string(translation)
          _, translation_key = @word.update_translation_key_hash(translation)
          tokens.join(" ").gsub(/"(.*)"/, "#{translation_key}")
        else
          tokens.join(" ")
        end
      end
    }.join(", ")
    "#{before} #{translated}"
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

  def normalize_full_translation(translation)
    ["#{@word.indentation}#{translation}", @word.translations]
  end

  def normalize_parted_translations(before_translation, translation, after_translation="")
    translation = match_string(translation)
    translation, translation_key = @word.update_translation_key_hash(translation)
    ["#{@word.indentation}#{before_translation} #{translation_key} #{after_translation}", @word.translations]
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

  def update_translation_key_hash(translation)
    translation_key = TranslationKeyBuilder.new(@key_base, translation).build
    @translations[translation_key] = translation
    [translation, i18nString(translation_key)]
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
    normalized_translation = DEFAULT_KEY_NAME
    if not (@translation.nil? or @translation.empty?) then
      normalized_translation = @translation.gsub(VALID, "_").gsub(/[_]+/, "_").downcase[0..20]
    end
    return DEFAULT_KEY_NAME if normalized_translation.strip == "_"
    strip_underscores(normalized_translation)
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

