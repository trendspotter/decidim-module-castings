# frozen_string_literal: true

source "https://rubygems.org"

ruby RUBY_VERSION
DECIDIM_VERSION = '0.22.0'

gem "decidim", DECIDIM_VERSION
gem "decidim-castings", path: "."
gem "caxlsx"

gem "bootsnap"
gem "puma", ">= 4.3.3"
gem "uglifier", "~> 4.1"

group :development, :test do
  gem 'pry'
  gem "byebug", "~> 11.0", platform: :mri
  gem "decidim-dev", DECIDIM_VERSION
  gem "faker", "~> 1.9"
  gem "rubocop-performance"
  gem "simplecov", require: false
end

group :development do
  gem "letter_opener_web", "~> 1.3"
  gem "listen", "~> 3.1"
  gem "spring", "~> 2.0"
  gem "spring-watcher-listen", "~> 2.0"
  gem "web-console", "~> 3.5"
end
