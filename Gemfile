source 'https://rubygems.org'

gem 'rails', '3.2.14'

gem 'mongoid'#, "3.1.5"
gem 'devise', '2.2.8'
gem "devise-async"
gem 'devise_invitable', '~> 1.1.8'
# gem 'devise_invitable', :git => 'git@github.com:scambra/devise_invitable.git'

gem "redis"
#for using redis as cache store
#gem 'redis-rails'
gem 'mongoid-history'
gem 'whenever', :require => false

gem "resque", "1.24.1"
gem 'resque-scheduler', '~> 2.2.0'
#NEDD vlad gem on every server since it is added in RakeFile
gem "vlad", :require => false
gem "vlad-git", :require => false

if RUBY_PLATFORM =~ /mingw32/
  gem 'mini_magick', :path => '../minimagick', :ref => '6d0f8f953112cce6324a524d76c7e126ee14f392'
else
  gem "mini_magick"
  # Use unicorn as the app server
  gem 'unicorn'
  gem 'unicorn-worker-killer'
end
gem 'carrierwave-mongoid', :require => 'carrierwave/mongoid'

gem 'jquery-rails'

gem "nested_form"

gem 'remotipart', '~> 1.2'

gem 'truncate_html'

group :development do
  #gem "better_errors"
  gem "thin"
  gem 'debugger'
end
gem 'dynamic_form'
gem 'embedly'
gem 'country_select'
gem "validate_url"
gem 'sunspot_mongoid2'
gem 'sunspot_rails'
gem 'sunspot_solr'
gem "linkedin"
gem "omniauth"
gem "omniauth-linkedin"
gem "omniauth-facebook"
gem 'omniauth-twitter' 
gem 'devise-encryptable'
gem 'eventbrite-client'
gem 'rest-client'
gem 'subdomain-fu', :git => "git://github.com/nhowell/subdomain-fu.git"
gem 'wkhtmltopdf-binary'
gem 'wicked_pdf'
gem "uuidtools", "~> 2.1.3"
gem 'zip-zip', '~> 0.3'
gem 'rubyzip', '>= 1.0.0', :require => 'zip/zip'
gem 'kaminari'

#for captcha
gem 'simple_captcha2', require: 'simple_captcha'
#gem 'stripe', :git => 'https://github.com/stripe/stripe-ruby'
gem 'currencies', :require => 'iso4217'
gem 'eurovat'
gem 'savon', "1.2.0"#, :platforms => :ruby_19
gem "geocoder"
gem "apipie-rails"
gem 'rabl'
gem 'oj'
gem 'open_badges'
