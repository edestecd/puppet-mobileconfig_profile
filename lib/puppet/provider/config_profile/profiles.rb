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
  commands :test     => '/bin/test'

  # Provider confines and defaults
  confine    :operatingsystem => :darwin
  defaultfor :operatingsystem => :darwin

  def self.root_cmd
    '/usr/bin/profiles'
  end

  def self.touch_cmd
    '/usr/bin/touch'
  end

  def self.rm_cmd
    '/bin/rm'
  end

  def self.grep_cmd
    '/usr/bin/grep'
  end

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
    options << self.std_options

    out = ""
    out << "#{self.rm_cmd} -rf #{state_file} && " if a_flag.eql?('-R')
    out << [self.root_cmd, a_flag, *options].join(' ')
    out << " && #{self.touch_cmd} #{state_file}" if a_flag.eql?('-I')
    out << " #{embeded_grep.join(' ')}" if a_flag.eql?('-L')

    out
  end

  def embeded_grep
    ['|', self.grep_cmd, '-q', @resource[:identifier]]
  end

  def install
    if @resource.system?
      profiles('-I', *(path_option + self.std_options))
    else
      su('-', @resource[:user], '-c', "'#{embeded_profiles('-I')}'")
    end
  end

  def remove
    if @resource.system?
      profiles('-R', *(path_option + self.std_options))
    else
      su('-', @resource[:user], '-c', "'#{embeded_profiles('-R')}'")
    end
  end

  def exists?
    if !@resource.system? and !console_login?
      # return that wich produces no change - ignore for now
      # we can't do nothin if we don't have a console
      return ([:present, :installed].include?(@resource[:ensure]) ? true : false)
    end

    if @resource.system?
      system_profile_loaded?
    else
      if [:present, :installed].include?(@resource[:ensure])
        user_profile_loaded? and state_file_exists?
      else
        user_profile_loaded? or state_file_exists?
      end
    end
  end

  # Check for console login
  # This means full GUI desktop and not a tty or ssh login alone
  # users must be logged into the GUI desktop and have finder/preferences running to load user profiles...
  # Hence we check if logged in with who command before installing them
  def console_login?
    begin
      who('|', self.grep_cmd, '-qE', "'#{@resource[:user]}\s*console'")
    rescue Puppet::ExecutionFailure => e
      Puppet.debug("Console was not found, grep returned: #{e.inspect}")
      return false
    end
    true
  end

  def system_profile_loaded?
    begin
      profiles('-C', *(self.std_options + embeded_grep))
    rescue Puppet::ExecutionFailure => e
      Puppet.debug("System Profile was not found, grep returned: #{e.inspect}")
      return false
    end
    true
  end

  def user_profile_loaded?
    begin
      su('-', @resource[:user], '-c', "'#{embeded_profiles('-L')}'")
    rescue Puppet::ExecutionFailure => e
      Puppet.debug("User Profile was not found, grep returned: #{e.inspect}")
      return false
    end
    true
  end

  def state_file_exists?
    File.file?(state_file)
  end

end
