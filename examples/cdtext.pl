#!/usr/bin/perl -w
# Program to show cdtext, similar to examples/cdtext.c
#
#  Copyright (C) 2012, 2017 Rocky Bernstein <rocky@gnu.org>
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.

# use Enbugger; Enbugger->load_debugger('trepan'); Enbugger->stop;

use strict;
use lib '../blib/lib';
use lib '../blib/arch';
use perlcdio;
use Device::Cdio;
use Device::Cdio::Device;

sub print_cdtext_track_info($)
{
    my $cdtext_ref = shift;
    foreach my $field (sort keys %{$cdtext_ref}) {
	  printf "\t%s: %s\n", $field, $cdtext_ref->{$field};
    }
}

my $drive_name;
my $d;
if ($ARGV[0]) {
    $drive_name = $ARGV[0];
    $d = Device::Cdio::Device->new($drive_name);
    print "Problem opening CD-ROM: $drive_name\n";
    exit 1;
} else {
    $d = Device::Cdio::Device->new(undef, $perlcdio::DRIVER_UNKNOWN);
    if ($d) {
	$drive_name = $d->get_device();
    } else {
	print "Problem finding a CD-ROM\n";
	exit 1;
    }
}

my $i_tracks = $d->get_num_tracks();
my $first_track = $d->get_first_track;

my $text;
$perlcdio::VERSION_NUM >= 10100 or die "Your version of libcdio is too old\n";
my $cdtext = $d->get_disc_cdtext();

my $langs =  $d->cdtext_list_languages ($cdtext);
if ($langs) {
    foreach my $lang (@$langs) {
	printf "Detected language: %s\n", $Device::Cdio::CDTEXT_LANGUAGE_byname{$lang};
    }
}

$text = $d->cdtext_field_for_disc($perlcdio::CDTEXT_FIELD_TITLE);
printf "CD-Text title for Disc: %s\n", $text;

my $last_track = $d->get_last_track();
for (my $i=$first_track->{track}; $i <= $last_track->{track}; $i++) {
    $text = $d->cdtext_field_for_track($perlcdio::CDTEXT_FIELD_TITLE, $i);
    printf "CD-Text TITLE for Track $i: %s\n",  $text;
}
