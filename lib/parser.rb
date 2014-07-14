
class Matcher
  LEXEMS = [
    /^(\||[a-z]+[0-9]?)/, # match all normal html tags
    /(?![-])=\s+([a-z]+[0-9]?[\._]?[a-z]+)/ # match all lines with a slim ruby tag
  ]
  def self.match(word)
    LEXEMS.select{|regex| word.match(regex)}
  end
end

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
        normalize_parted_translations(tokens[0].gsub("|", "="), @word.slice(1, -1))
      else nil end

    if result.nil? then
      return advanced_transform
    end

    result
  end

  def advanced_transform
    tokens = @word.as_list
    la = 0
    while la < tokens.size do
      result = case tokens[la]
        when "=" then
          la += 1
          if tokens[la].match(STARTING_EQUALS) then
            args = tokens[la..-1].join(" ")
            normalize_full_translation(param_list("=", args))
          else nil end
        else nil end

      if not result.nil? then
        return result
      end

      la += 1
    end
    ""
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
        if match_string(translation) then
          _, translation_key = @word.update_translation_key_hash(translation)
          tokens.join(" ").gsub(/"(.*)"/, "#{translation_key}")
        else
          tokens.join(" ")
        end
      end
    }.join(", ")
    "#{before} #{translated}"
  end

  def match_string(translation)
    translation.match(/"(.*)"/) != nil
  end

  def normalize_full_translation(translation)
    ["#{@word.indentation}#{translation}", @word.translations]
  end

  def normalize_parted_translations(before_translation, translation, after_translation="")
    translation, translation_key = @word.update_translation_key_hash(translation)
    ["#{@word.indentation}#{before_translation} #{translation_key} #{after_translation}", @word.translations]
  end
end


class Word
  attr_reader :line, :tokens, :line_no, :indentation
  attr_accessor :translations

  def initialize(line, line_no, key_base)
    @line = escape(line)
    @line_no = line_no
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
    translation = match_string(translation)
    translation_key = TranslationKeyBuilder.new(@key_base, translation).build
    @translations[translation_key] = translation
    [translation, i18nString(translation_key)]
  end

  def match_string(translation)
    m = translation.match(/\"(.*)\"/)
    m != nil ? $1 : ""
  end
end

class TranslationKeyBuilder
  SPECIAL_CHARS = /[:\-"'\(\)\|\}\{\]\[#]+/

  def initialize(key_base, translation)
    @key_base = key_base
    @translation = translation
  end

  def build
    "#{@key_base}.#{generate_key_name}"
  end

  def generate_key_name
    t = @translation.split(" ")
    if t.size >= 1 then
      four_words = t[0..3].join("_").downcase
      strip_special_chars = four_words.gsub(SPECIAL_CHARS, "_").gsub(/[_]+/, "_")
      strip_underscores(strip_special_chars, "_")[0..20]
    else
      ('a'..'z').to_a.shuffle[0,12].join
    end
  end

  def strip_underscores(s, delim)
    if s.start_with?(delim) then
      s = s[1..-1]
    end
    if s.end_with?(delim) then
      s = s[0..-2]
    end
    s
  end
end

