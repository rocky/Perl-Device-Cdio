#!/usr/bin/env perl
# Unit test for cdtext.
use Test::More; # 'no_plan';

use strict;
use warnings;

use lib '../lib';
use blib;

use File::Basename;
use Device::Cdio::Device;
use perlcdio;

# plan skip_all => "FIXME: CD-TEXT need updating for new interface";

no warnings;
is(perlcdio::cdtext_field2str($perlcdio::CDTEXT_FIELD_PERFORMER),
   "PERFORMER");

# Test getting CD-Text
my $tocpath = File::Spec->catfile(dirname(__FILE__), 'cdtext.toc');
my $device = Device::Cdio::Device->new($tocpath, $perlcdio::DRIVER_CDRDAO);
ok($device, "Able to find CDRDAO driver for cdtext.toc");

my $langs =  $device->cdtext_list_languages ();
if ($langs) {
    foreach my $lang (@$langs) {
	printf "Detected language: %s\n", $Device::Cdio::CDTEXT_LANGUAGE_byname{$lang};
    }
}

# my $i_tracks = $device->get_num_tracks();
# my $first_track = $device->get_first_track;
# my $last_track = $device->get_last_track();
# for (my $i=$first_track->{track}; $i <= $last_track->{track}; $i++) {
#     $text = $device->cdtext_field_for_track($perlcdio::CDTEXT_FIELD_TITLE, $i);
#     printf "CD-Text TITLE for Track $i: %s\n",  $text;
# }

# is($text->{PERFORMER}, 'Performer');
my $text = $device->cdtext_field_for_disc($perlcdio::CDTEXT_FIELD_TITLE);
is($text, 'CD Title');
# # is($text->get_cdtext($perlcdio::CDTEXT_FIELD_DISCID), 'XY12345');
# is($text->{PERFORMER}, 'Performer');
$text = $device->cdtext_field_for_track($perlcdio::CDTEXT_FIELD_TITLE, 1);
is($text, 'Track Title');
$device->close();
done_testing();
