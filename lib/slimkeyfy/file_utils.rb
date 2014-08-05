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
    FileWriter.write(new_file_path, "")
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

class FileReader
  def self.read(file)
    File.read(File.expand_path(file))
  end
end

class FileWriter
  def self.write(full_path, content)
    File.open(full_path, "w+") { |f| f.write(content) }
  end
  def self.append(full_path, content)
    open(full_path, 'a') { |f| f.puts content}
  end
end