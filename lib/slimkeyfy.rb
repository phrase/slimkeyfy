
class SlimKeyfy
  
  def self.translate(args)
    CommandLine.new(args).main
  end

end

require_relative 'slimkeyfy/file_utils'
require_relative 'slimkeyfy/hash_merging'
require_relative 'slimkeyfy/key_generator'
require_relative 'slimkeyfy/console'
require_relative 'slimkeyfy/yaml_processor'
require_relative 'slimkeyfy/translate'
require_relative 'slimkeyfy/transformer/base_transformer'
require_relative 'slimkeyfy/transformer/word'
require_relative 'slimkeyfy/transformer/slim_transformer'
require_relative 'slimkeyfy/transformer/controller_transformer'