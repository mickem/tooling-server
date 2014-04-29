# Class:: redmine::service
#
#
class redmine::service inherits redmine {
  service { 'redmine':
    ensure     => running,
    hasstatus  => true,
    hasrestart => true,
    enable     => true,
  }
}
