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
    translation_key = TranslationKeyGenerator.new(translation).generate_key_name
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