#!/usr/bin/perl -T
# $id$

use strict;
BEGIN {
    push @INC, ('blib/lib', 'blib/arch');
}

use Test::More;
eval "use Test::Pod::Coverage 1.04";
plan skip_all => "Test::Pod::Coverage 1.04 required for testing POD coverage" if $@;

all_pod_coverage_ok();

# Don't know how to get this from perlcdio ignored.
#all_pod_coverage_ok(
#		    'perlcdio', 
#		    { also_private => [ qr/this$/ ] },
#		    "perlcdio, 'this' routine"
#		    );
