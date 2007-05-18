#!perl -T
use strict;
use Test::More;

eval "use JSON::Any qw(XS)";
if ($@) {
    plan skip_all => "JSON::XS not installed: $@";
}
else {
    plan tests => 10;
}

skip "JSON::XS not installed: $@", 1 if $@;
diag("Testing JSON::XS backend");

is( JSON::Any->encode({foo=>'bar'}), qq[{"foo":"bar"}] );

my ( $json, $js, $obj );
ok( $json = JSON::Any->new( allow_nonref => 1 ) );
is( $json->encode("Ã¼"), qq["Ã¼"] );
ok( $json = JSON::Any->new( allow_nonref => 1, ascii => 1, utf8 => 1 ) );
is( $json->encode( chr 0x8000 ), '"\u8000"' );
ok(
    $json = JSON::Any->new(
        allow_nonref => 1,
        ascii        => 1,
        utf8         => 1,
        pretty       => 1
    )
);
is( $json->encode( chr 0x10402 ), '"\ud801\udc02"' );
ok( $json = JSON::Any->new( allow_nonref => 1, utf8 => 1 ) );

TODO: {

    local $TODO = 'figure out why Ã¼ ne qq["\xc3\xbc\"]';
    is( $json->encode("Ã¼"), qq["\xc3\xbc\"] );
}

is( JSON::Any->encode({foo=>'bar'}), qq[{"foo":"bar"}] );
