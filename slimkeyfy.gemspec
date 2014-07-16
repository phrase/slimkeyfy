Gem::Specification.new do |s|
  s.name               = "slimkeyfy"
  s.version            = "0.0.1"
  s.default_executable = "slimkeyfy"

  s.authors = ["Matthias Nitsche"]
  s.date = %q{2014-16-07}
  s.description = %q{Replace plain text strings in your .slim views with I18n tags}
  s.email = %q{xx@xx.com}
  s.files = [
    "lib/slimkeyfy",
    "lib/slimkeyfy/file_utils",
    "lib/slimkeyfy/yaml_writer", 
    "lib/slimkeyfy/console",  
    "lib/slimkeyfy/parser", 
    "lib/slimkeyfy/translate_slim", 
    "bin/slimkeyfy"]
  s.test_files = ["spec/parser_spec"]
  s.homepage = %q{https://github.com/phrase/slimkeyfy}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{2.2.2}
end