require_relative '../lib/slimkeyfy/yaml_processor'


describe "yaml_processor" do
  let(:yaml_path) {  }

end

describe "Merger" do
  let ( :translation_hash ) { {"z" => {"y" => {"a" => 1}, "x" => {"a1" => 2, "a" => 1}}} }
  describe "when single merge" do
    subject { Merger.merge_single_translation(translation_hash, translation_key, translation) }
    context "when key and value is same" do
      let ( :translation_key ) { "z.x.a" }
      let ( :translation ) { 1 }
      it { should == [translation_hash, translation_key, translation] }
    end
    context "when key not in hash but value" do
      let ( :translation_key ) { "z.y.d" }
      let ( :translation ) { 2 }
      let ( :result ) { {"z"=>{"y"=>{"a"=>1, "d"=>2}, "x"=>{"a1"=>2, "a"=>1}}} }
      it { should == [result, translation_key, translation] }
    end
    context "when key in hash and value is not" do
      let ( :translation_key ) { "z.x.a" }
      let ( :translation ) { 6 }
      let ( :result ) { {"z"=>{"y"=>{"a"=>1}, "x"=>{"a1"=>2, "a"=>1, "a_1" => 6}}} }
      it { should == [result, "z.x.a_1", 6] }
    end
  end
end