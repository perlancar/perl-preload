package preload;

# DATE
# VERSION

use 5.014;
use strict;
use warnings;
#use load;

use constant PRELOAD => $ENV{PRELOAD};

use Keyword::API;

sub import {
    my ($class, %params) = @_;

    my $name = %params && $params{-as} ? $params{-as} : "preload";

    install_keyword(__PACKAGE__, $name);
    #load->import;
}

sub unimport { uninstall_keyword() }

sub parser {
    lex_read_space(0);
    my $module = lex_unstuff_to_ws();
    lex_stuff("if (PRELOAD) { require $module }");
};

1;
# ABSTRACT: Load modules when PRELOAD

=head1 SYNOPSIS

 use preload;

 # Foo::Bar will be require'd when $ENV{PRELOAD} is true
 preload Foo::Bar;

 sub mysub {
     # Foo::Bar will be require'd when $ENV{PRELOAD} is false
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

will declare a constant C<PRELOAD> (currently set to C<$ENV{PRELOAD}>) and
introduce two new keywords: C<preload> and C<load>. C<preload> is defined to be:

 if (PRELOAD) { require $module }

this means it will become a no-op when PRELOAD is false. On the other hand,
C<load> is defined to be:

 unless (PRELOAD) { require $module }

this means it will become a no-op when PRELOAD is true.

With this module you can avoid run-time penalty associated with conditional
loading.


=head1 SEE ALSO

L<prefork>

=cut
