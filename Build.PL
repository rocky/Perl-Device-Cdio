#!/usr/bin/perl -w
#  Copyright (C) 2006, 2008, 2011 Rocky Bernstein <rocky@gnu.org>
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

use strict;
use warnings;
use Module::Build;
use ExtUtils::PkgConfig;
use Config;


my %libcdio_pkgcfg = ExtUtils::PkgConfig->find ('libcdio');
use constant MIN_LIBCDIO_VERSION => 0.82;
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


my $class = Module::Build->subclass( class => 'MyModuleBuild',
    code => q!
        use File::Basename;
        use Data::Dumper;
        sub process_swig_files {
            my $self = shift;
            my $verb = $self->runtime_params('verbose');
            my @p = @_;
            ##print Dumper($self);
            my $swigfiles = $self->rscan_dir('./', qr/\.swg/);
            print @$swigfiles,"\n";
            if($self->up_to_date($swigfiles,
                    $self->rscan_dir('blib',qr/\.so/))) {
                print "swig modules up to date\n" if $verb;
                return 1;
            }
            print "proces swig files\n" if $verb;
            my $swigdeps = $self->config('swig_source');
            my @swig_flags = $self->split_like_shell($self->config('swig_flags'));
            my @swigsource = keys %$swigdeps;
            my $blib_lib = File::Spec->catfile('blib', 'lib');
            my $blib_arch = File::Spec->catfile('blib', 'arch');
            my $cb = $self->cbuilder();
            print "CBuilder: ",$cb->VERSION,"\n" if $verb;
            foreach my $file (@swigsource) {
                print $file, ': ', @{$swigdeps->{$file}}, "\n" if $verb;
                ##check up todate
                my $basename = basename($file, '.swg');
                my $cfile = $basename."_wrap.c";
                $self->do_system('swig', '-o', $cfile, '-perl', '-outdir',
                    $blib_lib, @swig_flags, $file);
                my $obj = $cb->compile(source => $cfile, 
                    ## include_dirs => $self->config('include_dirs'),
                    extra_compiler_flags => $self->config('extra_compiler_flags'));
                print "CB compiled: $obj\n" if $verb;
                my $lib = $cb->link(objects => $obj,
                    extra_linker_flags => $self->config('extra_linker_flags'));
                print "CB generated: $lib\n" if $verb;
                $self->copy_if_modified(from => $lib, to_dir => $blib_arch);
            }
            return 1;
        }
    !);
#

#my $code = <<'EOC';
#;
#EOC
my $builder = $class->new( 
    module_name         => 'Device::Cdio',
    add_to_cleanup      => [ 'Device-Cdio-*', 'tmp*'  ],
    create_makefile_pl  => 'passthrough',
    dist_abstract       => 
    'Perl bindings for CD Input and control library (libcdio)',
    dist_author         => 'Rocky Bernstein <rocky@cpan.org>',
    dist_version_from   => 'lib/Device/Cdio.pm',
    license             => 'gpl',
    needs_compiler      => 1,
    release_status      => 'testing',
    requires => {
	'ExtUtils::PkgConfig'     => '1.03',
        'Test::More'              => 0,
        'version'                 => 0,
    },
    sign                => 1,
    swig_files          => ['./']);
$builder->config(swig_source => {   # with dependencies as hash value
    'perlcdio.swg' =>
        ['audio.swg', 'compat.swg', 'device.swg',
        'disc.swg', 'device_const.swg', 'disc.swg',
        'read.swg', 'track.swg', 'types.swg'],
    'perliso9660.swg' => ['types.swg'],
    'perlmmc.swg', => ['types.swg']} );

if($builder->have_c_compiler()) {
    $builder->notes('c_compiler' => 1);
    print "C compiler found - check swig\n" if $builder->config('verbose');
    my $swig_installed = check_swig(
        verbose => $builder->config('verbose'));
    $builder->notes(swig_installed => $swig_installed);
    my ($ccflags, $ldflags,$swig_flags) = check_c_compiler(
        verbose => $builder->config('verbose'));
    $builder->config(extra_linker_flags  => $ldflags);
    $builder->config(extra_compiler_flags=> $ccflags);
    if($swig_installed) {
        $builder->config(swig_flags          => $swig_flags);
        $builder->add_build_element('swig');
    }
    $builder->add_to_cleanup(['*.o']);
    #rearrange order of the build process
    my @el = @{$builder->build_elements};
    my ($i) = grep {$el[$_] eq 'swig'} 0..$#el;
    unshift @el, splice @el, $i, 1;
    foreach my $i (@el) {
        print " $i ";
    }
    print "\n";
}
#distclean : lib/perliso9660.pm, lib/perlmmc.pm lib/perlcdio.pm
#$builder->cbuilder();
#depends_on(@actions)
#config($key) config($key, $value)
#config_data($name) config_data($name => $value)
#do_system($cmd, @args)
#have_c_compiler()
#notes() notes($key) notes($key => $value)
#rscan_dir($dir, $pattern)
#up_to_date($source_file, $derived_file)
#up_to_date(\@source_files, \@derived_files
$builder->create_build_script();

sub try_compile {
    my ($c, %args) = @_;

    my $ok = 0;
    my $tmp = "tmp$$";
    local(*TMPC);

    my $obj_ext = $builder->config('obj_ext') || ".o";
    unlink("$tmp.c", "$tmp$obj_ext");

    if (open(TMPC, ">", "$tmp.c")) {
	print TMPC $c;
	close(TMPC);

	my $cccmd = $builder->config('cc');
	my $errornull;
	my $ccflags = $builder->config('ccflags');
        $ccflags .= " $args{ccflags}" if $args{ccflags};

        if ($args{silent} ) {
	    $errornull = "2>/dev/null" unless defined $errornull;
	} else {
	    $errornull = '';
	}

    $cccmd = "$cccmd -o $tmp $ccflags $tmp.c $errornull";

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
    print "Checking if ",$builder->config('cc')," supports \"$ccflags\"...";
    my $result = try_compile($c_prog, ccflags=>$ccflags);
    if ($result) {
	print "yes\n";
	return " $ccflags";
    }
    print "no\n";
    return '';
	
}

sub check_swig {

print "Checking for SWIG...";
my @swig_version = `swig -version 2>&1`;
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
    print "ok\n";
    return 1;
}
    return 0;
}

sub check_c_compiler {
    my $cc= shift;

    my $ccflags = $libcdio_pkgcfg{cflags}; #this doesn't wokt at all??
    $ccflags = "-fPIC -D_REENTRANT -D_GNU_SOURCE -DDEBIAN -fno-strict-aliasing -pipe -fstack-protector -I/usr/include -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64 ";
$ccflags = "-I/usr/include -D_GNU_SOURCE "; #that seems enough
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

return ($ccflags, $ldflags, $swig_flags);
}
