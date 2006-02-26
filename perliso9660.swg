/* -*- c -*-
    $Id%

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
"This is a wrapper for The CD Input and Control library's ISO-9660 library
See also the ISO-9660 specification. The freely available European
equivalant standard is called ECMA-119."
%enddef
%module(docstring=DOCSTRING) perliso9660

%{
/* Includes the header in the wrapper code */
#include <time.h>
#include <cdio/iso9660.h>
%}

#include <time.h>
#include <cdio/iso9660.h>

/* Various libcdio constants and typedefs */
%include "types.swg"

%include "typemaps.i"

typedef uint8_t iso_extension_mask_t;

%constant long int ISO_BLOCKSIZE        = CDIO_CD_FRAMESIZE;
%constant long int PVD_SECTOR 	        = ISO_PVD_SECTOR ;
%constant long int EVD_SECTOR 	        = ISO_EVD_SECTOR ;
%constant long int LEN_ISONAME 	        = LEN_ISONAME;
%constant long int MAX_SYSTEM_ID 	= ISO_MAX_SYSTEM_ID ;
%constant long int MAX_ISONAME 	        = MAX_ISONAME;
%constant long int MAX_PREPARER_ID 	= ISO_MAX_PREPARER_ID ;
%constant long int MAX_ISOPATHNAME 	= MAX_ISOPATHNAME;

%constant long int FILE                 = ISO_FILE;
%constant long int EXISTENCE            = ISO_EXISTENCE;
%constant long int DIRECTORY            = ISO_DIRECTORY;
%constant long int ASSOCIATED           = ISO_ASSOCIATED;
%constant long int RECORD               = ISO_RECORD;
%constant long int PROECTION            = ISO_PROECTION;
%constant long int DRESERVED1           = ISO_DRESERVED1;
%constant long int DRESERVED2           = ISO_DRESERVED2;
%constant long int MULTIEXTENT          = ISO_MULTIEXTENT;

%constant long int VD_BOOT_RECORD       = ISO_VD_BOOT_RECORD;
%constant long int VD_PRIMARY           = ISO_VD_PRIMARY;
%constant long int VD_SUPPLEMENTARY     = ISO_VD_SUPPLEMENTARY;
%constant long int VD_PARITION          = ISO_VD_PARITION;
%constant long int VD_END               = ISO_VD_END;

%constant long int MAX_PUBLISHER_ID     = ISO_MAX_PUBLISHER_ID;
%constant long int MAX_APPLICATION_ID   = ISO_MAX_APPLICATION_ID;
%constant long int MAX_VOLUME_ID        = ISO_MAX_VOLUME_ID;
%constant long int MAX_VOLUMESET_ID     = ISO_MAX_VOLUMESET_ID;
%constant long int STANDARD_ID          = ISO_STANDARD_ID;

%constant long int NOCHECK              = ISO9660_NOCHECK;
%constant long int SEVEN_BIT            = ISO9660_7BIT;
%constant long int ACHARS               = ISO9660_ACHARS;
%constant long int DCHARS               = ISO9660_DCHARS;


%constant long int EXTENSION_JOLIET_LEVEL1 = ISO_EXTENSION_JOLIET_LEVEL1;
%constant long int EXTENSION_JOLIET_LEVEL2 = ISO_EXTENSION_JOLIET_LEVEL2;
%constant long int EXTENSION_JOLIET_LEVEL3 = ISO_EXTENSION_JOLIET_LEVEL3;
%constant long int EXTENSION_ROCK_RIDGE    = ISO_EXTENSION_ROCK_RIDGE;
%constant long int EXTENSION_HIGH_SIERRA   = ISO_EXTENSION_HIGH_SIERRA;

%constant long int EXTENSION_ALL           = ISO_EXTENSION_ALL;
%constant long int EXTENSION_NONE          = ISO_EXTENSION_NONE;
%constant long int EXTENSION_JOLIET        = ISO_EXTENSION_JOLIET;

/*!
  Open an ISO 9660 image for reading. Maybe in the future we will have
  a mode. NULL is returned on error.
*/
%rename iso9660_open open_iso;
iso9660_t *iso9660_open (const char *psz_path /*flags, mode */);

/*!
  Open an ISO 9660 image for reading allowing various ISO 9660
  extensions.  Maybe in the future we will have a mode. NULL is
  returned on error.
*/
%rename iso9660_open_ext open_ext;
iso9660_t *iso9660_open_ext (const char *psz_path, 
			     iso_extension_mask_t iso_extension_mask);

/*!
  Open an ISO 9660 image for reading with some tolerence for positioning
  of the ISO9660 image. We scan for ISO_STANDARD_ID and use that to set
  the eventual offset to adjust by (as long as that is <= i_fuzz).

  Maybe in the future we will have a mode. NULL is returned on error.

  @see iso9660_open
*/
%rename iso9660_open_fuzzy open_fuzzy;
iso9660_t *iso9660_open_fuzzy (const char *psz_path /*flags, mode */,
			       uint16_t i_fuzz);

/*!
  Open an ISO 9660 image for reading with some tolerence for positioning
  of the ISO9660 image. We scan for ISO_STANDARD_ID and use that to set
  the eventual offset to adjust by (as long as that is <= i_fuzz).

  Maybe in the future we will have a mode. NULL is returned on error.

  @see iso9660_open
*/
%rename iso9660_open_fuzzy open_fuzzy_ext;
iso9660_t *iso9660_open_fuzzy_ext (const char *psz_path,
				   iso_extension_mask_t iso_extension_mask,
				   uint16_t i_fuzz
				   /*flags, mode */);
/*!
  Read the Super block of an ISO 9660 image but determine framesize
  and datastart and a possible additional offset. Generally here we are
  not reading an ISO 9660 image but a CD-Image which contains an ISO 9660
  filesystem.
*/
%rename iso9660_ifs_fuzzy_read_superblock ifs_fuzzy_read_superblock;
bool iso9660_ifs_fuzzy_read_superblock (iso9660_t *p_iso, 
					iso_extension_mask_t iso_extension_mask,
					uint16_t i_fuzz);
/*!
  Close previously opened ISO 9660 image.
  True is unconditionally returned. If there was an error false would
  be returned.
*/
%rename iso9660_close close;
bool iso9660_close (iso9660_t * p_iso);

/*!
  Seek to a position and then read n bytes. Size read is returned.
*/
%rename iso9660_is_seek_read iso_seek_read;
long int iso9660_iso_seek_read (const iso9660_t *p_iso, void *ptr, 
				lsn_t start, long int i_size);

/*!
  Read the Primary Volume Descriptor for a CD.
  True is returned if read, and false if there was an error.
*/
iso9660_pvd_t *fs_read_pvd ( const CdIo_t *p_cdio );
%inline %{
iso9660_pvd_t *fs_read_pvd ( const CdIo_t *p_cdio ) {
  static iso9660_pvd_t pvd;
  bool b_ok = iso9660_fs_read_pvd ( p_cdio, &pvd );
  if (!b_ok) return NULL;
  return &pvd;
 }
%}
 
/*!
  Read the Primary Volume Descriptor for an ISO 9660 image.
  True is returned if read, and false if there was an error.
*/
iso9660_pvd_t *ifs_read_pvd ( const iso9660_t *p_iso );
%inline %{
iso9660_pvd_t *ifs_read_pvd ( const iso9660_t *p_iso ) {
  static iso9660_pvd_t pvd;
  bool b_ok = iso9660_ifs_read_pvd ( p_iso, &pvd );
  if (!b_ok) return NULL;
  return &pvd;
 }
%}

/*!
  Read the Super block of an ISO 9660 image. This is the 
  Primary Volume Descriptor (PVD) and perhaps a Supplemental Volume 
  Descriptor if (Joliet) extensions are acceptable.
*/
%rename iso9660_fs_read_superblock fs_read_superblock;
bool iso9660_fs_read_superblock (CdIo_t *p_cdio, 
				 iso_extension_mask_t iso_extension_mask);

/*!
  Read the Supper block of an ISO 9660 image. This is the 
  Primary Volume Descriptor (PVD) and perhaps a Supplemental Volume 
  Descriptor if (Joliet) extensions are acceptable.
*/
%rename iso9660_ifs_read_superblock ifs_read_superblock;
bool iso9660_ifs_read_superblock (iso9660_t *p_iso,
				  iso_extension_mask_t iso_extension_mask);


/*====================================================
  Time conversion 
 ====================================================*/
/*!
  Set time in format used in ISO 9660 directory index record
  from a Unix time structure. */
iso9660_dtime_t *
set_dtime ( int tm_sec, int tm_min, int tm_hour, int tm_mday, int tm_mon, 
	    int tm_year, int tm_wday, int tm_yday, int tm_isdst);
%inline %{
iso9660_dtime_t *
set_dtime ( int tm_sec, int tm_min, int tm_hour, int tm_mday, int tm_mon, 
	    int tm_year, int tm_wday, int tm_yday, int tm_isdst)
{
  struct tm tm = { tm_sec, tm_min, tm_hour, tm_mday, tm_mon, tm_year, tm_wday,
		   tm_isdst };
  static iso9660_dtime_t idr_date;
  iso9660_set_dtime (&tm, &idr_date);
  return &idr_date;
}
%}

/*!
  Set "long" time in format used in ISO 9660 primary volume descriptor
  from a Unix time structure. */
iso9660_ltime_t *
set_ltime ( int tm_sec, int tm_min, int tm_hour, int tm_mday, int tm_mon, 
	    int tm_year, int tm_wday, int tm_yday, int tm_isdst);

%inline %{
iso9660_ltime_t *
set_ltime ( int tm_sec, int tm_min, int tm_hour, int tm_mday, int tm_mon, 
	    int tm_year, int tm_wday, int tm_yday, int tm_isdst)

{
  struct tm tm = { tm_sec, tm_min, tm_hour, tm_mday, tm_mon, tm_year, tm_wday,
		   tm_isdst };
  static iso9660_ltime_t pvd_date;
  iso9660_set_ltime (&tm, &pvd_date);
  return &pvd_date;
}
%}

/*!
  Get Unix time structure from format use in an ISO 9660 directory index 
  record. Even though tm_wday and tm_yday fields are not explicitly in
  idr_date, they are calculated from the other fields.

  If tm is to reflect the localtime, set "use_localtime" true, otherwise
  tm will reported in GMT.
*/
%apply int *OUTPUT { int *tm_sec, int *tm_min,  int *tm_hour, int *tm_mday,
                     int *tm_mon, int *tm_year, int *tm_wday, int *tm_yday,
                     int *tm_isdst };

bool get_dtime (const iso9660_dtime_t *idr_date, bool use_localtime,
		int *tm_sec, int *tm_min,  int *tm_hour, int *tm_mday,
		int *tm_mon, int *tm_year, int *tm_wday, int *tm_yday,
		int *tm_isdst);

%inline %{
bool get_dtime (const iso9660_dtime_t *idr_date, bool use_localtime,
		int *tm_sec, int *tm_min,  int *tm_hour, int *tm_mday,
		int *tm_mon, int *tm_year, int *tm_wday, int *tm_yday,
		int *tm_isdst) 
{
  struct tm tm;
  bool b_okay = iso9660_get_dtime (idr_date, use_localtime, &tm);
  if (b_okay) {
    *tm_sec   = tm.tm_sec;
    *tm_min   = tm.tm_min;
    *tm_hour  = tm.tm_hour;
    *tm_mon   = tm.tm_mon;
    *tm_mday  = tm.tm_mday;
    *tm_year  = tm.tm_year;
    *tm_wday  = tm.tm_wday;
    *tm_yday  = tm.tm_yday;
    *tm_isdst = tm.tm_isdst;
  }
  return b_okay;
}
%}

/*!
  Get "long" time in format used in ISO 9660 primary volume descriptor
  from a Unix time structure. 
*/
bool get_ltime (const iso9660_ltime_t *idr_date, 
		int *tm_sec, int *tm_min,  int *tm_hour, int *tm_mday,
		int *tm_mon, int *tm_year, int *tm_wday, int *tm_yday,
		int *tm_isdst);

%inline %{
bool get_ltime (const iso9660_ltime_t *p_ldate, 
		int *tm_sec, int *tm_min,  int *tm_hour, int *tm_mday,
		int *tm_mon, int *tm_year, int *tm_wday, int *tm_yday,
		int *tm_isdst) 
{
  struct tm tm;
  bool b_okay = iso9660_get_ltime (p_ldate, &tm);
  if (b_okay) {
    *tm_sec   = tm.tm_sec;
    *tm_min   = tm.tm_min;
    *tm_hour  = tm.tm_hour;
    *tm_mon   = tm.tm_mon;
    *tm_mday  = tm.tm_mday;
    *tm_year  = tm.tm_year;
    *tm_wday  = tm.tm_wday;
    *tm_yday  = tm.tm_yday;
    *tm_isdst = tm.tm_isdst;
  }
  return b_okay;
}
%}


/*====================================================
  Characters used in file and directory and manipulation
 ====================================================*/
/*!
   Return true if c is a DCHAR - a character that can appear in an an
   ISO-9600 level 1 directory name. These are the ASCII capital
   letters A-Z, the digits 0-9 and an underscore.
*/
%rename iso9660_isdchar is_dchar;
bool iso9660_isdchar (int c);

/*!
   Return true if c is an ACHAR - 
   These are the DCHAR's plus some ASCII symbols including the space 
   symbol.   
*/
%rename iso9660_isachar is_achar;
bool iso9660_isachar (int c);

/*!
   Convert ISO-9660 file name that stored in a directory entry into 
   what's usually listed as the file name in a listing.
   Lowercase name, and remove trailing ;1's or .;1's and
   turn the other ;'s into version numbers.

   The length of the translated string is returned.
*/
%rename iso9660_name_translate name_translate;
int iso9660_name_translate(const char *psz_oldname, char *psz_newname);

/*!
   Convert ISO-9660 file name that stored in a directory entry into
   what's usually listed as the file name in a listing.  Lowercase
   name if not using Joliet extension. Remove trailing ;1's or .;1's and
   turn the other ;'s into version numbers.

   The length of the translated string is returned.
*/
%rename iso9660_name_translate_ext name_translate_ext;
int iso9660_name_translate_ext(const char *psz_old, char *psz_new, 
                               uint8_t i_joliet_level);
  
/*!  
  Pad string src with spaces to size len and copy this to dst. If
  len is less than the length of src, dst will be truncated to the
  first len characters of src.

  src can also be scanned to see if it contains only ACHARs, DCHARs, 
  7-bit ASCII chars depending on the enumeration _check.

  In addition to getting changed, dst is the return value.
  Note: this string might not be NULL terminated.
 */
%newobject iso9660_strncpy_pad; // free malloc'd return value
%rename iso9660_strncpy_pad strncpy_pad;
char *strncpy_pad(const char src[], size_t len, enum strncpy_pad_check _check);
%inline %{
char *
strncpy_pad(const char src[], size_t len, enum strncpy_pad_check _check) {
  char *dst = calloc(sizeof(char), len);
  return iso9660_strncpy_pad(dst, src, len, _check);
}
%}
 
/*=====================================================================
  file/dirname's 
======================================================================*/

/*!
  Check that psz_path is a valid ISO-9660 directory name.

  A valid directory name should not start out with a slash (/), 
  dot (.) or null byte, should be less than 37 characters long, 
  have no more than 8 characters in a directory component 
  which is separated by a /, and consist of only DCHARs. 

  True is returned if psz_path is valid.
 */
%rename iso9660_dirname_valid_p dirname_valid_p;
bool iso9660_dirname_valid_p (const char psz_path[]);

/*!  
  Take psz_path and a version number and turn that into a ISO-9660
  pathname.  (That's just the pathname followd by ";" and the version
  number. For example, mydir/file.ext -> MYDIR/FILE.EXT;1 for version
  1. The resulting ISO-9660 pathname is returned.
*/
%rename iso9660_pathname_isofy pathname_isofy;
%newobject iso9660_pathname_isofy; // free malloc'd return value
char *iso9660_pathname_isofy (const char psz_path[], uint16_t i_version);

/*!
  Check that psz_path is a valid ISO-9660 pathname.  

  A valid pathname contains a valid directory name, if one appears and
  the filename portion should be no more than 8 characters for the
  file prefix and 3 characters in the extension (or portion after a
  dot). There should be exactly one dot somewhere in the filename
  portion and the filename should be composed of only DCHARs.
  
  True is returned if psz_path is valid.
 */
%rename iso9660_pathname_valid_p pathname_valid_p;
bool iso9660_pathname_valid_p (const char psz_path[]);

%perlcode %{
=pod

=head1 NAME

perliso9660 - lower-level wrappper to libiso9066, CD Input and Control library'sISO9660 library

=head1 SYNOPSIS

This is fairly straight-forward wrapper around the C library libiso9660
Although this is perfectly usable on its own, it is expected that the
Object-Oriented interface L<Device::Cdio::ISO9660> is what most people will
want to use. 

There are various constants that are defined here.

=head1 DESCRIPTION

Encapsulation is done in two parts. The lower-level Perl
interface is called perlcdio (this file) and is generated via SWIG.

=head1 CONSTANTS

=over 4

=back

=head1 METHODS

=head2 this

This seems to be an artifact of SWIG. 

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
