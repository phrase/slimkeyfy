Gem::Specification.new do |s|
  s.name               = "slimkeyfy"
  s.version            = "0.0.1"
  s.default_executable = "slimkeyfy"
  s.executables << "slimkeyfy"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Dynport", "Matthias Nitsche"]
  s.date = %q{2014-16-07}
  s.description = %q{Replace plain text strings in your .slim views with I18n tags}
  s.email = %q{xx@xx.com}
  s.files = ["lib/console.rb", "lib/file_utils.rb", "lib/parser.rb", "lib/slimkeyfy", "lib/yaml_writer", "bin/slimkeyfy"]
  s.test_files = ["spec/parser_spec.rb"]
  s.homepage = %q{https://github.com/phrase/slimkeyfy}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{2.2.2}
end