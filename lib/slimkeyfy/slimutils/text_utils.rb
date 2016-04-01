require "rails-html-sanitizer"

class String
  def truncate(truncate_at, options = {})
    return dup unless length > truncate_at

    omission = options[:omission] || '...'
    length_with_room_for_omission = truncate_at - omission.length
    stop = \
      if options[:separator]
        rindex(options[:separator], length_with_room_for_omission) || length_with_room_for_omission
      else
        length_with_room_for_omission
      end

    "#{self[0, stop]}#{omission}"
  end
end


class SlimKeyfy::Slimutils::TextUtils

  def initialize
    @sanitizer = Rails::Html::FullSanitizer.new
  end

  def prepare_string(text)
    self.truncate(self.strip_tags(text), length: 30,  omission: '', separator: ' ', escape: false)
  end

  def is_plain_text?(text)
    text == @sanitizer.sanitize(text)
  end

  def strip_tags(text)
    @sanitizer.sanitize(text)
  end

  def truncate(text, options = {}, &block)
    if text
      length  = options.fetch(:length, 30)
      content = text.truncate(length, options)
      content << capture(&block) if block_given? && text.length > length
      content
    end
  end

  def parameterize(string, sep = '-')
    parameterized_string = string.downcase
    parameterized_string.gsub!(/[^a-z0-9\-_]+/i, sep)
    unless sep.nil? || sep.empty?
      re_sep = Regexp.escape(sep)
      parameterized_string.gsub!(/#{re_sep}{2,}/, sep)
      parameterized_string.gsub!(/^#{re_sep}|#{re_sep}$/i, '')
    end
    parameterized_string.downcase
  end
end
