package preload;

# DATE
# VERSION

use 5.014;
use strict;
use warnings;

use constant PRELOAD => $ENV{PERL_PRELOAD};

use Keyword::API;

sub import {
    no strict 'refs';

    my $class = shift;

    install_keyword(__PACKAGE__, 'load');

    # XXX can't install_keyword() twice? so currently we cheat and make preload
    # as just an "alias" to require
    my $caller = caller();
    *{"$caller\::preload"} = sub { my $mod_pm = shift; $mod_pm =~ s!::!/!g; $mod_pm .= ".pm"; require $mod_pm };
}

sub unimport { uninstall_keyword() }

sub parser {
    lex_read_space(0);
    my $module = lex_unstuff_to_ws();
    lex_stuff("unless (preload::PRELOAD) { require $module }");
};

1;
# ABSTRACT: Load and preload modules

=for Pod::Coverage .+

=head1 SYNOPSIS

 use preload;

 # Foo::Bar will be require'd when $ENV{PERL_PRELOAD_MODULES} is true
 preload Foo::Bar;

 sub mysub {
     # Foo::Bar will be require'd when $ENV{PERL_PRELOAD_MODULES} is false
     load Foo::Bar;
 }


=head1 DESCRIPTION

B<STATUS: Experimental, interface will likely change.>

When running a script, especially one that has to start quickly, it's desirable
to delay loading modules until it's actually used, to reduce startup overhead.

When running a (preforking) daemon, it's usually desirable to preload modules at
startup, so the daemon can then service clients without any further delay from
loading modules, and the loading before forking means child processes can share
the module code (reduced memory usage).

This pragma module tries to offer the best of both worlds. This statement:

 use preload;

will declare a constant C<PRELOAD> (currently set to
C<$ENV{PERL_PRELOAD_MODULES}>) and introduce two new keywords: C<preload> and
C<load>. C<preload> is defined to be:

 if (PRELOAD) { require $module }

this means it will become a no-op when PRELOAD is false. On the other hand,
C<load> is defined to be:

 unless (PRELOAD) { require $module }

this means it will become a no-op when PRELOAD is true.

With this module you can avoid run-time penalty associated with conditional
loading.


=head1 ENVIRONMENT

=head2 PERL_PRELOAD_MODULES

Boolean.


=head1 SEE ALSO

L<prefork>

L<Dist::Zilla::Plugin::Preload>

=cut
