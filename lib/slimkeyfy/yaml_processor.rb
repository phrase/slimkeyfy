require 'yaml'

class YamlProcessor

  attr_reader :yaml_file_path, :original_yaml_hash

  def initialize(yaml_file_path)
    @bak_path = MFileUtils.backup(yaml_file_path)
    @yaml_file_path = yaml_file_path
    @original_yaml_hash = YAML::load_file(@yaml_file_path)
    @locale = extract_locale
    @translation_hash = yaml_hash
  end

  def yaml_hash
    @original_yaml_hash[@locale]
  end

  def delete_translations(translations)
    return if translations.nil?
    translations.each do |k, v|
      path = k.split('.')
      leaf = path.pop
      path.inject(@translation_hash){|h, el| h[el]}.delete(leaf)
    end
  end

  def store!
    merged = {@locale => @translation_hash}
    FileWriter.write(@yaml_file_path, merged.to_yaml)
  end

  def restore
    MFileUtils.restore(@bak_path, @yaml_file_path)
  end

  def extract_locale
    File.basename(@yaml_file_path).split(".")[1]
  end

  def merge!(translation_key, translation)
    @translation_hash, translation_key, translation = Merger.merge_single_translation(@translation_hash, translation_key, translation)
    [translation_key, translation]
  end
end

class Merger
  def self.merge_hashes(old_translations, new_translations)
    new_translations.each do |k, v|
      merge_single_translation(old_translations, new_translations)
    end
  end

  def self.merge_single_translation(translations, translation_key, translation)
    k = translation_key
    dir, file, name = k.split(".")
    value = multi_key_name(translations, k)
    if value != nil and value != translation then
      name = enhance_key_on_collision(translations, name)
    end
    h = triple_key_to_hash(dir, file, name, translation)
    translations = translations.deep_merge(h)
    k = "#{dir}.#{file}.#{name}"
    [translations, k, translation]
  end

  def self.enhance_key_on_collision(translations, translation_key_name)
    num = 1
    k = "#{translation_key_name}_#{num}"
    while translations.has_key?(k) do
      k = "#{translation_key_name}_#{num}"
      num += 1
    end
    k
  end

  def self.triple_key_to_hash(dir, file, name, translation)
    {dir => {file => {name => translation}}}
  end

  def self.multi_key_name(h, key)
    dir, file, name = key.split(".")
    if h[dir] and h[dir][file] then
      return h[dir][file][name]
    end
    nil
  end
end

class Hash
    def deep_merge(second)
        merger = proc { |key, v1, v2| Hash === v1 && Hash === v2 ? v1.merge(v2, &merger) : v2 }
        self.merge(second, &merger)
    end
end



