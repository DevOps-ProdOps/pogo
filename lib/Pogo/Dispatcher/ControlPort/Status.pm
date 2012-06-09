###########################################
package Pogo::Dispatcher::ControlPort::Status;
###########################################
use strict;
use warnings;
use Log::Log4perl qw(:easy);
use AnyEvent;
use AnyEvent::Strict;
use JSON qw( to_json );
use Pogo;
use Pogo::Util qw( http_response_json );

###########################################
sub app {
###########################################
    my ( $class, $dispatcher ) = @_;

    return sub {
        my ( $env ) = @_;

        return http_response_json(
            {   pogo_version => $Pogo::VERSION,
                workers => [ $dispatcher->{ wconn_pool }->workers_connected ],
            }
        );
    };
}

1;

__END__

=head1 NAME

Pogo::Dispatcher::ControlPort::Status - Pogo Dispatcher PSGI ControlPort

=head1 SYNOPSIS

    use Pogo::Dispatcher::ControlPort;

    my $app = Pogo::Dispatcher::ControlPort->app();

=head1 DESCRIPTION

PSGI app for Pogo Dispatcher.

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

