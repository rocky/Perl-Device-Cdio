/* -*- c -*-
    $Id$

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
*/
%define DOCSTRING 
"A Perl wrapper for The CD Input and Control library's ISO-9660 library's
MultiMedia Commands (MMC)."
%enddef
%module(docstring=DOCSTRING) perlmmc

/* See <cdio/mmc.h> for more extensive documentation. */

%{
/* Includes the header in the wrapper code */
#include <cdio/cdio.h>
#include <cdio/mmc.h>
%}

#include <cdio/cdio.h>
#include <cdio/mmc.h>

%include "types.swg"

%constant long int GPCMD_INQUIRY       = CDIO_MMC_GPCMD_INQUIRY;
%constant long int GPCMD_MODE_SELECT_6 = CDIO_MMC_GPCMD_MODE_SELECT_6;
%constant long int GPCMD_MODE_SENSE_6  = CDIO_MMC_GPCMD_MODE_SENSE_6;
%constant long int GPCMD_START_STOP    = CDIO_MMC_GPCMD_START_STOP;
%constant long int GPCMD_ALLOW_MEDIUM_REMOVAL = 
                                         CDIO_MMC_GPCMD_ALLOW_MEDIUM_REMOVAL;

/** Group 2 Commands (CDB's here are 10-bytes)  */

%constant long int CDIO_MMC_GPCMD_READ_10  = CDIO_MMC_GPCMD_READ_10;
%constant long int GPCMD_READ_SUBCHANNEL   = CDIO_MMC_GPCMD_READ_SUBCHANNEL;
%constant long int GPCMD_READ_HEADER       = CDIO_MMC_GPCMD_READ_HEADER;
%constant long int GPCMD_PLAY_AUDIO_10	   = CDIO_MMC_GPCMD_PLAY_AUDIO_10;
%constant long int GPCMD_GET_CONFIGURATION = CDIO_MMC_GPCMD_GET_CONFIGURATION;
%constant long int GPCMD_PLAY_AUDIO_MSF	   = CDIO_MMC_GPCMD_PLAY_AUDIO_MSF;
%constant long int GPCMD_PLAY_AUDIO_TI     = CDIO_MMC_GPCMD_PLAY_AUDIO_TI;
%constant long int GPCMD_PLAY_TRACK_REL_10 = CDIO_MMC_GPCMD_PLAY_TRACK_REL_10;
%constant long int GPCMD_GET_EVENT_STATUS  = CDIO_MMC_GPCMD_GET_EVENT_STATUS;
%constant long int GPCMD_PAUSE_RESUME      = CDIO_MMC_GPCMD_PAUSE_RESUME;
%constant long int GPCMD_READ_DISC_INFO	   = CDIO_MMC_GPCMD_READ_DISC_INFO;
%constant long int GPCMD_MODE_SELECT_10    = CDIO_MMC_GPCMD_MODE_SELECT_10;
%constant long int GPCMD_MODE_SENSE_10	   = CDIO_MMC_GPCMD_MODE_SENSE_10;
%constant long int GPCMD_PLAY_AUDIO_12	   = CDIO_MMC_GPCMD_PLAY_AUDIO_12;
%constant long int GPCMD_LOAD_UNLOAD	   = CDIO_MMC_GPCMD_LOAD_UNLOAD;
%constant long int GPCMD_READ_12	   = CDIO_MMC_GPCMD_READ_12;
%constant long int GPCMD_PLAY_TRACK_REL_12 = CDIO_MMC_GPCMD_PLAY_TRACK_REL_12;
%constant long int GPCMD_READ_DVD_STRUCTURE= CDIO_MMC_GPCMD_READ_DVD_STRUCTURE;
%constant long int GPCMD_READ_MSF	   = CDIO_MMC_GPCMD_READ_MSF;
%constant long int GPCMD_SET_SPEED         = CDIO_MMC_GPCMD_SET_SPEED;
%constant long int GPCMD_READ_CD	   = CDIO_MMC_GPCMD_READ_CD;

/** Vendor-unique Commands   */
%constant long int GPCMD_CD_PLAYBACK_STATUS= CDIO_MMC_GPCMD_CD_PLAYBACK_STATUS;
%constant long int GPCMD_PLAYBACK_CONTROL  = CDIO_MMC_GPCMD_PLAYBACK_CONTROL;
%constant long int GPCMD_READ_CDDA	   = CDIO_MMC_GPCMD_READ_CDDA;
%constant long int GPCMD_READ_CDXA	   = CDIO_MMC_GPCMD_READ_CDXA;
%constant long int GPCMD_READ_ALL_SUBCODES = CDIO_MMC_GPCMD_READ_ALL_SUBCODES;

/** Read Subchannel states */
%constant long int READ_SUB_ST_INVALID     = CDIO_MMC_READ_SUB_ST_INVALID;
%constant long int READ_SUB_ST_PLAY        = CDIO_MMC_READ_SUB_ST_PLAY;
%constant long int READ_SUB_ST_PAUSED      = CDIO_MMC_READ_SUB_ST_PAUSED;
%constant long int READ_SUB_ST_COMPLETED   = CDIO_MMC_READ_SUB_ST_COMPLETED;
%constant long int READ_SUB_ST_ERROR       = CDIO_MMC_READ_SUB_ST_ERROR;
%constant long int READ_SUB_ST_NO_STATUS   = CDIO_MMC_READ_SUB_ST_NO_STATUS;

%constant long int READ_TYPE_ANY           = CDIO_MMC_READ_TYPE_ANY;
%constant long int READ_TYPE_CDDA          = CDIO_MMC_READ_TYPE_CDDA;
%constant long int READ_TYPE_MODE1         = CDIO_MMC_READ_TYPE_MODE1;
%constant long int READ_TYPE_MODE2         = CDIO_MMC_READ_TYPE_MODE2;
%constant long int READ_TYPE_M2F1          = CDIO_MMC_READ_TYPE_M2F1;
%constant long int READ_TYPE_M2F2          = CDIO_MMC_READ_TYPE_M2F2;

/*! Format values for READ_TOC */
%constant long int READTOC_FMT_TOC         = CDIO_MMC_READTOC_FMT_TOC;
%constant long int READTOC_FMT_SESSION     = CDIO_MMC_READTOC_FMT_SESSION;
%constant long int READTOC_FMT_FULTOC      = CDIO_MMC_READTOC_FMT_FULTOC;

%constant long int CDIO_MMC_READTOC_FMT_PMA= CDIO_MMC_READTOC_FMT_PMA;
%constant long int READTOC_FMT_PMA         = CDIO_MMC_READTOC_FMT_PMA;
%constant long int READTOC_FMT_ATIP        = CDIO_MMC_READTOC_FMT_ATIP;
%constant long int READTOC_FMT_CDTEXT      = CDIO_MMC_READTOC_FMT_CDTEXT;

/* Page codes for MODE SENSE and MODE SET. */
%constant long int R_W_ERROR_PAGE          = CDIO_MMC_R_W_ERROR_PAGE;
%constant long int WRITE_PARMS_PAGE        = CDIO_MMC_WRITE_PARMS_PAGE;
%constant long int CDR_PARMS_PAGE          = CDIO_MMC_CDR_PARMS_PAGE;
%constant long int AUDIO_CTL_PAGE          = CDIO_MMC_AUDIO_CTL_PAGE;
%constant long int POWER_PAGE              = CDIO_MMC_POWER_PAGE;
%constant long int FAULT_FAIL_PAGE         = CDIO_MMC_FAULT_FAIL_PAGE;
%constant long int TO_PROTECT_PAGE         = CDIO_MMC_TO_PROTECT_PAGE;
%constant long int CAPABILITIES_PAGE       = CDIO_MMC_CAPABILITIES_PAGE;
%constant long int ALL_PAGES               = CDIO_MMC_ALL_PAGES;

/* Return type codes for GET_CONFIGURATION. */
%constant long int GET_CONF_ALL_FEATURES   = CDIO_MMC_GET_CONF_ALL_FEATURES;
%constant long int GET_CONF_CURRENT_FEATURES= CDIO_MMC_GET_CONF_CURRENT_FEATURES;
%constant long int GET_CONF_NAMED_FEATURE  = CDIO_MMC_GET_CONF_NAMED_FEATURE;

/* FEATURE codes used in GET CONFIGURATION. */
%constant long int FEATURE_PROFILE_LIST    = CDIO_MMC_FEATURE_PROFILE_LIST;
%constant long int FEATURE_CORE            = CDIO_MMC_FEATURE_CORE;
%constant long int FEATURE_MORPHING        = CDIO_MMC_FEATURE_MORPHING;
%constant long int FEATURE_REMOVABLE_MEDIUM= CDIO_MMC_FEATURE_REMOVABLE_MEDIUM;
%constant long int FEATURE_WRITE_PROTECT   = CDIO_MMC_FEATURE_WRITE_PROTECT;
%constant long int FEATURE_RANDOM_READABLE = CDIO_MMC_FEATURE_RANDOM_READABLE;
%constant long int FEATURE_MULTI_READ      = CDIO_MMC_FEATURE_MULTI_READ;
%constant long int FEATURE_CD_READ         = CDIO_MMC_FEATURE_CD_READ;
%constant long int FEATURE_DVD_READ        = CDIO_MMC_FEATURE_DVD_READ;
%constant long int FEATURE_RANDOM_WRITABLE = CDIO_MMC_FEATURE_RANDOM_WRITABLE;
%constant long int FEATURE_INCR_WRITE      = CDIO_MMC_FEATURE_INCR_WRITE;
%constant long int FEATURE_SECTOR_ERASE    = CDIO_MMC_FEATURE_SECTOR_ERASE;
%constant long int FEATURE_FORMATABLE      = CDIO_MMC_FEATURE_FORMATABLE;
%constant long int FEATURE_DEFECT_MGMT     = CDIO_MMC_FEATURE_DEFECT_MGMT;
%constant long int FEATURE_WRITE_ONCE      = CDIO_MMC_FEATURE_WRITE_ONCE;
%constant long int FEATURE_RESTRICT_OVERW  = CDIO_MMC_FEATURE_RESTRICT_OVERW;
%constant long int FEATURE_CD_RW_CAV       = CDIO_MMC_FEATURE_CD_RW_CAV;
%constant long int FEATURE_MRW             = CDIO_MMC_FEATURE_MRW;
%constant long int FEATURE_ENHANCED_DEFECT = CDIO_MMC_FEATURE_ENHANCED_DEFECT;
%constant long int FEATURE_DVD_PRW         = CDIO_MMC_FEATURE_DVD_PRW;
%constant long int FEATURE_DVD_PR          = CDIO_MMC_FEATURE_DVD_PR;
%constant long int FEATURE_RIGID_RES_OVERW = CDIO_MMC_FEATURE_RIGID_RES_OVERW;
%constant long int FEATURE_CD_TAO          = CDIO_MMC_FEATURE_CD_TAO;
%constant long int FEATURE_CD_SAO          = CDIO_MMC_FEATURE_CD_SAO;
%constant long int FEATURE_DVD_R_RW_WRITE  = CDIO_MMC_FEATURE_DVD_R_RW_WRITE;
%constant long int FEATURE_CD_RW_MEDIA_WRITE= CDIO_MMC_FEATURE_CD_RW_MEDIA_WRITE;
%constant long int FEATURE_DVD_PR_2_LAYER  = CDIO_MMC_FEATURE_DVD_PR_2_LAYER;
%constant long int FEATURE_POWER_MGMT      = CDIO_MMC_FEATURE_POWER_MGMT;
%constant long int FEATURE_CDDA_EXT_PLAY   = CDIO_MMC_FEATURE_CDDA_EXT_PLAY;
%constant long int FEATURE_MCODE_UPGRADE   = CDIO_MMC_FEATURE_MCODE_UPGRADE;
%constant long int FEATURE_TIME_OUT        = CDIO_MMC_FEATURE_TIME_OUT;
%constant long int FEATURE_DVD_CSS         = CDIO_MMC_FEATURE_DVD_CSS;
%constant long int FEATURE_RT_STREAMING    = CDIO_MMC_FEATURE_RT_STREAMING;
%constant long int FEATURE_LU_SN           = CDIO_MMC_FEATURE_LU_SN;
%constant long int FEATURE_FIRMWARE_DATE   = CDIO_MMC_FEATURE_FIRMWARE_DATE;
/* Profile profile codes used in GET_CONFIGURATION - PROFILE LIST. */

%constant long int FEATURE_PROF_NON_REMOVABLE = CDIO_MMC_FEATURE_PROF_NON_REMOVABLE;
%constant long int FEATURE_PROF_REMOVABLE  = CDIO_MMC_FEATURE_PROF_REMOVABLE;
%constant long int FEATURE_PROF_MO_ERASABLE= CDIO_MMC_FEATURE_PROF_MO_ERASABLE;
%constant long int FEATURE_PROF_MO_WRITE_ONCE= CDIO_MMC_FEATURE_PROF_MO_WRITE_ONCE;

%constant long int FEATURE_PROF_AS_MO      = CDIO_MMC_FEATURE_PROF_AS_MO;
%constant long int FEATURE_PROF_CD_ROM     = CDIO_MMC_FEATURE_PROF_CD_ROM;
%constant long int FEATURE_PROF_CD_R       = CDIO_MMC_FEATURE_PROF_CD_R;
%constant long int FEATURE_PROF_CD_RW      = CDIO_MMC_FEATURE_PROF_CD_RW;
%constant long int FEATURE_PROF_DVD_ROM    = CDIO_MMC_FEATURE_PROF_DVD_ROM;
%constant long int FEATURE_PROF_DVD_R_SEQ  = CDIO_MMC_FEATURE_PROF_DVD_R_SEQ;
%constant long int FEATURE_PROF_DVD_RAM    = CDIO_MMC_FEATURE_PROF_DVD_RAM;
%constant long int FEATURE_PROF_DVD_RW_RO  = CDIO_MMC_FEATURE_PROF_DVD_RW_RO;
%constant long int FEATURE_PROF_DVD_RW_SEQ = CDIO_MMC_FEATURE_PROF_DVD_RW_SEQ;
%constant long int FEATURE_PROF_DVD_PRW    = CDIO_MMC_FEATURE_PROF_DVD_PRW;
%constant long int FEATURE_PROF_DVD_PR     = CDIO_MMC_FEATURE_PROF_DVD_PR;
%constant long int FEATURE_PROF_DDCD_ROM   = CDIO_MMC_FEATURE_PROF_DDCD_ROM;
%constant long int FEATURE_PROF_DDCD_R     = CDIO_MMC_FEATURE_PROF_DDCD_R;
%constant long int FEATURE_PROF_DDCD_RW    = CDIO_MMC_FEATURE_PROF_DDCD_RW;
%constant long int FEATURE_PROF_DVD_PR2    = CDIO_MMC_FEATURE_PROF_DVD_PR2;
%constant long int FEATURE_PROF_NON_CONFORM= CDIO_MMC_FEATURE_PROF_NON_CONFORM;
%constant long int FEATURE_INTERFACE_UNSPECIFIED = CDIO_MMC_FEATURE_INTERFACE_UNSPECIFIED;
%constant long int FEATURE_INTERFACE_SCSI  = CDIO_MMC_FEATURE_INTERFACE_SCSI;
%constant long int FEATURE_INTERFACE_ATAPI = CDIO_MMC_FEATURE_INTERFACE_ATAPI;
%constant long int FEATURE_INTERFACE_IEEE_1394= CDIO_MMC_FEATURE_INTERFACE_IEEE_1394;
%constant long int FEATURE_INTERFACE_IEEE_1394A= CDIO_MMC_FEATURE_INTERFACE_IEEE_1394A;
%constant long int FEATURE_INTERFACE_FIBRE_CH= CDIO_MMC_FEATURE_INTERFACE_FIBRE_CH;


%feature("autodoc",
"Read Audio Subchannel information
  
 param p_cdio the CD object to be acted upon.
 param p_subchannel place for returned subchannel information
.");
%rename mmc_audio_read_subchannel audio_read_subchannel;

%feature("autodoc",
"Return a string containing the name of the audio state as returned from
 the Q_SUBCHANNEL.
");
%rename mmc_audio_state2str audio_state2str;

%rename mmc_eject_media eject_media;
%rename mmc_feature2str feature2str;
%rename mmc_get_cmd_len get_cmd_len;
%rename mmc_get_blocksize get_blocksize;
%rename mmc_get_disc_last_lsn get_lsn;

%perlcode %{

import Device::Cdio::VERSION;
$VERSION = $Device::Cdio::VERSION;

=pod

=head1 NAME

perlmmc - lower-level wrapper to MMC from libcdio, the ISO 9660 library of the CD Input and Control package

=head1 SYNOPSIS

This is fairly straight-forward wrapper around the MultiMedia commands from
the C library libcdio. Although this is perfectly usable on its own, it is expected that the interfaces L<Device::Cdio::MMC> or L<Device::Cdio::Device::MMC> 
is what most people will want to use. 

There are various constants that are defined here.

=head1 SEE ALSO

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

%}
