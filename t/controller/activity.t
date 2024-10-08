use strict;
use warnings;
use lib 't/lib';

use MetaCPAN::Web::Test qw( app GET test_psgi tx );
use Test::More;

my @tests
    = qw(/activity/releases.svg /author/PERLER/activity.svg /dist/Moose/activity.svg);

test_psgi app, sub {
    my $cb = shift;
    foreach my $test (@tests) {
        ok( my $res = $cb->( GET $test ), $test );
        is( $res->code, 200, 'code 200' );
        is(
            $res->header('content-type'),
            'image/svg+xml; charset=UTF-8',
            'Content-type is image/svg+xml; charset=UTF-8'
        );
        ok( my $tx = eval { tx($res) }, 'valid xml' );
    }
};

done_testing;
