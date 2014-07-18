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
```
Usage
-----
Two modes are supported:

1. **Stream** - default mode, walks through the given file and if an untagged plain string is found you are prompted to apply (y)es discard (n)o or to tag (x) if you would like it to be marked for later (like a git conflict).

2. **Diff** - currently not recommended in recursive mode. Applies all changes and uses colordiff or diff to show any changes between the files. Faster if you do not like to approve every single matching line. Also more error prone

default stream mode
```unix
slimkeyfy path/to/your/file.html.slim path/to/your/locale.yml
```
unix_diff with -d --diff
```unix
slimkeyfy path/to/your/file.html.slim path/to/your/locale.yml --diff
```
recursively with through all files from a given dir -r --recursive
```unix
slimkeyfy path/to/your/dir/ path/to/your/locale.yml --diff --recursive
```
A Backup (.bak) of the old file will be created e.g. index.html.slim => index.html.slim.bak

If you do not like the output and want to get rid of the .baks use slimrestore to move the .bak content to your original files and remove the .baks afterwards
```unix
slimrestore path/to/some/changed/view/
```

Testing
-----

To test the application simply call rspec spec/.. from the root directory of slimkeyfy

```unix
    bundle install
    bundle exec rspec spec/
```

Example USAGE
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
 
> slimkeyfy app/views/user/ config/locales/en.yml
... your changes here (y/n/x)

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
3. The matching of some html is still imperfect. As a result you will encounter lines that do not need to be translated therefore encouring the stream mode (default) for now.




