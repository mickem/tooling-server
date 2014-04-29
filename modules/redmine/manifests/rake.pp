#Class redmine::rake - DB migrate/prep tasks
class redmine::rake {

  $ruby_prefix = '/usr/local/rvm/bin/rvm 2.0 exec'

  Exec {
    user      => $redmine_user,
    path      => $exec_path,
	logoutput => false,
    cwd       => "${redmine_home}/redmine-${version}",
  }

  exec { 'bundle_redmine':
    command   => "${ruby_prefix} bundle install --gemfile ${redmine_home}/redmine-${version}/Gemfile --without development test postgresql sqlite",
    unless    => "${ruby_prefix} bundle check --gemfile ${redmine_home}/redmine-${version}/Gemfile",
    timeout   => 0,
	provider  => 'shell',
    notify    => Exec['generate redmine secret'],
  }
  exec { 'generate redmine secret':
    command     => "${ruby_prefix} bundle exec rake generate_secret_token",
    refreshonly =>  true,
    notify      => Exec['run redmine migrations'],
  }

  exec { 'run redmine migrations':
    command     => "${ruby_prefix} bundle exec rake db:migrate RAILS_ENV=production",
    refreshonly =>  true,
#    notify      => Exec['precompile assets'],
  }

}
