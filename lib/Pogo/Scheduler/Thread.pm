###########################################
package Pogo::Scheduler::Thread;
###########################################
use strict;
use warnings;
use Log::Log4perl qw(:easy);
use AnyEvent;
use AnyEvent::Strict;
use base qw(Pogo::Object::Event);

use Pogo::Util qw( make_accessor id_gen );
__PACKAGE__->make_accessor( $_ ) for qw( id slots is_done);

use overload ( 'fallback' => 1, '""' => 'as_string' );

###########################################
sub new {
###########################################
    my ( $class, %options ) = @_;

    my $self = {
        slots         => [],
        next_slot_idx => 0,
        active_slot   => undef,
        is_done       => 0,
        %options,
    };

    $self->{ id } = id_gen( "thread" ) if !defined $self->{ id };

    bless $self, $class;

    $self->reg_cb(
        "task_mark_done",
        sub {
            my ( $c, $task ) = @_;

            $self->task_mark_done( $task );
        }
    );

    return $self;
}

###########################################
sub slots {
###########################################
    my ( $self, $slot ) = @_;

    return $self->{ slots };
}

###########################################
sub slot_add {
###########################################
    my ( $self, $slot ) = @_;

    push @{ $self->{ slots } }, $slot;
}

###########################################
sub kick {
###########################################
    my ( $self ) = @_;

    DEBUG "Thread $self kick";

    # There could be either more tasks in the current slot (because
    # we were limited by constraints) or subsequent slots.
    if ($self->slots_left()
        or ( defined $self->{ active_slot }
            and $self->{ active_slot }->tasks_left() )
        )
    {
        DEBUG "Still tasks left in thread.";
    } else {

        DEBUG "No more slots, thread $self done";
        $self->is_done( 1 );
        DEBUG "Thread ", $self->id(), " sends thread_done event";
        $self->event( "thread_done", $self );
        return 0;
    }

    my $slot = $self->slot_next();

    $slot->reg_cb(
        "waiting",
        sub {
            # let thread subscribers know about blocked slot
            DEBUG "Thread $self noticed waiting event by slot $slot";
            $self->event( "waiting", $self, $slot );
        }
    );

    DEBUG "Thread $self: Next slot is '$slot'";

    $self->event_forward( { forward_from => $slot }, "task_run" );

    $slot->reg_cb(
        "slot_done",
        sub {
            DEBUG "Thread $self received slot_done from slot $slot";
            $self->kick();
        }
    );

    $slot->start();
}

###########################################
sub start {
###########################################
    my ( $self ) = @_;

    DEBUG "Starting thread $self with slots ",
        join( ", ", @{ $self->{ slots } } );

    $self->kick();
}

###########################################
sub slot_next {
###########################################
    my ( $self ) = @_;

    DEBUG "slot_next";

    if ( !$self->slots_left() ) {
        $self->{ active_slot } = undef;
        $self->event( "thread_done", $self );
        DEBUG "No more slots left in thread $self";
        return undef;
    }

    my $slot = $self->{ slots }->[ $self->{ next_slot_idx } ];
    $self->{ active_slot } = $slot;

    $self->{ next_slot_idx }++;

    return $slot;
}

###########################################
sub slots_left {
###########################################
    my ( $self ) = @_;

    return $self->{ next_slot_idx } <= $#{ $self->{ slots } };
}

###########################################
sub task_mark_done {
###########################################
    my ( $self, $task ) = @_;

    if ( $self->{ active_slot }->task_mark_done( $task ) ) {
        return 1;
    }
}

###########################################
sub as_string {
###########################################
    my ( $self ) = @_;

    return "$self->{ id }";
}

1;

__END__

=head1 NAME

Pogo::Scheduler::Thread - Pogo Scheduler Thread Abstraction

=head1 SYNOPSIS

    use Pogo::Scheduler::Thread;

    my $task = Pogo::Scheduler::Thread->new();

=head1 DESCRIPTION

Pogo::Scheduler::Thread abstraction. A thread holds a number of slots,
which must be processed in sequence. Only if all tasks of a slot have
been processed (i.e. the slot emits "slot_done"), the thread can move
on to the next slot.

=head2 METHODS

=over 4

=item C<slot_add( $slot )>

Adds a slot to the thread's slot sequence.

=item C<slot_next>

Schedules the next slot.

=item C<task_mark_done( $task )>

Marks a task (which must be marked active in the thread's single
active slot) complete.

=back

=head2 EVENTS

=over 4

=item C<>

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

