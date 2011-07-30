#!perl -T
use strict;
BEGIN {
    chdir '..' if ! -d 't';
    push @INC, ('blib/lib', 'blib/arch');
}

use Test::More;
eval "use Test::Pod 1.14";
plan skip_all => "Test::Pod 1.14 required for testing POD" if $@;
all_pod_files_ok();
