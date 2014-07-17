require 'yaml'

class YamlProcessor

  attr_reader :yaml_file_path, :original_yaml_hash

  def initialize(yaml_file_path)
    @bak_path = MFileUtils.backup(yaml_file_path)
    @yaml_file_path = yaml_file_path
    @original_yaml_hash = YAML::load_file(@yaml_file_path)
    @locale = extract_locale
  end

  def yaml_hash
    @original_yaml_hash[@locale]
  end

  def store!(merged_yaml_hash)
    merged = {@locale => merged_yaml_hash}
    FileWriter.write(@yaml_file_path, merged.to_yaml)
  end

  def restore
    MFileUtils.restore(@bak_path, @yaml_file_path)
  end

  def extract_locale
    File.basename(@yaml_file_path).split(".")[0]
  end
end

class Merger
  def self.merge_hashes(old_translations, new_translations)
    old_translations.merge(new_translations)
  end

  def self.merge_single_translation(translations, translation_key, translation)
    k, v = translation_key, translation
    if translations.has_key?(k) then
      if translations[k] != v then
        num = 1
        k = "#{translation_key}#{num}"
        while translations.has_key?(k) do
          k = "#{translation_key}#{num}"
          num += 1
        end
        translations[k] = v
      else
        translations[k] = v
      end
    else
      translations.each do |k1, v1|
        if v1 == v then
          return [translations, k1, v] 
        end
      end
      translations[k] = v
    end
    [translations, k, v]
  end 
end



