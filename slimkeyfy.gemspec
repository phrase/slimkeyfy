lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

Gem::Specification.new do |s|
  s.name               = "slimkeyfy"
  s.version            = "0.0.2"
  s.platform           = Gem::Platform::RUBY
  s.homepage    = %q{https://github.com/phrase/slimkeyfy}
  s.authors     = ["Dynport GmbH"]
  s.summary     = %q{The best way to tag plain strings with i18n.}
  s.description = %q{Replace plain text strings in your .slim views with I18n tags}
  s.email       = %q{xx@xx.com}
  git_files     = `git ls-files | grep -v spec/`.split("\n") rescue ''
  s.files       = git_files
  s.test_files  = s.files.grep(%r{^(spec)/})
  s.executables = ["slimkeyfy", "slimrestore"]
  s.require_paths = ["lib"]
  s.add_development_dependency('rspec')
end
