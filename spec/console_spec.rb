#!/usr/bin/env ruby

require_relative '../lib/slimkeyfy'

describe "given a .slim file" do
  let ( :input ) { "./spec/test_files/_form.html.slim" }
  let ( :yaml_file ) { "./spec/test_files/en.yml" }
  let ( :locale ) { "en" }
end 