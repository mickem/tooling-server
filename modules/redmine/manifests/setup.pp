# Class:: redmine::setup
#
#
class redmine::setup inherits redmine {
  File {
    owner     => $redmine_user,
    group     => $redmine_user,
  }

  # user
  user { $redmine_user:
    ensure   => present,
    shell    => '/bin/bash',
    password => '*',
    home     => $redmine_home,
    comment => "Redmine User",
    system   => true,
    groups => 'rvm',
  }

#  exec { "$redmine_home":
#    command => "/bin/cp -R /etc/skel $redmine_home; /bin/chown -R $redmine_user:$redmine_group $redmine_home",
#    creates => "$redmine_home",
#    require => User[$redmine_user],
#  }
  
  
  # directories
  file { $redmine_home:
    ensure => directory,
    mode   => '0755',
  }
  # database dependencies
  case $::osfamily {
    'Debian': {
      case $redmine_dbtype {
        'mysql': {
          ensure_packages(['libmysql++-dev','libmysqlclient-dev'])
        }
        'pgsql': {
          ensure_packages(['libpq-dev','postgresql-client'])
        }
        default: {
          fail("unknow dbtype (${redmine_dbtype})")
        }
      }
    }
    'RedHat': {
      case $redmine_dbtype {
        'mysql': {
          ensure_packages(['mysql-devel'])
        }
        'pgsql': {
          ensure_packages(['postgresql-devel'])
        }
        default: {
          fail("unknow dbtype (${redmine_dbtype})")
        }
      }
    }
    default: {
      fail("${::osfamily} not supported yet")
    }
  } # Case $::osfamily

  
  # Install dependencies
  
  $generic_packages = [ 'wget', 'tar', 'make', 'gcc' ]
  $debian_packages = [ 'libmysql++-dev', 'libmysqlclient-dev', 'libmagickcore-dev', 'libmagickwand-dev' ]
  $redhat_packages = [ 'mysql-devel', 'postgresql-devel', 'sqlite-devel', 'ImageMagick-devel' ]

  case $::osfamily {
    'Debian':   { $packages = concat($generic_packages, $debian_packages) }
    default:    { $packages = concat($generic_packages, $redhat_packages) }
  }
  
  ensure_packages($packages)
  
  # system packages
#  package { 'bundler':
#    ensure    => installed,
#    provider  => gem,
#  }

  # dev. dependencies
  #ensure_packages($system_packages)

  # other packages
  #ensure_packages([$git_package_name,'postfix','curl'])
}
