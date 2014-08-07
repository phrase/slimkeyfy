Slimkeyfy
========
Extract plain Strings from .slim views and rails controllers to replace them with I18n's t() method. Keys with it's translations will be streamed to a .yml output.
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
------
```unix
git clone https://github.com/phrase/slimkeyfy.git 
cd slimkeyfy
gem build slimkeyfy.gemspec
gem install slimkeyfy-0.0.6.gem
# Later: gem install slimkeyfy
```

Approach
--------
The current approach goes for a 80/20 solution. Tagging strings in html with translation tags is extremely error prone so I decided that the user should verify each change. That means that you will be prompted for each possible translation to choose whether you like to keep it, to ignore it or to tag it. The collected data is then processed into a yaml file. If you don't provide a yaml  one will be created. All your processed views and resulting translations will be merged with the existing.

Suggested Approach
-----------------
As HTML is not 100% parsable there will be errors in the conversion. To minimize your error rate I suggest to approach each view or view_folder individually. The i18n-tasks gem helped a lot by finding errors. Always double check your views and make sure that everything went smoothly. Especially double check all your links.

Usage
-----
```unix
slimkeyfy INPUT_FILENAME_OR_DIRECTORY LOCALE (e.g. en, fr) [YAML_FILE] [Options]
```
- If you do not provide a yaml_file - one will be created at configs/locales/view_folder_name.locale.yml. 
- If you provide one make sure that the top level locale matches your provided locale

Two modes are supported:

1. **Stream** - **recommended** - default mode, walks through the given file/files and if a regex hits you will be prompted to apply (y)es, discard (n)o, tag (x) (like a git conflict with information) or (a)bort (only aborts the current file).

2. **Diff** - **currently not recommended** - Applies all changes and uses colordiff or diff to show any changes between the files. Faster if you do not like to approve every single matching line. It is also more error prone because some faulty translations will be translated nonetheless.

default stream mode
```unix
slimkeyfy path/to/your/file.html.slim en
```
default stream mode with given yml file (has to be valid yaml! with the top level locale matching your provided locale)
```unix
slimkeyfy path/to/your/dir/ en path/to/your/en.yml
```
unix_diff with -d --diff
```unix
slimkeyfy path/to/your/file.html.slim path/to/your/en.yml en --diff
```
A Backup (.bak) of the old file will be created e.g. index.html.slim => index.html.slim.bak

Testing
-----

To test the application simply call rspec spec/.. from the root directory of slimkeyfy

```unix
bundle install
bundle exec rspec spec/
```

Example Usage
-------------
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
 
> slimkeyfy app/views/user/ en
... choose your changes here (y/n/x/a)

> ls app/views/user/
    new.html.slim
    show.html.slim
    new.html.slim.bak
    show.html.slim.bak
    
> ls config/locales/
    user.en.yml
    en.yml
    
> cat ../user/new.html.slim.bak
  h1 Hello World!
    
> cat ../user/new.html.slim
  h1= t('.hello_world')
 
> cat config/locales/en.yml
  --
  en:
    keys..
          
> cat config/locales/user.en.yml
  ---
  en:
    user:
      new:
        hello_world: Hello World!
      show:
        ...
```
PhraseApp Integration
--------------------
Now that you processed your views and moved the generated keys to your localization files it is quite easy to push it to PhraseApp. If you have not set up your account yet [take a look here](https://phraseapp.com/docs/about/setup-your-translations-with-phraseapp?language=en). Make sure that the latest gem of PhraseApp is installed by simply typing:
```unix
> gem install phrase
```
If you are already familiar with the PhraseApp gem you can upload your translation/localization files now (normally found in app_folder/config/locales/ or app_folder/phrase/locales/. Otherwise have a look at our [detailed guide](https://phraseapp.com/docs/about/access-your-locale-files-with-the-api-client?language=en).

Todo
----
- Yaml placeholders are currently not supported (I am working on it!).
- a lot of regexp can be added or extended
- whitespace handling is currently very simple (fills translations with whitespaces)
- currently you are prompted for all hits - I would like to do 70-80% automatically and prompt for the 20-30% that cannot be decided upon.
- a dry run option where you can see what will happen if you convert.
- Options/flags (no_backup_creation, dry_run) 

Issues
------
- If you choose to take a lot of files at one time make sure to go through with it. It is not an issue to completely rerun everything (already translated strings are ignored) but should be avoided.
- some hits will not be correct, some things that should be found are not and sometimes the regex engine won't work for mysterious reasons. Slimkeyfy is a helper, it does not provide full automatization. It might make your work a little easier.

Helpful Information
-------------------
* Other tools, not slim specific for this task is the [i15r gem](https://github.com/balinterdi/i15r). It can process .haml and .erb.
* I strongly recommend checking your translated app with the [i18n-tasks gem](https://github.com/glebm/i18n-tasks). It is a great tool in     finding missing and unused translations.
