# Class redmine::install
#
#
class redmine::install inherits redmine {

  $ruby_prefix = '/usr/local/rvm/bin/rvm 2.0 exec'

  Exec {
    user      => $redmine_user,
    path      => $exec_path,
	logoutput => false,
	cwd       => $redmine_home,
  }

  File {
    owner => $redmine_user,
    group => $redmine_user,
  }

  # Install redmine from source

  exec { 'redmine_source':
    command => "/usr/bin/wget ${download_url}",
    creates => "${redmine_home}/redmine-${version}.tar.gz",
    require => Package['wget'],
  } ->

  exec { 'extract_redmine':
    command => "/bin/tar xvzf redmine-${version}.tar.gz",
    creates => [ "${redmine_home}/redmine-${version}",
	"${redmine_home}/redmine-${version}/public"],
    require => Package['tar'],
  } ->
  # Symbolic link
  file { $webroot:
    ensure => link,
    target => "${redmine_home}/redmine-${redmine::version}"
  } ->
  file { "${webroot}/config/database.yml":
    ensure  => present,
    content => template('redmine/database.yml.erb'),
    require => File[$redmine::webroot]
  } ->
  file { "${redmine::webroot}/config/configuration.yml":
    ensure  => present,
    content => template('redmine/configuration.yml.erb'),
    require => File[$redmine::webroot]
  }  
  if $redmine_relative_url_root {
    file { "${redmine_home}/redmine/public/${redmine_relative_url_root}":
       ensure => 'link',
       target => "${redmine_home}/redmine/public",
    } ->
    exec { 'add suburi to env':
      command => "/bin/echo 'Redmine::Utils::relative_url_root = \"${redmine_relative_url_root}\"' >> ${redmine_home}/redmine/config/environment.rb",
	logoutput => true,
      unless => "/bin/grep relative_url_root ${redmine_home}/redmine/config/environment.rb"
    } ->
    exec { 'add suburi to routes':
      command => "/bin/sed -i -e 's/\\(.*RedmineApp::Application.routes.draw.*\\)/\\1\\nscope \"\\${redmine_relative_url_root}\" do/' ${redmine_home}/redmine/config/routes.rb && /bin/echo end >> ${redmine_home}/redmine/config/routes.rb",
      unless => "/bin/grep redmine ${redmine_home}/redmine/config/routes.rb"
    }
  }
}
