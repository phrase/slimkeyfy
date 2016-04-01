require_relative '../../lib/slimkeyfy/'


describe "BaseKeyGenerator" do
  let( :base_generator ) { SlimKeyfy::Slimutils::BaseKeyGenerator }

  describe "slim" do
    let( :extension ) { "slim" }

    context "without nested structure" do
      let( :file_path ) { "app/views/application/_show.html.slim"}
      subject { base_generator.generate_key_base_from_path(file_path, extension) }
      it { should == "application.show" }
    end
    context "with nested structure" do
      let( :file_path ) { "app/views/application/sidebar/_show.html.slim"}
      subject { base_generator.generate_key_base_from_path(file_path, extension) }
      it { should == "application.sidebar.show" }
    end
    context "subdir name" do
      let( :file_path ) { "app/views/application/sidebar/_show.html.slim"}
      subject { base_generator.subdir_name(file_path, "views") }
      it { should == "application.sidebar" }
    end
    context "filename with .html.slim" do
      let( :file_path ) { "app/views/application/sidebar/_show.html.slim"}
      subject { base_generator.filename(file_path) }
      it { should == "show" }
    end
    context "filename with .slim" do
      let( :file_path ) { "app/views/application/sidebar/_show.slim"}
      subject { base_generator.filename(file_path) }
      it { should == "show" }
    end
    context "filename with invalid file" do
      let( :file_path ) { "app/views/application/sidebar/_show.html.haml"}
      subject { base_generator.filename(file_path) }
      it { should == "" }
    end
  end

  describe "rb"  do
    let( :extension ) { "rb" }
    context "without nested structure" do
      let( :file_path ) { "app/controllers/some_controller.rb"}
      subject { base_generator.generate_key_base_from_path(file_path, extension) }
      it { should == "some_controller" }
    end
    context "with nested structure" do
      let( :file_path ) { "app/controllers/some_dir/some_controller.rb"}
      subject { base_generator.generate_key_base_from_path(file_path, extension) }
      it { should == "some_dir.some_controller" }
    end
    context "subdir name" do
      let( :file_path ) { "app/controllers/some_dir/some_controller.rb"}
      subject { base_generator.subdir_name(file_path, "controllers") }
      it { should == "some_dir" }
    end
    context "filename" do
      let( :file_path ) { "app/controllers/some_dir/some_controller.rb"}
      subject { base_generator.filename(file_path) }
      it { should == "some_controller" }
    end
  end
end

describe "TranslationKeyGenerator" do
  subject { SlimKeyfy::Slimutils::TranslationKeyGenerator.new(translation).generate_key_name }

  context "with valid translation and html" do
    let( :translation ) { ":<span>Hello</span> <br/> <strong>'World!~</strong>" }
    it { should ==  "hello_world_html" }
  end

  context "with valid czech string" do
    let( :translation ) { "Ahoj světe" }
    it { should ==  "hello_world" }
  end

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
