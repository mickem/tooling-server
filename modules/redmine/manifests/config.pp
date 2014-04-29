# Class redmine::config
#
#
class redmine::config inherits redmine {

  File {
    owner => $redmine::params::user,
    group => $redmine::params::group,
    mode  => '0644'
  }

  # nginx config
  if $redmine_nginx {
    file { '/etc/nginx/conf.d/redmine.conf':
      ensure  => file,
      content => template('redmine/nginx-redmine.conf.erb'),
      owner   => root,
      group   => root,
    }

  }

  # Startscript config
  file { '/etc/default/redmine':
    ensure  => file,
    content => template('redmine/redmine.default.erb'),
    owner   => root,
    group   => root,

  }

  # Startscript
  file { '/etc/init.d/redmine':
    ensure  => file,
    content => template('redmine/redmine.init.erb'),
    owner   => root,
    group   => root,
    mode    => '0755',
    require => File['/etc/default/redmine'],
  }

  # Log rotation
  file { '/etc/logrotate.d/redmine':
      ensure  => file,
      source  => 'puppet:///modules/redmine/redmine-logrotate',
      owner   => root,
      group   => root,
  }

  # backup task
  if $redmine_backup {
    file { '/usr/local/sbin/backup-redmine.sh':
      ensure  => present,
      content => template('redmine/backup-redmine.sh.erb'),
      mode    => '0755',
      owner   => 'root',
      group   => 'root',
    }

    cron { 'gitlab backup':
      command => '/usr/local/sbin/backup-redmine.sh',
      hour    => $redmine_backup_time,
      minute  => fqdn_rand(60),
      user    => $redmine_user,
      require => File['/usr/local/sbin/backup-redmine.sh'],
    }
  }
}