Yumrepo <| |> -> Package <| |>

node default {

  # Death to the allow_virtual_packages warning
  if versioncmp($::puppetversion,'3.6.1') >= 0 {
    $allow_virtual_packages = hiera('allow_virtual_packages',false)
    Package {
      allow_virtual => $allow_virtual_packages,
    }
  }

  class { 'firewall': }

  firewall { "006 Allow inbound http(s) (v4)":
    port     => [80, 443],
    proto    => tcp,
    action   => accept
  }

  class { 'epel': }

  class { 'timezone':
        timezone => 'UTC',
  }
  class { 'apache':
    default_vhost => false,
  }

  class { 'apache::mod::php':  }

  $user = 'apache'
  $webdir = '/var/www/yourls'

  apache::vhost { 'webnode.sandbox.internal':
    port        => '80',
    docroot     => $webdir,
    serveradmin => 'admin@localhost'
  }

  @package {"php-mysql":
    ensure => installed,
  }

  @package {"php-gd":
    ensure => installed,
  }

  @package {"php-mbstring":
    ensure => installed,
  }

  @package {"php-xml":
    ensure => installed,
  }

  @package {"php-pecl-apcu":
    ensure => installed,
  }

  @package {"php-pecl-geoip":
    ensure => installed,
  }

  @package {"unzip":
    ensure => installed,
  }

  realize Package[ "php-mysql", "php-gd", "php-xml", "php-mbstring", "php-pecl-apcu", "php-pecl-geoip", "unzip" ]

  staging::deploy { '1.7.tar.gz':
    source => 'https://github.com/YOURLS/YOURLS/archive/1.7.tar.gz',
    target => '/var/www',
  }

  file { 'yourls-htdocs':
    name     => '/var/www/YOURLS-1.7',
    ensure   => 'directory',
    owner    => 'apache',
    group    => 'apache',
    require  => [ Package['httpd'],
                  Staging::Deploy['1.7.tar.gz']
                ]
  }

  file { '/var/www/yourls':
    ensure  => 'link',
    target  => '/var/www/YOURLS-1.7',
    require => Staging::Deploy['1.7.tar.gz'],
  }
}
