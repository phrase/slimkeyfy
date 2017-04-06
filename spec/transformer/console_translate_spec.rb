require_relative '../../lib/slimkeyfy/'

describe "ConsoleTranslate" do
  let( :translate_class ) { SlimKeyfy::Console::Translate }
  let( :single_lined_string ) { '  .some_div\n    | Some Multiline String is displayed here\n'.split('\n') }

  describe "join multilines" do
    context "join with vert bar indent" do
      let(:multi_line) {'  .some_div\n    | Some Multiline\n     | String is displayed here'}
      it {
        single_lined_string == translate_class.join_multiline( multi_line.split('\n') )
      }
    end

    context "join with whitespaces indent" do
      let(:multi_line) {'  .some_div\n    | Some Multiline\n       String is displayed here'}
      it {
        single_lined_string == translate_class.join_multiline( multi_line.split('\n') )
      }
    end
  end

end