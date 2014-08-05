class SlimTransformer < BaseTransformer

  HTML_TAGS = /^(?<html_tag>\||[a-z0-9.-]+)/
  BEFORE = /(?<before>.*)/
  TRANSLATION = /['"](?<translation>.*?)['"]/
  AFTER = /(?<after>,?.*)?/
  HTML_ARGUMENTS = {
    hint: /#{BEFORE}(?<html_tag>hint:\s*)["'](?<translation>.*)["']/,
    link_to: /#{BEFORE}(?<html_tag>link_to(\s[a-z]*)?\(?)#{TRANSLATION}#{AFTER}/,
    inconified: /#{BEFORE}(?<html_tag>inconified\(\s*)#{TRANSLATION}#{AFTER}/,
    placeholder: /#{BEFORE}(?<html_tag>placeholder:\s*)#{TRANSLATION}#{AFTER}/,
    title: /#{BEFORE}(?<html_tag>title:\s*)#{TRANSLATION}#{AFTER}/,
    label: /#{BEFORE}(?<html_tag>[a-z]*_?label:\s*)#{TRANSLATION}#{AFTER}/,
    tag_input_button: /#{BEFORE}(?<html_tag>[a-z]*[\._]?(button|input|tag):?\s*)#{TRANSLATION}#{AFTER}/,
  }

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

  def match_any_slim?(line)
    HTML_ARGUMENTS.values.any?{ |regex| line.match(regex) }
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
        
        next if line_already_translated?(line, html_tag)

        translation_key = update_hashes(translation)
        line = "#{before}#{html_tag}#{translation_key}#{after}"
      end
    end
    line
  end

  def line_already_translated?(line, html_tag)
    line.match(TRANSLATED) != nil and html_tag.match(/link_to/) != nil # edge case... 
  end
  
  def to_equals_tag(s)
    s = s.gsub("|", "=")
    m = s.match(HTML_TAGS)
    return s if m.nil? or m[:html_tag].nil?
    return s if has_equals_tag(s, m[:html_tag])
    s.gsub(m[:html_tag], "#{m[:html_tag]}=")
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