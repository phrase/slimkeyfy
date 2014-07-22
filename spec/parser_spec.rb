require_relative '../lib/slimkeyfy/parser'

describe "Transformer should transform .slim correctly" do

  let( :key_base ) { "key_base.new"}
  subject  { Transformer.new(word, nil).transform }

  describe "with basic html tags" do
    context "with h1 html tag" do
      let(:word){ Word.new("  h1 Hello World!", key_base) }
      it {should == [
        "  h1= t('.hello_world')", 
        {"#{key_base}.hello_world" => "Hello World!"}]
      }
    end
    context "with small html tag" do
      let(:word){ Word.new("  small Hello World!", key_base) }
      it {should == [
        "  small= t('.hello_world')", 
        {"#{key_base}.hello_world" => "Hello World!"}]
      }
    end
    context "with pipe | slim symbol" do
      let(:word){ Word.new("  | Hello World!", key_base) }
      it {should == [
        "  = t('.hello_world')", 
        {"#{key_base}.hello_world" => "Hello World!"}]
      }
    end
    context "with pipe and ampersand" do
      let(:word){ Word.new("  | &nbsp;Hello World!", key_base) }
      it {should == [
        "  = t('.hello_world')", 
        {"#{key_base}.hello_world" => " Hello World!"}]
      }
    end
  end

  describe "with invalid tags" do
    context "with valid tag and nothing to translate" do
      let(:word){ Word.new("  actions", key_base) }
      it {should == [nil, nil]}
    end
  end

  describe "when line starts with equal" do
    context "when word contains link_to" do
      let( :raw_input ) { '= link_to "Settings", "#settings", data: { toggle: "tab" }' }
      let(:word) { Word.new(raw_input, key_base) }
      let(:translated) { '= link_to t(\'.settings\'), "#settings", data: { toggle: "tab" }' }
      it { should == [ translated , {"key_base.new.settings"=>"Settings"}] }
    end

    context "when word contains [a-z].input"  do
      let( :raw_input ) { '= f.input :max_characters_allowed, label: "Max. Characters", hint: "Shows an indicator how..."' }
      let(:word) { Word.new(raw_input, key_base) }
      let(:translated) { 
        "= f.input :max_characters_allowed, label: t('.max_characters'), hint: t('.shows_an_indicator_how')" 
      }
      let(:word_translation) { {"key_base.new.max_characters"=>"Max. Characters", "key_base.new.shows_an_indicator_how"=>"Shows an indicator how..."} }
      it { should == [ translated , word_translation] }
    end 

    context "with link_to title and 'title' attribute" do
      let( :raw_input ) { '= link_to "Add the first locale", new_project_locale_path(current_project), class: "modalized", data: {"modal-flavor" => "form"}, title: "Add Locale"' }
      let(:word) { Word.new(raw_input, key_base) }
      let(:translated) { 
        "= link_to t('.add_the_first_locale'), new_project_locale_path(current_project), class: \"modalized\", data: {\"modal-flavor\" => \"form\"}, title: t('.add_locale')"
      }
      let(:word_translation) { {"key_base.new.add_the_first_locale"=>"Add the first locale", "key_base.new.add_locale"=>"Add Locale"} }
      it { should == [ translated , word_translation] }
    end

    context "it should render too much with interpolated strings" do
      let( :raw_input ) { '= f.input :is_plural, inline_label: "Enable pluralization for this key", hint: "#{link_to("What does that mean?", article_path(slug: "working-with-phrase/pluralization"), target: "_blank")}".html_safe'}
      let(:word) { Word.new(raw_input, key_base) }
      let(:translated) { 
        '= f.input :is_plural, inline_label: t(\'.enable_pluralization_for_this\'), hint: t(\'.link_to_what\')'
      }
      let(:word_translation) { {"key_base.new.enable_pluralization_for_this"=>"Enable pluralization for this key", "key_base.new.link_to_what"=>'#{link_to("What does that mean?", article_path(slug: "working-with-phrase/pluralization"), target: "_blank")}'} }
      it { should == [ translated , word_translation] }
    end

    context "iconified links with several translatable attributes should work" do
      let( :raw_input ) { '= link_to iconified("Hello World!", :pencil), title: "Hi there! How are, you?!", :translation_search => {:query => translation.translation_key.nil? ? "" : "\"#{translation.translation_key.name}\"" }), placeholder: "Hi there! How are, you?!", :class => "btn btn-default btn-sm tooltipped", hint: "Hi! What up?"'}
      let(:word) { Word.new(raw_input, key_base) }
      let(:translated) { 
        '= link_to iconified(t(\'.hello_world\'), :pencil), title: t(\'.hi_there_how_are\'), :translation_search => {:query => translation.translation_key.nil? ? "" : "\"#{translation.translation_key.name}\"" }), placeholder: t(\'.hi_there_how_are\'), :class => "btn btn-default btn-sm tooltipped", hint: t(\'.hi_what_up\')'
      }
      let(:word_translation) { {"key_base.new.hello_world"=>"Hello World!", "key_base.new.hi_there_how_are"=>"Hi there! How are, you?!", "key_base.new.hi_what_up"=>"Hi! What up?"} }
      it { should == [ translated , word_translation] }
    end

    context "when word contains link_to" do
      let( :raw_input ) { '= link_to "Settings", "#settings", data: { toggle: "tab" }' }
      let(:word) { Word.new(raw_input, key_base) }
      let(:translated) { '= link_to t(\'.settings\'), "#settings", data: { toggle: "tab" }' }
      it { should == [ translated , {"key_base.new.settings"=>"Settings"}] }
    end

    context "when word contains link_to" do
      let( :raw_input ) { 'span= link_to "Settings", "#settings", data: { toggle: "tab" }' }
      let(:word) { Word.new(raw_input, key_base) }
      let(:translated) { 'span= link_to t(\'.settings\'), "#settings", data: { toggle: "tab" }' }
      it { should == [ translated , {"key_base.new.settings"=>"Settings"}] }
    end

    context "when line contains a translatable label" do
      let( :raw_input ) { '= f.input :data_type, label: "Type", hint: "Some formats lol"' }
      let(:word) { Word.new(raw_input, key_base) }
      let(:translated) { "= f.input :data_type, label: t('.type'), hint: t('.some_formats_lol')" }
      it { should == [ translated , {"key_base.new.type"=>"Type", "key_base.new.some_formats_lol" => "Some formats lol"}] }
    end

    context "when line contains a translatable placeholder" do
      let( :raw_input ) { '= f.input :query, placeholder: "Search translations by content", required: false, input_html: { class: "input-lg", tabindex: 2 }' }
      let(:word) { Word.new(raw_input, key_base) }
      let(:translated) { '= f.input :query, placeholder: t(\'.search_translations_by_content\'), required: false, input_html: { class: "input-lg", tabindex: 2 }' }
      it { should == [ translated , {"key_base.new.search_translations_by_content"=>"Search translations by content"}] }
    end

    context "when line contains a translatable submit_tag" do
      let( :raw_input ) { '= submit_tag "Search", class: "btn btn-primary"' }
      let(:word) { Word.new(raw_input, key_base) }
      let(:translated) { '= submit_tag t(\'.search\'), class: "btn btn-primary"' }
      it { should == [ translated , {"key_base.new.search"=>"Search"}] }
    end 

    context "when line contains a translatable submit_tag" do
      let( :raw_input ) {  "= small_button 'Upgrade Account', blabla" }
      let(:word) { Word.new(raw_input, key_base) }
      let(:translated) {  "= small_button t('.upgrade_account'), blabla" }
      it { should == [ translated , {"key_base.new.upgrade_account"=>"Upgrade Account"}] }
    end
  end
end

describe "TranslationKeyBuilder" do
  subject { TranslationKeyBuilder.new(translation).generate_key_name }

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







