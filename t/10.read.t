#!/usr/bin/perl -w
# $Id$

# Test functioning of read routines

use strict;

BEGIN {
    chdir 't' if -d 't';
}
use lib '../lib';
use blib;

use Device::Cdio::Device;
use Test::Simple tests => 4;

my $cuefile="../data/isofs-m1.cue";
my $device = Device::Cdio::Device->new(-source=>$cuefile);

# Read the ISO Primary Volume descriptor

my($data, $size, $drc) = 
    $device->read_sectors(16, $perlcdio::READ_MODE_M1F1);

ok(substr($data, 1, 5) eq 'CD001');

my $data2 = $device->read_sectors(16, $perlcdio::READ_MODE_M1F1);
ok($data2 eq $data);

($data, $size, $drc) = $device->read_data_blocks(26);
ok(substr($data, 6, 26) eq 'GNU GENERAL PUBLIC LICENSE');
ok($size == $perlcdio::ISO_BLOCKSIZE);
