#!/usr/bin/perl -w
# $Id$

use strict;
BEGIN {
    push @INC, '../blib/lib';
}

use Test::More tests => 1;

BEGIN {
use_ok( 'Device::Cdio' );
}

diag( "Testing Device::Cdio $Device::Cdio::VERSION" );
