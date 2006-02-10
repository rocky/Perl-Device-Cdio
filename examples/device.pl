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

# Program to read CD blocks. See read-cd from the libcdio distribution
# for a more complete program.

BEGIN {
    chdir 'example' if -d 'example';
}
use lib '../lib';
use blib;

use Device::Cdio;
use Device::Cdio::Device;

use vars qw($0 $program $pause %opts);

use strict;

my $vcid ='$Id$';

# Prints out drive capabilities
sub print_drive_capabilities($$$) {
    my ($i_read_cap, $i_write_cap, $i_misc_cap) = @_;
  if ($perlcdio::DRIVE_CAP_ERROR == $i_misc_cap) {
    printf("Error in getting drive hardware properties\n");
  } else {
    printf("Hardware                    : %s\n", 
	   $i_misc_cap & $perlcdio::DRIVE_CAP_MISC_FILE  
	   ? "Disk Image"  : "CD-ROM or DVD");
    printf("Can eject                   : %s\n", 
	   $i_misc_cap & $perlcdio::DRIVE_CAP_MISC_EJECT
	   ? "Yes" : "No");
    printf("Can close tray              : %s\n", 
	   $i_misc_cap & $perlcdio::DRIVE_CAP_MISC_CLOSE_TRAY
	   ? "Yes" : "No");
    printf("Can disable manual eject    : %s\n", 
	   $i_misc_cap & $perlcdio::DRIVE_CAP_MISC_LOCK          
	   ? "Yes" : "No");
    printf("Can select juke-box disc    : %s\n\n", 
	   $i_misc_cap & $perlcdio::DRIVE_CAP_MISC_SELECT_DISC   
	   ? "Yes" : "No");

    printf("Can set drive speed         : %s\n", 
	   $i_misc_cap & $perlcdio::DRIVE_CAP_MISC_SELECT_SPEED  
	   ? "Yes" : "No");
    printf("Can detect if CD changed    : %s\n", 
	   $i_misc_cap & $perlcdio::DRIVE_CAP_MISC_MEDIA_CHANGED 
	   ? "Yes" : "No");
    printf("Can read multiple sessions  : %s\n", 
	   $i_misc_cap & $perlcdio::DRIVE_CAP_MISC_MULTI_SESSION 
	   ? "Yes" : "No");
    printf("Can hard reset device       : %s\n\n", 
	   $i_misc_cap & $perlcdio::DRIVE_CAP_MISC_RESET         
	   ? "Yes" : "No");
  }
  
    
  if ($perlcdio::DRIVE_CAP_ERROR == $i_read_cap) {
      printf("Error in getting drive reading properties\n");
  } else {
    printf("Reading....\n");
    printf("  Can play audio            : %s\n", 
	   $i_read_cap & $perlcdio::DRIVE_CAP_READ_AUDIO      
	   ? "Yes" : "No");
    printf("  Can read  CD-R            : %s\n", 
	   $i_read_cap & $perlcdio::DRIVE_CAP_READ_CD_R       
	   ? "Yes" : "No");
    printf("  Can read  CD-RW           : %s\n", 
	   $i_read_cap & $perlcdio::DRIVE_CAP_READ_CD_RW      
	   ? "Yes" : "No");
    printf("  Can read  DVD-ROM         : %s\n", 
	   $i_read_cap & $perlcdio::DRIVE_CAP_READ_DVD_ROM    
	   ? "Yes" : "No");
  }
  

  if ($perlcdio::DRIVE_CAP_ERROR == $i_write_cap) {
      printf("Error in getting drive writing properties\n");
  } else {
    printf("\nWriting....\n");
    printf("  Can write CD-RW           : %s\n", 
	   $i_read_cap & $perlcdio::DRIVE_CAP_READ_CD_RW     ? "Yes" : "No");
    printf("  Can write DVD-R           : %s\n", 
	   $i_write_cap & $perlcdio::DRIVE_CAP_READ_DVD_R    ? "Yes" : "No");
    printf("  Can write DVD-RAM         : %s\n", 
	   $i_write_cap & $perlcdio::DRIVE_CAP_READ_DVD_RAM  ? "Yes" : "No");
  }
}

my ($d, $drive_name);

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
        
my ($vendor, $model, $release, $drc) = $d->get_hwinfo();

print "drive: $drive_name, vendor: $vendor, " .
    "model: $model, release: $release\n";

printf "***Remaining Currently broken pending investigation...\n";
exit 0;

my ($i_read_cap, $i_write_cap, $i_misc_cap) =  $d->get_drive_cap();
print_drive_capabilities($i_read_cap, $i_write_cap, $i_misc_cap);


