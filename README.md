Slimkeyfy
========
Extract rails i18n keys from slim partials and replace strings with t() method calls adding unique nested keys to selected .yml localization file.
```slim
# user/show.html.slim
h1 Hello World!
# converts to
h1= t('.hello_world') 
# some yaml
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
gem install slimkeyfy-0.0.2.gem
# Later: gem install slimkeyfy
```

Approach
--------
The current approach like most, go for a 80/20 solution. Localizing files is extremely error prone so I decided that the user should verify each change. That means that you will be prompted for each possible translation to choose whether you like to keep it, to ignore it or to tag it. In the future it might be possible to parse the 80% automatically and ask for the 20% in return.

Usage
-----
```unix
slimkeyfy INPUT_FILENAME_OR_DIRECTORY LOCALIZATION_YAML_FILE LOCALE (e.g. en, fr) [Options]
```
Two modes are supported:

1. **Stream** - **recommended** - default mode, walks through the given file and if an untagged plain string is found you are prompted to apply (y)es, discard (n)o, tag (x) if you would like it to be marked for later (like a git conflict) or to (a)bort (only aborts the current file process).

2. **Diff** - **currently not recommended** - Applies all changes and uses colordiff or diff to show any changes between the files. Faster if you do not like to approve every single matching line. It is also more error prone because some faulty translations will be translated nonetheless. In the future somewhat 80% will be parsed and you will be prompted for 20%.

default stream mode
```unix
slimkeyfy path/to/your/file.html.slim path/to/your/en.yml en
```
unix_diff with -d --diff
```unix
slimkeyfy path/to/your/file.html.slim path/to/your/en.yml en --diff
```
recursively walks through all files from a given dir -r --recursive
```unix
slimkeyfy path/to/your/dir/ path/to/your/en.yml en --recursive
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
 
> slimkeyfy app/views/user/ config/locales/en.yml en
... choose your changes here (y/n/x/a)

> ls app/views/user/
    new.html.slim
    show.html.slim
    new.html.slim.bak
    show.html.slim.bak
    
> ls config/locales/
    en.yml
    en.yml.bak
    
> cat ../user/new.html.slim.bak
  h1 Hello World!
    
> cat ../user/new.html.slim
  h1= t('.hello_world')
 
> cat config/locales/en.yml.bak
  --
  en:
    keys..
          
> cat config/locales/en.yml
  --
  en:
    keys..
    user:
      new:
        hello_world: Hello World!
      show:
        ...
```

Issues
------

1. Recursively updating can be dangerous as there are moments (ctrl + c) where you can corrupt a file. Normally this only affects the file currently processed. Also the localization.yml can get out of sync.
2. If you choose to take a lot of files at one time make sure to go through with it. It is not an issue to completely rerun everything (already translated strings are ignored) but should be avoided.
