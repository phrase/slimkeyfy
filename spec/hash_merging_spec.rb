require_relative '../lib/slimkeyfy/'

describe "Merger" do
  let ( :translation_hash ) { {"z" => {"y" => {"a" => 1}, "x" => {"a1" => 2, "a" => 1}}} }
  describe "when single merge" do
    subject { SlimKeyfy::Merger.merge_single_translation(translation_hash, translation_key, translation) }
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

  describe "convert dotted key to nested hash" do
    let ( :translation_key ) { "a.b.file.name" }
    let ( :translation ) { "some_value" }
    subject { SlimKeyfy::Merger.key_to_hash(translation_key, translation) }
    it { 
      should == {"a" => {"b" => {"file" => {"name" => translation}}}}
    }
  end

  describe "extract value from deeply nested hash" do
    let ( :translation_key ) { "z.y.a" }
    subject { SlimKeyfy::Merger.extract_value(translation_key, translation_hash) }
    it { should == 1}
  end

  describe "extract value from deeply nested hash when it is not in it" do
    let ( :translation_key ) { "z.y.x" }
    subject { SlimKeyfy::Merger.extract_value(translation_key, translation_hash) }
    it { should be_nil}
  end

  describe "extract value from deeply neested hash" do
    let ( :translation_key ) { "z.y.a.name" }
    let ( :new_name ) { "new_name" }
    subject { SlimKeyfy::Merger.generate_dotted_key(translation_key, new_name) }
    it { should == "z.y.a.new_name"}
  end
end