use strict;
use warnings;
use lib 't/lib';

use MetaCPAN::Web::Test qw( app GET test_psgi tx );
use Test::More;

my %tests = (
    'DBIx:Class:::ResultSet'   => 'DBIx::Class::ResultSet',
    'DBIx::Class:ResultSet'    => 'DBIx::Class::ResultSet',
    'DBIx:Class'               => 'DBIx::Class',
    'DBIx: Class'              => 'DBIx::Class',
    'DBIx ::Class:  ResultSet' => 'DBIx::Class::ResultSet',
);

test_psgi app, sub {
    my $cb = shift;
    while ( my ( $k, $v ) = each %tests ) {
        ok( my $res = $cb->( GET "/search?q=$k" ), 'search for ' . $k );
        my $tx = tx($res);
        my $module
            = $tx->find_value(
            '//div[contains-token(@class, "no-results")]//div[contains-token(@class,"alert")][contains-token(@class, "alert-danger")]//a[1]'
            );
        is( $module, $v, 'get no result page with suggestion' );
    }
};

done_testing;
