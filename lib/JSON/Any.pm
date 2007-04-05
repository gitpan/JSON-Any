##############################################################################
# JSON::Any
# v1.03
# Copyright (c) 2007 Chris Thompson
##############################################################################

package JSON::Any;

use warnings;
use strict;
use Carp;

my ( %conf, $handler, $encoder, $decoder );

BEGIN {
    %conf = (
        json => {
            encoder       => 'objToJson',
            decoder       => 'jsonToObj',
            create_object => sub {
                my ($self) = @_;
                my @params = qw(
                  autoconv
                  skipinvalid
                  execcoderef
                  pretty
                  indent
                  delimiter
                  keysort
                  convblessed
                  selfconvert
                  singlequote
                );
                return $handler->new( map { $_ => $self->{$_} } @params );
            },
        },

        json_dwiw => {
            encoder       => 'to_json',
            decoder       => 'from_json',
            create_object => sub {
                my ($self) = @_;
                my @params = qw(bare_keys);
                return $handler->new( { map { $_ => $self->{$_} } @params } );
            },
        },

        json_xs => {
            encoder       => 'to_json',
            decoder       => 'from_json',
            create_object => sub {
                my ($self) = @_;

                my @params = qw(
                  ascii
                  utf8
                  pretty
                  indent
                  space_before
                  space_after
                  canonical
                  allow_nonref
                  shrink
                  max_depth
                );
                               
                my $obj = $handler->new;                
                for my $mutator (@params) {
                    next unless exists $self->{$mutator};
                    $obj = $obj->$mutator( $self->{$mutator} );
                }                
                $encoder = 'encode';
                $decoder = 'decode';
                return $obj;
            },
        },
        json_syck => {
            encoder => 'Dump',
            decoder => 'Load',
        },
    );

    # JSON::PC claims it has the same API as JSON
    $conf{json_pc} = $conf{json};
}

sub import {
    my $class = shift;
    my @order = @_;

    ( $handler, $encoder, $decoder ) = ();

    @order = qw(XS JSON DWIW Syck) unless @order;

    foreach my $testmod (@order) {
        $testmod = "JSON::$testmod" unless $testmod eq "JSON";
        eval "require $testmod";
        unless ($@) {
            $handler = $testmod;            
            ( my $key = lc($handler) ) =~ s/::/_/g;
            $encoder = $conf{$key}->{encoder};
            $decoder = $conf{$key}->{decoder};
            last;
        }
    }

    croak "Couldn't find a JSON Package." unless $handler;
    croak "Couldn't find a decoder method." unless $decoder;
    croak "Couldn't find a encoder method." unless $encoder;
}

=head1 NAME

JSON::Any - Wrapper Class for the various JSON classes.

=head1 VERSION

Version 1.03

=cut

our $VERSION = '1.03';

=head1 SYNOPSIS

This module will provide a coherent API to bring together the various JSON
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

	JSON::XS 
	JSON 
	JSON::DWIW 
	JSON::Syck

And loading the first one it finds.

You may change the order by specifying it on the C<use JSON::Any> line:

	use JSON::Any qw(DWIW Syck XS JSON);

Specifying an order that is missing one of the modules will prevent that module from being used:

	use JSON::Any qw(DWIW XS JSON);

This will check in that order, and will never attempt to load JSON::Syck.

=head1 FUNCTIONS

=over

=item C<new>

Will take any of the parameters for the underlying system and pass them through. 
However these values don't map between JSON modules, so, from a portability
standpoint this is really only helpful for those paramters that happen
to have the same name. This will be addressed in a future release.

=back

=cut

sub new {
    my $class = shift;
    my $self  = bless [], $class;
    ( my $key = lc($handler) ) =~ s/::/_/g;
    if ( my $creator = $conf{$key}->{create_object} ) {
        $self->[0] = $creator->(@_);
    }
    return $self;
}

=over

=item C<handlerType>

Takes no arguments, returns a string indicating which JSON Module is in use.

=back

=cut

sub handlerType {
    my $class = shift;
    $handler;
}

=over

=item C<handler>

Takes no arguments, if called on an object returns the internal JSON::* 
object in use.  Otherwise returns the JSON::* package we are using for 
class methods.

=back

=cut

sub handler {
    my $self = shift;
    if ( ref $self ) {
        return $self->[0];
    }
    return $handler;
}

=over

=item C<objToJson>

Takes a single argument, a hashref to be converted into JSON.
It returns the JSON text in a scalar.

=back

=cut

sub objToJson {
    my $self = shift;
    my $obj  = shift;
    if ( ref $self ) {
        croak "No $handler Object created!" unless exists $self->{[0]};
        my $method = $self->[0]->can($encoder);
        croak "$handler can't execute $encoder" unless $method;
        return $self->[0]->$method($obj);
    }
    return $handler->can($encoder)->($obj);
}

=over

=item C<to_json>

=item C<Dump>

=item C<encode>

Aliases for objToJson, can be used interchangeably, regardless of the 
underlying JSON module.

=back

=cut

{
    no strict "refs";
    *to_json = \&objToJson;
    *Dump    = \&objToJson;
    *encode  = \&objToJson;
}

=over

=item C<jsonToObj>

Takes a single argument, a string of JSON text to be converted
back into a hashref.

=back

=cut

sub jsonToObj {
    my $self = shift;
    my $obj  = shift;    
    if ( ref $self ) {
        croak "No $handler Object created!" unless exists $self->{[0]};
        my $method = $self->[0]->can($decoder);
        croak "$handler can't execute $encoder" unless $method;
        return $self->[0]->$method($obj);
    }
    $handler->can($decoder)->($obj);
}

=over

=item C<from_json>

=item C<Load>

=item C<decode>

Aliases for jsonToObj, can be used interchangeably, regardless of the 
underlying JSON module.

=back

=cut

{
    no strict "refs";
    *from_json = \&jsonToObj;
    *Load      = \&jsonToObj;
    *decode    = \&jsonToObj;
}

=head1 AUTHOR

Chris Thompson, C<< <cthom at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-json-any at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=JSON-Any>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 ACKNOWLEDGEMENTS

This module came about after discussions on irc.perl.org about the fact 
that there were now six separate JSON perl modules with different interfaces.

In the spirit of Class::Any, JSON::Any was created with the considerable 
help of Chris 'perigrin' Prather, and Matt 'mst' Trout.

JSON::Any 1.01 was written almost entirely by Chris Prather.

San Dimas High School Football Rules!

=head1 COPYRIGHT & LICENSE

Copyright 2007 Chris Thompson, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;    # End of JSON::Any