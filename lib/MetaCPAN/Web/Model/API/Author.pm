package MetaCPAN::Web::Model::API::Author;

use Moose;
use namespace::autoclean;

use Future ();
use Ref::Util qw( is_arrayref );

extends 'MetaCPAN::Web::Model::API';

=head1 NAME

MetaCPAN::Web::Model::Author - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.

=head1 AUTHOR

Matthew Phillips

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

sub get {
    my ( $self, $author ) = @_;

    return $self->request( '/author/' . uc($author) )->then( sub {
        my $data = shift;
        if ( $data->{code} ) {
            return Future->done($data);
        }
        else {
            return Future->done( {
                author => $data,
            } );
        }
    } );
}

sub get_multiple {
    my ( $self, @authors ) = @_;
    return $self->request( '/author/by_ids', { id => [ map uc, @authors ] } )
        ->transform(
        done => sub {
            my $data = shift;
            my %authors;
            $authors{ $_->{pauseid} } = $_ for @{ $data->{authors} };
            $data->{authors} = [ @authors{@authors} ];
            $data;
        }
        );
}

sub search {
    my ( $self, $query, $from ) = @_;
    return $self->request( '/author/search', undef,
        { q => $query, from => $from } );
}

sub by_user {
    my ( $self, $users ) = @_;
    return Future->done( [] ) unless $users;

    my $ret;
    if ( is_arrayref($users) ) {
        return unless @{$users};
        $ret = $self->request( '/author/by_user', undef, { user => $users } );
    }
    else {
        $ret = $self->request("/author/by_user/$users");
    }
    $ret->transform(
        done => sub {
            return exists $_[0]->{authors} ? $_[0]->{authors} : [];
        }
    );
}

__PACKAGE__->meta->make_immutable;

1;
