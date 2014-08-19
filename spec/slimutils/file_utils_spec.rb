require_relative '../../lib/slimkeyfy/'


describe "MFileUtils" do
  let ( :file_path ) { "app/views/application/_show.html.slim" }
  let ( :file_util ) { SlimKeyfy::Slimutils::MFileUtils }

  describe "file_extension" do
    subject { file_util.file_extension(file_path) }

    context "filename with .slim" do
      it { should == "slim" }
    end
    context "filename .rb" do
      let ( :file_path ) { "app/blubb.rb" }
      it { should == "rb" }
    end
    context "filename is empty" do
      let ( :file_path ) { "" }
      it { should be_nil }
    end
  end

  describe "is_valid_extension?" do
    subject { file_util.is_valid_extension?(file_path) }

    context "filename with .slim" do
      it { should == true }
    end
    context "filename with .rb" do
      let ( :file_path ) { "app/blubb.rb" }
      it { should == true }
    end
    context "filename is empty" do
      let ( :file_path ) { "" }
      it { should == false }
    end
    context "filename with invalid extension" do
      let ( :file_path ) { "app/views/application/_show.html.haml" }
      it { should == false }
    end
  end

end