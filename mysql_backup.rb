# encoding: utf-8
require 'mail'
require 'open3'

#create the db dump Files
def make_db_dump
  dump_production =  'mysqldump --user=backup-user --password=password --databases db_name > /db_backup/db_name.sql &&'

  dump_production << 'mysqldump --user=backup-user --password=password --databases db_name > /db_backup/db_name.sql &&'

  dump_production << 'mysqldump --user=backup-user --password=password --databases db_name > /db_backup/db_name.sql &&'

  dump_production << 'mysqldump --user=backup-user --password=password --databases db_name > /db_backup/db_name.sql'
  
  stdin, stdout, stderr = Open3.popen3(dump_production)

  error_msg = stderr.readlines

  send_mail(error_msg) unless error_msg.blank?

  compress

end

def compress
  compress_production =  "cd db_backup;"
  compress_production << "tar -zcf zip/db_name.sql.tar.gz db_name.sql &&"
  compress_production << "tar -zcf zip/db_name.sql.tar.gz db_name.sql &&"
  compress_production << "tar -zcf zip/db_name.sql.tar.gz db_name.sql &&"
  compress_production << "tar -zcf zip/db_name.sql.tar.gz db_name.sql"

  stdin, stdout, stderr = Open3.popen3(compress_production)

  error_msg = stderr.readlines

  send_mail(error_msg) unless error_msg.blank?

  send_to_backup_srv

end

def send_to_backup_srv
  gentoo_server      = "user@host:/target/folder"
  send_at_home       = "rsync -urlpgt /db_backup/zip #{gentoo_server}"

  stdin, stdout, stderr = Open3.popen3(send_at_home)

  error_msg = stderr.readlines

  send_mail(error_msg) unless error_msg.blank?  
end

def send_mail(error_msg)
  options = { :address              => "your_mail_host",
            :port                   => 25,
            :domain                 => "your_mail_domain",  
            :authentication         => :login,  
            :user_name              => "your@email.me",  
            :password               => "password",
            :openssl_verify_mode    => 'none'  }

  Mail.defaults do
    delivery_method :smtp, options
  end

  mail = Mail.new do
    from    'your@email.me'
    to      'target@email.me'
    subject 'DB Backup Failed'
    body    error_msg
  end

  mail.deliver!

end
make_db_dump

