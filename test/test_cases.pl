#!/usr/bin/env perl

use strict;
use warnings;
use lib 'lib';
use PearlDB::Parser;
use PearlDB::Executor;

my @commands = (
    "CREATE DATABASE testdb;",
    "USE testdb;",
    "CREATE TABLE users;",
    "INSERT INTO users VALUES ('1', 'Alice');",
    "INSERT INTO users VALUES ('2', 'Bob');",
    "SELECT * FROM users;",
    "UPDATE users SET col2='Charlie' WHERE col1='2';",
    "SELECT * FROM users;",
    "DELETE FROM users WHERE col1='1';",
    "SELECT * FROM users;",
    "SHOW TABLES;",
    "DROP TABLE users;",
    "SHOW TABLES;",
    "DROP DATABASE testdb;",
    "SHOW DATABASES;",
);

print "Running test cases...\n";

for my $sql (@commands) {
    print "Executing: $sql\n";
    my $cmd = PearlDB::Parser::parse($sql);
    PearlDB::Executor::execute($cmd);
}

print "✅ All test cases executed.\n";
