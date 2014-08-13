require_relative '../../lib/slimkeyfy/'

describe "Controllers Transformer should transform .rb correctly" do
  let( :key_base ) { "some_controller"}
  let( :extension ) { "rb" }
  let( :line ) { "" }
  let( :word ) { SlimKeyfy::Transformer::Word.new(line, key_base, extension) }
  subject  { SlimKeyfy::Transformer::ControllerTransformer.new(word, nil).transform }

  context "with alert message and new syntax" do
    let(:line){ "redirect_to root_path, alert: 'You cannot delete your account.'" }
    it {should == [
      "redirect_to root_path, alert: t('some_controller.you_cannot_delete_your')", 
      {"#{key_base}.you_cannot_delete_your" => "You cannot delete your account."}]
    }
  end
  context "with alert message and old syntax" do
    let(:line){ "redirect_to root_path, alert => 'You cannot delete your account.'" }
    it {should == [
      "redirect_to root_path, alert => t('some_controller.you_cannot_delete_your')", 
      {"#{key_base}.you_cannot_delete_your" => "You cannot delete your account."}]
    }
  end
  context "with flash message" do
    let(:line){ "flash[:notice] = 'You have successfully done something.' if some_boolean?" }
    it {should == [
      "flash[:notice] = t('some_controller.you_have_successfully_done') if some_boolean?", 
      {"#{key_base}.you_have_successfully_done" => "You have successfully done something."}]
    }
  end
  context "with subject message" do
    let(:line){ 'mail(to: user_email, subject: "You have been added to a discussion...")' }
    it {should == [
      "mail(to: user_email, subject: t('some_controller.you_have_been_added'))", 
      {"#{key_base}.you_have_been_added" => "You have been added to a discussion..."}]
    }
  end
end