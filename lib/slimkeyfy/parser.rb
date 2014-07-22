
class Transformer

  HTML_TAGS = /^(\||[a-z]+[0-9]?)/
  T_TAG = /t\(['"]\.?[a-z\_]+["']\)/
  STRING = /"(.*)"/
  SLIM = {
    hint: /(?<before>.*)(?<hint>hint:\s*)"(?<translation>.*)"/,
    link_to: /(?<before>.*)(?<link_to>link_to(\s[a-z]*)?\(?)"(?<translation>.*?)",(?<after>.*)/,
    placeholder: /(?<before>.*)(?<placeholder>placeholder:\s*)"(?<translation>.*?)"(?<after>,?.*)?/,
    title: /(?<before>.*)(?<title>title:\s*)"(?<translation>.*?)"(?<after>,?.*)?/,
    label: /(?<before>.*)(?<label>[a-z]*_?label:\s*)"(?<translation>.*?)"(?<after>,?.*)?/,
    tag: /(?<before>.*)(?<tag>[a-z]+_tag:?\s*)"(?<translation>.*?)",(?<after>.*)/,
    input: /(?<before>.*)(?<input>[a-z]*[\._]input:?\s*)['"](?<translation>.*?)['"],(?<after>.*)/,
    button: /(?<before>.*)(?<button>[a-z]*[\._]button:?\s*)['"](?<translation>.*?)['"],(?<after>.*)/,
  }
  def match_any_slim?(line)
    SLIM.values.any?{ |regex| line.match(regex) }
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
    if tokens[0].match(HTML_TAGS) then
      simple_html(tokens)
    elsif match_any_slim?(unindented_line) then
      complex_html(unindented_line)
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
    line = hint(line)
    line = link_to(line)
    line = placeholder(line)
    line = title(line)
    line = label(line)
    line = tag(line)
    line = input(line)
    line = button(line)
    normalize_translation(line)
  end

  def hint(s)
    m_data = s.match(SLIM[:hint])
    if m_data != nil then
      before, hint, translation = m_data[:before], m_data[:hint], m_data[:translation]
      translation_key = update_hashes(translation)
      s = "#{before}#{hint}#{translation_key}"
    end
    s
  end

  def link_to(s)
    m_data = s.match(SLIM[:link_to])
    if m_data != nil then
      before, link_to, translation, after = m_data[:before], m_data[:link_to], m_data[:translation], m_data[:after]
      translation_key = update_hashes(translation)
      s = "#{before}#{link_to}#{translation_key},#{after}"
    end
    s
  end

  def placeholder(s)
    m_data = s.match(SLIM[:placeholder])
    if m_data != nil then
      before, placeholder, translation, after = m_data[:before], m_data[:placeholder], m_data[:translation], m_data[:after]
      translation_key = update_hashes(translation)
      s = "#{before}#{placeholder}#{translation_key}#{after}"
    end
    s
  end

  def title(s)
    m_data = s.match(SLIM[:title])
    if m_data != nil then
      before, title, translation, after = m_data[:before], m_data[:title], m_data[:translation], m_data[:after]
      translation_key = update_hashes(translation)
      s = "#{before}#{title}#{translation_key}#{after}"
    end
    s
  end

  def label(s)
    m_data = s.match(SLIM[:label])
    if m_data != nil then
      before, label, translation, after = m_data[:before], m_data[:label], m_data[:translation], m_data[:after]
      translation_key = update_hashes(translation)
      s = "#{before}#{label}#{translation_key}#{after}"
    end
    s
  end

  def tag(s)
    m_data = s.match(SLIM[:tag])
    if m_data != nil then
      before, tag, translation, after = m_data[:before], m_data[:tag], m_data[:translation], m_data[:after]
      translation_key = update_hashes(translation)
      s = "#{before}#{tag}#{translation_key},#{after}"
    end
    s
  end

  def input(s)
    m_data = s.match(SLIM[:input])
    if m_data != nil then
      before, input, translation, after = m_data[:before], m_data[:input], m_data[:translation], m_data[:after]
      translation_key = update_hashes(translation)
      s = "#{before}#{input}#{translation_key},#{after}"
    end
    s
  end

  def button(s)
    m_data = s.match(SLIM[:button])
    if m_data != nil then
      before, button, translation, after = m_data[:before], m_data[:button], m_data[:translation], m_data[:after]
      translation_key = update_hashes(translation)
      s = "#{before}#{button}#{translation_key},#{after}"
    end
    s
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

