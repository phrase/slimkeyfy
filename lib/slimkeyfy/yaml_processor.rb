require 'yaml'

class YamlProcessor

  attr_reader :locale, :yaml_output, :yaml_hash

  def initialize(locale, key_base, yaml_output=nil)
    @locale = locale
    @key_base = key_base
    @yaml_output = process_output_file(yaml_output)
    @yaml_hash = load_hash
  end

  def process_output_file(yaml_output)
    if yaml_output.nil? then
      dir_of_key = @key_base.split(".").first
      yaml_output = default_yaml(dir_of_key, @locale)
    end
    path = File.expand_path(yaml_output.to_s)
    if File.exist?(path) then 
      path
    else
      FileWriter.write(path, "---")
      path
    end
  end

  def store!
    merged = {@locale => @yaml_hash}
    FileWriter.write(@yaml_output, merged.to_yaml)
  end

  def load_hash
    h = YAML::load_file(@yaml_output)
    if h then h[@locale]
    else {} end
  end

  def default_yaml(key, locale)
    File.expand_path("./config/locales/#{key}.#{locale}.yml")
  end

  def merge!(translation_key, translation)
    @yaml_hash, translation_key, translation = Merger.merge_single_translation(@yaml_hash, translation_key, translation)
    [translation_key, translation]
  end

  def delete_translations(translations)
    return if translations.nil? or translations.empty? or @yaml_hash.empty?
    translations.each do |k, v|
      path = k.split('.')
      leaf = path.pop
      path.inject(@yaml_hash){|h, el| h[el]}.delete(leaf)
    end
  end
end