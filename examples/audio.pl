#!/usr/bin/perl -w
#$Id$
#
#    Copyright (C) 2006 Rocky Bernstein <rocky@panix.com>
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
    push @INC, ('../blib/lib', '../blib/arch', 'blib/lib', 'blib/arch');
}

use Device::Cdio;
use Device::Cdio::Device;
use Device::Cdio::Track;

use vars qw($0 $program $pause %opts);

use strict;

my $vcid ='$Id$';

sub init() {
  use File::Basename;
  $program = basename($0); # Who am I today, anyway?
  $opts{close}=undef;
  $opts{eject}=0;
  $opts{pause}=0;
  $opts{play}=0;
  $opts{resume}=0;
  $opts{stop}=0;
  $opts{stop}=0;
}

# Show the CVS version id string and quit.
sub show_version() {
    print "$program version $vcid\n";
    exit 1;
}

sub usage {
  my($full_help) = @_;

  print "
usage:

   $program [options] [device]
    Issue analog audio CD controls - like playing

options:
    --help                 -- print this help and exit
    --version              -- show a CVS version string and exit
    --eject DEVICE         -- eject disc from DEVICE
    --close DEVICE         -- close CD tray of DEVICE
    -P | --pause           -- pause playing
    --play                 -- play entire CD
    --resume               -- resume playing
    --stop                 -- stop playing
    --track=N              -- play track N
";
  exit 100;
}

# The bane of programming.
sub process_options() {
  use Getopt::Long;
  my(@opt_cf);
  $Getopt::Long::autoabbrev = 1;
  my($help, $long_help, $show_version);

  my $result = &GetOptions
    (
     'help'           => \$help,
     'close'          => \$opts{close},
     'version'        => \$opts{show_version},
     'P|pause'        => \$opts{pause},
     'play'           => \$opts{play},
     'resume'         => \$opts{resume},
     'stop'           => \$opts{stop},
     'track=n'        => \$opts{track},
    );
  show_version() if $show_version;

  usage(0) unless $result || @ARGV > 1;
  usage(1) if $help;
}

init();
process_options();

my ($drc, $device_name);

# Handle closing the CD-ROM tray if that was specified.
if ($opts{close}) {
    $device_name = $opts{close};
    $drc = Cdio::close_tray(-drive=>$opts{close});
    printf "Error closing: %s\n", perlcdio::driver_errmsg($drc) if ($drc);
}

my $d;
if ($ARGV[0]) {
    $d = Device::Cdio::Device->new($ARGV[0]);
    exit(1) if !defined($d);
} else {
    $d = Device::Cdio::Device->new(-driver_id=>$perlcdio::DRIVER_DEVICE);
    exit(1) if !defined($d);
}

$device_name = $d->get_device();

if ($opts{play}) {
    if ($d->get_disc_mode() ne 'CD-DA') {
        printf("The disc on %s I found was not CD-DA, but %s\n",
	       $device_name, $d->get_disc_mode());
        print "I have bad feeling about trying to play this...";
    }
    my $start_lsn = $d->get_first_track()->get_lsn();
    my $end_lsn=$d->get_disc_last_lsn();
    printf "Playing entire CD on %s\n", $device_name;
    $drc = $d->audio_play_lsn($start_lsn, $end_lsn);
    printf "Error playing CD: %s\n", perlcdio::driver_errmsg($drc) if ($drc);

#} elsif ($opts{track}) {
#    if ($opts{track > $d->get_last_track().track}) {
#	printf ("Requested track %d but CD only has %d tracks", 
#		opts.track, $d->get_last_track().track);
#	exit(2);
#    }
#        
#    if ($opts{track < $d->get_first_track().track}) {
#	printf("Requested track %d but first track on CD is %d" 
#	       opts.track, $d->get_first_track().track);
#	exit(2);
#    }
#    printf("Playing track %d on %s"  % opts.track, device_name);
#    $start_lsn = $d->get_track(opts.track).get_lsn();
#    $end_lsn = $d->get_track(opts.track+1).get_lsn();
#    $drc = $d->audio_play_lsn(start_lsn, end_lsn);
#    printf "Error closing: %s\n", perlcdio::driver_errmsg($drc) if ($drc);
#        
} elsif ($opts{pause}) {
    printf "Pausing playing in drive %s\n", $device_name;
    $drc = $d->audio_pause();
    printf "Error pausing: %s\n", perlcdio::driver_errmsg($drc) if ($drc);
} elsif ($opts{resume}) {
    printf "Resuming playing in drive %s\n", $device_name;
    $drc = $d->audio_resume();
    printf "Error resuming: %s\n", perlcdio::driver_errmsg($drc) if ($drc);
} elsif ($opts{stop}) {
    printf "Stopping playing in drive %s\n", $device_name;
    $drc = $d->audio_stop();
    printf("Stopping failed on drive %s: %s\n", 
	   $device_name, perlcdio::driver_errmsg($drc)) 
	if $drc;
} elsif ($opts{eject}) {
    print "Ejecting CD in drive %s\n", $device_name;
    $drc = $d->eject_media();
    printf("Eject failed on drive %s: %s\n", 
	   $device_name, perlcdio::driver_errmsg($drc))
	if $drc;
}
        
$d->close();
