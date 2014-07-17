require_relative '../lib/slimkeyfy/yaml_processor'

describe "Merger" do
  let ( :translation_hash ) { {"a" => 1, "a1" => 2, "a3" => 3, "b" => 5} }
  describe "when single merge" do
    subject { Merger.merge_single_translation(translation_hash, translation_key, translation) }
    context "when key and value is same" do
      let ( :translation_key ) { "a" }
      let ( :translation ) { 1 }
      it { should == [translation_hash, translation_key, translation] }
    end
    context "when key not in hash but value" do
      let ( :translation_key ) { "d" }
      let ( :translation ) { 2 }
      it { should == [translation_hash, "a1", translation] }
    end
    context "when key in hash and value is not" do
      let ( :translation_key ) { "a" }
      let ( :translation ) { 6 }
      it { should == [translation_hash.merge({"a2" => translation}), "a2", translation] }
    end
  end
end