#!perl -T
use 5.014;
use strict;
use warnings FATAL => 'all';
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'YDL::Compute' ) || print "Bail out!\n";

}

diag( "\nTesting YDL::Compute v$YDL::Compute::VERSION, Perl $], $^X" );

