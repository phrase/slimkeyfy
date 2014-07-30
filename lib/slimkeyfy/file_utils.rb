require 'find'
require 'fileutils'

class MFileUtils
  def self.restore(backup_path, original_file_path)
    FileUtils.cp(backup_path, original_file_path)
    FileUtils.rm(backup_path)
  end
  def self.rm(file_path)
    FileUtils.rm(file_path)
  end
  def self.backup(input)
    original_file_path = abs_path(input)
    backup_path = "#{original_file_path}.bak"
    FileUtils.cp(original_file_path, backup_path)
    backup_path
  end
  def self.create_new_file(input)
    new_file_path = self.abs_path(input)
    FileWriter.overwrite(new_file_path)
    new_file_path
  end
  def self.abs_path(file)
    File.absolute_path(file)
  end
  def self.walk(arg, recursive=false)
    directory = abs_path(arg)
    files = []
    if recursive then
      Find.find(directory) do |f|
        files << f if File.file?(f)
      end
    else
      files = Dir["#{directory}/*"]
    end
    files
  end
  def self.file_extension(file_path)
    file_path.split(".").last
  end
end

class KeyGenerator
  def self.generate_key_base_from_file(file_path, file_extension)
    dir, fname = case file_extension
      when "slim" then 
        [subdir_name_views(file_path), filename(file_path)] 
      when "rb" then 
        [subdir_name_controller(file_path,), filename(file_path, ".rb")]
      else nil end
    "#{dir}.#{fname}"
  end
  def self.filename(file_path, file_extension=".html.slim")
    return "" if file_path.nil?
    fname = File.basename(file_path, file_extension)
    fname = fname[1..-1] if fname.start_with?("_")
    fname
  end
  def self.subdir_name_views(file_path)
    return "" if file_path.nil?
    dirs = file_path.split("/").drop_while{|e| e != "views"}
    return "" if dirs.empty?
    strip_dirs_and_file = dirs.pop(dirs.size-1)
    strip_dirs_and_file[0..-2].join(".")
  end
  def self.subdir_name_controller(file_path)
    return "" if file_path.nil?
    dirs = file_path.split("/").drop_while{|e| e != "controllers"}
    return "" if dirs.empty?
    strip_dirs_and_file = dirs.pop(dirs.size)
    r = strip_dirs_and_file[0..-2].join(".")
    puts "result= #{r}"
    r
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
end
