require_relative '../lib/slimkeyfy/yaml_processor'
require_relative '../lib/slimkeyfy/file_utils'

describe "yaml_processor" do
  describe "should render locale yaml file properly" do
    let ( :file ) { "./spec/test_files/en.yml" }
    let ( :locale ) { "en" }
    let ( :key_base ) { "some_key.new" }
    let ( :yaml_processor ) { YamlProcessor.new(locale, key_base, file) }

    context "yaml_hash should loose top level locale name" do
      subject { yaml_processor.yaml_hash }
      it { should == {"new"=>{"hello_world"=>"Hello World!"}} }
    end

    context "yaml_hash should be empty after deleting the only translation" do
      let( :translations ) { {"new.hello_world" => "Hello World!"} }
      subject { 
        yaml_processor.delete_translations(translations) 
        yaml_processor.yaml_hash
      }
      it { should == {"new" => {}} }
    end 

    context "merge! should render correct translation_key and translation if translation_key already in yaml hash" do
      let( :translation_key ) { "new.hello_world"  }
      let( :translation ) { "Ahoi World!" } 
      let( :result ) { ["new.hello_world_1", translation] }
      subject { 
        yaml_processor.merge!(translation_key, translation) 
      }
      it { should == result }
    end

    context "it should merge new key with same nesting" do
      let( :translation_key ) { "new.ahoi_world"  }
      let( :translation ) { "Ahoi World!" } 
      let( :result_hash ) { {"new" => {"ahoi_world" => "Ahoi World!", "hello_world"=>"Hello World!"}} }
      subject { 
        yaml_processor.merge!(translation_key, translation) 
        yaml_processor.yaml_hash
      }
      it { should == result_hash }
    end

    context "it should merge new key without same nesting" do
      let( :translation_key ) { "index.hello_world" }
      let( :translation ) { "Hello World!" }
      let( :result_hash ) { {"index" => {"hello_world" => "Hello World!"}, "new"=>{"hello_world"=>"Hello World!"}} }
      subject { 
        yaml_processor.merge!(translation_key, translation) 
        yaml_processor.yaml_hash
      }
      it { should == result_hash }
    end

    context "it should not add new key if it is already in it" do
      let( :translation_key ) { "new.ahoi_world"  }
      let( :translation ) { "Ahoi World!" } 
      let( :result_hash ) { {"new" => {"ahoi_world" => "Ahoi World!", "hello_world"=>"Hello World!"}} }
      subject { 
        yaml_processor.merge!(translation_key, translation) 
        yaml_processor.merge!(translation_key, translation) 
        yaml_processor.yaml_hash
      }
      it { should == result_hash }
    end

    context "it should add key if it is already in hash but values are different" do
      let( :translation_key ) { "new.ahoi_world"  }
      let( :translation1 ) { "Ahoi World!" } 
      let( :translation2 ) { "No World!" } 
      let( :result_hash ) { {"new" => {"ahoi_world" => "Ahoi World!", "ahoi_world_1" => "No World!", "hello_world"=>"Hello World!"}} }
      subject { 
        yaml_processor.merge!(translation_key, translation1) 
        yaml_processor.merge!(translation_key, translation2) 
        yaml_processor.yaml_hash
      }
      it { should == result_hash }
    end
  end
  after(:suite) do 
    MFileUtils.rm("./spec/test_files/en.yml.bak")
  end
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

  describe "convert dotted key to nested hash" do
    let ( :translation_key ) { "a.b.file.name" }
    let ( :translation ) { "some_value" }
    subject { Merger.key_to_hash(translation_key, translation) }
    it { 
      should == {"a" => {"b" => {"file" => {"name" => translation}}}}
    }
  end

  describe "extract value from deeply nested hash" do
    let ( :translation_key ) { "z.y.a" }
    subject { Merger.extract_value(translation_key, translation_hash) }
    it { should == 1}
  end

  describe "extract value from deeply nested hash when it is not in it" do
    let ( :translation_key ) { "z.y.x" }
    subject { Merger.extract_value(translation_key, translation_hash) }
    it { should be_nil}
  end

  describe "extract value from deeply neested hash" do
    let ( :translation_key ) { "z.y.a.name" }
    let ( :new_name ) { "new_name" }
    subject { Merger.generate_dotted_key(translation_key, new_name) }
    it { should == "z.y.a.new_name"}
  end
end




