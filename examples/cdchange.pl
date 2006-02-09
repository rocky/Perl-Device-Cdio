#!/usr/bin/perl -w 
#$Id$
#
#    Copyright (C) 2006 Rocky Bernstein <rocky@cpan.org>
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#

## Program to show CD media changing

BEGIN {
    chdir 'example' if -d 'example';
}
use lib '../lib';
use blib;

use Device::Cdio;
use Device::Cdio::Device;

my $sleep_time = 15;

my $d;
if ($ARGV[0]) {
    $drive_name=$ARGV[0];
    $d = Device::Cdio::Device->new(-source=>$drive_name);
    if (!defined($drive_name)) {
	print "Problem opening CD-ROM: $drive_name\n";
	exit(1);
    }
} else {
    $d = Device::Cdio::Device->new(-driver_id=>$perlcdio::DRIVER_DEVICE);
    $drive_name = $d->get_device();
    if (!defined($drive_name)) {
        print "Problem finding a CD-ROM\n";
        exit(1);
    }
}

$sleep_time = $ARGV[1] if defined($ARGV[1]);

if ($d->get_media_changed()) {
    print "Initial media status: changed\n";
} else {
    print "Initial media status: not changed\n";
}

print "Giving you $sleep_time seconds to change CD if you want to do so.\n";
sleep($sleep_time);
if ($d->get_media_changed()) {
    print "Media status: changed\n";
} else {
    print "Media status: not changed\n";
}
$d->close();
