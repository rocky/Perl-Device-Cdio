package Device::Cdio::Track;
require 5.8.7;
#
#    $Id$
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

### CD Input and control track class

=pod

=head1 NAME

Cdio:Track handles track aspects of Cdio.

=cut 

use strict;
use Exporter;
use perlcdio;
use Device::Cdio::Util qw(_rearrange _check_arg_count _extra_args);
use Device::Cdio;
use Device::Cdio::Device;

=pod

=head1 METHODS

=cut 

=pod

=head2 new

new(device, track)->object

Creates a new track object.

=cut 

sub new {

  my($class,@p) = @_;

  my($device, $track, @args) = _rearrange(['DEVICE', 'TRACK'], @p);

  return undef if _extra_args(@args);

  my $self = {};
  
  if ($track !~ m/^\d+$/) {
      print "*** Expecting track to be an integer; got '$track'\n";
      return undef;
  } elsif ($track < 0 || $track > 200) {
      print "*** Track number should be within 0 and 200; got '$track'\n";
      return undef;
  }

  $self->{track}  = $track;

  # See if the device parameter is a reference (a device object) or
  # a device name of which we will turn into a device object.
  if (ref($device)) {
      $self->{device} = $device;
  } else {
      $self->{device} = Device::Cdio::Device->new(-source=>$device);
  }

  bless ($self, $class);


  return $self;
}

=pod

=head2 get_audio_channels

get_audio_channels(cdio, track)->int
    
Return number of channels in track: 2 or 4.
Not meaningful if track is not an audio track.
-1 is returned on error and -2 if the driver doesn't support the
operation.

=cut

sub get_audio_channels {

    my($self,@p) = @_;
    return 0 if !_check_arg_count($#_, 0);
    return perlcdio::get_track_channels($self->{device}, $self->{track});
}
    
=pod

=head2 get_copy_permit

get_copy_permit(cdio, track)->int

Return copy protection status on a track. Is this meaningful 
not an audio track?

=cut

sub get_copy_permit {
    my ($self, @p) = @_;
    return 0 if !_check_arg_count($#_, 0);
    return perlcdio::get_track_copy_permit($self->{device}, $self->{track});
}

=pod

=head2 get_format

get_format()->format
       
Get the format (audio, mode2, mode1) of track. 

=cut

sub get_format {
    my ($self, @p) = @_;
    return 0 if !_check_arg_count($#_, 0);
    return perlcdio::get_track_format($self->{device}, $self->{track});
}

=pod

=head2 get_last_lsn

get_last_lsn()->lsn
        
Return the ending LSN for a track 
$perlcdio::INVALID_LSN is returned on error.

=cut

sub get_last_lsn {
    my ($self, @p) = @_;
    return 0 if !_check_arg_count($#_, 0);
    return perlcdio::get_track_last_lsn($self->{device}, $self->{track});
}

=pod

=head2 get_lba

get_lba()->lba
       
Return the starting LBA for a track
$perlcdio::INVALID_LBAN is returned on error.

=cut

sub get_lba {
    my ($self, @p) = @_;
    return 0 if !_check_arg_count($#_, 0);
    return perlcdio::get_track_lba($self->{device}, $self->{track});
}

=pod

=head2 get_lsn

get_lsn()->lsn
       
Return the starting LSN for a track
$perlcdio::INVALID_LSN is returned on error.

=cut

sub get_lsn {
    my ($self, @p) = @_;
    return 0 if !_check_arg_count($#_, 0);
    return perlcdio::get_track_lsn($self->{device}, $self->{track});
}

=pod

=head2 get_preemphasis

get_preemphasis()->result
       
Get linear preemphasis status on an audio track.
This is not meaningful if not an audio track?

=cut

sub get_preemphasis {
    my ($self, @p) = @_;
    return 0 if !_check_arg_count($#_, 0);
    my $rc = perlcdio::get_track_preemphasis($self->{device}, $self->{track});
    if ($rc == $perlcdio::TRACK_FLAG_FALSE) {
	return 'none';
    } elsif ($rc == $perlcdio::TRACK_FLAG_TRUE) {
	return 'preemphasis';
    } elsif ($rc == $perlcdio::TRACK_FLAG_UNKNOWN) {
	return 'unknown';
    } else {
	return 'invalid';
    }
}

=pod

=head2 get_track_sec_count

item get_track_sec_count()->int
Get the number of sectors between this track an the next.  This
includes any pregap sectors before the start of the next track.
Track numbers usually start at something 
greater than 0, usually 1.
       
$perlcdio::INVALID_LSN is returned on error.

=cut 

sub get_track_sec_count {
    my ($self, @p) = @_;
    return 0 if !_check_arg_count($#_, 0);
    return perlcdio::get_track_sec_count($self->{device}, $self->{track});
}

=pod 

=head2 is_track_green

is_track_green(cdio, track) -> bool
       
Return True if we have XA data (green, mode2 form1) or
XA data (green, mode2 form2). That is track begins:
sync - header - subheader
12     4      -  8

=cut

sub is_track_green {
    my ($self, @p) = @_;
    return 0 if !_check_arg_count($#_, 0);
    return perlcdio::is_track_green($self->{device}, $self->{track});
}

1; # Magic true value requred at the end of a module

__END__

=pod

=head1 SEE ALSO

L<Device::Cdio> for the top-level routines and L<Device::Cdio::Device>
for device objects.

L<perlcdio> is the lower-level interface to libcdio.

L<http://www.gnu.org/software/libcdio> has documentation on
libcdio including the a manual and the API via doxygen.

=head1 AUTHORS

Rocky Bernstein C<< <rocky at cpan.org> >>.

=head1 COPYRIGHT

Copyright (C) 2006 Rocky Bernstein <rocky@cpan.org>

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

=cut
