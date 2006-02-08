package Device::Cdio;
require 5.8.7;
#
#    $Id$
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

=pod

=head1 NAME

Cdio The CD Input and Control library (Cdio) encapsulates CD-ROM 
reading and control. Applications wishing to be oblivious of the OS-
and device-dependent properties of a CD-ROM can use this library.

=cut

# You can run this file through either pod2man or pod2html to produce
# pretty documentation in manual or html file format (these utilities
# are part of the Perl 5 distribution).

use version; $VERSION = qv('0.0.1');

use vars qw($VERSION $revision @EXPORT_OK @EXPORT @ISA %drivers);
use perlcdio;
use Device::Cdio::Util qw( _check_arg_count _extra_args _rearrange );

$revision = '$Id$';

use warnings;
use strict;
use Carp;

@ISA = qw(Exporter);
@EXPORT    = qw(close_tray have_driver is_binfile is_cuefile is_nrg is_device
		is_tocfile convert_drive_cap_misc convert_drive_cap_read
		convert_drive_cap_write);
@EXPORT_OK = qw(_rearrange drivers);

# Note: the keys below match those the names returned by
# cdio_get_driver_name()

%Device::Cdio::drivers = (
    'Unknown'   => $perlcdio::DRIVER_UNKNOWN,
    'AIX'       => $perlcdio::DRIVER_AIX,
    'BSDI'      => $perlcdio::DRIVER_BSDI,
    'FreeBSD'   => $perlcdio::DRIVER_FREEBSD,
    'GNU/Linux' => $perlcdio::DRIVER_LINUX,
    'Solaris'   => $perlcdio::DRIVER_SOLARIS,
    'OS X'      => $perlcdio::DRIVER_OSX,
    'WIN32'     => $perlcdio::DRIVER_WIN32,
    'CDRDAO'    => $perlcdio::DRIVER_CDRDAO,
    'BIN/CUE'   => $perlcdio::DRIVER_BINCUE,
    'NRG'       => $perlcdio::DRIVER_NRG,
    'device'    => $perlcdio::DRIVER_DEVICE
    );

%Device::Cdio::read_mode2blocksize = (
    $perlcdio::READ_MODE_AUDIO => $perlcdio::CD_FRAMESIZE_RAW,
    $perlcdio::READ_MODE_M1F1  => $perlcdio::M2RAW_SECTOR_SIZE,
    $perlcdio::READ_MODE_M1F2  => $perlcdio::CD_FRAMESIZE,
    $perlcdio::READ_MODE_M2F1  => $perlcdio::M2RAW_SECTOR_SIZE,
    $perlcdio::READ_MODE_M2F2  => $perlcdio::CD_FRAMESIZE
    );

=pod

=head1 SUBROUTINES

=head2 close_tray 

close_tray(drive=undef, driver_id=$perlcdio::DRIVER_UNKNOWN) 
 -> (drc, driver_id)
   
close media tray in CD drive if there is a routine to do so. 

In an array context, the driver return-code status and the
name of the driver used are returned.
In a scalar context, just the return code status is returned.
=cut

sub close_tray {
    my (@p) = @_;
    my($drive, $driver_id, @args) = _rearrange(['DRIVE','DRIVER_ID'], @p);
    return undef if _extra_args(@args);
    $driver_id = $perlcdio::DRIVER_UNKNOWN if !defined($driver_id);

    my ($drc, $found_driver_id) = perlcdio::close_tray($drive, $driver_id);
    ## Use wantarray to determine if we want one output or two.
    return wantarray ? ($drc, $found_driver_id) : $drc;
}

=pod

=head2 get_default_device_driver

get_default_device_driver(driver_id=DRIVER_DEVICE)->[device, driver]

Return a string containing the default CD device if none is specified.
if driver_id is DRIVER_UNKNOWN or DRIVER_DEVICE then find a suitable
one set the default device for that.
   
undef is returned as the driver if we couldn't get a default device.
=cut

sub get_default_device_driver {
    my (@p) = @_;
    my($driver_id, @args) = _rearrange(['DRIVER_ID'], @p);
    return undef if _extra_args(@args);
    $driver_id = $perlcdio::DRIVER_DEVICE if !defined($driver_id);
    my($drive, $out_driver_id) = 
	perlcdio::get_default_device_driver($driver_id);
    return wantarray ? ($drive, $out_driver_id) : $drive;
}

=pod

=head2 get_devices

get_devices(driver_id=$Cdio::DRIVER_UNKNOWN)->@devices

Return an array of device names. If you want a specific devices for a
driver, give that device. If you want hardware devices, give
$perlcdio::DRIVER_DEVICE and if you want all possible devices, image
drivers and hardware drivers give $perlcdio::DRIVER_UNKNOWN.  undef is
returned if we couldn't return a list of devices.

In some situations of drivers or OS's we can't find a CD device if
there is no media in it and it is possible for this routine to return
undef even though there may be a hardware CD-ROM.

=cut

sub get_devices {
    my (@p) = @_;
    my($driver_id, @args) = _rearrange(['DRIVER_ID'], @p);
    return undef if _extra_args(@args);
    $driver_id = $perlcdio::DRIVER_DEVICE if !defined($driver_id);
    # There's a bug in the swig code in that the input parameter
    # is left on the stack
    my @ret = perlcdio::get_devices($driver_id);
    shift @ret;
    return @ret;
}

=pod

=head2 get_devices_ret

get_devices_ret($driver_id)->(@devices, $driver_id)

Like get_devices, but we may change the p_driver_id if we were given
$perlcdio::DRIVER_DEVICE or $perlcdio::DRIVER_UNKNOWN.  This is
because often one wants to get a drive name and then *open* it
afterwards. Giving the driver back facilitates this, and speeds things
up for libcdio as well.

=cut

sub get_devices_ret {
    my (@p) = @_;
    my($driver_id, @args) = _rearrange(['DRIVER_ID'], @p);
    return undef if _extra_args(@args);
    $driver_id = $perlcdio::DRIVER_DEVICE if !defined($driver_id);
    # There's a bug in the swig code in that the input parameter
    # is left on the stack
    my @ret = perlcdio::get_devices_ret($driver_id);
    shift @ret;
    return @ret;
}

=pod

=head2 get_devices_with_cap

get_devices_with_cap($capabilities, $any)->@devices

Get an array of device names in search_devices that have at least
the capabilities listed by the capabilities parameter.

If "any" is set false then ALL capabilities listed in the extended
portion of capabilities (i.e. not the basic filesystem) must be
satisified. If "any" is set true, then if any of the capabilities
matches, we call that a success.

To find a CD-drive of any type, use the mask $perlcdio::FS_MATCH_ALL.

The array of device names is returned or undef if we couldn't get a
default device.  It is also possible to return a () but after
This means nothing was found.

=cut

sub get_devices_with_cap {
    my (@p) = @_;
    my($cap, $any, @args) = _rearrange(['CAPABILITIES', 'ANY'], @p);
    return undef if _extra_args(@args);
    $any = 1 if !defined($any);
    # There's a bug in the swig code in that the input parameters
    # are left on the stack
    print "cap: $cap, any $any\n";
    my @ret = perlcdio::get_devices_with_cap($cap, $any);
    shift @ret; shift @ret;
    return @ret;
}

=pod

=head2 get_devices_with_cap_ret

Like get_devices_with_cap but we return the driver we found as
well. This is because often one wants to search for kind of drive and
then *open* it afterwards. Giving the driver back facilitates this,
and speeds things up for libcdio as well.

=cut

sub get_devices_with_cap_ret {
    my (@p) = @_;
    my($cap, $any, @args) = _rearrange(['CAPABILITIES', 'ANY'], @p);
    return undef if _extra_args(@args);
    $any = 1 if !defined($any);
    # There's a bug in the swig code in that the input parameters
    # are left on the stack
    my @ret = perlcdio::get_devices_with_cap($cap, $any);
    shift @ret; shift @ret;
    return @ret;
}

=pod

=head2 have_driver

have_driver(driver_id) -> bool

Return True if we have driver driver_id. undef is returned if
driver_id is invalid. driver_id can either be an integer driver name
defined in perldio or a string as defined in the hash %drivers.

=cut

sub have_driver {
    my (@p) = @_;
    my($driver_id) = _rearrange(['DRIVER_ID'], @p);
    # driver_id can be an integer representing an enum value
    # or a string of the driver name in the drivers dictionary.
    return perlcdio::have_driver($driver_id)
	if $driver_id =~ m/^\d+$/;
    return perlcdio::have_driver($drivers{$driver_id})
	if defined($drivers{$driver_id});
    return undef;
}

=pod

=head2 is_binfile

is_binfile(binfile)->cue_name

Determine if binfile is the BIN file part of a CDRWIN Compact
Disc image.
    
Return the corresponding CUE file if bin_name is a BIN file or
undef if not a BIN file.

=cut
sub is_binfile {
    my (@p) = @_;
    my($file_name) = _rearrange(['BINFILE'], @p);
    return perlcdio::is_binfile($file_name);
}

=pod

=head2 is_cuefile

is_cuefile(cuefile)->bin_name

Determine if cuefile is the CUE file part of a CDRWIN Compact
Disc image.
    
Return the corresponding BIN file if cue_name is a CUE file or
undef if not a CUE file.
=cut

sub is_cuefile {
    my (@p) = @_;
    my($file_name) = _rearrange(['CUEFILE'], @p);
    return perlcdio::is_cuefile($file_name);
}

=pod

=head2 is_nrg

is_nrg(nrgfile)->bool

Determine if nrgfile is a Nero NRG file disc image.

=cut 

sub is_nrg {
    my (@p) = @_;
    my($file_name) = _rearrange(['NRGFILE'], @p);
    return perlcdio::is_nrg($file_name);
}

=pod

=head2 is_device

is_device(source, driver_id=$perlcdio::DRIVER_UNKNOWN)->bool

Return True if source refers to a real hardware CD-ROM.
=cut
sub is_device {

    my (@p) = @_;
    my($source, $driver_id) = _rearrange(['SOURCE', 'DRIVER_ID'], @p);

    $driver_id=$perlcdio::DRIVER_UNKNOWN if !defined($driver_id);
    return perlcdio::is_device($source, $driver_id);
}

=pod

=head2 is_tocfile

is_tocfile(tocfile_name)->bool
    
Determine if tocfile_name is a cdrdao CD disc image.

=cut

sub is_tocfile {

    my (@p) = @_;
    my($tocfile) = _rearrange(['TOCFILE'], @p);
    return perlcdio::is_tocfile($tocfile);
}

=pod

=head2 convert_drive_cap_misc

convert_drive_cap_misc(bitmask)->hash_ref

Convert bit mask for miscellaneous drive properties
into a hash reference of drive capabilities
=cut

sub convert_drive_cap_misc {

    my (@p) = @_;
    my($bitmask) = _rearrange(['BITMASK'], @p);

    my %result={};
    $result{DRIVE_CAP_ERROR} = 1
	if $bitmask & $perlcdio::DRIVE_CAP_ERROR;
    $result{DRIVE_CAP_UNKNOWN} = 1
	if $bitmask & $perlcdio::DRIVE_CAP_UNKNOWN;
    $result{DRIVE_CAP_MISC_CLOSE_TRAY} = 1
	if $bitmask & $perlcdio::DRIVE_CAP_MISC_CLOSE_TRAY;
    $result{DRIVE_CAP_MISC_EJECT} = 1
	if $bitmask & $perlcdio::DRIVE_CAP_MISC_EJECT;
    $result{DRIVE_CAP_MISC_LOCK} = 1
	if $bitmask & $perlcdio::DRIVE_CAP_MISC_LOCK;
    $result{DRIVE_CAP_MISC_SELECT_SPEED} = 1
	if $bitmask & $perlcdio::DRIVE_CAP_MISC_SELECT_SPEED;
    $result{DRIVE_CAP_MISC_SELECT_DISC} = 1
	if $bitmask & $perlcdio::DRIVE_CAP_MISC_SELECT_DISC;
    $result{DRIVE_CAP_MISC_MULTI_SESSION} = 1
	if $bitmask & $perlcdio::DRIVE_CAP_MISC_MULTI_SESSION;
    $result{DRIVE_CAP_MISC_MEDIA_CHANGED} = 1
	if $bitmask & $perlcdio::DRIVE_CAP_MISC_MEDIA_CHANGED;
    $result{DRIVE_CAP_MISC_RESET} = 1
	if $bitmask & $perlcdio::DRIVE_CAP_MISC_RESET;
    $result{DRIVE_CAP_MISC_FILE} = 1
	if $bitmask & $perlcdio::DRIVE_CAP_MISC_FILE;
    my $ref = \%result;
    return $ref;
}

=pod

=head2 convert_drive_cap_read

convert_drive_cap_read($bitmask)->hash_ref

Convert bit mask for read drive properties
into a hash reference of drive capabilities
=cut

sub convert_drive_cap_read {

    my (@p) = @_;
    my($bitmask) = _rearrange(['BITMASK'], @p);

    my %result=();
    $result{DRIVE_CAP_READ_AUDIO} = 1
	if $bitmask & $perlcdio::DRIVE_CAP_READ_AUDIO;
    $result{DRIVE_CAP_READ_CD_DA} = 1
	if $bitmask & $perlcdio::DRIVE_CAP_READ_CD_DA;
    $result{DRIVE_CAP_READ_CD_G} = 1
	if $bitmask & $perlcdio::DRIVE_CAP_READ_CD_G;
    $result{DRIVE_CAP_READ_CD_R} = 1
	if $bitmask & $perlcdio::DRIVE_CAP_READ_CD_R;
    $result{DRIVE_CAP_READ_CD_RW} = 1
	if $bitmask & $perlcdio::DRIVE_CAP_READ_CD_RW;
    $result{DRIVE_CAP_READ_DVD_R} = 1
	if $bitmask & $perlcdio::DRIVE_CAP_READ_DVD_R;
    $result{DRIVE_CAP_READ_DVD_PR} = 1
	if $bitmask & $perlcdio::DRIVE_CAP_READ_DVD_PR;
    $result{DRIVE_CAP_READ_DVD_RAM} = 1
	if $bitmask & $perlcdio::DRIVE_CAP_READ_DVD_RAM;
    $result{DRIVE_CAP_READ_DVD_ROM} = 1
	if $bitmask & $perlcdio::DRIVE_CAP_READ_DVD_ROM;
    $result{DRIVE_CAP_READ_DVD_RW} = 1
	if $bitmask & $perlcdio::DRIVE_CAP_READ_DVD_RW;
    $result{DRIVE_CAP_READ_DVD_RPW} = 1
	if $bitmask & $perlcdio::DRIVE_CAP_READ_DVD_RPW;
    $result{DRIVE_CAP_READ_C2_ERRS} = 1
	if $bitmask & $perlcdio::DRIVE_CAP_READ_C2_ERRS;
    $result{DRIVE_CAP_READ_MODE2_FORM1} = 1
	if $bitmask & $perlcdio::DRIVE_CAP_READ_MODE2_FORM1;
    $result{DRIVE_CAP_READ_MODE2_FORM2} = 1
	if $bitmask & $perlcdio::DRIVE_CAP_READ_MODE2_FORM2;
    $result{DRIVE_CAP_READ_MCN} = 1
	if $bitmask & $perlcdio::DRIVE_CAP_READ_MCN;
    $result{DRIVE_CAP_READ_ISRC} = 1
	if $bitmask & $perlcdio::DRIVE_CAP_READ_ISRC;
    my $ref = \%result;
    return $ref;
}

=pod

=head2 convert_drive_cap_write

convert_drive_cap_write($bitmask)->hash_ref
=cut
sub convert_drive_cap_write {

    my (@p) = @_;
    my($bitmask) = _rearrange(['BITMASK'], @p);

    my %result=();
    $result{DRIVE_CAP_WRITE_CD_R} = 1
	if $bitmask & $perlcdio::DRIVE_CAP_WRITE_CD_R;
    $result{DRIVE_CAP_WRITE_CD_RW} = 1
	if $bitmask & $perlcdio::DRIVE_CAP_WRITE_CD_RW;
    $result{DRIVE_CAP_WRITE_DVD_R} = 1
	if $bitmask & $perlcdio::DRIVE_CAP_WRITE_DVD_R;
    $result{DRIVE_CAP_WRITE_DVD_PR} = 1
	if $bitmask & $perlcdio::DRIVE_CAP_WRITE_DVD_PR;
    $result{DRIVE_CAP_WRITE_DVD_RAM} = 1
	if $bitmask & $perlcdio::DRIVE_CAP_WRITE_DVD_RAM;
    $result{DRIVE_CAP_WRITE_DVD_RW} = 1
	if $bitmask & $perlcdio::DRIVE_CAP_WRITE_DVD_RW;
    $result{DRIVE_CAP_WRITE_DVD_RPW} = 1
	if $bitmask & $perlcdio::DRIVE_CAP_WRITE_DVD_RPW;
    $result{DRIVE_CAP_WRITE_MT_RAINIER} = 1
	if $bitmask & $perlcdio::DRIVE_CAP_WRITE_MT_RAINIER;
    $result{DRIVE_CAP_WRITE_BURN_PROOF} = 1
	if $bitmask & $perlcdio::DRIVE_CAP_WRITE_BURN_PROOF;
    my $ref = \%result;
    return $ref;
}
	
1; # Magic true value requred at the end of a module

__END__
