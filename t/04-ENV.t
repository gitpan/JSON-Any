use strict;
use warnings;

use Test::More;

eval "use JSON::Any";
plan skip_all => "$@" if $@;

SKIP: {
    eval { require JSON; };
    skip "JSON not installed: $@", 1 if $@;

    $ENV{JSON_ANY_ORDER} = qw(JSON);
    JSON::Any->import();
    skip "JSON not installed: $@", 1 if $@;
    is_deeply( $ENV{JSON_ANY_ORDER}, qw(JSON) );
    is( JSON::Any->handlerType, 'JSON' );
}

SKIP: {
    eval { require JSON::XS; };
    skip "JSON::XS not installed: $@", 1 if $@;

    $ENV{JSON_ANY_ORDER} = qw(XS);

    JSON::Any->import();
    is( JSON::Any->handlerType, 'JSON::XS' );

    my ($json);
    ok( $json = JSON::Any->new() );
    eval { $json->encode("ü") };
    ok( $@, 'trapped a failure' );
    undef $@;
    $ENV{JSON_ANY_CONFIG} = 'allow_nonref=1';
    ok( $json = JSON::Any->new() );
    ok( $json->encode("dahut"), qq["dahut"] );
    is( $@, undef, 'no failure' );
}

done_testing;
