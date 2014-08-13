require_relative '../../lib/slimkeyfy/'

describe "Word" do
  let( :raw_input ) { '       = submit_tag "Search", class: "btn btn-primary"' }
  let( :key_base ) { "key_base.new"}
  let( :extension ) { "slim" }
  let( :word ) { SlimKeyfy::Transformer::Word.new(raw_input, key_base, extension) }
  let( :translation_key ) { "hello_world" }

  context "with slim extension the key should be relative" do
    subject { word.i18nString(translation_key) }
    it { should == "t('.hello_world')" }
  end

  context "with rb extension the key should be absolute" do
    let( :extension ) { "rb" }
    subject { word.i18nString(translation_key) }
    it { should == "t('key_base.new.hello_world')" }
  end

  context "with raw_input and trimmed indentation" do
    subject { word.unindented_line }
    it { should == '= submit_tag "Search", class: "btn btn-primary"' }
  end

  context "when converting translation to tagged localization" do
    let( :translation ) { "Search" }
    let( :yaml_processor ) { nil }
    subject { word.update_translation_key_hash(yaml_processor, translation) }
    it { should == "t('.search')" }
  end

  context "extract a dotted key" do
    let( :translation_key_with_base ) { "users.show.hello_world" }
    subject{ word.extract_updated_key(translation_key_with_base) }
    it { should == "hello_world" }
  end

  context "extract a dotted key when key is nil" do
    let( :translation_key_with_base ) { nil }
    subject{ word.extract_updated_key(translation_key_with_base) }
    it { should == "" }
  end
end