Slimkeyfy
=
Extract plain Strings from .slim views and Rails controllers to replace them with I18n's t() method. Keys with it's translations will be streamed to a YAML file.
```ruby
slimkeyfy app/views/users/show.html.slim en
# users/show.html.slim
h1 Hello World!
# converts to
h1= t('.hello_world') 
# config/locales/users.en.yaml
# en: 
#   user:
#     show:
#       hello_world: Hello World!
```

Install
-
```unix
git clone https://github.com/phrase/slimkeyfy.git 
cd slimkeyfy
gem build slimkeyfy.gemspec
gem install slimkeyfy-0.0.6.gem
# Later: gem install slimkeyfy
```

Approach
-
Most of the time tools like this go for a 80/20 approach stating that 80% can be done right and 20% have to be done manually. Our approach is similar but a bit different. Translating and tagging your Rails app can be error prone. In order to reduce this Slimkeyfy streams in every line that matches the regular expression engine and prompts you to take an action. This guarantees a higher quality but also gets us closer to the 90%. It might take a little more time than full automation. The collected data is then processed into a YAML file. If you don't provide a YAML one will be created. All your processed views and resulting translations will be merged with the existing YAML.

Usage
-
```unix
slimkeyfy INPUT_FILENAME_OR_DIRECTORY LOCALE (e.g. en, fr) [YAML_FILE] [Options]
```
- If you do not provide a YAML file - one will be created at configs/locales/view_folder_name.locale.yml
- If you provide one make sure that the top level locale matches your provided locale
- The YAML file will be loaded as a hash and deep_merged with the new found translations

**Stream** - walks through the given file/files and if a regex hits you will be prompted to apply (y)es, discard (n)o, tag (x) (like a git conflict with information) or (a)bort (only aborts the current file).

without YAML file
```unix
slimkeyfy path/to/your/file.html.slim en
```
with given YAML file (has to be valid YAML! with the top level locale matching your provided locale)
```unix
slimkeyfy path/to/your/dir/ en path/to/your/en.yml
```
A Backup (.bak) of the old file will be created e.g. index.html.slim => index.html.slim.bak

Example Usage
-
```unix
your_app_name/
  |- app/
    |- views/
      |- user/
        new.html.slim
        show.html.slim
      |- project/
        index.html.slim
        ...
    ...
  |- config/
    |- locales/
      en.yml
      ...
  ...

> pwd
../your_app_name/
 
> slimkeyfy app/views/users/ en
... choose your changes here (y/n/x/a)

> ls app/views/users/
    new.html.slim
    show.html.slim
    new.html.slim.bak
    show.html.slim.bak
    
> ls config/locales/
    user.en.yml
    en.yml
    
> cat ../users/new.html.slim.bak
  h1 Hello World!
    
> cat ../users/new.html.slim
  h1= t('.hello_world')
 
> cat config/locales/en.yml
  --
  en:
    keys..
          
> cat config/locales/users.en.yml
  ---
  en:
    users:
      new:
        hello_world: Hello World!
      show:
        ...
```
Suggested Workflow
-
As HTML is not 100% parsable there will be errors in the conversion. To minimize your error rate we suggest to approach each view or view_folder individually. The i18n-tasks gem helped a lot by finding errors. Always double check your views and make sure that everything went smoothly. Especially double check all your links. Here is an example workflow:
```ruby
# 1. create a branch for a view folder 
> git checkout -b users_localization

# 2. slimkeyfy the view folder you would like to tag
> slimkeyfy app/views/users/ en

# 3. go through all files and verify/add missing translations 
# (check against the .bak files (use git diff))
> git diff app/views/users/views.html.slim

# 4. add your translations + keys to your locale file(s)
# 4.1 optional: Use the I18n-tasks gem to find missing translations

# 5. go through all your views and click through everything to actually "see" what changed

# 6. If everything is fine - clean up (remove .baks)
> rm app/views/users/*.bak
# Optional: remove temporary YAML files
> rm config/locales/users.en.yml
```
Testing
-
To test the application simply call rspec spec/.. from the root directory of slimkeyfy
```unix
bundle install
bundle exec rspec spec/
```
PhraseApp Integration
-
Now that you processed your views and moved the generated keys to your localization files it is quite easy to push it to PhraseApp. If you have not set up your account yet [take a look here](https://phraseapp.com/docs/about/setup-your-translations-with-phraseapp?language=en). Make sure that the latest gem of PhraseApp is installed by simply typing:
```unix
> gem install phrase
```
If you are already familiar with the PhraseApp gem you can upload your translation/localization files now. For more details on your setup have a look at our [detailed guide](https://phraseapp.com/docs/about/access-your-locale-files-with-the-api-client?language=en).

Todo
-
- YAML placeholders are currently not supported (We are working on it!).
- currently you are prompted for all hits - We would like to do 70-80% automatically and prompt for the 20-30% that cannot be decided upon.
- adding / generalizing Regular Expressions for better hit rate
- a dry run option where you can see what will happen if you convert.
- Options/flags (no_backup_creation, dry_run) 

Issues
-
- If you choose to take a lot of files at one time make sure to go through with it. It is not an issue to completely rerun everything (already translated strings are ignored) but should be avoided.
- some hits will not be correct, some things that should be found are not and sometimes the regex engine won't work for mysterious reasons. Slimkeyfy is a helper, it does not provide full automation. It might make your work a little easier.

References
-
* Other tools, not slim specific for this task is the [i15r gem](https://github.com/balinterdi/i15r). It can process .haml and .erb.
* I strongly recommend checking your translated app with the [i18n-tasks gem](https://github.com/glebm/i18n-tasks). It is a great tool in     finding missing and unused translations.
* Always consult the [Official Rails Internationalization guide](http://guides.rubyonrails.org/i18n.html) if in doubt.
* Visit [PhraseApp on Github](https://github.com/phrase/phrase)
