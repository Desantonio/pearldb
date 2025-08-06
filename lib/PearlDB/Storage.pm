package PearlDB::Storage;

use strict;
use warnings;
use File::Path qw(make_path remove_tree);
use File::Spec;
use Storable qw(store retrieve);

sub new {
    my ($class, %args) = @_;
    my $self = {
        base_path => $args{base_path} || "data",
    };
    make_path($self->{base_path});
    bless $self, $class;
    return $self;
}

# DATABASE OPERATIONS

sub create_database {
    my ($self, $db) = @_;
    my $db_path = File::Spec->catdir($self->{base_path}, $db);
    return -d $db_path ? 0 : make_path($db_path);
}

sub drop_database {
    my ($self, $db) = @_;
    my $db_path = File::Spec->catdir($self->{base_path}, $db);
    return -d $db_path ? remove_tree($db_path) : 0;
}

sub list_databases {
    my ($self) = @_;
    opendir my $dh, $self->{base_path} or return ();
    my @dbs = grep { -d File::Spec->catdir($self->{base_path}, $_) && !/^\./ } readdir($dh);
    closedir $dh;
    return @dbs;
}

# TABLE OPERATIONS

sub create_table {
    my ($self, $db, $table) = @_;
    my $table_file = $self->_table_file($db, $table);
    make_path($self->_db_path($db)) unless -d $self->_db_path($db);
    store([], $table_file);
}

sub drop_table {
    my ($self, $db, $table) = @_;
    my $file = $self->_table_file($db, $table);
    return -e $file ? unlink($file) : 0;
}

sub list_tables {
    my ($self, $db) = @_;
    my $db_path = $self->_db_path($db);
    return () unless -d $db_path;
    opendir my $dh, $db_path or return ();
    my @tables = map { s/\.tbl$//r } grep { /\.tbl$/ } readdir($dh);
    closedir $dh;
    return @tables;
}

# DATA OPERATIONS

sub insert {
    my ($self, $db, $table, $values) = @_;
    my $data = $self->_load_table($db, $table);
    push @$data, $values;
    $self->_save_table($db, $table, $data);
}

sub select {
    my ($self, $db, $table) = @_;
    my $data = $self->_load_table($db, $table);
    return [] unless @$data;
    my @headers = map { "col$_" } (1 .. scalar(@{$data->[0]}));
    return [ \@headers, @$data ];
}

sub delete {
    my ($self, $db, $table, $where) = @_;
    my $data = $self->_load_table($db, $table);
    return 0 unless @$data;

    my $col_index = $self->_get_col_index($data, $where->{column});
    return 0 unless defined $col_index;

    my $val = $where->{value};
    my @filtered = grep { $_->[$col_index] ne $val } @$data;

    my $deleted = @$data - @filtered;
    $self->_save_table($db, $table, \@filtered);
    return $deleted;
}

sub update {
    my ($self, $db, $table, $set_col, $set_val, $where) = @_;
    my $data = $self->_load_table($db, $table);
    return 0 unless @$data;

    my $set_idx = $self->_get_col_index($data, $set_col);
    my $col_index = $self->_get_col_index($data, $where->{column});
    return 0 unless defined $set_idx && defined $col_index;

    my $val = $where->{value};
    my $updated = 0;

    foreach my $row (@$data) {
        if ($row->[$col_index] eq $val) {
            $row->[$set_idx] = $set_val;
            $updated++;
        }
    }

    $self->_save_table($db, $table, $data);
    return $updated;
}

# INTERNAL

sub _db_path {
    my ($self, $db) = @_;
    return File::Spec->catdir($self->{base_path}, $db);
}

sub _table_file {
    my ($self, $db, $table) = @_;
    return File::Spec->catfile($self->_db_path($db), "$table.tbl");
}

sub _load_table {
    my ($self, $db, $table) = @_;
    my $file = $self->_table_file($db, $table);
    return -e $file ? retrieve($file) : [];
}

sub _save_table {
    my ($self, $db, $table, $data) = @_;
    my $file = $self->_table_file($db, $table);
    store($data, $file);
}

sub _get_col_index {
    my ($self, $data, $col_name) = @_;
    return undef unless @$data;

    # Expect column names like col1, col2...
    if ($col_name =~ /^col(\d+)$/i) {
        my $idx = $1 - 1;
        return $idx if defined $data->[0][$idx];
    }

    return undef;
}

1;
