class SlimKeyfy::Transformer::SlimTransformer < SlimKeyfy::Transformer::BaseTransformer

  HTML_TAGS = /^(?<html_tag>'|\||([a-z\.]+[0-9\-]*)+)/
  BEFORE = /(?<before>.*)/
  TRANSLATION = /(?<translation>(".*?"|'.*?'))/
  AFTER = /(?<after>,?.*)?/
  HTML_ARGUMENTS = {
    hint: /(?<html_tag>hint:\s*)/,
    link_to: /(?<html_tag>link_to\s*\(?)/,
    inconified: /(?<html_tag>(iconified\s*\(?))/,
    placeholder: /(?<html_tag>placeholder:\s*)/,
    title: /(?<html_tag>title:\s*)/,
    label: /(?<html_tag>[a-z]*_?label:\s*)/,
    tag_input_button: /(?<html_tag>[a-z]*[\._]?(button|input|tag):?\s*)/,
  }

  def regex_list
    HTML_ARGUMENTS.map{|_, regex| /#{BEFORE}#{regex}#{TRANSLATION}#{AFTER}/ }
  end

  def match_any_slim?(line)
    line.match(/(?<before>.*=.*)/)
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

    return nil_elem if (result.last.nil? or result.last.empty?)

    result
  end

  def simple_html
    return nil_elem if @word.line.match(TRANSLATED)

    tagged_with_equals = to_equals_tag(@word.head)

    body = @word.tail.join(" ")
    if body.match(/(?<html_tag>link_to\s*\(?)(?<translation>(".*?"|'.*?'))/) != nil then
      translation = link_tos(body)
    else
      translation = convert_html_whitespace(match_string(body))
    end
    
    translation_key = update_hashes(translation)
    normalize_translation("#{tagged_with_equals} #{translation_key}")
  end

  def complex_html(line)
    line = parse_html_arguments(line)
    normalize_translation(line)
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
    line
  end
  
  def to_equals_tag(s)
    s = s.gsub(/[\|']/, "=")
    m = s.match(HTML_TAGS)
    return s if m.nil? or m[:html_tag].nil?
    return s if has_equals_tag(s, m[:html_tag])
    s.gsub(m[:html_tag], "#{m[:html_tag]}=")
  end

  def link_tos(line)
    r = /(?<html_tag>link_to\s*\(?)(?<translation>(".*?"|'.*?'))/
    m = line.match(r)
    if m != nil then
      _, translation = m[:html_tag], match_string(m[:translation])
      translation_key = update_hashes(translation)
      line = line.gsub(m[:translation], translation_key)
      link_tos(line)
    else
      line
    end
  end

  def has_equals_tag(s, html_tag)
    s.gsub(html_tag, "").strip.start_with?("=")
  end

  def convert_html_whitespace(s)
    s.gsub("&nbsp;", " ")
  end

  def normalize_translation(translation)
    ["#{@word.indentation}#{translation}", @word.translations]
  end
end