
module SlimKeyfy
  
  def translate(args)
    CommandLine.new(args).main
  end

end

require 'slimkeyfy/file_utils'
require 'slimkeyfy/hash_merging'
require 'slimkeyfy/key_generator'
require 'slimkeyfy/console'
require 'slimkeyfy/yaml_processor'
require 'slimkeyfy/translate'
require 'slimkeyfy/transformer'