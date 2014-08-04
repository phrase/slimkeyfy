
class SlimKeyfy
  
  def self.translate(args)
    CommandLine.new(args).main
  end

end

require_relative 'slimkeyfy/file_utils'
require_relative 'slimkeyfy/key_generator'
require_relative 'slimkeyfy/console'
require_relative 'slimkeyfy/yaml_processor'
require_relative 'slimkeyfy/translate'
require_relative 'slimkeyfy/parser'