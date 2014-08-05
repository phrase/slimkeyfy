class BaseTransformer
  TRANSLATED = /t\s*\(?\s*(".*?"|'.*?')\s*\)?/
  STRING = /(\".*\"|\'.*\')/
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