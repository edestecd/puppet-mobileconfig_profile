source 'https://rubygems.org'

ruby '2.1.2', :engine => 'ruby', :engine_version => '2.1.2', :patchlevel => '95'
#ruby=ruby-2.1.2
#ruby-gemset=puppet-mobileconfig_profile

gem 'facter'
gem 'hiera'
gem 'puppet'

# Bundle edge puppet instead:
# gem 'puppet', :git => 'git://github.com/puppetlabs/puppet.git'

group :development, :test do
  gem 'rake',                   :require => false
  #gem 'rspec-puppet',           :require => false
  #gem 'puppetlabs_spec_helper', :require => false
  #gem 'serverspec',             :require => false
  gem 'puppet-lint', '1.0.1',   :require => false
  #gem 'puppet-blacksmith',      :require => false
  #gem 'beaker',                 :require => false
  #gem 'beaker-rspec',           :require => false
end
