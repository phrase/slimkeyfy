require_relative '../lib/slimkeyfy/key_generator'


describe "BaseKeyGenerator" do
  describe "slim" do
    let( :extension ) { "slim" }
    context "without nested structure" do
      let( :file_path ) { "app/views/application/_show.html.slim"}
      subject { SlimKeyfy::BaseKeyGenerator.generate_key_base_from_path(file_path, extension) }
      it { should == "application.show" }
    end
    context "with nested structure" do
      let( :file_path ) { "app/views/application/sidebar/_show.html.slim"}
      subject { SlimKeyfy::BaseKeyGenerator.generate_key_base_from_path(file_path, extension) }
      it { should == "application.sidebar.show" }
    end
    context "subdir name" do
      let( :file_path ) { "app/views/application/sidebar/_show.html.slim"}
      subject { SlimKeyfy::BaseKeyGenerator.subdir_name(file_path, ["views"]) }
      it { should == "application.sidebar" }
    end
    context "filename" do
      let( :file_path ) { "app/views/application/sidebar/_show.html.slim"}
      subject { SlimKeyfy::BaseKeyGenerator.filename(file_path) }
      it { should == "show" }
    end
  end
  describe "rb"  do
    let( :extension ) { "rb" }
    context "without nested structure" do
      let( :file_path ) { "app/controllers/some_controller.rb"}
      subject { SlimKeyfy::BaseKeyGenerator.generate_key_base_from_path(file_path, extension) }
      it { should == "some_controller" }
    end
    context "with nested structure" do
      let( :file_path ) { "app/controllers/some_dir/some_controller.rb"}
      subject { SlimKeyfy::BaseKeyGenerator.generate_key_base_from_path(file_path, extension) }
      it { should == "some_dir.some_controller" }
    end
    context "subdir name" do
      let( :file_path ) { "app/controllers/some_dir/some_controller.rb"}
      subject { SlimKeyfy::BaseKeyGenerator.subdir_name(file_path, ["controllers", "models"]) }
      it { should == "some_dir" }
    end
    context "filename" do
      let( :file_path ) { "app/controllers/some_dir/some_controller.rb"}
      subject { SlimKeyfy::BaseKeyGenerator.filename(file_path, ".rb") }
      it { should == "some_controller" }
    end
  end
end

describe "TranslationKeyGenerator" do
  subject { SlimKeyfy::TranslationKeyGenerator.new(translation).generate_key_name }

  context "with valid translation and special characters" do
    let( :translation ) { ":Hello 'World!~" }
    it { should ==  "hello_world" }
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

