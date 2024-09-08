# expense-puppet
Frontend
--------------------------------------
cd /etc/puppetlabs/code/
puppet module install puppet-archive

/etc/puppetlabs/code/environments/production/manifests

mkdir -p /etc/puppetlabs/code/environments/production/modules/nginx/files
cp expense.conf /etc/puppetlabs/code/environments/production/modules/nginx/files/

cd /etc/puppetlabs/code/environments/production/modules/nginx/files

==============================================

mkdir -p /etc/puppetlabs/code/environments/production/modules/backend/files
cp backend.service /etc/puppetlabs/code/environments/production/modules/backend/files

# Load MySQL Schema
exec { 'load-mysql-schema':
  command => 'mysql -uroot -pExpenseApp@1 -h 172.31.44.162 all < /app/schema/backend.sql',
  path    => ['/usr/bin', '/bin'],
  require => Package['mysql-client'],
  unless  => "mysql -uroot -pExpenseApp@1 -h 172.31.44.162 -e 'SHOW DATABASES;' | grep all",
}

==========================================================
sudo journalctl -u backend.service -xe
sudo journalctl -xe

========================
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo bash -
sudo apt-get install -y nodejs