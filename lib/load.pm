package load;

use 5.014;
use strict;
use warnings;
use preload ();

use Keyword::API;

sub import {
    my ($class, %params) = @_;

    my $name = %params && $params{-as} ? $params{-as} : "load";

    install_keyword(__PACKAGE__, $name);
}

sub unimport { uninstall_keyword() }

sub parser {
    lex_read_space(0);
    my $module = lex_unstuff_to_ws();
    lex_stuff("unless (preload::PRELOAD) { require $module }");
};

1;
# ABSTRACT: Load module when not PRELOAD
