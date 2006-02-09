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
"This is a wrapper for The CD Input and Control library (libcdio) which
encapsulates CD-ROM reading and control. Python programs wishing to be
oblivious of the OS- and device-dependent properties of a CD-ROM can
use this library."
%enddef
%module(docstring=DOCSTRING) perlcdio
%{
/* Includes the header in the wrapper code */
#include <cdio/cdio.h>
#include <cdio/audio.h>
#include <cdio/cd_types.h>
%}

#include <cdio/cdio.h> 
#include <cdio/audio.h>

%include "compat.swg"

%include "typemaps.i"
/*%include "cstring.i"*/

/* Various libcdio constants and typedefs */
%include "types.swg"

%feature("autodoc", 1);

%include "audio.swg"
%include "read.swg"
%include "track.swg"

/* In the presence of the exception handling, the order is important. 
   The below use %exception.
*/
%include "device.swg"
%include "disc.swg"

/* Encapsulation is done in two parts. The lower-level Perl interface
is called perlcdio (this file) and is generated via SWIG.

The more object-oriented module is Device::Cdio; it is a Perl class
that uses perlcdio. Although perlcdio is perfectly usable on its own,
it is expected that cdio is what most people will use. As pycdio more
closely models the C interface, it is conceivable (if unlikely) that
diehard libcdio C users who are very familiar with that interface
could prefer that.

It is probably possible to change the SWIG in such a way to combine
these pieces. However there are the problems. First, I'm not that much
of a SWIG expert. Second it looks as though the resulting SWIG code
would be more complex. Third the separation makes translation very
straight forward to understand and maintain: first get what's in C
into Python as a one-to-one translation. Then we implement some nice
abstraction off of that. The abstraction can be modified without
having to redo the underlying translation. (But the reverse is
generally not true: usually changes to the C-to-python translation,
pycdio, do result in small, but obvious and straightforward changes to
the abstraction layer cdio.)
*/
%perlcode %{
=pod

=head1 NAME

perlcdio - lower-level wrappper to libcdio, the CD Input and Control library

=head1 SYNOPSIS

This is fairly straight-forward wrapper around the C library libcdio.
Although this is perfectly usable on its own, it is expected that the
Object-Oriented interface L<Device::Cdio> is what most people will
want to use. 

There are various constants that are defined here.

=head1 DESCRIPTION

Encapsulation is done in two parts. The lower-level Perl
interface is called perlcdio (this file) and is generated via SWIG.

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
