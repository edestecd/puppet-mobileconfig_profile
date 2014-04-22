# params.pp
# Set up configuration profile parameters defaults etc.
#

class mobileconfig_profile::params {

  # init.pp
  # At least OSX 10.8 "Mountain Lion"
  if ($::osfamily == 'Darwin') and ($::macosx_productversion >= '10.8.0') {
    $ensure        = installed
    $profiles_path = "/var/lib/puppet/mobileconfigs"
    $path          = "${profiles_path}/${identifier}"
    $system        = undef

    $root_user     = 'root'
    $root_group    = 'wheel'
  } else {
    fail("The ${module_name} module is not supported on a ${::osfamily} based system with version ${::macosx_productversion}.")
  }

}
