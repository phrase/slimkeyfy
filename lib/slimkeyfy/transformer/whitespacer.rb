class SlimKeyfy::Transformer::Whitespacer

  HTML = /([a-z\.]+[0-9\-]*)+/
  HTML_TAGS = /^(?<html_tag>'|\||#{HTML})/

  def self.convert_slim(s)
    m = s.match(HTML_TAGS)

    return s if m.nil? or m[:html_tag].nil?
    return s if has_equals_tag?(s, m[:html_tag])
    tag = m[:html_tag]

    case tag
    when /\|/ then
      s.gsub("|", "=")
    when /\'/ then
      s.gsub("'", "=>")
    when HTML then
      s.gsub(s, "#{s}=")
      else s end
  end

  def self.convert_nbsp(body, tag)
    lead = leading_nbsp(body)
    trail = trailing_nsbp(body, tag)

    body = lead ? body.sub("&nbsp;", "") : body
    body = trail ? body.reverse.sub(";psbn&", "").reverse : body

    tag = tag.gsub(tag, "#{tag}#{lead.to_s}#{trail.to_s}")
    [body.gsub("&nbsp;", " "), tag.gsub("=><", "=<>")]
  end

  def self.leading_nbsp(body)
    return "<"  if body.start_with?("&nbsp;")
  end

  def self.trailing_nsbp(body, tag)
    return if tag.start_with?("=>")
    return ">"  if body.end_with?("&nbsp;")
  end

  def self.has_equals_tag?(s, html_tag)
    s.gsub(html_tag, "").strip.start_with?("=")
  end
end
