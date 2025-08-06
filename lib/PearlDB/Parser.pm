package PearlDB::Parser;

use strict;
use warnings;

sub parse {
    my ($input) = @_;
    $input =~ s/^\s+|\s+$//g;
    $input =~ s/;?\s*$//;

    return { command => 'exit' } if $input =~ /^exit$/i;

    if ($input =~ /^CREATE DATABASE (\w+)$/i) {
        return { command => 'create_database', db => $1 };
    }
    if ($input =~ /^DROP DATABASE (\w+)$/i) {
        return { command => 'drop_database', db => $1 };
    }
    if ($input =~ /^USE (\w+)$/i) {
        return { command => 'use', db => $1 };
    }
    if ($input =~ /^SHOW DATABASES$/i) {
        return { command => 'show_databases' };
    }
    if ($input =~ /^SHOW TABLES$/i) {
        return { command => 'show_tables' };
    }
    if ($input =~ /^CREATE TABLE (\w+)$/i) {
        return { command => 'create_table', table => $1 };
    }
    if ($input =~ /^DROP TABLE (\w+)$/i) {
        return { command => 'drop_table', table => $1 };
    }
    if ($input =~ /^INSERT INTO (\w+) VALUES \((.*?)\)$/i) {
        my @values = map { s/^'|'$//gr } split /\s*,\s*/, $2;
        return { command => 'insert', table => $1, values => \@values };
    }
    if ($input =~ /^SELECT \* FROM (\w+)$/i) {
        return { command => 'select', table => $1 };
    }
    if ($input =~ /^DELETE FROM (\w+) WHERE (\w+) *= *'?(.*?)'?$/i) {
        return {
            command => 'delete',
            table   => $1,
            where   => { column => $2, value => $3 }
        };
    }
    if ($input =~ /^UPDATE (\w+) SET (\w+)= *'?(.*?)'? WHERE (\w+)= *'?(.*?)'?$/i) {
        return {
            command => 'update',
            table   => $1,
            set     => { column => $2, value => $3 },
            where   => { column => $4, value => $5 }
        };
    }

    return { command => 'invalid', input => $input };
}

1;
