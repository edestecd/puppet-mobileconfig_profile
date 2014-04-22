source 'https://rubygems.org'

ruby '1.9.3', :engine => 'ruby', :engine_version => '1.9.3', :patchlevel => '392'
#ruby=ruby-1.9.3-p392
#ruby-gemset=puppet-mobileconfig_profile

gem 'puppet'
gem 'facter'

# Bundle edge puppet instead:
# gem 'puppet', :git => 'git://github.com/puppetlabs/puppet.git'

# bundler requires these gems for puppet master
group :master do
  gem 'librarian-puppet'
  gem 'hiera-mysql', '~> 0.2.0'
  gem 'unicorn'
  gem 'rack'
  gem 'puppetdb-terminus', :git => 'https://github.com/edestecd/puppetdb-terminus.git'
end

group :linux_agent do
  gem 'libshadow'
end
