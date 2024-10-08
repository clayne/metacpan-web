use strict;
use warnings;
use lib 't/lib';

use MetaCPAN::Web::Test qw( app GET test_cache_headers test_psgi );
use Test::More;

test_psgi app, sub {
    my $cb = shift;
    ok( my $res = $cb->( GET '/robots.txt' ), 'GET /robots.txt' );
    is( $res->code, 200, 'code 200' );

SKIP: {
        skip 'Root controller is not serving /robots.txt!', 3;
        test_cache_headers(
            $res,
            {
                cache_control     => 'max-age=3600',
                surrogate_key     => 'ROBOTS',
                surrogate_control => 'max-age=86400',
            }
        );
    }
};

done_testing;
