#!/usr/bin/perl
use warnings;
use strict;
use HTML::Template;
use CGI;
use Date::Calc;
use DBI;
use CGI::Carp qw(fatalsToBrowser);
use List::Util 'shuffle';
use Mail::Sendmail;
use Net::Subnet;

# This script should only be accessible from within the core Babraham IP range.

my $babraham_ip_matcher = subnet_matcher qw(149.155.144.0/255.255.248.0 149.155.134.0/255.255.255.0);

unless ($babraham_ip_matcher->($ENV{REMOTE_ADDR})) {
    print_error("New sites can only be created from within the Babraham intranet, or via VPN");
    exit;
}


my $q = CGI->new();

my $action = $q->param('action');

my $dbh = DBI->connect("DBI:mysql:database=ftp_sites;host=localhost",'cgiuser','',{RaiseError=>0,AutoCommit=>1});

unless ($dbh) {
    print_bug("Couldn't connect to database: $DBI::errstr");
    exit;
}

if ($action) {

    if ($action eq 'new') {
	new_site();
    }
    elsif ($action eq 'extend') {
	extend();
    }
    elsif ($action eq 'check') {
	check();
    }
    elsif ($action eq 'delete') {
	delete_site();
    }

    else {
	print_bug("Unknown action '$action'");
    }

}
else {

    show_welcome();

}

sub show_welcome {

    my $template = HTML::Template->new(filename=>'/var/www/templates/ftp_welcome.html');

    # Add the amount of free space

    open (DF,"df -h |") or die "Can't open df";
    while (<DF>) {
	my (undef,undef,undef,$free,undef,$share) = split(/\s+/);

	next unless ($share);
	next unless ($share eq '/usr');
	$template->param(FREE_SPACE => $free);
    }

    print $template->output();

}

sub extend {

    my $id = $q->param('id');
    my $secret = $q->param('secret');
    my $duration = $q->param('duration');


    # Check that the id and secret match.

    unless ($id and $id =~ /^\d+$/) {
	print_error("ID value '$id' was missing or invalid");
	return;
    }

    unless ($secret) {
	print_error("Secret value was not passed");
	return;
    }

    my ($username,$retrieved_secret) = $dbh->selectrow_array("SELECT username,secret FROM site WHERE id=?",undef,($id));

    unless ($retrieved_secret eq $secret) {
	print_error("Secrets did not match - not allowing update");
	return;
    }

    # If we get here then we're good to go

    my $template = HTML::Template->new(filename => '/var/www/templates/extend_site.html');

    $template->param(DURATION => $duration,
		     USERNAME => $username,
		     ID => $id,
		     SECRET => $secret,);

    if ($duration) {
	unless ($duration =~ /^\d+$/) {
	    print_bug("Invalid duration '$duration'");
	    return;
	}

	# Update the database with the new date
	$dbh->do("UPDATE site SET end_date=NOW()+INTERVAL $duration DAY WHERE id=?",undef,($id)) or do {
	    print_bug("Failed to update duration: ".$dbh->errstr());
	    return;
	};

    }

    print $template->output();

}


sub check {

    my $email = $q->param('email');

    if ($email) {

	unless ($email =~ /[^@]+\@[^@]+/) {
	    print_error("Email didn't look like an actual email address");
	    return;
	}

	unless ($email =~ /\@babraham\.ac\.uk$/i or $email =~ /\@babraham\.co\.uk$/i) {
	    print_error("Only babraham emails (babraham.ac.uk or babraham.co.uk) can use this system, not $email");
	    return;
	}
    }
    
    my $template = HTML::Template->new(filename => '/var/www/templates/check_sites.html');

    $template->param(
		     EMAIL => $email,
		     );

    if ($email) {

	my $message = "This is an automated message from the Babraham FTP system which lists the FTP sites you currently have active\n\n";

	$message .= "You can use the links below to extend or delete your sites\n\n";

	$message .= "Active sites for $email:\n\n";

	my $all_sites_sth = $dbh->prepare("SELECT id,username,secret,end_date,name FROM site WHERE 
end_date IS NOT NULL AND email=?");

	$all_sites_sth->execute($email) or do {
	    print_bug("ERROR: Failed to list all sites for $email: ".$dbh->errstr());
	    return
	};

	my $site_count = 0;

	while (my ($id,$username,$secret,$end_date,$site_name) = $all_sites_sth->fetchrow_array()) {

	    $site_name = " ($site_name)" if ($site_name);

	    ++$site_count;

	    # Find out how much space this site is using

	    my $usage = `sudo /usr/bin/du -sh /usr/users/$username`;
	    $usage = (split(/\s+/,$usage))[0];


	    $message .= "${username}${site_name} currently using $usage and expires on $end_date\n\n";

	    $message .= "EXTEND $username: http://ftp2.babraham.ac.uk/cgi-bin/ftp.pl?action=extend&id=$id&secret=$secret\n\n";
	    $message .= "DELETE $username: http://ftp2.babraham.ac.uk/cgi-bin/ftp.pl?action=delete&id=$id&secret=$secret\n\n";
	    $message .= "\n\n";

	}

	if ($site_count == 0) {
	    $message .= "You do not currently have any active FTP sites\n\n";
	}

	my %mail = (
		    To => $email,
		    From => 'Babraham FTP System<simon.andrews@babraham.ac.uk>',
		    Message => $message,
		    Subject => 'Active FTP sites summary',
		    smtp => '149.155.145.27',
		    );

	sendmail(%mail) or do {
	    print_bug("Failed to send mail: $Mail::Sendmail::error\n");
	    return;
	};

    }

    print $template->output();

}


sub delete_site {

    my $id = $q->param('id');
    my $secret = $q->param('secret');
    my $confirm = $q->param('confirm');


    # Check that the id and secret match.

    unless ($id and $id =~ /^\d+$/) {
	print_error("ID value '$id' was missing or invalid");
	return;
    }

    unless ($secret) {
	print_error("Secret value was not passed");
	return;
    }

    my ($username,$retrieved_secret) = $dbh->selectrow_array("SELECT username,secret FROM site WHERE id=?",undef,($id));

    unless ($retrieved_secret eq $secret) {
	print_error("Secrets did not match - not allowing update");
	return;
    }

    # If we get here then we're good to go

    my $template = HTML::Template->new(filename => '/var/www/templates/delete_site.html');

    $template->param(CONFIRM => $confirm,
		     USERNAME => $username,
		     ID => $id,
		     SECRET => $secret,);

    if ($confirm) {
	# Update the database to flag this for deletion in the next cleanup
	$dbh->do("UPDATE site SET end_date=NOW() WHERE id=?",undef,($id)) or do {
	    print_bug("Failed to update end_date: ".$dbh->errstr());
	    return;
	};

    }

    print $template->output();

}

sub new_site {

    my $email = $q->param('email');
    my $duration = $q->param('duration');
    my $site_name = $q->param('name');
    my $http = $q->param('web');

    $http = 0 unless ($http);


    unless ($duration) {
	# We just need to show the input form

	my $template = HTML::Template -> new(filename => '/var/www/templates/new_site.html');
	print $template->output();
	return;
    }

    unless ($email) {
	print_error("No email address was entered");
	return;
    }

    unless ($email =~ /[^@]+\@[^@]+/) {
	print_error("Email '$email' didn't look like an actual email address");
	return;
    }

    unless ($email =~ /\@babraham\.ac\.uk$/i or $email =~ /\@babraham\.co\.uk$/i) {
	print_error("Only babraham emails (babraham.ac.uk or babraham.co.uk) can use this system, not $email");
	return;
    }

    unless ($duration =~ /^\d+$/) {
	print_bug("Invalid duration '$duration'");
	return;
    }

    if ($duration < 1 or $duration > 62) {
	print_bug("Invalid duration range '$duration'");
	return;
    }

    $site_name = "" unless ($site_name);

    # We need to create a new site.

    # Make sure we don't clash with anyone else
    $dbh->do("LOCK TABLES site WRITE") or do {
	print_bug("Failed to lock tables: ".$dbh->errstr());
	return;
    };

    # Find a free site

    my ($id,$username) = $dbh->selectrow_array("SELECT id,username FROM site WHERE end_date is NULL ORDER BY RAND() LIMIT 1");

    unless ($id) {
	print_bug("No free sites found");
	$dbh->do("UNLOCK TABLES");
	return;
    }

    my $password = make_password();

    my $secret = make_password();

    # Update the database with the new information

    $dbh->do("UPDATE site SET email=?,secret=?,name=?,start_date=NOW(),end_date=NOW()+INTERVAL $duration DAY WHERE id=?",undef,($email,$secret,$site_name,$id)) or do {
	print_bug("Couldn't enter new site information:".$dbh->errstr());
	$dbh->do("UNLOCK TABLES");
	return;
    };


    # Change the account password and set permissions for web access
    my $usernumber = $username;
    $usernumber =~ s/ftpusr//;

    system ("sudo /usr/local/bin/setftppw $usernumber $password $http > /dev/null 2>&1") == 0 or do {
       print_bug("Failed to set password to $password for $username");
	$dbh->do("UNLOCK TABLES");
	return;
    };



 
    # Print out the details of the new site

    my $web_url = "";
    $web_url = "\nWEB URL 	http://ftp2.babraham.ac.uk/ftpusr$usernumber\n" if ($http);

    my $template = HTML::Template -> new(filename=>'/var/www/templates/new_site_complete.html');

    $template->param(username => $username,
		     password => $password,
		     web => $http,
		     );

    # Send an email with the site details

    my $message = <<"END_EMAIL";
Your new FTP site is ready for use. The site is currently empty, but you can upload data to it via FTP.

You can connect to your site either using a dedicated FTP client (eg Cyberduck (http://cyberduck.ch) or Filezilla (http://filezilla-project.org)) or you can download from the site using a web browser. Data upload will generally require the use of a proper FTP client.

The section below shows the connection information you need. If you forward this email to your collaborators they too will have access to the site.

This FTP site allows both read and write access to anyone who connects to it. This means you can use to send or receive data with your collaborators. At the end of the period you specified the site will be shut down and the data on it will be deleted automatically (you\'ll get a warning email the day before and you can choose to extend the site at that point). There are no file protection measures on this site, so anyone who has the login details can alter or delete any of the data on the site. 

If you have chosen to allow web (HTTP) access to your site then you can use the web url below to access the data on the site without using a password.  This method can only be used to download, not upload, data.

Do not use this site to store your only copy of any data.

Connection Details
==================

Hostname 	ftp2.babraham.ac.uk

Username 	$username

Password 	$password

FTP URL 	ftp://$username:$password\@ftp2.babraham.ac.uk
$web_url
END_EMAIL

;
    my %mail = (
		To => $email,
		From => 'Babraham FTP System<simon.andrews@babraham.ac.uk>',
		Message => $message,
		Subject => 'New FTP Site Created',
		smtp => '149.155.145.27',
		);

    sendmail(%mail) or do {
	print_bug("Failed to send email: $Mail::Sendmail::error");
	return;
    };

    

    print $template->output();

}

sub make_password {

    my @letters = ('a'..'z','A'..'Z',0..9);

    @letters = shuffle @letters;

    return join('',@letters[0..7]);

}


sub print_bug {

    my ($message) = @_;

    # Put something in the logs
    warn $message;

    my $template = HTML::Template -> new (filename=>'/var/www/templates/error.html');
    $template -> param(ERROR=>$message);
    print $template -> output();


}

sub print_error {

    my ($message) = @_;

    my $template = HTML::Template -> new (filename=>'/var/www/templates/error.html');
    $template -> param(WARNING=>$message);
    print $template -> output();

}
