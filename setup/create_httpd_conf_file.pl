#!/usr/bin/perl
use warnings;
use strict;

for my $id (1..100) {

    print << "END_BLOCK";
Alias /ftpusr$id /usr/users/ftpusr$id
<Directory /usr/users/ftpusr$id>
        Options Indexes
	Header set Access-Control-Allow-Origin "*"
        Header set Access-Control-Allow-Headers Range
</Directory>
END_BLOCK
}
