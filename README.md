slimkeyfy
=========

Extract rails i18n keys from slim partials and replace strings with t() method calls.


Testing & Usage
===============

To use this you have to reference the translateSlim.rb file.
  
  translateSlim.rb path/to/your/file.html.slim

Currently there is only one mode. You have to verify all changes line per line (yes/no) to update.
Each line will be processed into the file with the name given. A Backup (.bak) of the old file
will be created.


  "h1 Überschrift" => "h1= t('.ueberschrift')"
