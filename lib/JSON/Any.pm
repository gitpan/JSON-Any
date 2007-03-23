##############################################################################
# JSON::Any
# v1.00
# Copyright (c) 2007 Chris Thompson
##############################################################################

package JSON::Any;

use warnings;
use strict;
use Carp;
my $handler;
	
sub import {
	my $class = shift;
	my @order = @_;

	 
	@order = qw(XS JSON DWIW Syck) unless @order;

    foreach my $testmod (@order) {
	        $testmod = "JSON::$testmod" unless $testmod eq "JSON";
			eval "require $testmod";
			unless($@) {
				$handler = $testmod;
				last;
			}
		}
		
		croak "Couldn't find a JSON Package." unless $handler;
}


=head1 NAME

JSON::Any - Wrapper Class for the myriad JSON classes.

=head1 VERSION

Version 1.00

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

This module will provide a coherent API to bring together the various JSON modules
currently on CPAN.

    use JSON::Any;

	my $j = JSON::Any->new;

	$json = $j->objToJson({foo=>'bar', baz=>'quux'});

	$obj = $j->jsonToObj($json);

or without creating an object:

	$json = JSON::Any->objToJson({foo=>'bar', baz=>'quux'});

	$obj = JSON::Any->jsonToObj($json);

JSON::Any currently only implements converting back and forth between JSON and hashrefs. 
There is considerably more functionality in many of the JSON modules. Ability to access these
will be provided in subsequent versions of JSON::Any.

On load, JSON::Any will find a valid JSON module in your @INC by looking for them in this order:

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

=item C<new>

There are currently no arguments to C<new>

=cut

sub new {
    my $class = shift;
    my %conf = @_;

    return bless {%conf}, $class;
}

=item C<handlerType>

Takes no arguments, returns a string indicating which JSON Module is in use.

=cut

sub handlerType {
	my $class = shift;
	$handler;
}

=item C<objToJson>

Takes a single argument, a hashref to be converted into JSON.
It returns the JSON text in a scalar.

=cut


sub objToJson {
	my $self = shift;
	my $obj = shift;
	
	if (($handler eq 'JSON::PC') || ($handler eq 'JSON')) {
		return $handler->can('objToJson')->($obj);
	} elsif (($handler eq 'JSON::DWIW') || ($handler eq 'JSON::XS')) {
		return $handler->can('to_json')->($obj);		
	} elsif ($handler eq 'JSON::Syck'){
		return $handler->can('Dump')->($obj);
	}	
}

=item C<jsonToObj>

Takes a single argument, a string of JSON text to be converted
back into a hashref.

=cut


sub jsonToObj {
	my $self = shift;
	my $obj = shift;
	
	if (($handler eq 'JSON::PC') || ($handler eq 'JSON')) {
		return $handler->can('jsonToObj')->($obj);
	} elsif (($handler eq 'JSON::DWIW') || ($handler eq 'JSON::XS')) {
		return $handler->can('from_json')->($obj);		
	} elsif ($handler eq 'JSON::Syck'){
		return $handler->can('Load')->($obj);
	}
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

This module came about after discussions on irc.perl.org about the fact that there were
now six separate JSON perl modules with different interfaces.

In the spirit of Class::Any, I have created JSON::Any with the considerable help of
Chris 'Perigrin' Prather, and Matt 'mst' Trout.

=head1 COPYRIGHT & LICENSE

Copyright 2007 Chris Thompson, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of JSON::Any
