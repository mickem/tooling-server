
$root_dbpwd = 'O4tl56uOCqZw'
$gitlab_dbpwd = 'n07074RY1u8r'
$redmine_dbpwd = 'c9IJTvvJYLsh'
$tooling_domain = 'test001.medin.name'
$http_port = 80
$email = 'foo@bar.com'

exec { "apt-update":
    command => "/usr/bin/apt-get update"
}
Exec["apt-update"] -> Package <| |>


file { '/home/git/.profile':
	mode      => 0700,
	source    => "/etc/puppet/files/git-profile",
	owner     => 'git',
	group     => 'git',
	subscribe => User['git'],
}
file { '/home/redmine/.profile':
	mode      => 0700,
	source    => "/etc/puppet/files/redmine-profile",
	owner     => 'redmine',
	group     => 'redmine',
	subscribe => User['redmine'],
}

class { 'nginx': 
} ->
file { "nginx front":
	owner => 'root',
	path => '/etc/nginx/conf.d/front.conf',
	content => template('/vagrant/templates/nginx-front.conf.erb')
}->
class { 'ldap::server::master':
  suffix      => 'dc=foo,dc=bar',
  rootpw      => '{SHA}iEPX+SQWIR3p67lj/0zigSWTKHg=',
} ->
class { 'rvm': 
} ->
class { '::mysql::server':
	root_password    => $root_dbpwd,
	override_options => { 'mysqld' => { 'max_connections' => '1024' } },
} -> 
mysql::db { 'gitlab':
	user     => 'gitlab',
	password => $gitlab_dbpwd,
	host     => 'localhost',
	grant    => ['ALL'],
} ->
mysql::db { 'redmine':
	user     => 'redmine',
	password => $redmine_dbpwd,
	host     => 'localhost',
	grant    => ['ALL'],
} ->
package { "redis-server":
	ensure      => 'present',
} -> 
rvm_system_ruby { 'ruby-2.0':
	ensure      => 'present',
	default_use => false;
} ->
class { 'redmine': 
		redmine_dbtype     => 'mysql',
		redmine_dbname     => 'redmine',
		redmine_dbuser     => 'redmine',
		redmine_dbpwd      => $redmine_dbpwd,
		redmine_domain     => "redmine.${tooling_domain}",
		redmine_relative_url_root => '/redmine',
} ->
class {
	'gitlab':
		git_email         => $email,
		git_comment       => 'GitLab',
		gitlab_domain     => "gitlab.${tooling_domain}",
		gitlab_dbtype     => 'mysql',
		gitlab_dbname     => 'gitlab',
		gitlab_dbuser     => 'gitlab',
		gitlab_dbpwd      => $gitlab_dbpwd,
		gitlab_relative_url_root => '/gitlab',
		ldap_enabled      => false,
} -> 
exec { 'restart nginx':
	command => '/usr/sbin/service nginx restart'
} -> 
exec { 'restart gitlab':
	command => '/usr/sbin/service gitlab restart'
} ->
exec { 'restart redmine':
	command => '/usr/sbin/service redmine restart'
}