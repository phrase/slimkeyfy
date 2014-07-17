require 'yaml'

class YamlWriter

  attr_reader :translation_hash, :yaml_hash

  def initialize(yaml_file_path, translation_hash, locale="en")
    @yaml_file_path = yaml_file_path
    @translation_hash = {locale => translation_hash}
    @yaml_hash = YAML::load_file(@yaml_file_path)
    @locale = locale
  end

  def process_and_store!
    process
    store
  end

  def process
    @yaml_hash = @yaml_hash.deep_merge(@translation_hash)
  end

  def store
    FileWriter.write(@yaml_file_path, @yaml_hash.to_yaml)
  end
end

class Hash
  def deep_merge(second)
    merger = proc { |key, v1, v2| Hash === v1 && Hash === v2 ? v1.merge(v2, &merger) : v2 }
    self.merge(second, &merger)
  end
end

class Merger
  def self.merge_hashes(old_translations, new_translations)
    old_translations.merge(new_translations)
  end

  # merge key => value pair into Hash
  # 1.) merge(a, 2) with {a => 1} results in {a => 1, a1 => 2} return [a1, 2]
  # 2.) merge(b, 1) with {a => 1} results in  {a => 1} return [a, 1]
  # 3.) merge(c, 3) with {a => 1} results in  {a => 1, c => 3} return [c, 3]
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

#YamlWriter.new("#{p}test.yaml",h).process_and_store!




