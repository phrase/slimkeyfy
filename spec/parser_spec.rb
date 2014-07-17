require_relative '../lib/slimkeyfy/parser'

describe "Transformer should transform .slim correctly" do

  subject  { Transformer.new(word, {}).transform }

  describe "with basic html tags" do
    context "with h1 html tag" do
      let(:word){ Word.new("  h1 Hallo Welt!") }
      it {should == [
        {"hallo_welt" => "Hallo Welt!"},
        "  h1= t('hallo_welt')", 
        {"hallo_welt" => "Hallo Welt!"}]
      }
    end
    context "with small html tag" do
      let(:word){ Word.new("  small Hallo Welt!") }
      it {should == [
        {"hallo_welt" => "Hallo Welt!"},
        "  small= t('hallo_welt')", 
        {"hallo_welt" => "Hallo Welt!"}]
      }
    end
    context "with pipe | slim symbol" do
      let(:word){ Word.new("  | Hallo Welt!") }
      it {should == [
        {"hallo_welt" => "Hallo Welt!"},
        "  = t('hallo_welt')", 
        {"hallo_welt" => "Hallo Welt!"}]
      }
    end
  end

  describe "with invalid tags" do
    context "with valid tag and nothing to translate" do
      let(:word){ Word.new("  actions") }
      it {should == [{}, nil, nil]}
    end
  end

  describe "when line starts with equal" do

    context "when word contains link_to" do
      let( :raw_input ) { '= link_to "Settings", "#settings", data: { toggle: "tab" }' }
      let(:word) { Word.new(raw_input) }
      let(:translated) { '= link_to t(\'settings\'), "#settings", data: { toggle: "tab" }' }
      let(:translation_hash) { {"settings" => "Settings"} }
      it { should == [ translation_hash, translated , translation_hash] }
    end

    context "when word contains [a-z].input"  do
      let( :raw_input ) { '= f.input :max_characters_allowed, label: "Max. Characters", hint: "Shows an indicator how..."' }
      let(:word) { Word.new(raw_input) }
      let(:translated) { 
        "= f.input :max_characters_allowed, label: t('max_characters'), hint: t('shows_an_indicator_how')" 
      }
      let(:translation_hash) { 
        {"max_characters"=>"Max. Characters", "shows_an_indicator_how"=>"Shows an indicator how..."}
      }
      it { should == [ translation_hash, translated , translation_hash] }
    end

  end
end

describe "TranslationKeyBuilder" do
  subject { TranslationKeyBuilder.new(translation).generate_key_name }

  context "with valid translation and special characters" do
    let( :translation ) { ":Hallo 'Welt!~" }
    it { should ==  "hallo_welt" }
  end

  context "with special characters only" do
    let( :translation ) { ":{}'!~" }
    it { should ==  "default_key" }
  end

  context "with empty translation" do
    let( :translation ) { "" }
    it { should == "default_key" }
  end
end







