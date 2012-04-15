#!/usr/bin/env perl
# Unit test for cdtext.
use Test::More;

plan skip_all => "CD-Text not finished yet";

use strict;
use warnings;

use lib '../lib';
use blib;

use File::Basename;
use Device::Cdio::Device;
use perlcdio;

if ($perlcdio::VERSION_NUM <= 83) {
    is("PERFORMER", perlcdio::cdtext_field2str($perlcdio::CDTEXT_PERFORMER),
       "Getting CD-Text performer field");
}  else {
    is(perlcdio::cdtext_field2str($perlcdio::CDTEXT_FIELD_PERFORMER),
       "PERFORMER");
}
 
# Test getting CD-Text
my $tocpath = File::Spect->catfile(dirname(__FILE__), 'cdtext.toc');
my $device = Device::Cdio::Device->new($tocpath, $perlcdio::DRIVER_CDRDAO);

if ($perlcdio::VERSION_NUM <= 83) {
    my $disctext = $device->track(0)->get_cdtext();
    is($disctext->get_cdtext($perlcdio::CDTEXT_PERFORMER), 'Performer');
    is($disctext->get_cdtext($perlcdio::CDTEXT_TITLE), 'CD Title');
    # is($disctext->get_cdtext($perlcdio::CDTEXT_DISCID), 'XY12345');

    my $track1text = $device->track(1)->get_cdtext();
    is($track1text->get_cdtext($perlcdio::CDTEXT_PERFORMER), 'Performer');
    is($track1text->get_cdtext($perlcdio::CDTEXT_TITLE), 'Track Title');
} else {
    my $text = $device->get_cdtext();
    is($text->get_cdtext($perlcdio::CDTEXT_FIELD_PERFORMER, 0), 'Performer');
    is($text->get_cdtext($perlcdio::CDTEXT_FIELD_TITLE, 0), 'CD Title');
    # is($text->get_cdtext($perlcdio::CDTEXT_FIELD_DISCID, 0), 'XY12345');

    print $text->get_cdtext($perlcdio::CDTEXT_FIELD_PERFORMER, 0);
    is($text->get_cdtext($perlcdio::CDTEXT_FIELD_PERFORMER, 1), 'Performer');
    is($text->get_cdtext($perlcdio::CDTEXT_FIELD_TITLE, 1), 'Track Title');
}


