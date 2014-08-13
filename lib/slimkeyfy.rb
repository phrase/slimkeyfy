
module SlimKeyfy
  
  def self.translate(args)
    SlimKeyfy::Console::Commandline.new(args).main
  end

end

require 'slimkeyfy/slimutils'
require 'slimkeyfy/console'
require 'slimkeyfy/transformer'