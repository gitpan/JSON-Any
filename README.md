# NAME

JSON::Any - Wrapper Class for the various JSON classes.

# VERSION

version 1.34

# SYNOPSIS

This module tries to provide a coherent API to bring together the various JSON
modules currently on CPAN. This module will allow you to code to any JSON API
and have it work regardless of which JSON module is actually installed.

    use JSON::Any;

    my $j = JSON::Any->new;

    $json = $j->objToJson({foo=>'bar', baz=>'quux'});
    $obj = $j->jsonToObj($json);

or

    $json = $j->encode({foo=>'bar', baz=>'quux'});
    $obj = $j->decode($json);

or

    $json = $j->Dump({foo=>'bar', baz=>'quux'});
    $obj = $j->Load($json);

or

    $json = $j->to_json({foo=>'bar', baz=>'quux'});
    $obj = $j->from_json($json);

or without creating an object:

    $json = JSON::Any->objToJson({foo=>'bar', baz=>'quux'});
    $obj = JSON::Any->jsonToObj($json);

On load, JSON::Any will find a valid JSON module in your @INC by looking
for them in this order:

    Cpanel::JSON::XS
    JSON::XS
    JSON::PP
    JSON
    JSON::DWIW

And loading the first one it finds.

You may change the order by specifying it on the `use JSON::Any` line:

    use JSON::Any qw(DWIW XS CPANEL JSON PP);

Specifying an order that is missing modules will prevent those module from
being used:

    use JSON::Any qw(CPANEL PP); # same as JSON::MaybeXS

This will check in that order, and will never attempt to load [JSON::XS](https://metacpan.org/pod/JSON::XS),
["JSON" in JSON.pm](https://metacpan.org/pod/JSON.pm#JSON), or [JSON::DWIW](https://metacpan.org/pod/JSON::DWIW). This can also be set via the `$ENV{JSON_ANY_ORDER}`
environment variable.

[JSON::Syck](https://metacpan.org/pod/JSON::Syck) has been deprecated by its author, but in the attempt to still
stay relevant as a "Compatibility Layer" JSON::Any still supports it. This support
however has been made optional starting with JSON::Any 1.19. In deference to a
bug request starting with [JSON.pm](https://metacpan.org/pod/JSON) 1.20, [JSON::Syck](https://metacpan.org/pod/JSON::Syck) and other deprecated modules
will still be installed, but only as a last resort and will now include a
warning.

    use JSON::Any qw(Syck XS JSON);

or

    $ENV{JSON_ANY_ORDER} = 'Syck XS JSON';

At install time, JSON::Any will attempt to install [JSON::PP](https://metacpan.org/pod/JSON::PP) as a reasonable
fallback if you do not appear have **any** backends installed on your system.

WARNING: If you call JSON::Any with an empty list

    use JSON::Any ();

It will skip the JSON package detection routines and will die loudly that it
couldn't find a package.

# WARNING

[JSON::XS](https://metacpan.org/pod/JSON::XS) 3.0 or higher has a conflict with any version of [JSON.pm](https://metacpan.org/pod/JSON) less than 2.90
when you use [JSON.pm](https://metacpan.org/pod/JSON)'s `-support_by_pp` option, which JSON::Any enables by
default.

This situation should only come up with JSON::Any if you have [JSON.pm](https://metacpan.org/pod/JSON) 2.61 or
lower **and** [JSON::XS](https://metacpan.org/pod/JSON::XS) 3.0 or higher installed, and you use [JSON.pm](https://metacpan.org/pod/JSON)
via `use JSON::Any qw(JSON);` or the `JSON_ANY_ORDER` environment variable.

If you run into an issue where you're getting recursive inheritance errors in a
[Types::Serialiser](https://metacpan.org/pod/Types::Serialiser) package, please try upgrading [JSON.pm](https://metacpan.org/pod/JSON) to 2.90 or higher.

# DEPRECATION

The original need for [JSON::Any](https://metacpan.org/pod/JSON::Any) has been solved (quite some time ago
actually). If you're producing new code it is recommended to use [JSON::MaybeXS](https://metacpan.org/pod/JSON::MaybeXS) which
will optionally use [Cpanel::JSON::XS](https://metacpan.org/pod/Cpanel::JSON::XS) for speed purposes.

JSON::Any will continue to be maintained for compatibility with existing code,
but for new code you should strongly consider using [JSON::MaybeXS](https://metacpan.org/pod/JSON::MaybeXS) instead.

# METHODS

- `new`

    Will take any of the parameters for the underlying system and pass them
    through. However these values don't map between JSON modules, so, from a
    portability standpoint this is really only helpful for those parameters that
    happen to have the same name. This will be addressed in a future release.

    The one parameter that is universally supported (to the extent that is
    supported by the underlying JSON modules) is `utf8`. When this parameter is
    enabled all resulting JSON will be marked as unicode, and all unicode strings
    in the input data structure will be preserved as such.

    Also note that the `allow_blessed` parameter is recognised by all the modules
    that throw exceptions when a blessed reference is given them meaning that
    setting it to true works for all modules. Of course, that means that you
    cannot set it to false intentionally in order to always get such exceptions.

    The actual output will vary, for example [JSON](https://metacpan.org/pod/JSON) will encode and decode
    unicode chars (the resulting JSON is not unicode) whereas [JSON::XS](https://metacpan.org/pod/JSON::XS) will emit
    unicode JSON.

- `handlerType`

    Takes no arguments, returns a string indicating which JSON Module is in use.

- `handler`

    Takes no arguments, if called on an object returns the internal JSON::\*
    object in use.  Otherwise returns the JSON::\* package we are using for
    class methods.

- `true`

    Takes no arguments, returns the special value that the internal JSON
    object uses to map to a JSON `true` boolean.

- `false`

    Takes no arguments, returns the special value that the internal JSON
    object uses to map to a JSON `false` boolean.

- `objToJson`

    Takes a single argument, a hashref to be converted into JSON.
    It returns the JSON text in a scalar.

- `to_json`
- `Dump`
- `encode`

    Aliases for `objToJson`, can be used interchangeably, regardless of the
    underlying JSON module.

- `jsonToObj`

    Takes a single argument, a string of JSON text to be converted
    back into a hashref.

- `from_json`
- `Load`
- `decode`

    Aliases for `jsonToObj`, can be used interchangeably, regardless of the
    underlying JSON module.

# ACKNOWLEDGEMENTS

This module came about after discussions on irc.perl.org about the fact
that there were now six separate JSON perl modules with different interfaces.

In the spirit of Class::Any, JSON::Any was created with the considerable
help of Matt 'mst' Trout.

Simon Wistow graciously supplied a patch for backwards compatibility with JSON::XS
versions previous to 2.01

San Dimas High School Football Rules!

# AUTHORS

- Chris Thompson <cthom@cpan.org>
- Chris Prather <chris@prather.org>
- Robin Berjon <robin@berjon.com>
- Marc Mims <marc@questright.com>
- Tomas Doran <bobtfish@bobtfish.net>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2007 by Chris Thompson.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

# CONTRIBUTORS

- Dagfinn Ilmari Mannsåker <ilmari@ilmari.org>
- Justin Hunter <justin.d.hunter@gmail.com>
- Karen Etheridge <ether@cpan.org>
- Matthew Horsfall <wolfsage@gmail.com>
- Todd Rinaldo <toddr@cpan.org>
- יובל קוג'מן (Yuval Kogman) <nothingmuch@woobling.org>
