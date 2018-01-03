Stupidly rough install instructions
-----------------------------------

* Start from a standard CentOS6 base image with all normal changes applied (especially auto-updates!)

* Clone AutoFTP git repository into /srv/

* Run add_ftp_users to create ftpusr users and vsftp config files

* Copy sudoers.txt to /etc/sudoers.d/ftpsudoers (NB Do NOT put dots in the sudoers.d file name otherwise it won't work)

* mysql -u root -p < [mysql template]

* Copy httpd conf file to /etc/httpd/conf.d/

* Copy vsftpd.conf file into /etc/vsftpd/

* Copy setftppw to /usr/local/bin/ and set permissions to 755

* Copy index.html to /var/www/html/

* Copy ftp.pl to /var/www/cgi-bin/ and set permissions to 755

* Run system-config-firewall-tui and allow ssh/ftp/http/https

* perl -MCPAN -e 'install HTML::Template'

* yum install perl-Date-Calc

* perl -MCPAN -e 'install Mail::Sendmail'

* perl -MCPAN -e 'install Net::Subnet'

* If there are odd problems with Net::Subnet then install 'Subnet'

* cat cleanup.cron | crontab

* cp ftp_cleanup.pl /usr/local/bin/

* chkconfig httpd on

* chkconfig mysqld on

* Edit /etc/sysconfig/selinux - set to disabled

* Reboot.
