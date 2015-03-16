require 'find'
require 'fileutils'

class SlimKeyfy::Slimutils::MFileUtils
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
    SlimKeyfy::Slimutils::FileWriter.write(new_file_path, "")
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
  def self.is_valid_extension?(file_path)
    return false if (file_path.nil? or file_path.empty?)
    (file_path.end_with?(".slim") or file_path.end_with?(".rb"))
  end
end

class SlimKeyfy::Slimutils::FileReader
  def self.read(file)
    File.read(File.expand_path(file))
  end
end

class SlimKeyfy::Slimutils::FileWriter
  def self.write(full_path, content)
    File.open(full_path, "w+") { |f| f.write(content) }
  end
  def self.append(full_path, content)
    open(full_path, 'a') { |f| f.puts content}
  end
end