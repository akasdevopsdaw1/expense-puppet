class backend {
    # Disable Default NodeJS Module (Ubuntu doesn't use DNF, so skipping the module disable part)

    # Enable NodeJS Version 20 (No module system in apt, so directly install the correct NodeJS version)
    exec { 'add-nodejs-repository':
    command => 'curl -fsSL https://deb.nodesource.com/setup_20.x | bash -',
    path    => ['/usr/bin', '/bin'],
    }

    # Install NodeJS
    package { 'nodejs':
    ensure  => 'installed',
    require => Exec['add-nodejs-repository'],
    }
    
    # Ensure npm is installed
    exec { 'install-npm':
    command => '/usr/bin/npm install -g npm',
    path    => ['/usr/bin', '/bin'],
    unless  => 'test -f /usr/bin/npm',  # Check if npm is installed
    require => Package['nodejs'],        # Ensure Node.js is installed first
    }


    # Add Application User 'expense'
    user { 'expense':
    ensure => present,
    }

    # Clean the old content and create the /app directory
    file { '/app':
    ensure  => directory,  # This ensures the directory is created
    owner   => 'expense',
    group   => 'expense',
    mode    => '0755',
    recurse => true,       # Recursively manage the directory's contents
    force   => true,       # Forcibly remove the old contents if they exist
    require => User['expense'],
    }


    # Download and Extract App Content
    archive { '/app/expense-backend-v2.zip':
    source       => 'https://expense-artifacts.s3.amazonaws.com/expense-backend-v2.zip',
    extract      => true,
    extract_path => '/app',
    creates      => '/app/index.js',  # Ensure this file is created after extraction
    cleanup      => true,
    require      => File['/app'],
    }

    # Install NodeJS Dependencies
    exec { 'install-node-dependencies':
    command => 'npm install',
    cwd     => '/app',
    path    => ['/usr/bin', '/bin'],
    require => Archive['/app/expense-backend-v2.zip'],
    }

    # Copy Backend Service File to Systemd Directory
    file { '/etc/systemd/system/backend.service':
    ensure  => file,
    source  => 'puppet:///modules/backend/backend.service',  # You need to place this file in your Puppet file server
    mode    => '0644',
    }

    # Install MySQL Client
    #package { 'mysql-client':
    #ensure => installed,
    #}

    # Load MySQL Schema
    exec { 'load-mysql-schema':
    command => 'mysql -uroot -pExpenseApp@1 < /app/schema/backend.sql',
    path    => ['/usr/bin', '/bin'],
    #require => Package['mysql-client'],
    unless  => "mysql -uroot -pExpenseApp@1 -e 'SHOW DATABASES;' | grep all",
    }

    # Start and Enable Backend Service
    service { 'backend':
    ensure     => running,
    enable     => true,
    require    => File['/etc/systemd/system/backend.service'],
    subscribe  => File['/etc/systemd/system/backend.service'],  # Restarts the service if the service file is updated
    }

}