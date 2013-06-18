source 'https://rubygems.org'

gem 'sinatra'
gem 'sinatra-contrib'
gem 'sinatra-activerecord', :github => 'zenbaku/sinatra-activerecord'
gem "activerecord"
gem 'rake'
gem 'json'

group :development do
  gem 'sqlite3'
  gem 'shotgun'
  gem "tux"
end

group :production do
  gem 'pg'
end

# testing
group :test do
  gem 'sqlite3'
  gem 'rspec'
  gem 'rack-test'  
end