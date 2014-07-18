
class Transformer

  HTML_TAGS = /^(\||[a-z]+[0-9]?)/
  HTML_STRING_PARAMETERS = /(label|hint|[a-z]\.input|[a-z]\.button|link_to|submit|title)/

  T_TAG = /t\(['"]\.?[a-z\_]+["']\)/
  STRING_INTERPOLATION = /["'](#\{.*\})["']/
  STRING = /"(.*)"/

  def initialize(word, yaml_processor=nil)
    @word = word
    @yaml_processor = yaml_processor
  end

  def transform
    tokens = @word.as_list
    return nil_elem if should_not_be_processed?(tokens)

    result = case tokens[0]
      when HTML_TAGS then
        simple_html(tokens)
      when "=" then
        complex_html(tokens)
      else nil_elem end

    result
  end

  def should_not_be_processed?(tokens)
    (tokens.nil? or tokens.size < 2 or @word.line.match(T_TAG))
  end

  def nil_elem
    [nil, nil]
  end

  def simple_html(tokens)
    tagged_with_equals = to_equals_tag(tokens[0])
    translation = match_string(@word.slice(1, -1)).gsub("&nbsp;", " ")
    _, translation_key = update_hashes(translation)
    normalize_translation(tagged_with_equals, translation_key)
  end

  def complex_html(tokens)
    if tokens[1].match(HTML_STRING_PARAMETERS) then
      translated_arguments = html_argument_list(tokens[1..-1].join(" "))
      normalize_translation("=", translated_arguments)
    else nil_elem end
  end

  def html_argument_list(arguments)
    arguments = interpolation(arguments)
    raw_args = arguments.split(", ")
    raw_arg_tokens = raw_args.map{|tokens| tokens.split(" ") }

    translated = raw_arg_tokens.map{ |tokens| 
      m = tokens[0].match(HTML_STRING_PARAMETERS)
      if m.nil? then
        tokens.join(" ")
      else
        translation = tokens[1..-1].join(" ")
        if matches_string?(translation) then
          translation = tokens[1..-1].join(" ")
          strings(tokens, translation)
        else
          tokens.join(" ")
        end
      end
    }.join(", ")
    translated
  end

  def interpolation(arguments)
    interpolated_match = arguments.match(STRING_INTERPOLATION) 
    if interpolated_match != nil then
      _, translation_key = update_hashes($1)
      arguments = arguments.gsub(STRING_INTERPOLATION, "#{translation_key}")
    end
    arguments
  end

  def strings(tokens, translation)
    plain_translation = match_string(translation).gsub("&nbsp;", " ")
    _, translation_key = update_hashes(plain_translation)
    tokens.join(" ").gsub(STRING, "#{translation_key}")
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
    translation.match(STRING) != nil
  end

  def match_string(translation)
    translation.match(STRING) ? $1 : translation
  end

  def normalize_translation(before_translation, translation)
    ["#{@word.indentation}#{before_translation} #{translation}", @word.translations]
  end

  def update_hashes(translation)
    @word.update_translation_key_hash(@yaml_processor, translation)
  end
end


class Word
  attr_reader :line, :tokens, :indentation
  attr_accessor :translations

  def initialize(line, key_base)
    @line = escape(line)
    @key_base = key_base
    @indentation = " " * (@line.size - unindented_line.size)
    @translations = {}
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
    "t('.#{translation_key}')"
  end

  def update_translation_key_hash(yaml_processor, translation)
    translation_key_without_base, translation_key = create_translation_keys(translation)
    translation_key, translation = yaml_processor.merge!(translation_key, translation) unless yaml_processor.nil?
    @translations.merge!({translation_key => translation})
    [translation, i18nString(translation_key_without_base)]
  end

  def create_translation_keys(translation)
    translation_key_without_base = TranslationKeyBuilder.new(translation).generate_key_name
    [translation_key_without_base, "#{@key_base}.#{translation_key_without_base}"]
  end
end

class TranslationKeyBuilder
  VALID = /[^0-9a-z]/i
  DEFAULT_KEY_NAME = "default_key"

  def initialize(translation)
    @translation = translation
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

