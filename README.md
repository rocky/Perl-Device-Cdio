Device::Cdio - Perl bindings for libcdio (CD Input and Control library)
============================================================================

This adds Perl bindings for the GNU CD Input and Control library
(`libcdio`) and it's ISO 9660 library (`libiso9660`) which are written
in C. The library encapsulates CD-ROM reading and control and ISO 9660
handling. Perl programs wishing to be oblivious of the OS- and
device-dependent properties of a CD-ROM can use this library.

The encapsulation is done in two parts. The lower-level Perl interface
creates _perlcdio_, _perliso9660_ and _perlmmc_ libraries; these
are generated by SWIG.

There are also object-oriented modules that use _perlcdio_ and
_perliso9660_ (but not yet _perlmmc_). Although _perlcdio_ and
`perliso9660 are perfectly usable on there own, it is expected that
the _Device::Cdio..._ modules are what most people will use. As
_perlcdio_ and _perliso9660_ more closely model the C interface, it is
conceivable (if unlikely) that die-hard _libcdio_ or _libiso9660_ C
users who are very familiar with that interface may use that.

It may also be possible to change the SWIG in such a way to combine
the low-level and Object-Oriented pieces. However there are the
problems. First, I'm not that much of a SWIG expert. Second it looks
as though the resulting SWIG code would be more complex. Third the
separation makes translation very straight forward to understand and
maintain: first we get what's in C into Perl as a one-to-one
translation. Then we implement some nice Perl abstraction off of
that. The abstraction can be modified without having to redo the
underlying translation. (But the reverse is generally not true:
usually changes to the C-to-Perl translation, _perlcdio_ or
_perliso9660_, do result in small, but obvious and straightforward
changes to the abstraction layer cdio.)

GNU CD Input and Control Library is rather large, and yet may yet grow
a bit.  (Any volunteers for adding UDF support?) So what is here is
incomplete; over time it may grow to completion, depending on various
factors: e.g. whether others will help out (hint).

Some of the incompleteness is due to my lack of understanding of how
to get SWIG to accomplish wrapping various return values. If you know
how to do better, please let me know. Likewise suggestions on how to
improve classes or Perl interaction are more than welcome.

Sections of _libcdio_ that have been left out wholesale is the the
cdparanoia library and almost all of the MMC library. About 1/2 of the
ISO-9660 library has been done. Of the audio controls, I put in those
things that didn't require any thought. But Jerry G. Geiger added
more audio and CD-Text support

There is much to be done - you want to help out, please do so!

Standalone documentation via _perlpod_. See also the
programs in the example directory.


INSTALLATION
------------

To install this module, run the following commands:

    perl Build.PL
    ./Build
    ./Build test
    ./Build install


For compatibility, the older idiom is tolerated:

    perl Makefile.PL
    make
    make test
    make install


DEPENDENCIES
------------

* libcdio and development headers
* C compiler
* SWIG (optional)


COPYRIGHT AND LICENSE
---------------------

  Copyright (C) 2006, 2008, 2011, 2017 Rocky Bernstein <rocky@cpan.org>

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/>.
