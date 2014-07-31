require_relative '../lib/slimkeyfy/file_utils'



describe "FileUtils" do

  describe "KeyGenerator" do
    describe "slim" do
      let( :extension ) { "slim" }
      context "without nested structure" do
        let( :file_path ) { "app/views/application/_show.html.slim"}
        subject { KeyGenerator.generate_key_base_from_file(file_path, extension) }
        it { should == "application.show" }
      end
      context "with nested structure" do
        let( :file_path ) { "app/views/application/sidebar/_show.html.slim"}
        subject { KeyGenerator.generate_key_base_from_file(file_path, extension) }
        it { should == "application.sidebar.show" }
      end
    end
    describe "rb"  do
      let( :extension ) { "rb" }
      context "without nested structure" do
        let( :file_path ) { "app/controllers/some_controller.rb"}
        subject { KeyGenerator.generate_key_base_from_file(file_path, extension) }
        it { should == "some_controller" }
      end
      context "with nested structure" do
        let( :file_path ) { "app/controllers/some_dir/some_controller.rb"}
        subject { KeyGenerator.generate_key_base_from_file(file_path, extension) }
        it { should == "some_dir.some_controller" }
      end
    end
  end

end