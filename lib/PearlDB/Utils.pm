package PearlDB::Utils;
use strict;
use warnings;

sub trim {
    my ($str) = @_;
    $str =~ s/^\s+|\s+$//g;
    return $str;
}

1;
