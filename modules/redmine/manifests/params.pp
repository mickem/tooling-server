# Class redmine::params
class redmine::params  {

  $version              = '2.5.1'

  $download_url = $version ? {
    '2.5.1' => 'http://www.redmine.org/releases/redmine-2.5.1.tar.gz',
    '2.2.3' => 'http://rubyforge.org/frs/download.php/76771/redmine-2.2.3.tar.gz',
    '2.2.2' => 'http://rubyforge.org/frs/download.php/76722/redmine-2.2.2.tar.gz',
    '2.2.1' => 'http://rubyforge.org/frs/download.php/76677/redmine-2.2.1.tar.gz',
    default => $download_url
  }

  $redmine_nginx            = true
  $exec_path                = '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'
  $redmine_dbtype            = 'mysql'
  $redmine_dbname            = 'gitlab_db'
  $redmine_dbuser            = 'gitlab_user'
  $redmine_dbpwd             = 'changeme'
  $redmine_dbhost            = 'localhost'
  $redmine_dbport            = '5432'
  $redmine_user              = 'redmine'
  $redmine_home              = '/home/redmine'
  $redmine_backup            = false
  $redmine_backup_path       = 'tmp/backups/'
  $redmine_backup_keep_time  = '0'
  $redmine_backup_time       = fqdn_rand(5)+1
  $redmine_backup_postscript = false
  $redmine_relative_url_root = false
  
  $redmine_http_port         = 80
  $redmine_domain            = $::fqdn
  
  $webroot                   = '/home/redmine/redmine'
}
