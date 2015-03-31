# source 'https://rubygems.org'
source 'http://ruby.taobao.org'

gem 'rails', '3.2.21'
gem 'i18n',  '0.6.11'

group :assets do
  gem 'sass-rails',   '~> 3.2.5'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'

# To use Jbuilder templates for JSON
gem 'jbuilder'

group :test, :development do
  gem 'rspec-rails', '~> 3.0'
  gem 'spreadsheet'
end

group :test do
  gem 'json_spec'
  gem 'database_cleaner'
  gem 'rest-client'
  gem "factory_girl_rails", "~> 4.0"
  gem 'simplecov', :require => false
  gem 'simplecov-csv', :require => false
  gem 'rspec_junit_formatter'
end

gem "twitter-bootstrap-rails"
gem 'devise'
gem 'devise-token_authenticatable'
gem 'mongoid'
gem 'mongoid-paperclip', :require => "mongoid_paperclip"
gem 'paperclip-qiniu', :github => 'lidaobing/paperclip-qiniu'
gem 'paperclip-meta'
gem 'thin'
gem 'rails_admin'
gem "cancan"
gem 'simple_form'
gem 'kaminari'

# Fix rails console error on ubuntu
gem 'rb-readline', '~> 0.5.0', require: 'readline'

gem 'money-rails'
gem 'nested_form'
gem 'datetimepicker-rails', git: 'git://github.com/zpaulovics/datetimepicker-rails', tag: 'v1.0.0'
gem 'jquery_mobile_rails'
gem 'mongoid-history'
gem 'jquery-validation-rails'
gem 'ruby-pinyin'
gem 'mongoid_auto_increment', :git => 'git://github.com/teriyakisan/mongoid_auto_increment.git'

gem 'rqrcode-with-patches'
gem 'chartkick'
gem 'newrelic_rpm'
gem 'puma'

group :development, :test do
  gem 'http_logger' # log api request response
  gem 'pry'
  gem 'pry-rails'
  gem 'awesome_print' # pretty log

  gem 'quiet_assets'

  # debug
  gem 'better_errors'
  gem 'meta_request'
  gem 'binding_of_caller'
end


# clean code
gem 'inherited_resources'

group :development do
  gem 'capistrano'
  gem 'capistrano-bundler'
  gem 'capistrano-rails'
  gem 'capistrano-rbenv'
  gem 'capistrano3-puma'
  # highlight mongoid output for optimizing
  gem 'mongoid_colored_logger'
end

# api

gem 'grape'
gem 'grape-entity'
gem 'grape-jbuilder'
gem 'swagger-ui_rails'
gem 'grape-swagger-rails'
gem 'rack-cors'
gem 'mongoid_userstamp'
