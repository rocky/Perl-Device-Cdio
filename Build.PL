#!/usr/bin/perl -w
# $Id$
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
use strict;
use warnings;
use Module::Build;
use ExtUtils::PkgConfig;
use Config;

my $code = <<'EOC';
;
EOC


sub try_compile {
    my ($c, %args) = @_;

    my $ok = 0;
    my $tmp = "tmp$$";
    local(*TMPC);

    my $obj_ext = $Config{obj_ext} || ".o";
    unlink("$tmp.c", "$tmp$obj_ext");

    if (open(TMPC, ">", "$tmp.c")) {
	print TMPC $c;
	close(TMPC);

	my $cccmd = $args{cccmd};
	my $errornull;
	my $ccflags = $Config{'ccflags'};
        $ccflags .= " $args{ccflags}" if $args{ccflags};

        if ($args{silent} ) {
	    $errornull = "2>/dev/null" unless defined $errornull;
	} else {
	    $errornull = '';
	}

        $cccmd = "$Config{'cc'} -o $tmp $ccflags $tmp.c $errornull"
	    unless defined $cccmd;

	printf "cccmd = $cccmd\n" if $args{verbose};
	my $res = system($cccmd);
	$ok = defined($res) && $res == 0;

	if ( !$ok ) {
	    my $errno = $? >> 8;
	    local $! = $errno;
	    print "
		
*** The test compile of '$tmp.c' failed: status $?
*** (the status means: errno = $errno or '$!')
*** DO NOT PANIC: this just means that *some* you may get some innocuous
*** compiler warnings.
";
	}
	unlink("$tmp.c");

    }
    return $ok;
}

sub try_cflags ($) {
    my ($ccflags) = @_;
    my $c_prog = "int main () { return 0; }\n";
    print "Checking if $Config{cc} supports \"$ccflags\"...";
    my $result = try_compile($c_prog, ccflags=>$ccflags);
    if ($result) {
	print "yes\n";
	return " $ccflags";
    }
    print "no\n";
    return '';
	
}

my %libcdio_pkgcfg = ExtUtils::PkgConfig->find ('libcdio');

use constant MIN_LIBCDIO_VERSION => 0.76;
my $lv = $libcdio_pkgcfg{'modversion'};
if (exists($libcdio_pkgcfg{'modversion'})) {
    if ($libcdio_pkgcfg{'modversion'} =~ m{\A((?:\d+)(?:\.\d+))}) {
	if ($1 < MIN_LIBCDIO_VERSION) {
	    printf "
*** 
*** You need to have libcdio %s or greater installed. (You have $lv).
*** Get libcdio from http://www.gnu.org/software/libcdio/download.html
", MIN_LIBCDIO_VERSION;
	    exit 1;
	} else {
	    print "Good, I found libcdio version $lv installed.\n";
	    
	}
    } else {
	print "
*** 
*** Can't parse libcdio version $lv.
*** Will continue and keep my fingers crossed for luck.
";
    }
} else {
    print "
*** 
*** Can't find libcdio configuration info. Is libcdio installed?
*** Get libcdio from http://www.gnu.org/software/libcdio/download.html
";
    exit 1;
}

print "Checking for SWIG...";
my @swig_version = `swig -version 2>&1`;
my $swig_installed = 0;
if ($?) {
    my $errno = $? >> 8;
    print "
*** I don't see SWIG installed. I'll use the SWIG-generated file
*** that comes with the distribution. If you want SWIG, get it
*** from http://www.swig.org
"; 
    print "*** Output was:
	@swig_version
" if @swig_version;
} else {
    $swig_installed = 1;
    print "ok\n";
}

my $ccflags = $libcdio_pkgcfg{cflags};

 ## Swig produces a number of GCC warnings. Turn them off if we can.
$ccflags .= try_cflags("-Wno-strict-aliasing");
$ccflags .= try_cflags("-Wno-unused-function");
$ccflags .= try_cflags("-Wno-unused-value");
$ccflags .= try_cflags("-Wno-unused-function");
$ccflags .= try_cflags("-Wno-unused-variable");

my %libiso9660_pkgcfg = ExtUtils::PkgConfig->find ('libiso9660');
my $ldflags = "$libcdio_pkgcfg{libs} $libiso9660_pkgcfg{libs} -lcdio";
my $swig_flags='';
if ('cygwin' eq $Config{osname} && 
    $Config{shrpenv} =~ m{\Aenv LD_RUN_PATH=(.*)\Z} ) {
    $ldflags .= " -L$1 -lperl";
    # Should we check the 32-ness?
    $swig_flags = '-DNEED_LONG';
} elsif ('darwin' eq $Config{osname}) {
    $ldflags .= " -bundle -flat_namespace";
}
$ccflags =~ s/^\s+//;
$ccflags =~ s/\s+$//;
$ldflags =~ s/^\s+//;
$ldflags =~ s/\s+$//;

my $class = Module::Build->subclass( code => $code );

my $builder = $class->new( 
    module_name         => 'Device::Cdio',
    add_to_cleanup      => [ 'Device-Cdio-*', 'tmp*'  ],
    create_makefile_pl  => 'passthrough',
    dist_abstract       => 'CD Input and control library',
    dist_author         => 'Rocky Bernstein <rocky@cpan.org>',
    dist_version_from   => 'lib/Device/Cdio.pm',
    extra_linker_flags  => $ldflags,
    extra_compiler_flags=> $ccflags,
    swig_flags          => $swig_flags,
    swig_installed      => $swig_installed,
    license             => 'gpl',
    requires => {
	'ExtUtils::PkgConfig'     => '1.03',
        'Test::More'              => 0,
        'version'                 => 0,
    },
    sign                => 1,
    swig_source         => [ ['perlcdio.swg', 
			      ['audio.swg', 'compat.swg', 'device.swg',
			       'disc.swg', 'device_const.swg', 'disc.swg',
			       'read.swg', 'track.swg', 'types.swg']],
			     ['perliso9660.swg', 
			      ['types.swg']],
			     ['perlmmc.swg', 
			      ['types.swg']] ],
			   );

$builder->add_build_element('swig');
$builder->create_build_script();
