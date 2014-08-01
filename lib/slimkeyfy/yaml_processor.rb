require 'yaml'

class YamlProcessor

  attr_reader :yaml_output, :locale, :yaml_hash

  def default_yaml(locale)
    "./config/locales/slimkeyfy.#{locale}.yml"
  end

  def initialize(locale, yaml_output=nil)
    @yaml_output = if yaml_output.nil? then
      default_yaml(locale) else yaml_output end
    @locale = locale
    @yaml_hash = {}
  end

  def delete_translations(translations)
    return if translations.nil? or translations.empty? or @yaml_hash.empty?
    translations.each do |k, v|
      path = k.split('.')
      leaf = path.pop
      path.inject(@yaml_hash){|h, el| h[el]}.delete(leaf)
    end
  end

  def store!
    merged = {@locale => @yaml_hash}
    FileWriter.write(@yaml_output, merged.to_yaml)
  end

  def merge!(translation_key, translation)
    @yaml_hash, translation_key, translation = Merger.merge_single_translation(@yaml_hash, translation_key, translation)
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
    name = k.split(".").last
    value = extract_value(k, translations)
    if value != nil and value != translation then
      name = enhance_key_on_collision(translations, name)
      k = generate_dotted_key(k, name)
    end
    h = key_to_hash(k, translation)
    translations = translations.deep_merge(h)
    [translations, k, translation]
  end

  def self.enhance_key_on_collision(translations, translation_key_name)
    num = 1
    k = "#{translation_key_name}_#{num}"
    while extract_value(k, translations) != nil do
      k = "#{translation_key_name}_#{num}"
      num += 1
    end
    k
  end

  def self.generate_dotted_key(old_dotted_key, new_name)
    "#{old_dotted_key.split(".")[0..-2].join(".")}.#{new_name}"
  end

  def self.key_to_hash(dotted_key, translation)
    {dotted_key => translation}.explode
  end

  def self.extract_value(dotted_key, translations, default=nil)
    key, value = dotted_key.split(".", 2)
    if key != nil and translations.has_key?(key) then
      if value != nil then
        extract_value(value, translations[key])
      else
        translations[key]
      end
    else
      default
    end
  end
end

class Object
  def recursive_send(*args)
    args.inject(self) { |obj, m| obj.send(m.shift, *m) }
  end
end

class Hash
  def deep_merge(second)
    merger = proc { |key, v1, v2| Hash === v1 && Hash === v2 ? v1.merge(v2, &merger) : v2 }
    self.merge(second, &merger)
  end
  
  # https://gist.github.com/potatosalad/760726
  # auto creates children
  # from: http://rubyworks.github.com/facets/doc/api/core/Hash.html
  def self.autonew(*args)
    leet = lambda { |hsh, key| hsh[key] = new( &leet ) }
    new(*args,&leet)
  end
 
  def explode(divider = '.')
    h = Hash.autonew
    for k,v in self.dup
      tree = k.split(divider).map { |x| [ :[], x ] }
      tree.push([ :[]=, tree.pop[1], v ])
      h.recursive_send(*tree)
    end
    h
  end
end



