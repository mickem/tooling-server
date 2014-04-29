# = Class: redmine
#
# This module installs redmine server using puppet.
#
# Tested on CentOS 6.3 and debian wheezy
#
#== Requirements
# Packages installed during process:
# All OS: wget, tar, make, gcc
# CentOS: mysql-devel, postgresql-devel, sqlite-devel, ImageMagick-devel
# Debian: libmysql++-dev, libmysqlclient-dev, libmagickcore-dev, libmagickwand-dev
#
# Gems installed during process: bundler
#
# Modules required: johanek-apache, johanek-passenger, puppetlabs-mysql 2.0 or later, puppetlabs-stdlib
#
#
#== Example
# class { 'apache': }
# class { 'passenger': }
# class { '::mysql::server': }
# class { 'redmine': }
#
# == Parameters
#
# [*version*]
#   Set to desired version. Default: 2.2.3
#
# [*download_url*]
#   Download URL for redmine tar.gz. If you want to install an unsupported version, this is required.
#   Versions Supported: 2.2.1, 2.2.2, 2.2.3
#
# [*database_server*]
#   Database server to use. Default: 'localhost'
#   If server is not on localhost, the database and user must be setup in advance.
#
# [*database_user*]
#   Database user. Default: 'redmine'
#
# [*database_password*]
#   Database user password. Default: 'redmine'
#
# [*production_database*]
#   Name of database to use for production environment. Default: 'redmine'
#
# [*development_database*]
#   Name of database to use for development environment. Default: 'redmind_development'
#
# [*database_adapter*]
#   Database adapter to use for database configuration. 'mysql' for ruby 1.8, 'mysql2' for ruby 1.9. Default: 'mysql'
#
# [*smtp_server*]
#   SMTP server to use. Default: 'localhost'
#
# [*smtp_domain*]
#   Domain to send emails from. Default: $::domain
#
# [*smtp_port*]
#   SMTP port to use. Default: 25
#
# [*smtp_authentication*]
#   SMTP authentication mode. Default: ':login'
#
# [*smtp_username*]
#   SMTP user name for authentication. Default: none
#
# [*smtp_password*]
#   SMTP password for authentication. Default: none
#
# [*webroot*]
#   Directory in which redmine web files will be installed. Default: '/var/www/html/redmine'
#
# [*redmine_user*]
#   Name of redmine user
#   default: redmine
#
# [*redmine_home*]
#   Home directory for redmine installation
#   default: /home/redmine
#
# === Copyright
#
# See LICENSE file
# Michael Medin (c) 2014
#

class redmine (
  $version              = $redmine::params::version,
  $download_url         = $redmine::params::download_url,

  $redmine_dbtype       = $redmine::params::redmine_dbtype,
  $redmine_dbname       = $redmine::params::redmine_dbname,
  $redmine_dbuser       = $redmine::params::redmine_dbuser,
  $redmine_dbpwd        = $redmine::params::redmine_dbpwd,
  $redmine_dbhost       = $redmine::params::redmine_dbhost,
  $redmine_dbport       = $redmine::params::redmine_dbport,
  $redmine_domain       = $redmine::params::redmine_domain,
  $redmine_http_port    = $redmine::params::redmine_http_port,
  $redmine_relative_url_root = $redmine::params::redmine_relative_url_root,


#  $redmine_database_server      = 'localhost',
#  $database_user        = 'redmine',
#  $database_password    = 'redmine',
#  $production_database  = 'redmine',
#  $development_database = 'redmine_development',
#  $database_adapter     = 'mysql',
  $smtp_server          = 'localhost',
  $smtp_domain          = $::domain,
  $smtp_port            = 25,
  $smtp_authentication  = false,
  $smtp_username        = '',
  $smtp_password        = '',
  $exec_path            = $redmine::params::exec_path,

  $vhost_aliases        = 'redmine',
  $webroot              = $redmine::params::webroot,
  $redmine_user         = $redmine::params::redmine_user,
  $redmine_home         = $redmine::params::redmine_home,
  ) inherits redmine::params {
  
  case $::osfamily {
    Debian: {}
    Redhat: {
      warning("${::osfamily} not fully tested with ${gitlab_branch}")
    }
    default: {
      fail("${::osfamily} not supported yet")
    }
  } # case

  validate_absolute_path($redmine_home)
#  validate_absolute_path($redmine_ssl_cert)
#  validate_absolute_path($redmine_ssl_key)


  validate_re($redmine_dbtype, '(mysql|pgsql)', 'redmine_dbtype is not supported')
  validate_re($redmine_dbport, '^\d+$', 'redmine_dbport is not a valid port')


  validate_string($redmine_user)
  validate_string($redmine_dbname)
  validate_string($redmine_dbuser)
  validate_string($redmine_dbpwd)
  validate_string($redmine_dbhost)


  anchor { 'redmine::begin': } ->
  class { '::redmine::setup': } ->
#  class { '::redmine::package': } ->
  class { '::redmine::install': } ->
  class { '::redmine::config': } ->
  class { '::redmine::service': } ->
  class { '::redmine::rake': }
  anchor { 'redmine::end': }

} # Class:: redmine
