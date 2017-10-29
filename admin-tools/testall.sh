#!/bin/bash
# sudo su rocky-rvm -c "
PACKAGE=Perl-Device-Cdio/
source /home/rocky/perl5/perlbrew/etc/bashrc && \
cd /tmp && \
rm -fr $PACKAGE && \
git clone /src/external-vcs/github/rocky/$PACKAGE && \
cd /tmp/$PACKAGE && \
list=$(perlbrew list | sed -e 's/[ *] perl-//') && \
for perl in $list ; do
  echo $perl && \
      perlbrew use $perl && \
      cpan ExtUtils::PkgConfig && \
      perl ./Build.PL >/dev/null 2>&1 && \
      ./Build installdeps 2>&1 && \
      make && make test 2>&1 | grep '^Result:'; echo '---'; \
done
#"
