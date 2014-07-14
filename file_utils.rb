require 'find'

class FileUtils
  def self.abs_path(file)
    File.absolute_path(file)
  end
  def self.walk(arg)
    files = []
    Find.find(abs_path(arg)) do |f|
      files << f if File.file?(f)
    end
    files
  end
end

class FileReader
  def self.read(file)
    File.read(File.expand_path(file))
  end
end

class FileWriter
  def self.rename_to_bak(file)
    fname = file_basename(file).split(".")
    File.rename(file, "#{File.dirname(file)}/#{fname}.bak")
  end
  def self.overwrite(path, content="")
    self.write(path, content)
  end
  def self.write(path, content)
    open(File.expand_path(path), "w") { |f| f.write(content) }
  end
  def self.append(path, content)
    open(path, 'a') { |f| f.puts content}
  end
  def self.create_temporary_file(file)
    "#{File.dirname(file)}/translated_#{file_basename(file)}.html.slim"
  end
  def self.file_basename(file)
    return "" if file.nil?
    fname = File.basename(file).split(".").first
    if fname.start_with? "_"
      fname = fname[1..-1]
    end
    fname
  end
  def self.subdir_name(file_path)
    file_path.split("/")[-2]
  end
end
