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




