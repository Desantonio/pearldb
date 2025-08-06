package PearlDB::Executor;

use strict;
use warnings;
use PearlDB::Storage;

my $current_db;
my $storage = PearlDB::Storage->new();

sub execute {
    my ($cmd) = @_;

    if ($cmd->{command} eq 'create_database') {
        $storage->create_database($cmd->{db});
        print "✅ Database '$cmd->{db}' created.\n";
    } elsif ($cmd->{command} eq 'drop_database') {
        $storage->drop_database($cmd->{db});
        print "🗑️ Database '$cmd->{db}' dropped.\n";
    } elsif ($cmd->{command} eq 'use') {
        $current_db = $cmd->{db};
        print "✅ Using database '$current_db'.\n";
    } elsif ($cmd->{command} eq 'show_databases') {
        my @dbs = $storage->list_databases;
        print "📚 Databases:\n";
        print " - $_\n" for @dbs;
    } elsif ($cmd->{command} eq 'show_tables') {
        unless ($current_db) {
            print "⚠️ No database selected.\n";
            return;
        }
        my @tables = $storage->list_tables($current_db);
        print "📁 Tables in $current_db:\n";
        print " - $_\n" for @tables;
    } elsif ($cmd->{command} eq 'create_table') {
        return print "⚠️ No DB selected.\n" unless $current_db;
        $storage->create_table($current_db, $cmd->{table});
        print "✅ Table '$cmd->{table}' created in $current_db.\n";
    } elsif ($cmd->{command} eq 'drop_table') {
        return print "⚠️ No DB selected.\n" unless $current_db;
        $storage->drop_table($current_db, $cmd->{table});
        print "🗑️ Table '$cmd->{table}' dropped.\n";
    } elsif ($cmd->{command} eq 'insert') {
        return print "⚠️ No DB selected.\n" unless $current_db;
        $storage->insert($current_db, $cmd->{table}, $cmd->{values});
        print "✅ Inserted into '$cmd->{table}'.\n";
    } elsif ($cmd->{command} eq 'select') {
        return print "⚠️ No DB selected.\n" unless $current_db;
        my $rows = $storage->select($current_db, $cmd->{table});
        return print "⚠️ Table is empty or missing.\n" unless @$rows;

        my $headers = shift @$rows;
        my $width = 15;
        print join('|', map { sprintf("%-${width}s", $_) } @$headers), "\n";
        print '-' x (($width+1) * @$headers), "\n";
        for my $row (@$rows) {
            print join('|', map { sprintf("%-${width}s", $_) } @$row), "\n";
        }
    } elsif ($cmd->{command} eq 'delete') {
        return print "⚠️ No DB selected.\n" unless $current_db;
        my $count = $storage->delete($current_db, $cmd->{table}, $cmd->{where});
        print "🗑️ Deleted $count rows.\n";
    } elsif ($cmd->{command} eq 'update') {
        return print "⚠️ No DB selected.\n" unless $current_db;
        my $count = $storage->update($current_db, $cmd->{table}, $cmd->{set}, $cmd->{where});
        print "🔁 Updated $count rows.\n";
    } elsif ($cmd->{command} eq 'exit') {
        print "👋 Exiting PearlDB.\n";
        exit;
    } else {
        print "❌ Invalid command: $cmd->{input}\n";
    }
}

1;
