class SlimKeyfy::Transformer::SlimTransformer < SlimKeyfy::Transformer::BaseTransformer

  HTML_TAGS = /^(?<html_tag>'|\||([a-z\.]+[0-9\-]*)+)/
  EQUALS = /#?([a-z0-9\.\-\s]+)?\=.*/

  BEFORE =        /(?<before>.*)/
  TRANSLATION =   /(?<translation>(".*?"|'.*?'))/
  AFTER =         /(?<after>,?.*)?/

  HTML_ARGUMENTS = {
    hint:               /(?<html_tag>hint:\s*)/,
    link_to:            /(?<html_tag>link_to\s*\(?)/,
    inconified:         /(?<html_tag>(iconified\s*\(?))/,
    placeholder:        /(?<html_tag>placeholder:\s*)/,
    title:              /(?<html_tag>title:\s*)/,
    label:              /(?<html_tag>[a-z]*_?label:\s*)/,
    optionals:          /(?<html_tag>(default|include_blank|alt):\s*)/,
    input:              /(?<html_tag>[a-z]*\.?input:?\s*)/,
    button:             /(?<html_tag>[a-z]*\.?button:?\s*(\:[a-z]+\s*,\s*)?)/,
    tag:                /(?<html_tag>(submit|content)_tag[\:\(]?\s*)/,
    data_naive:         /(?<html_tag>data:\s*\{\s*(confirm|content):\s*)/
  }

  LINK_TO = /#{HTML_ARGUMENTS[:link_to]}#{TRANSLATION}/
  
  INTERPOLATED_VARIABLES = /\#{[^}]*}/

  def regex_list
    HTML_ARGUMENTS.map{|_, regex| /#{BEFORE}#{regex}#{TRANSLATION}#{AFTER}/ }
  end

  def transform
    return nil_elem if should_not_be_processed?(@word.as_list)
    unindented_line = @word.unindented_line

    result = 
    if unindented_line.match(EQUALS)
      parse_html_arguments(unindented_line)
    elsif @word.head.match(HTML_TAGS)
      parse_html
    else nil_elem end

    return nil_elem if (result.last.nil? or result.last.empty?)

    result
  end

  def parse_html
    return nil_elem if @word.line.match(TRANSLATED)

    tagged_with_equals = SlimKeyfy::Transformer::Whitespacer.convert_slim(@word.head)
    body = @word.tail.join(" ")
    body, tagged_with_equals = SlimKeyfy::Transformer::Whitespacer.convert_nbsp(body, tagged_with_equals)

    if body.match(LINK_TO) != nil
      body = link_tos(body)
    end
    
    translation_key = update_hashes(body)
    normalize_translation("#{tagged_with_equals} #{translation_key}")
  end

  def parse_html_arguments(line)
    regex_list.each do |regex|
      line.scan(regex) do |m_data|
        before, html_tag = m_data[0], m_data[1]
        translation, after = match_string(m_data[2]), m_data[3]
        translation_key = update_hashes(translation)
        line = "#{before}#{html_tag}#{translation_key}#{after}"
      end
    end
    normalize_translation(line)
  end

  def link_tos(line)
    m = line.match(LINK_TO)
    if m != nil
      _, translation = m[:html_tag], match_string(m[:translation])
      translation_key = update_hashes(translation)
      line = line.gsub(m[:translation], translation_key)
      link_tos(line)
    else
      line
    end
  end

  def normalize_translation(translation)
    ["#{@word.indentation}#{translation}", @word.translations]
  end

  def slim?
    true
  end
end