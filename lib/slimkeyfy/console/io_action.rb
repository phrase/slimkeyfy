class SlimKeyfy::Console::IOAction
  def self.yes_or_no?(msg)
    puts "#{msg} (y|n)"
    arg = STDIN.gets.chomp
    if arg =~ /[yY](es)?/
      true
    elsif arg =~ /[nN]o?/
      false
    else
      puts "Provide either (y)es or (n)o!"
      self.yes_or_no?(msg)
    end
  end
  def self.choose(msg)
    puts "#{msg} (y|n) (x for tagging | (a)bort)"
    arg = STDIN.gets.chomp
    if arg =~ /[yY](es)?/
      "y"
    elsif arg =~ /[nN]o?/
      "n"
    elsif arg =~ /x/
      "x"
    elsif arg =~ /a/
      "a"
    else
      puts "Either (y)es, (n)o, (x) for tagging or (a) to abort"
      self.choose(msg)
    end
  end
end