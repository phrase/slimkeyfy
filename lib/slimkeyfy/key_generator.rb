class SlimKeyfy::BaseKeyGenerator
  def self.generate_key_base_from_path(file_path, file_extension)
    key_name = case file_extension
      when "slim" then 
        [subdir_name(file_path), filename(file_path)].join(".") 
      when "rb" then 
        sub = subdir_name(file_path, ["controllers"])
        fname = filename(file_path, ".rb")
        if sub != nil and !sub.strip.empty? then
          "#{sub}.#{fname}"
        else
          fname
        end
      else nil end
    key_name
  end
  def self.filename(file_path, file_extension=".html.slim")
    return "" if file_path.nil?
    fname = File.basename(file_path, file_extension)
    fname = fname[1..-1] if fname.start_with?("_")
    fname
  end
  def self.subdir_name(file_path, delim=["views"])
    return "" if file_path.nil?
    dirs = file_path.split("/").drop_while{|e| delim.all?{|d| e != d }}
    return "" if dirs.empty?
    strip_dirs_and_file = dirs.pop(dirs.size-1)
    strip_dirs_and_file[0..-2].join(".")
  end
end

class SlimKeyfy::TranslationKeyGenerator
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

