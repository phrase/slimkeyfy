
class SlimKeyfy
  
  def self.translate(args)
    CommandLine.new(args).main
  end

  def self.restore(input)
    if File.file?(input) then
      bak_file = "#{input}.bak"
      MFileUtils.restore(bak_file, input)
    else
      files = MFileUtils.walk(input)
      files.select{|f| f.end_with?(".bak") }.each do | bak_file |
        original_file = bak_file[0..-5]
        MFileUtils.restore(bak_file, original_file)
      end
    end
  end

end

require_relative 'slimkeyfy/file_utils'
require_relative 'slimkeyfy/console'
require_relative 'slimkeyfy/yaml_processor'
require_relative 'slimkeyfy/translate_slim'
require_relative 'slimkeyfy/parser'