###########################################
package Pogo::Dispatcher::ControlPort;
###########################################
use strict;
use warnings;
use Log::Log4perl qw(:easy);
use AnyEvent;
use AnyEvent::Strict;
use AnyEvent::HTTPD;
use JSON qw(from_json to_json);
use Data::Dumper;
use Template;
use Pogo::Plack::Handler::AnyEvent::HTTPD;
use Pogo::Defaults qw(
    $POGO_DISPATCHER_CONTROLPORT_HOST
    $POGO_DISPATCHER_CONTROLPORT_PORT
);
use base qw(Pogo::Object::Event);

our $APPS_LOADED = {};

###########################################
sub new {
###########################################
    my ( $class, %options ) = @_;

    my $self = {
        host             => $POGO_DISPATCHER_CONTROLPORT_HOST,
        port             => $POGO_DISPATCHER_CONTROLPORT_PORT,
        dispatcher       => undef,
        protocol_version => "v1",
        %options,
    };

    bless $self, $class;
}

###########################################
sub base_url {
###########################################
    my ( $self ) = @_;

    return "http://$self->{ host }:$self->{ port }/$self->{ protocol_version }";
}

###########################################
sub start {
###########################################
    my ( $self ) = @_;

    DEBUG "Starting ControlPort HTTP server on port $self->{ port }";

    my $httpd = Plack::Handler::AnyEvent::HTTPD->new(
        host         => $self->{ host },
        port         => $self->{ port },
        server_ready => sub {
            $self->event( "dispatcher_controlport_up" );
        }
    );

    $httpd->register_service( $self->app( ) );

    $self->{ httpd } = $httpd;    # guard

    $self->reg_cb(
        "dispatcher_controlport_send_cmd",
        sub {
            my ( $cmd, $data ) = @_;
            DEBUG "Received ControlPort command: $cmd";
        }
    );
}

###########################################
sub app {
###########################################
    my ( $self ) = @_;

    no strict 'refs';
    my $app_pkg = __PACKAGE__ . "::PSGI";

    if( ! exists $APPS_LOADED->{ $app_pkg } ) {
        eval "require $app_pkg";
        $APPS_LOADED->{ $app_pkg } = 1;
    }

    return $app_pkg->app( $self->{ dispatcher } );
}

1;

__END__

=head1 NAME

Pogo::Dispatcher::ControlPort - Dispatcher's ControlPort interface

=head1 SYNOPSIS

    use Pogo::Dispatcher::ControlPort;

    my $cp = Pogo::Dispatcher::ControlPort->new();
    $cp->start();

=head1 DESCRIPTION

Dispatcher internal ControlPort to allow querying its internal status
and submitting commands.

=head1 METHODS

=over 4

=item C<new()>

Constructor.

=item C<start()>

Start the server.

=back

=head1 EVENTS

=over 4

=item C<dispatcher_controlport_up>

Fired as soon as the HTTPD server is up.

=back

=head1 LICENSE

Copyright (c) 2010-2012 Yahoo! Inc. All rights reserved.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
imitations under the License.

=head1 AUTHORS

Mike Schilli <m@perlmeister.com>
Ian Bettinger <ibettinger@yahoo.com>

Many thanks to the following folks for implementing the
original version of Pogo: 

Andrew Sloane <andy@a1k0n.net>, 
Michael Fischer <michael+pogo@dynamine.net>,
Nicholas Harteau <nrh@hep.cat>,
Nick Purvis <nep@noisetu.be>,
Robert Phan <robert.phan@gmail.com>,
Srini Singanallur <ssingan@yahoo.com>,
Yogesh Natarajan <yogesh_ny@yahoo.co.in>

