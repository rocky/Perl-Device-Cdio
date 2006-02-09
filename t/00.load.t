#!/usr/bin/perl -w
# $Id$

use strict;
BEGIN {
    chdir 't' if -d 't';
}
use lib '../lib';
use blib;

use Test::More tests => 1;

BEGIN {
use_ok( 'Device::Cdio' );
}

diag( "Testing Device::Cdio $Device::Cdio::VERSION" );
