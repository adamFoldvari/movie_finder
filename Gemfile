source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.2.2"

gem "rails"
gem "sprockets-rails"
gem "puma"
gem "jbuilder"
gem "tzinfo-data"
gem "bootsnap", require: false
gem 'dalli'

group :development, :test do
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
  gem 'rspec-rails'
  gem 'rspec-html-matchers'
  gem 'webmock'
end

group :development do
  gem "web-console"
  gem "dotenv-rails"
end

