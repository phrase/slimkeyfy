require_relative '../lib/parser'

describe "parser should convert correctly" do
  let(:word){Word.new("  h1 Hallo Welt!", "key_base")}
  subject  { Transformer.new(word).transform }
  it {should == [
    "  h1= t('key_base.hallo_welt') ", 
    {"key_base.hallo_welt" => "Hallo Welt!"}]
  }
end

