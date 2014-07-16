Slimkeyfy
=========
**Extract rails i18n keys from slim partials and replace strings with t() method calls.**

Install
=======
To install this gem

<pre><code>
    git clone https://github.com/phrase/slimkeyfy.git 
    cd slimkeyfy
    gem install slimkeyfy-0.0.1.gem
</code></pre>

Usage
=====
**Two modes are supported:**

1. **Stream** - default mode, walks through the given file and if an untagged plain string is found you are prompted to apply (yes) or discard (no). You are prompted until the end of the file.
2. **unix_diff** - applies all changes and uses colordiff or diff to show any changes between the files. Faster if you do not like to approve every single matching line.

default stream mode
<pre><code>
  slimkeyfy path/to/your/file.html.slim 
</code></pre>
unix_diff with -d --diff
<pre><code>
  slimkeyfy path/to/your/file.html.slim --diff
</code></pre>
recursively with through all files from a given dir -r --recursive
<pre><code>
  slimkeyfy path/to/your/dir/ --diff --recursive
</code></pre>
A Backup (.bak) of the old file will be created e.g. index.html.slim => index.html.slim.bak

Testing
=======

To test the application simply call rspec spec/.. from the root directory of slimkeyfy

<pre><code>
    bundle install
    bundle exec rspec spec/
</code></pre>

Example
<pre><code>
 # views/user/new.html.slim
 h1 Hello World!
    
 # execute
 slimkeyfy user/new.html.slim
    
 # user/new.html.slim
 h1= t('user_new.hello_world')
    
 # user/new.html.slim.bak
 h1 Hello World!
    
 # locale_name.yml
 locale:
    user_new.hello_world: Hello World!
</code></pre>