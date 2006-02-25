#!/usr/bin/perl -w
# $Id$

# Test some low-level ISO9660 routines

use strict;

BEGIN {
    chdir 't' if -d 't';
}
use lib '../lib';
use blib;

use perliso9660;
use Test::Simple tests => 2;

my @achars = ('!', '"', '%', '&', '(', ')', '*', '+', ',', '-', '.',
	   '/', '?', '<', '=', '>');

my $bad = 0;
for (my $c=ord('A'); $c<=ord('Z'); $c++ ) {
    if (!perliso9660::isdchar($c)) {
	printf "Failed iso9660_isachar test on %c\n", $c;
	$bad++;
    }
    if (!perliso9660::isachar($c)) {
	printf "Failed iso9660_isachar test on %c\n", $c;
	$bad++;
    }
}

ok($bad==0, 'isdchar & isarch A..Z');

for (my $c=ord('0'); $c<=ord('9'); $c++ ) {
    if (!perliso9660::isdchar($c)) {
	printf "Failed iso9660_isdchar test on %c\n", $c;
	$bad++;
    }
    if (!perliso9660::isachar($c)) {
	printf "Failed iso9660_isachar test on %c\n", $c;
	$bad++;
    }
}

ok($bad==0, 'isdchar & isachar 0..9');

exit 0;
