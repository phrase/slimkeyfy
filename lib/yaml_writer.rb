require 'yaml' 
require './file_utils'

class YamlWriter

  attr_reader :translation_hash, :yaml_hash

  def initialize(yaml_file_path, translation_hash, locale="en")
    @yaml_file_path = yaml_file_path
    @translation_hash = {locale => translation_hash}
    @yaml_hash = YAML::load_file(@yaml_file_path)
    @locale = locale
  end

  def process_and_store!
    process!
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

#YamlWriter.new("#{p}test.yaml",h).process_and_store!