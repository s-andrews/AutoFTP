#!/usr/bin/perl
use warnings;
use strict;
use DBI;
use Mail::Sendmail;

my $log;

my $dbh = DBI->connect("DBI:mysql:database=ftp_sites;host=localhost",'cgiuser','',{RaiseError=>0,AutoCommit=>1});

unless ($dbh) {
    $log .= "ERROR: Failed to connect to database : $DBI::errstr\n";
}


# Find the list of sites we're going to warn

my $warn_sites_sth = $dbh->prepare("SELECT id,email,name,secret,username FROM site WHERE end_date > NOW() AND end_date < NOW()+INTERVAL 1 DAY");

$warn_sites_sth -> execute() or $log .= "ERROR: Failed to list warning sites: ".$dbh->errstr()."\n";

while (my ($id,$email,$name,$secret,$username) = $warn_sites_sth->fetchrow_array()) {

    $name = " ($name)" if ($name);

    # List the files they have on this site
    my @files = </usr/users/$username/*>;

    my $message = "This email is a warning that the FTP site you have with username ${username}${name} will be automatically deleted in the next 24 hours\n\n";

    $message .= "If you still need this site, please use the link below to extend the life of the site\n\n";

    $message .= "http://ftp2.babraham.ac.uk/cgi-bin/ftp.pl?action=extend&id=$id&secret=$secret\n\n";

    $message .= "If you no longer need this site then you do not need to take any action\n\n";

    $message .= "The files you currently have on this site are:\n\n";

    if (@files) {
	$message .= "  $_\n" foreach (@files);
    }
    else {
	$message .= "  [No files on site]\n";
    }

    my %mail = (
		To => $email,
		From => 'Babraham FTP System<simon.andrews@babraham.ac.uk>',
		Message => $message,
		Subject => 'FTP site will be deleted soon',
		smtp => '149.155.145.25',
		);

    sendmail(%mail) or $log .= "Failed to send email to $email: $Mail::Sendmail::error\n";


    $log .= "Sent warning to $email about $username\n";
}


# Find the list of sites we're going to delete

my $delete_sites_sth = $dbh->prepare("SELECT id,email,secret,username FROM site WHERE end_date < NOW()");
    
$delete_sites_sth -> execute() or $log .= "ERROR: Failed to list delete sites: ".$dbh->errstr()."\n";

while (my ($id,$email,$secret,$username) = $delete_sites_sth->fetchrow_array()) {
    # Reset the password (lock the account)
    system ("/usr/bin/passwd -l $username > /dev/null 2>&1") == 0 or $log .= "ERROR: Failed to delete password for $username\n";

    # Update the database
    $dbh->do("UPDATE site set start_date=null,end_date=null,email=null,secret=null WHERE id=?",undef,($id)) or $log .= "ERROR: Failed to remove site from database: ".$dbh->errstr()."\n";
    
    # Delete the files
    system("/usr/bin/sudo -u $username rm -rf /usr/users/$username/* /usr/users/$username/.[^.] /usr/users/$username/.??*") == 0 or $log .= "ERROR: Failed to delete files for $username\n";


    # Reset the permissions on the top level folder
    system("chmod 700 /usr/users/$username") == 0 or die "Failed to reset permissions on /usr/users/$username";

    $log .= "Deleted account for $username belonging to $email\n";
}

# Write a summary of all sites which are still active

$log .= "\nUsage summary\n=============\n\n";

my $all_sites_sth = $dbh->prepare("SELECT username,email,end_date FROM site WHERE end_date IS NOT NULL");

$all_sites_sth->execute() or $log .= "ERROR: Failed to list all active sites: ".$dbh->errstr()."\n";

while (my ($username,$email,$end_date) = $all_sites_sth->fetchrow_array()) {

    # Find out how much space this site is using

    my $usage = `du -sh /usr/users/$username`;
    $usage = (split(/\s+/,$usage))[0];

    $log .= join("\t",($username,$usage,$email,$end_date));
    $log .= "\n";

}



# Send the log

my %mail = (
	    To => 'simon.andrews@babraham.ac.uk',
	    From => 'Babraham FTP System<simon.andrews@babraham.ac.uk>',
	    Message => $log,
	    Subject => 'FTP cleanup log',
	    smtp => '149.155.145.25',
	    );

sendmail(%mail);

