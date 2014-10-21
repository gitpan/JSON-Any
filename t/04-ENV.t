#!/usr/bin/perl -w

use strict;
use Test::More tests => 8;

BEGIN {
    $ENV{JSON_ANY_ORDER} = qw(JSON);
}
use JSON::Any;
is_deeply( $ENV{JSON_ANY_ORDER}, qw(JSON) );
is( JSON::Any->handlerType, 'JSON' );

$ENV{JSON_ANY_ORDER} = qw(XS);
JSON::Any->import();
is(JSON::Any->handlerType, 'JSON::XS');

my ($json); 
ok( $json = JSON::Any->new() );
eval{ $json->encode("ü"), qq["ü"] };
ok($@, 'trapped a failure');
undef $@;
$ENV{JSON_ANY_CONFIG} = 'allow_nonref=1';
ok( $json = JSON::Any->new() );
ok($json->encode("ü"), qq["ü"]);
ok($@ == undef, 'no failure');

