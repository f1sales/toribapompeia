# frozen_string_literal: true

source 'https://rubygems.org'

gem 'f1sales_custom-email', github: 'marciok/f1sales_custom-email', branch: 'master'
gem 'f1sales_custom-hooks', github: 'marciok/f1sales_custom-hooks', branch: 'master'
gem 'f1sales_helpers', github: 'f1sales/f1sales_helpers', branch: 'master'

gemspec

gem 'http'
gem 'rake', '~> 13.0'

group :development do
  gem 'rubocop', require: false
end

group :development, :test do
  gem 'byebug'
  gem 'rspec', '~> 3.0'
  gem 'webmock'
end
