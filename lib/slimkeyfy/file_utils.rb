require 'find'

class FileUtils
  def self.create_backup(options)
    original_file_path = FileUtils.abs_path(options[:input])
    content = FileReader.read(original_file_path)
    bak_path = "#{original_file_path}.bak"
    File.open(bak_path, "w"){|f| f.write(content)}
    validate_content!(bak_path, content)
    [bak_path, content.split("\n")]
  end

  def self.create_new_file(options)
    new_file_path = build_new_file_path(options)
    FileWriter.overwrite(new_file_path)
    new_file_path
  end

  def self.build_new_file_path(options)
    out = options[:output]
    if out and File.file?(out) then
      FileUtils.abs_path(out)
    else
      FileUtils.abs_path(options[:input])
    end
  end

  def self.validate_content!(bak_path, orig_content)
    backed_content = FileReader.read(bak_path)
    if backed_content != orig_content then
      puts "Content in backup got corrupted! Please retry"
      exit
    end
  end
  
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
  def self.overwrite(full_path, content="")
    self.write(full_path, content)
  end
  def self.write(full_path, content)
    File.open(full_path, "w") { |f| f.write(content) }
  end
  def self.append(full_path, content)
    open(full_path, 'a') { |f| f.puts content}
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
