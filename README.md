mobileconfig_profile
===========================

####Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with mobileconfig_profile](#setup)
    * [What mobileconfig_profile affects](#what-mobileconfig_profile-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with mobileconfig_profile](#beginning-with-mobileconfig_profile)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

##Overview

Puppet Module for managing OS X Configuration profiles (both device and user profiles)

##Module Description

The mobileconfig_profile module provides a new resource type to install and remove mobileconfig profiles on Mac OS X.
These profiles allow you to enforce policy and otherwise configure OS X.

You can make such profiles in a couple of ways:
* Profile Manager part of OSX server :(
  * https://itunes.apple.com/us/app/os-x-server/id537441259?mt=12
  * http://www.apple.com/support/osxserver/profilemanager/
* mcxToProfile by timsutton :)
  * https://github.com/timsutton/mcxToProfile
* Make them by hand if you know the correct format/keys (They are just xml plists)

##Setup

###What mobileconfig_profile affects

* Installed Profiles (listed in System Preferences -> Profiles)
* Any settings contained in Profiles you install
* Setting Payloads with System (Device) or User scope

###Setup Requirements

pluginsync needs to be enabled on agents

###Beginning with mobileconfig_profile

This module provides the `config_profile` type for installing/removing profiles.  
Minimal system profile (you manage the file/directory seperately):

```puppet
config_profile { 'com.apple.mdm.host.private.uuid.alacarte':
  ensure    => installed,
  path      => '/path/to/profile/file/on/system/file.mobileconfig',
  system    => true,
  subscribe => File['/path/to/profile/file/on/system/file.mobileconfig'],
}
```

##Usage

###Install System Profile (manage the file myself)

```puppet
config_profile { 'com.apple.mdm.host.device.uuid.alacarte':
  ensure    => installed,
  path      => '/path/to/profile/file/on/system/file.mobileconfig',
  system    => true,
  subscribe => File['/path/to/profile/file/on/system/file.mobileconfig'],
}
```

###Install same Profile for two Users (manage the file myself)

```puppet
config_profile { 'johns_cool_profile':
  identifier => 'com.apple.mdm.host.user.uuid.alacarte',
  ensure     => installed,
  path       => '/path/to/profile/file/on/system/file.mobileconfig',
  user       => 'john',
  subscribe  => File['/path/to/profile/file/on/system/file.mobileconfig'],
}

config_profile { 'sues_cool_profile':
  identifier => 'com.apple.mdm.host.user.uuid.alacarte',
  ensure     => installed,
  path       => '/path/to/profile/file/on/system/file.mobileconfig',
  user       => 'sue',
  subscribe  => File['/path/to/profile/file/on/system/file.mobileconfig'],
}
```

###Install System/User Profile (also manage the file)

Use a template:
```puppet
mobileconfig_profile { 'com.apple.mdm.host.device.uuid.alacarte':
  ensure  => installed,
  path    => '/path/to/profile/file/on/system/file.mobileconfig',
  system  => true,
  content => template("${module_name}/profiles/Settings_for_device.mobileconfig.erb"),
}
```

Use puppet file server:
```puppet
mobileconfig_profile { 'com.apple.mdm.host.user.uuid.alacarte':
  ensure  => installed,
  path    => '/path/to/profile/file/on/system/file.mobileconfig',
  user    => 'sue',
  source  => "puppet:///modules/${module_name}/profiles/Settings_for_user.mobileconfig",
}
```

##Reference

### Defined Types

* `mobileconfig_profile`: Manages file/directory and installing profile

### Types with Providers

* `config_profile`: Only Manages installing profile

##Limitations

This module has been built on and tested against Puppet 3.2.4 and higher.  
While I am sure other versions work, I have not tested them.

Configuration profiles are only supported on Apple Mac OS X.  
This module has been tested on 10.8 "Mountain Lion" and newer.

No plans to support other versions (unless you add it :)..

##Development

Pull Requests welcome

##Contributors

Chris Edester (edestecd)
