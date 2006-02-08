use strict;
use warnings;
use Module::Build;
use ExtUtils::PkgConfig;

my $code = <<'EOC'
use Cwd;
use File::Copy;
sub process_swig_files {
    my $self = shift;
    # locate and process swig files, and create something in blib/
    $self->process_swig('perlcdio.swg');
}

sub process_swig {
  my ($self, $file) = @_;
  my $cf = $self->{config}; # For convenience

  # File name. e.g, perlcdio.swg -> perlcdio_wrap.c
  (my $file_base = $file) =~ s/\.[^.]+$//;
  my $c_file = "${file_base}_wrap.c";

  # .swg -> .c
  $self->add_to_cleanup($c_file);

  # print "+++ c_file: $c_file, file: $file ", `pwd`, "\n";
  unless ($self->up_to_date($file, $c_file)) {
    $self->compile_swig($file, $c_file);
  }
  
  # .c -> .o
  my $obj_file = $self->compile_c($c_file);
  $self->add_to_cleanup($obj_file);

  # The .so files don't go in blib/lib/, they go in blib/arch/auto/.
  # Unfortunately we have to pre-compute the whole path.
  my $archdir;
  {
    my @dirs = File::Spec->splitdir($file_base);
    $archdir = File::Spec->catdir($self->blib,'arch', @dirs[1..$#dirs]);
  }
  
  # .o -> .so
  $self->link_c($archdir, $file_base, $obj_file);
}

sub compile_swig {
    my ($self, $file, $c_file) = @_;
    my ($cf, $p) = ($self->{config}, $self->{properties}); # For convenience
    
    # File name, minus the suffix
    (my $file_base = $file) =~ s/\.[^.]+$//;
    return $c_file if $self->up_to_date($file, $c_file);
    
    my @swig;
    if (defined($cf->{swig})) {
	@swig = $self->split_like_shell($cf->{cc});
    } else {
	@swig = ('swig');
    }

    my $blib_lib = File::Spec->catfile($self->blib, 'lib');

    # print "+++swig -o $c_file -outdir $blib_lib -perl $file\n";
    $self->do_system(@swig, '-o', $c_file, '-outdir', $blib_lib,
		     '-perl', $file)
	or die "error building $blib_c_file file from '$file'";
    
    return $c_file;
}

# From Base.pm but modified for SWIG conventions.
# Actually that's not all that true. We just pass a $obj_file parameter.
# SWIG objects have a _wrap is added, but compile() knows that.
# Also we modified the die to report the full file name.
sub link_c {
  my ($self, $to, $file_base, $obj_file) = @_;
  my ($cf, $p) = ($self->{config}, $self->{properties}); # For convenience

  my $lib_file = File::Spec->catfile($to, File::Basename::basename("$file_base.$cf->{dlext}"));

  $self->add_to_cleanup($lib_file);
  my $objects = $p->{objects} || [];
  
  unless ($self->up_to_date([$obj_file, @$objects], $lib_file)) {
    $self->prelink_c($to, $file_base) if $self->need_prelink_c;

    my @linker_flags = $self->split_like_shell($p->{extra_linker_flags});
    my @lddlflags = $self->split_like_shell($cf->{lddlflags});
    my @shrp = $self->split_like_shell($cf->{shrpenv});
    my @ld = $self->split_like_shell($cf->{ld});
    $self->do_system(@shrp, @ld, @lddlflags, @user_libs, '-o', $lib_file,
		     $obj_file, @$objects, @linker_flags)
      or die "error building $lib_file file from '$obj_file'";
  }
  
  return $lib_file;
}

EOC
    ;


my %pkgcfg = ExtUtils::PkgConfig->find ('libcdio');

# FIXME: add a test to make sure we are 0.76 or greater.

my $class = Module::Build->subclass( code => $code );

my $builder = $class->new( 
    module_name         => 'Device::Cdio',
    license             => 'gpl',
    dist_author         => 'Rocky Bernstein <rocky@panix.com>',
    dist_version_from   => 'lib/Device/Cdio.pm',
    extra_linker_flags  => $pkgcfg{libs},
    ccflags             => $pkgcfg{cflags},
    requires => {
	'ExtUtils::PkgConfig'     => '1.03',
        'Test::More'              => 0,
        'version'                 => 0,
    },
    add_to_cleanup      => [ 'Device-Cdio-*' ],
);

$builder->add_build_element('swig');
$builder->create_build_script();
