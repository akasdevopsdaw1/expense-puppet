class frontend {
  package { 'unzip':
  ensure => installed,
  }
  package { 'nginx':
    ensure => latest,
  }

  file { '/etc/nginx/conf.d/expense.conf':
    ensure  => file,
    source  => 'puppet:///modules/nginx/expense.conf',
    mode    => '0644',
  }

  file { '/usr/share/nginx/html':
  ensure => directory,
  mode   => '0755',
  recurse => true,      # Ensures all contents in the directory are managed
  force   => true,      # Required if you're removing files within a directory
  purge   => true,      # Removes any unmanaged content in the directory before recreating it
  }


  archive { '/usr/share/nginx/html/expense-frontend-v2.zip':
    source       => 'https://expense-artifacts.s3.amazonaws.com/expense-frontend-v2.zip',
    extract      => true,
    extract_path => '/usr/share/nginx/html',
    creates      => '/usr/share/nginx/html/index.html',
    cleanup      => true,
    require      => Package['unzip'],
  }

  service { 'nginx':
    ensure    => running,
    enable    => true,
    subscribe => File['/etc/nginx/conf.d/expense.conf'],
  }
}