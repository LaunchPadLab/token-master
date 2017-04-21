require 'simplecov'
SimpleCov.start do
  add_filter './test/'
end
require 'minitest/autorun'
require 'token_master'
