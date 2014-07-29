
class Transformer

  HTML_TAGS = /^(\||[a-z]+[0-9]?)/
  T_TAG = /t\(['"]\.?[a-z\_]+["']\)/
  STRING = /"(.*)"/

  BEFORE = /(?<before>.*)/
  TRANSLATION = /['"](?<translation>.*?)['"]/
  AFTER = /(?<after>,?.*)?/

  HTML_ARGUMENTS = {
    hint: /#{BEFORE}(?<html_tag>hint:\s*)["'](?<translation>.*)["']/,
    link_to: /#{BEFORE}(?<html_tag>link_to(\s[a-z]*)?\(?)#{TRANSLATION}#{AFTER}/,
    placeholder: /#{BEFORE}(?<html_tag>placeholder:\s*)#{TRANSLATION}#{AFTER}/,
    title: /#{BEFORE}(?<html_tag>title:\s*)#{TRANSLATION}#{AFTER}/,
    label: /#{BEFORE}(?<html_tag>[a-z]*_?label:\s*)#{TRANSLATION}#{AFTER}/,
    tag_input_button: /#{BEFORE}(?<html_tag>[a-z]*[\._]?(button|input|tag):?\s*)#{TRANSLATION}#{AFTER}/,
  }

  def match_any_slim?(line)
    HTML_ARGUMENTS.values.any?{ |regex| line.match(regex) }
  end

  def initialize(word, yaml_processor=nil)
    @word = word
    @yaml_processor = yaml_processor
  end

  def transform
    tokens = @word.as_list
    unindented_line = @word.unindented_line

    return nil_elem if should_not_be_processed?(tokens)

    result = 
    if match_any_slim?(unindented_line) then
      complex_html(unindented_line)
    elsif tokens[0].match(HTML_TAGS) then
      simple_html(tokens)
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
    translation_key = update_hashes(translation)
    normalize_translation("#{tagged_with_equals} #{translation_key}")
  end

  def complex_html(line)
    line = parse_html_arguments(line)
    normalize_translation(line)
  end

  def parse_html_arguments(line)
    HTML_ARGUMENTS.each do |key, regex|
      m_data = nil
      m_data = line.match(regex)
      if m_data != nil then
        before, html_tag, translation = m_data[:before], m_data[:html_tag], m_data[:translation]
        after = m_data.names.include?("after") ? m_data[:after] : ""
        translation_key = update_hashes(translation)
        line = "#{before}#{html_tag}#{translation_key}#{after}"
      end
    end
    line
  end

  def strings(tokens, translation)
    plain_translation = match_string(translation).gsub("&nbsp;", " ")
    translation_key = update_hashes(plain_translation)
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

  def normalize_translation(translation)
    ["#{@word.indentation}#{translation}", @word.translations]
  end

  def update_hashes(translation)
    @word.update_translation_key_hash(@yaml_processor, translation)
  end
end


class Word
  attr_reader :line, :tokens, :indentation
  attr_accessor :translations

  def initialize(line, key_base)
    @line = line
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

  def i18nString(translation_key)
    "t('.#{translation_key}')"
  end

  def update_translation_key_hash(yaml_processor, translation)
    translation_key_without_base, translation_key = create_translation_keys(translation)
    translation_key, translation = yaml_processor.merge!(translation_key, translation) unless yaml_processor.nil?
    @translations.merge!({translation_key => translation})
    i18nString(translation_key_without_base)
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


class ModelControllerTransformer
  REGEX = /((notice|message|alert|raise):?\s*)(?<translation>\".*\")/

  def initialize(word, yaml_processor=nil)
    @word = word
    @yaml_processor = yaml_processor
  end

  def transform
    m = @word.line.match(REGEX)
    if m != nil then
      translation = m[:translation]
      translation_key = update_hashes(translation)
      localized = @word.line.gsub(translation, translation_key)
      return [localized, @word.translations]
    end
    [nil, nil]
  end

  def update_hashes(translation)
    @word.update_translation_key_hash(@yaml_processor, translation)
  end
end




