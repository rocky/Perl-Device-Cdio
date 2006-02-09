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
/* See <cdio/read.h> for more extensive documentation. */

%constant long int READ_MODE_AUDIO = CDIO_READ_MODE_AUDIO;
%constant long int READ_MODE_M1F1  = CDIO_READ_MODE_M1F1;
%constant long int READ_MODE_M1F2  = CDIO_READ_MODE_M1F2;
%constant long int READ_MODE_M2F1  = CDIO_READ_MODE_M2F1;
%constant long int READ_MODE_M2F2  = CDIO_READ_MODE_M2F2;

typedef int cdio_read_mode_t;

%rename cdio_lseek lseek;
off_t cdio_lseek(const CdIo_t *p_cdio, off_t offset, int whence=SEEK_SET);

/*
From: Henri Asseily <henri <at> bizrate.com>
Subject: Perl typemaps for byte arrays
Newsgroups: gmane.comp.programming.swig
Date: 2004-05-26 20:12:21 GMT 

For the archive, here are an in and an out Perl typemaps for bytearrays 
where the first int (4 bytes) is the length of the array:

%typemap(in) (unsigned char * x) {
         $1 = (unsigned char *)SvPV_nolen($input);
}

%typemap(out) unsigned char * myFunction {
         int *iptr;
         iptr = (int *)$1;
         int len = *iptr;
         $result = newSVpv((char *)$1, len);
         sv_2mortal($result);
         argvi++;
         delete [] $1;
}
*/

#ifdef FINISHED_READ    
%cstring_output_withsize(char *p_buf, ssize_t *i_size);
ssize_t read_cd(const CdIo_t *p_cdio, char *p_buf, ssize_t *i_size);

%inline %{
ssize_t
read_cd(const CdIo_t *p_cdio, char *p_buf, ssize_t *i_size) 
{
  *i_size = cdio_read(p_cdio, p_buf, *i_size);
  return *i_size;
}
%}

%inline %{

ssize_t read_sectors(const CdIo_t *p_cdio, char *p_buf, ssize_t *i_size, 
		     lsn_t i_lsn, cdio_read_mode_t read_mode)
{
  
  driver_return_code_t drc;
  uint32_t i_blocks;
  uint16_t i_blocksize;
  switch (read_mode) {
  case CDIO_READ_MODE_AUDIO: 
    i_blocksize = CDIO_CD_FRAMESIZE_RAW;
    break;
  case CDIO_READ_MODE_M1F1: 
    i_blocksize = M2RAW_SECTOR_SIZE;
    break;
  case CDIO_READ_MODE_M1F2: 
    i_blocksize = M2RAW_SECTOR_SIZE;
    break;
  case CDIO_READ_MODE_M2F1: 
    i_blocksize = CDIO_CD_FRAMESIZE;
    break;
  case CDIO_READ_MODE_M2F2: 
    i_blocksize = M2F2_SECTOR_SIZE;
    break;
  default: 
    i_size = NULL;
    return DRIVER_OP_BAD_PARAMETER;
  }

  i_blocks = *i_size / i_blocksize;
  drc = cdio_read_sectors(p_cdio, p_buf, i_lsn, read_mode, i_blocks);
  if (drc < 0) {
    i_size = NULL;
    return drc;
  }
  return *i_size;
}
%}

%inline %{
ssize_t read_data_bytes(const CdIo_t *p_cdio, char *p_buf, ssize_t *i_size, 
			lsn_t i_lsn, int16_t i_blocksize)
{
  driver_return_code_t drc;
  uint32_t i_blocks = *i_size / i_blocksize;

  switch (i_blocksize) {
  case CDIO_CD_FRAMESIZE:
  case CDIO_CD_FRAMESIZE_RAW:
  case M2F2_SECTOR_SIZE:
  case M2RAW_SECTOR_SIZE:
    break;
  default:
    /* Don't know about these block sizes */
    i_size = NULL;
    return DRIVER_OP_BAD_PARAMETER;
  }
  
#if DEGUGGING  
  printf("p_cdio: %x, i_size: %d, lsn: %d, blocksize %d, blocks %d\n",
	 p_cdio, *i_size, i_lsn, i_blocksize, i_blocks);
#endif
  drc = cdio_read_data_sectors (p_cdio, p_buf, i_lsn, 
				i_blocksize, i_blocks);
#if DEGUGGING  
  printf("drc: %d\n", drc);
#endif
  if (drc < 0) {
    i_size = NULL;
    return drc;
  }
  return *i_size;
}
%}
#endif /* FINISHED_READ */
