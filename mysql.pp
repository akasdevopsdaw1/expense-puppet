class mysql {
  # Install MySQL Server
    package { 'mysql-server':
    ensure => installed,
    }

    # Ensure MySQL service is running and enabled at boot
    service { 'mysql':
    ensure     => running,
    enable     => true,
    require    => Package['mysql-server'],  # Ensure the service starts after MySQL is installed
    }

    # Set MySQL Root Password
    exec { 'set-mysql-root-password':
    command => 'mysql_secure_installation --set-root-pass ExpenseApp@1',
    path    => ['/usr/bin', '/bin'],
    unless  => "mysql -uroot -pExpenseApp@1 -e 'show databases;'",
    require => Service['mysql'],  # Run after MySQL is running
    }

}