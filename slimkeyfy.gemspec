lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'slimkeyfy/version'

Gem::Specification.new do |s|
  s.name               = "slimkeyfy"
  s.version            = SlimKeyfy::VERSION
  s.platform           = Gem::Platform::RUBY
  s.homepage    = %q{https://phraseapp.com/}
  s.authors     = ["Dynport GmbH"]
  s.summary     = %q{Extract plain strings from slim templates to replace them with calls to I18n's t() method.}
  s.description = %q{Replace plain text strings in your slim templates and Rails controllers with calls to I18n t() method. Keys and YAML output files will be automatically generated and filled in.}
  s.email       = ["info@phraseapp.com"]
  git_files     = `git ls-files | grep -v spec/`.split("\n") rescue ''
  s.files       = git_files
  s.test_files  = s.files.grep(%r{^(spec)/})
  s.executables = ["slimkeyfy"]
  s.require_paths = ["lib"]
  s.add_development_dependency('rspec')
  s.add_dependency('rails-html-sanitizer')
  s.add_dependency('yandex-translator')
end
