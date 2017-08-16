DROP DATABASE ftp_sites;

CREATE DATABASE ftp_sites;

USE ftp_sites;

CREATE TABLE site (

	id int auto_increment primary key,
	username VARCHAR(20),
	start_date DATE,
	end_date DATE,
	email VARCHAR(100),
	secret VARCHAR(100),
	name VARCHAR(200),
	KEY (end_date),
	KEY (email)
);

GRANT SELECT,UPDATE on ftp_sites.site TO cgiuser@localhost;
GRANT LOCK TABLES on ftp_sites.* TO cgiuser@localhost;


FLUSH PRIVILEGES;

INSERT INTO site (username) VALUES ("ftpusr1");
INSERT INTO site (username) VALUES ("ftpusr2");
INSERT INTO site (username) VALUES ("ftpusr3");
INSERT INTO site (username) VALUES ("ftpusr4");
INSERT INTO site (username) VALUES ("ftpusr5");
INSERT INTO site (username) VALUES ("ftpusr6");
INSERT INTO site (username) VALUES ("ftpusr7");
INSERT INTO site (username) VALUES ("ftpusr8");
INSERT INTO site (username) VALUES ("ftpusr9");
INSERT INTO site (username) VALUES ("ftpusr10");
INSERT INTO site (username) VALUES ("ftpusr11");
INSERT INTO site (username) VALUES ("ftpusr12");
INSERT INTO site (username) VALUES ("ftpusr13");
INSERT INTO site (username) VALUES ("ftpusr14");
INSERT INTO site (username) VALUES ("ftpusr15");
INSERT INTO site (username) VALUES ("ftpusr16");
INSERT INTO site (username) VALUES ("ftpusr17");
INSERT INTO site (username) VALUES ("ftpusr18");
INSERT INTO site (username) VALUES ("ftpusr19");
INSERT INTO site (username) VALUES ("ftpusr20");
INSERT INTO site (username) VALUES ("ftpusr21");
INSERT INTO site (username) VALUES ("ftpusr22");
INSERT INTO site (username) VALUES ("ftpusr23");
INSERT INTO site (username) VALUES ("ftpusr24");
INSERT INTO site (username) VALUES ("ftpusr25");
INSERT INTO site (username) VALUES ("ftpusr26");
INSERT INTO site (username) VALUES ("ftpusr27");
INSERT INTO site (username) VALUES ("ftpusr28");
INSERT INTO site (username) VALUES ("ftpusr29");
INSERT INTO site (username) VALUES ("ftpusr30");
INSERT INTO site (username) VALUES ("ftpusr31");
INSERT INTO site (username) VALUES ("ftpusr32");
INSERT INTO site (username) VALUES ("ftpusr33");
INSERT INTO site (username) VALUES ("ftpusr34");
INSERT INTO site (username) VALUES ("ftpusr35");
INSERT INTO site (username) VALUES ("ftpusr36");
INSERT INTO site (username) VALUES ("ftpusr37");
INSERT INTO site (username) VALUES ("ftpusr38");
INSERT INTO site (username) VALUES ("ftpusr39");
INSERT INTO site (username) VALUES ("ftpusr40");
INSERT INTO site (username) VALUES ("ftpusr41");
INSERT INTO site (username) VALUES ("ftpusr42");
INSERT INTO site (username) VALUES ("ftpusr43");
INSERT INTO site (username) VALUES ("ftpusr44");
INSERT INTO site (username) VALUES ("ftpusr45");
INSERT INTO site (username) VALUES ("ftpusr46");
INSERT INTO site (username) VALUES ("ftpusr47");
INSERT INTO site (username) VALUES ("ftpusr48");
INSERT INTO site (username) VALUES ("ftpusr49");
INSERT INTO site (username) VALUES ("ftpusr50");
INSERT INTO site (username) VALUES ("ftpusr51");
INSERT INTO site (username) VALUES ("ftpusr52");
INSERT INTO site (username) VALUES ("ftpusr53");
INSERT INTO site (username) VALUES ("ftpusr54");
INSERT INTO site (username) VALUES ("ftpusr55");
INSERT INTO site (username) VALUES ("ftpusr56");
INSERT INTO site (username) VALUES ("ftpusr57");
INSERT INTO site (username) VALUES ("ftpusr58");
INSERT INTO site (username) VALUES ("ftpusr59");
INSERT INTO site (username) VALUES ("ftpusr60");
INSERT INTO site (username) VALUES ("ftpusr61");
INSERT INTO site (username) VALUES ("ftpusr62");
INSERT INTO site (username) VALUES ("ftpusr63");
INSERT INTO site (username) VALUES ("ftpusr64");
INSERT INTO site (username) VALUES ("ftpusr65");
INSERT INTO site (username) VALUES ("ftpusr66");
INSERT INTO site (username) VALUES ("ftpusr67");
INSERT INTO site (username) VALUES ("ftpusr68");
INSERT INTO site (username) VALUES ("ftpusr69");
INSERT INTO site (username) VALUES ("ftpusr70");
INSERT INTO site (username) VALUES ("ftpusr71");
INSERT INTO site (username) VALUES ("ftpusr72");
INSERT INTO site (username) VALUES ("ftpusr73");
INSERT INTO site (username) VALUES ("ftpusr74");
INSERT INTO site (username) VALUES ("ftpusr75");
INSERT INTO site (username) VALUES ("ftpusr76");
INSERT INTO site (username) VALUES ("ftpusr77");
INSERT INTO site (username) VALUES ("ftpusr78");
INSERT INTO site (username) VALUES ("ftpusr79");
INSERT INTO site (username) VALUES ("ftpusr80");
INSERT INTO site (username) VALUES ("ftpusr81");
INSERT INTO site (username) VALUES ("ftpusr82");
INSERT INTO site (username) VALUES ("ftpusr83");
INSERT INTO site (username) VALUES ("ftpusr84");
INSERT INTO site (username) VALUES ("ftpusr85");
INSERT INTO site (username) VALUES ("ftpusr86");
INSERT INTO site (username) VALUES ("ftpusr87");
INSERT INTO site (username) VALUES ("ftpusr88");
INSERT INTO site (username) VALUES ("ftpusr89");
INSERT INTO site (username) VALUES ("ftpusr90");
INSERT INTO site (username) VALUES ("ftpusr91");
INSERT INTO site (username) VALUES ("ftpusr92");
INSERT INTO site (username) VALUES ("ftpusr93");
INSERT INTO site (username) VALUES ("ftpusr94");
INSERT INTO site (username) VALUES ("ftpusr95");
INSERT INTO site (username) VALUES ("ftpusr96");
INSERT INTO site (username) VALUES ("ftpusr97");
INSERT INTO site (username) VALUES ("ftpusr98");
INSERT INTO site (username) VALUES ("ftpusr99");
INSERT INTO site (username) VALUES ("ftpusr100");

