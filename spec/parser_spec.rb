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

=begin
    context "with interpolated string" do
      let( :raw_input ) { '= f.input :is_plural, inline_label: "Enable pluralization for this key", hint: "#{link_to("What does that mean?", article_path(slug: "working-with-phrase/pluralization"), target: "_blank")}".html_safe' }
      let(:word) { Word.new(raw_input, key_base) }
      let(:translated) { 
        '= f.input :is_plural, inline_label: t(\'.enable_pluralization_for_this\'), hint: t(\'.link_to_what\').html_safe'
      }
      let(:word_translation) { {"key_base.new.enable_pluralization_for_this"=>"Enable pluralization for this key", "key_base.new.link_to_what"=>'#{link_to("What does that mean?", article_path(slug: "working-with-phrase/pluralization"), target: "_blank")}'} }
      it { should == [ translated , word_translation] }
    end
'= link_to iconified("asd", :pencil), title: "Hi there! How are, you?!", project_locale_translations_path(current_project, translation.locale, :translation_search => {:query => translation.translation_key.nil? ? "" : "\"#{translation.translation_key.name}\"" }), placeholder: "Hi there! How are, you?!", :class => "btn btn-default btn-sm tooltipped", hint: "absbd, ashdhasd, \" w00t \" asdkaskd"',
  '= link_to "Settings", "#settings", data: { toggle: "tab" }',
  '= f.input :data_type, label: "Type", collection: translation_key_data_types, include_blank: false, hint: "Some formats (e.g. YAML) support data types, leave it to String otherwise"',
  '= f.input :is_plural, label: false, inline_label: "Enable pluralization for this key", hint: "#{link_to("What does that mean?", article_path(slug: "working-with-phrase/pluralization"), target: "_blank")}".html_safe',
  '= link_to "What does that mean?", "http://support.phraseapp.com/knowledgebase/articles/333155", target: "_blank"',
  '= f.input :query, placeholder: "Search translations by content, default content, key name or with tag:tag_name", label: false, wrapper: false, required: false, input_html: { class: "input-lg", tabindex: 2 }',
  '= submit_tag "Search", class: "btn btn-primary"',
  'span.caption= link_to "Unverified", params.deep_merge( page: 1, translation_search: {filter: params[:translation_search][:filter] == "unverified" ? :none : :unverified } )',
  "= small_button 'Upgrade Account', my_account_subscriptions_path, class: 'btn btn-primary', only_manager: true"
=end

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







