#!/usr/bin/perl
use warnings;
use strict;

open(USERS,'>>','/etc/vsftpd/user_list') or die $!;
open(CHROOT,'>>','/etc/vsftpd/chroot_list') or die $!;

for my $number (1..100) {

	my $username = "ftpusr$number";
	system("/usr/sbin/useradd -b /usr/users/ -m -s /sbin/nologin $username") == 0 or die "Failed to create $username";

	print USERS $username,"\n";
	print CHROOT $username,"\n";

}

close USERS or die $!;
close CHROOT or die $!;

