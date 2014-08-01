
class Transformer
  TRANSLATED = /(?<t>t[\s\(](".*?"|'.*?')\)?)/
  STRING_WITHOUT_QUOTES = /("(?<double_quot>.*)"|'(?<single_quot>.*)')/

  def initialize(word, yaml_processor=nil)
    @word = word
    @yaml_processor = yaml_processor
  end

  def nil_elem
    [nil, nil]
  end

  def should_not_be_processed?(tokens)
    (tokens.nil? or tokens.size < 2)
  end

  def matches_string?(translation)
    m = translation.match(STRING_WITHOUT_QUOTES)
    return false if m.nil?
    (m[:double_quot] != nil or m[:single_quot] != nil)
  end

  def match_string(translation)
    m = translation.match(STRING_WITHOUT_QUOTES)
    return translation if m.nil?
    (m[:double_quot] != nil) ? m[:double_quot] : ((m[:single_quot] != nil) ? m[:single_quot] : translation)
  end

  def update_hashes(translation)
    @word.update_translation_key_hash(@yaml_processor, translation)
  end
end

class SlimTransformer < Transformer
  HTML_TAGS = /^(?<html_tag>\||[a-z]+[0-9]?)/

  NOT_TRANSLATED = /(?!=#{TRANSLATED})/
  BEFORE = /(?<before>.*)/
  TRANSLATION = /['"](?<translation>.*?)['"]/
  AFTER = /(?<after>,?.*)?/

  HTML_ARGUMENTS = {
    hint: /#{BEFORE}(?<html_tag>hint:\s*)["'](?<translation>.*)["']/,
    link_to: /#{NOT_TRANSLATED}#{BEFORE}(?<html_tag>link_to(\s[a-z]*)?\(?)#{TRANSLATION}#{AFTER}/,
    inconified: /#{BEFORE}(?<html_tag>inconified\(\s*)#{TRANSLATION}#{AFTER}/,
    placeholder: /#{BEFORE}(?<html_tag>placeholder:\s*)#{TRANSLATION}#{AFTER}/,
    title: /#{BEFORE}(?<html_tag>title:\s*)#{TRANSLATION}#{AFTER}/,
    label: /#{BEFORE}(?<html_tag>[a-z]*_?label:\s*)#{TRANSLATION}#{AFTER}/,
    tag_input_button: /#{BEFORE}(?<html_tag>[a-z]*[\._]?(button|input|tag):?\s*)#{TRANSLATION}#{AFTER}/,
  }

  def match_any_slim?(line)
    HTML_ARGUMENTS.values.any?{ |regex| line.match(regex) }
  end

  def transform
    return nil_elem if should_not_be_processed?(@word.as_list)
    unindented_line = @word.unindented_line

    result = 
    if match_any_slim?(unindented_line) then
      complex_html(unindented_line)
    elsif @word.head.match(HTML_TAGS) then
      simple_html
    else nil_elem end

    result
  end

  def simple_html
    return nil_elem if @word.line.match(TRANSLATED)

    tagged_with_equals = to_equals_tag(@word.head)
    translation = convert_html_whitespace(match_string(@word.tail.join(" ")))
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

  def to_equals_tag(s)
    s = s.gsub("|", "=")
    m = s.match(HTML_TAGS)
    return s if m.nil? or m[:html_tag].nil?
    s.gsub(m[:html_tag], "#{m[:html_tag]}=")
  end

  def convert_html_whitespace(s)
    s.gsub("&nbsp;", " ")
  end

  def normalize_translation(translation)
    ["#{@word.indentation}#{translation}", @word.translations]
  end
end


class ModelControllerTransformer < Transformer
  STRING = /(\".*\"|\'.*\')/
  TAGS = /(text|notice|message|alert|raise|subject|flash\[:[a-z]+\])/
  CONNECTING_SYMBOLS = /\s*(:|=>?)?\s*/
  REGEX = /(?<tag>#{TAGS}#{CONNECTING_SYMBOLS})(?<translation>#{STRING})/

  def transform
    m = @word.line.match(REGEX)
    if m != nil then
      translation = match_string(m[:translation])
      translation_key = update_hashes(translation)
      localized = @word.line.gsub(m[:translation], translation_key)
      return [localized, @word.translations]
    end
    nil_elem
  end
end


class Word
  attr_reader :line, :tokens, :indentation
  attr_accessor :translations

  def initialize(line, key_base, extension)
    @line = line
    @key_base = key_base
    @extension = extension
    @indentation = " " * (@line.size - unindented_line.size)
    @translations = {}
  end

  def as_list(delim=" ")
    @line.split(delim)
  end

  def unindented_line
    @line.sub(/^\s*/, "")
  end

  def head
    as_list.first
  end

  def tail
    as_list.drop(1)
  end

  def i18nString(translation_key)
    if @extension == "rb" then
      "t('#{@key_base}.#{translation_key}')"
    else
      "t('.#{translation_key}')"
    end
  end

  def update_translation_key_hash(yaml_processor, translation)
    translation_key = TranslationKeyBuilder.new(translation).generate_key_name
    translation_key_with_base = "#{@key_base}.#{translation_key}"
    translation_key_with_base, translation = yaml_processor.merge!(translation_key_with_base, translation) unless yaml_processor.nil?
    @translations.merge!({translation_key_with_base => translation})
    i18nString(extract_updated_key(translation_key_with_base))
  end

  def extract_updated_key(translation_key_with_base)
    return "" if (translation_key_with_base.nil? or translation_key_with_base.empty?)
    translation_key_with_base.split(".").last
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
