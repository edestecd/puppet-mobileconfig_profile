# init.pp
# Manage both the file resource and config_profile resource for an
# OS X configuration profile (mobileconfig)
#

define mobileconfig_profile (
  $identifier    = $name,
  $ensure        = $mobileconfig_profile::params::ensure,
  $profiles_path = $mobileconfig_profile::params::profiles_path,
  $path          = $mobileconfig_profile::params::path,
  $system        = $mobileconfig_profile::params::system,
  $user          = undef,
  $home          = undef,
  $content       = undef,
  $source        = undef,
) {

  include ::mobileconfig_profile::params

  validate_absolute_path($profiles_path)
  validate_absolute_path($path)
  #validate_bool($system)

  if !defined(File[$profiles_path]) {
    file { $profiles_path:
      ensure => directory,
      mode   => '0755',
      owner  => $mobileconfig_profile::params::root_user,
      group  => $mobileconfig_profile::params::root_group,
    }
  }

  if !defined(File[$path]) {
    file { $path:
      ensure  => file,
      mode    => '0644',
      owner   => $mobileconfig_profile::params::root_user,
      group   => $mobileconfig_profile::params::root_group,
      content => $content,
      source  => $source,
    }
  }

  config_profile { $name:
    ensure     => $ensure,
    identifier => $identifier,
    path       => $path,
    system     => $system,
    user       => $user,
    home       => $home,
    subscribe  => File[$path],
  }

}
