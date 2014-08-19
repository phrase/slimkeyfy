class SlimKeyfy::Transformer::ControllerTransformer < SlimKeyfy::Transformer::BaseTransformer
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

  def controller?
    true
  end
end