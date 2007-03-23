#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'JSON::Any' );
}

diag( "Testing JSON::Any $JSON::Any::VERSION, Perl $], $^X" );
