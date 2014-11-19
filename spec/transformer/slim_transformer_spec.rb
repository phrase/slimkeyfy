require_relative '../../lib/slimkeyfy/'

describe "SlimTransformer" do
  let( :key_base ) { "key_base.new"}
  let( :extension ) { "slim" }
  let( :line ) { "" }
  let( :word ) { SlimKeyfy::Transformer::Word.new(line, key_base, extension) } 

  subject  { SlimKeyfy::Transformer::SlimTransformer.new(word, nil).transform }

  describe "with basic html tags" do
    context "with h1 html tag" do
      let(:line){ "  h1 Hello World!" }
      it {should == [
        "  h1= t('.hello_world')", 
        {"#{key_base}.hello_world" => "Hello World!"}]
      }
    end
    context "with small html tag" do
      let(:line){ "  small Hello World!" }
      it {should == [
        "  small= t('.hello_world')", 
        {"#{key_base}.hello_world" => "Hello World!"}]
      }
    end
    context "with pipe | slim symbol" do
      let(:line){ "  | Hello World!" }
      it {should == [
        "  = t('.hello_world')", 
        {"#{key_base}.hello_world" => "Hello World!"}]
      }
    end
    context "with ' slim symbol" do
      let(:line){ "  ' Hello World!" }
      it {should == [
        "  => t('.hello_world')", 
        {"#{key_base}.hello_world" => "Hello World!"}]
      }
    end
    context "with pipe and ampersand" do
      let(:line){ "  | &nbsp;Hello World!" }
      it {should == [
        "  =< t('.hello_world')", 
        {"#{key_base}.hello_world" => "Hello World!"}]
      }
    end
    context "with dotted html" do
      let(:line){ "  aside.pointer Hello World!" }
      it {should == [
        "  aside.pointer= t('.hello_world')", 
        {"#{key_base}.hello_world" => "Hello World!"}]
      }
    end
  end

  describe "html/slim whitespacing rules" do
    context "with leading and trailing nbsp; and |" do
      let(:line){ "| &nbsp;Hello World!&nbsp;" }
      it {should == [
        "=<> t('.hello_world')", 
        {"#{key_base}.hello_world" => "Hello World!"}]
      }
    end

    context "with leading nbsp; and |" do
      let(:line){ "| &nbsp;Hello World!" }
      it {should == [
        "=< t('.hello_world')", 
        {"#{key_base}.hello_world" => "Hello World!"}]
      }
    end

    context "with trailing nbsp; and |" do
      let(:line){ "| Hello World!&nbsp;" }
      it {should == [
        "=> t('.hello_world')", 
        {"#{key_base}.hello_world" => "Hello World!"}]
      }
    end

    context "with | and regular whitespace" do
      let(:line){ "|  Hello World!" }
      it {should == [
        "= t('.hello_world')", 
        {"#{key_base}.hello_world" => "Hello World!"}]
      }
    end

    context "with leading and trailing nbsp; and '" do
      let(:line){ "' &nbsp;Hello World!&nbsp;" }
      it {should == [
        "=<> t('.hello_world')", 
        {"#{key_base}.hello_world" => "Hello World!"}]
      }
    end

    context "with leading nbsp; and '" do
      let(:line){ "' &nbsp;Hello World!" }
      it {should == [
        "=<> t('.hello_world')", 
        {"#{key_base}.hello_world" => "Hello World!"}]
      }
    end

    context "with trailing nbsp; and '" do
      let(:line){ "' Hello World!&nbsp;" }
      it {should == [
        "=> t('.hello_world')", 
        {"#{key_base}.hello_world" => "Hello World!"}]
      }
    end

    context "with ' and regular whitespace" do
      let(:line){ "'  Hello World!" }
      it {should == [
        "=> t('.hello_world')", 
        {"#{key_base}.hello_world" => "Hello World!"}]
      }
    end
  end


  describe "with translated tags" do
    context "with valid tag and nothing to translate" do
      let(:line){ "p= t '.actions'" }
      it {should == [nil, nil]}
    end

    context "with valid tag and nothing to translate" do
      let(:line){ "= link_to 'blubb', hint: t '.actions' " }
      it {should == ["= link_to t('.blubb'), hint: t '.actions' ", {"key_base.new.blubb"=>"blubb"}]}
    end
  end

  describe "with invalid tags" do
    context "with valid tag and nothing to translate" do
      let(:line){ "  actions" }
      it {should == [nil, nil]}
    end
    context "with invalid line" do
      let(:line){ '  - widget_text = "Use stuff for more stuff: #{stuff}"' }
      it { should == [nil, nil] }
    end
    context "it should not work with complex interpolated strings" do
      let( :line ) { '= f.input :is_plural, inline_label: "Enable pluralization for this key", hint: "#{link_to("What does that mean?", article_path(slug: "working-with-phrase/pluralization"), target: "_blank")}".html_safe'}
      let(:translated) { 
        '= f.input :is_plural, inline_label: t(\'.enable_pluralization_for_this\'), hint: t(\'.link_to\')What does that mean?", article_path(slug: "working-with-phrase/pluralization"), target: "_blank")}".html_safe'
      }
      let(:word_translation) { {"key_base.new.enable_pluralization_for_this"=>"Enable pluralization for this key", "key_base.new.link_to"=>'#{link_to('} }
      it { should == [ translated , word_translation] }
    end
  end

  describe "when line starts with equal" do
    context "when word contains link_to" do
      let( :line ) { '= link_to "Settings", "#settings", data: { toggle: "tab" }' }
      let(:translated) { '= link_to t(\'.settings\'), "#settings", data: { toggle: "tab" }' }
      it { should == [ translated , {"key_base.new.settings"=>"Settings"}] }
    end

    context "when word contains link_to" do
      let( :line ) { 'p Not sure yet? Learn more and #{link_to("browse our features", features_path)} or #{link_to("Try our demo", demo_path)}.' }
      let(:translated) { 'p= t(\'.not_sure_yet_learn\')' }
      let(:result_hash) {{"key_base.new.browse_our_features" => "browse our features", "key_base.new.try_our_demo" => "Try our demo", "key_base.new.not_sure_yet_learn" => 'Not sure yet? Learn more and #{link_to(t(\'.browse_our_features\'), features_path)} or #{link_to(t(\'.try_our_demo\'), demo_path)}.'}}
      it { should == [ translated , result_hash] }
    end

    context "when word contains [a-z].input"  do
      let( :line ) { '= f.input :max_characters_allowed, label: "Max. Characters", hint: "Shows an indicator how..."' }
      let(:translated) { 
        "= f.input :max_characters_allowed, label: t('.max_characters'), hint: t('.shows_an_indicator_how')" 
      }
      let(:word_translation) { {"key_base.new.max_characters"=>"Max. Characters", "key_base.new.shows_an_indicator_how"=>"Shows an indicator how..."} }
      it { should == [ translated , word_translation] }
    end 

    context "with link_to title and 'title' attribute" do
      let( :line ) { '= link_to "Add the first locale", new_project_locale_path(current_project), class: "modalized", data: {"modal-flavor" => "form"}, title: "Add Locale"' }
      let(:translated) { 
        "= link_to t('.add_the_first_locale'), new_project_locale_path(current_project), class: \"modalized\", data: {\"modal-flavor\" => \"form\"}, title: t('.add_locale')"
      }
      let(:word_translation) { {"key_base.new.add_the_first_locale"=>"Add the first locale", "key_base.new.add_locale"=>"Add Locale"} }
      it { should == [ translated , word_translation] }
    end

    context "iconified links with several translatable attributes should work" do
      let( :line ) { '= link_to iconified("Hello World!", :pencil), title: "Hi there! How are, you?!", :translation_search => {:query => translation.translation_key.nil? ? "" : "\"#{translation.translation_key.name}\"" }), placeholder: "Hi there! How are, you?!", :class => "btn btn-default btn-sm tooltipped", hint: "Hi! What up?"'}
      let(:translated) { 
        '= link_to iconified(t(\'.hello_world\'), :pencil), title: t(\'.hi_there_how_are\'), :translation_search => {:query => translation.translation_key.nil? ? "" : "\"#{translation.translation_key.name}\"" }), placeholder: t(\'.hi_there_how_are\'), :class => "btn btn-default btn-sm tooltipped", hint: t(\'.hi_what_up\')'
      }
      let(:word_translation) { {"key_base.new.hi_there_how_are"=>"Hi there! How are, you?!", "key_base.new.hi_what_up"=>"Hi! What up?", "key_base.new.hello_world" => "Hello World!"} }
      it { should == [ translated , word_translation] }
    end

    context "when word contains link_to" do
      let( :line ) { '= link_to "Settings", "#settings", data: { toggle: "tab" }' }
      let(:translated) { '= link_to t(\'.settings\'), "#settings", data: { toggle: "tab" }' }
      it { should == [ translated , {"key_base.new.settings"=>"Settings"}] }
    end

    context "when word contains link_to" do
      let( :line ) { 'span= link_to "Settings", "#settings", data: { toggle: "tab" }' }
      let(:translated) { 'span= link_to t(\'.settings\'), "#settings", data: { toggle: "tab" }' }
      it { should == [ translated , {"key_base.new.settings"=>"Settings"}] }
    end

    context "when line contains a translatable label" do
      let( :line ) { '= f.input :data_type, label: "Type", hint: "Some formats lol"' }
      let(:translated) { "= f.input :data_type, label: t('.type'), hint: t('.some_formats_lol')" }
      it { should == [ translated , {"key_base.new.type"=>"Type", "key_base.new.some_formats_lol" => "Some formats lol"}] }
    end

    context "when line contains a translatable placeholder" do
      let( :line ) { '= f.input :query, placeholder: "Search translations by content", required: false, input_html: { class: "input-lg", tabindex: 2 }' }
      let(:translated) { '= f.input :query, placeholder: t(\'.search_translations_by_content\'), required: false, input_html: { class: "input-lg", tabindex: 2 }' }
      it { should == [ translated , {"key_base.new.search_translations_by_content"=>"Search translations by content"}] }
    end

    context "when line contains a translatable submit_tag" do
      let( :line ) { '= submit_tag "Search", class: "btn btn-primary"' }
      let(:translated) { '= submit_tag t(\'.search\'), class: "btn btn-primary"' }
      it { should == [ translated , {"key_base.new.search"=>"Search"}] }
    end 

    context "when line contains a translatable submit_tag" do
      let( :line ) {  "= small_button 'Upgrade Account', blabla" }
      let(:translated) {  "= small_button t('.upgrade_account'), blabla" }
      it { should == [ translated , {"key_base.new.upgrade_account"=>"Upgrade Account"}] }
    end

    context "when line contains a translatable submit_tag" do
      let( :line ) { "  = f.input :some_input, label: \"Your friends' emails\", hint: \"Separate multiple email addresses by comma\", input_html: {class: \"input-block-level\"}" }
      let(:translated) { "  = f.input :some_input, label: t('.your_friends_emails'), hint: t('.separate_multiple_email_addresses'), input_html: {class: \"input-block-level\"}" }
      it { should == [ translated , 
        {"key_base.new.your_friends_emails" => "Your friends' emails",
         "key_base.new.separate_multiple_email_addresses" => "Separate multiple email addresses by comma"}]
        }
    end

    context "when line contains a button with symbolic reference" do
      let( :line ) { " = f.button :submit, \"Add Language\", class: \"btn btn-primary\", title: \"A Title\"" }
      let(:translated) { " = f.button :submit, t('.add_language'), class: \"btn btn-primary\", title: t('.a_title')" }
      it { should == [ translated , 
        {"key_base.new.a_title" => "A Title",
         "key_base.new.add_language" => "Add Language"}]
        }
    end

    context "when line contains a alt tag" do
      let( :line ) { "= link_to image_tag(\"application/logo.png\", alt: \"PhraseApp\", height: 21, width: 106), root_path, class: \"navbar-brand\"" }
      let(:translated) { "= link_to image_tag(\"application/logo.png\", alt: t('.phraseapp'), height: 21, width: 106), root_path, class: \"navbar-brand\"" }
      it { should == [ translated , {"key_base.new.phraseapp" => "PhraseApp"}]}
    end

    context "when line contains a include_blank tag" do
      let( :line ) { "= f.input :currency, collection: available_currencies, required: false, include_blank: \"Aha, I delete selected\", selected: @billing_currency, hint: t('.please_select_the_currency')" }
      let(:translated) { "= f.input :currency, collection: available_currencies, required: false, include_blank: t('.aha_i_delete_selected'), selected: @billing_currency, hint: t('.please_select_the_currency')" }
      it { should == [ translated , {"key_base.new.aha_i_delete_selected" => "Aha, I delete selected"}]}
    end

    context "when line contains a data tag followed by confirm tag" do
      let( :line ) { "= button_tag t('.delete_selected'), data: {confirm: \"Do you really want to delete this?\"}, class: \"btn btn-danger btn-sm\"" }
      let(:translated) { "= button_tag t('.delete_selected'), data: {confirm: t('.do_you_really_want')}, class: \"btn btn-danger btn-sm\"" }
      it { should == [ translated , {"key_base.new.do_you_really_want" => "Do you really want to delete this?"}]}
    end

    context "when line contains a data tag followed by content tag" do
      let( :line ) { "- key_stuff = \"#\{raw(t('.key_names', href: \"#\{link_to(\"W00t\", title: t('.key_names_column'), data: {content: \"Some more Content\", html: true})}\"" }
      let(:translated) { "- key_stuff = \"#\{raw(t('.key_names', href: \"#\{link_to(t('.w00t'), title: t('.key_names_column'), data: {content: t('.some_more_content'), html: true})}\"" }
      it { should == [ translated , 
        {"key_base.new.w00t" => "W00t",
         "key_base.new.some_more_content" => "Some more Content"}]
        }
    end
    
    context "when line contains a #" do
      let( :line ) { "# key_stuff = \"#\{raw(t('.key_names', href: \"#\{link_to(\"W00t\", title: t('.key_names_column'), data: {content: \"Some more Content\", html: true})}\"" }
      let(:translated) { "# key_stuff = \"#\{raw(t('.key_names', href: \"#\{link_to(t('.w00t'), title: t('.key_names_column'), data: {content: t('.some_more_content'), html: true})}\"" }
      it { should == [ translated , 
        {"key_base.new.w00t" => "W00t",
         "key_base.new.some_more_content" => "Some more Content"}]
        }
    end
  end
end