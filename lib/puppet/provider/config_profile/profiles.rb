# lib/puppet/provider/config_profile/profiles.rb

Puppet::Type.type(:config_profile).provide(:profiles) do
  desc "Configuration Profile (mobileconfig) management via `profiles` command on OS X.
    /usr/bin/profiles must be present.
    https://developer.apple.com/library/mac/documentation/Darwin/Reference/Manpages/man1/profiles.1.html"

  commands :profiles => '/usr/bin/profiles'
  commands :su       => '/usr/bin/su'
  commands :touch    => '/usr/bin/touch'
  commands :rm       => '/bin/rm'
  commands :grep     => '/usr/bin/grep'
  commands :who      => '/usr/bin/who'

  # Provider confines and defaults
  confine    :operatingsystem => :darwin
  defaultfor :operatingsystem => :darwin

  def self.std_options
    ['-f']
  end

  def path_option
    ['-F', @resource[:path]]
  end

  def user_option
    ['-U', @resource[:user]]
  end

  def state_file
    File.join(@resource[:home], ".puppet_profile_updated_#{@resource[:identifier]}")
  end

  def embeded_profiles(a_flag)
    options = []
    options << path_option unless a_flag.eql?('-L')
    options << user_option
    options << self.class.std_options

    cmd = ""
    cmd << [command(:profiles), a_flag, *options].join(' ')
    cmd << " && #{command(:touch)} #{state_file}" if a_flag.eql?('-I')
    cmd << " && #{command(:rm)} -f #{state_file}" if a_flag.eql?('-R')
    cmd << " #{embeded_grep.join(' ')}" if a_flag.eql?('-L')

    cmd
  end

  def embeded_grep(quiet=true)
    cmd = ['|', command(:grep)]
    cmd << '-q' if quiet
    cmd << @resource[:identifier]
    cmd
  end

  def install
    if @resource.system?
      profiles('-I', *(path_option + self.class.std_options))
    else
      cmd = [command(:su), '-', @resource[:user], '-c', "'#{embeded_profiles('-I')}'"].join(' ')
      execute(cmd, {:failonfail => true, :override_locale => true, :squelch => false, :combine => true})
      #su('-', @resource[:user], '-c', "'#{embeded_profiles('-I')}'")
    end
  end

  def remove
    if @resource.system?
      profiles('-R', *(path_option + self.class.std_options))
    else
      cmd = [command(:su), '-', @resource[:user], '-c', "'#{embeded_profiles('-R')}'"].join(' ')
      execute(cmd, {:failonfail => true, :override_locale => true, :squelch => false, :combine => true})
      #su('-', @resource[:user], '-c', "'#{embeded_profiles('-R')}'")
    end
  end

  def exists?
    unless @resource.system? or console_login?
      # return that wich produces no change - ignore for now
      # we can't do nothin if we don't have a console
      return (@resource[:ensure].eql?(:present) ? true : false)
    end

    if @resource.system?
      system_profile_loaded?
    else
      if @resource[:ensure].eql?(:present)
        user_profile_loaded? and state_file_exists?
      else
        user_profile_loaded?# or state_file_exists?
      end
    end
  end

  # Refresh the profile (usually after the file changes)
  def refresh
    if @resource.system?
      # Just install it again - it will overwrite the old one
      install
    else
      # Remove the state file letting us know it needs to be updated
      # the next time this user is logged in (console_login?)
      File.delete(state_file)
    end
  end

  # Check for console login
  # This means full GUI desktop and not a tty or ssh login alone
  # users must be logged into the GUI desktop and have finder/preferences running to load user profiles...
  # Hence we check if logged in with who command before installing them
  def console_login?
    begin
      cmd = [command(:who), '|', command(:grep), '-qE', "'#{@resource[:user]}\\s*console'"].join(' ')
      out = execute(cmd, {:failonfail => true, :override_locale => true, :squelch => false, :combine => true})
      #who('|', command(:grep), '-qE', "'#{@resource[:user]}\s*console'")
      Puppet.debug("Console was found, grep returned: #{out.inspect}")
      return true
    rescue Puppet::ExecutionFailure => e
      Puppet.debug("Console was NOT found, grep returned: #{e.inspect}")
      return false
    end
  end

  def system_profile_loaded?
    begin
      cmd = [command(:profiles), '-C', *(self.class.std_options + embeded_grep)].join(' ')
      out = execute(cmd, {:failonfail => true, :override_locale => true, :squelch => false, :combine => true})
      #profiles('-C', *(self.class.std_options + embeded_grep))
      Puppet.debug("System Profile was found, grep returned: #{out.inspect}")
      return true
    rescue Puppet::ExecutionFailure => e
      Puppet.debug("System Profile was NOT found, grep returned: #{e.inspect}")
      return false
    end
  end

  def user_profile_loaded?
    begin
      cmd = [command(:su), '-', @resource[:user], '-c', "'#{embeded_profiles('-L')}'"].join(' ')
      out = execute(cmd, {:failonfail => true, :override_locale => true, :squelch => false, :combine => true})
      #su('-', @resource[:user], '-c', "'#{embeded_profiles('-L')}'")
      Puppet.debug("User Profile was found, grep returned: #{out.inspect}")
      return true
    rescue Puppet::ExecutionFailure => e
      Puppet.debug("User Profile was NOT found, grep returned: #{e.inspect}")
      return false
    end
  end

  def state_file_exists?
    File.file?(state_file)
  end

end
