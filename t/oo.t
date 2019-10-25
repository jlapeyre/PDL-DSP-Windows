use Test::More;

use PDL::DSP::Windows;
use Try::Tiny;

is ref PDL::DSP::Windows->new, 'PDL::DSP::Windows', 'Has constructor';

subtest 'Default window' => sub {
    my $window = PDL::DSP::Windows->new(10);
    is_deeply [ $window->get( 'N', 'name', 'periodic' ) ],
        [ 10, 'hamming', 0 ],
        'Defaults to symmetric hamming window';
};

subtest 'Empty constructor' => sub {
    is +PDL::DSP::Windows->new->init(10)->samples->nelem, 10,
        'Can initialise windows late';

    is +PDL::DSP::Windows->new(100)->init(10)->samples->nelem, 10,
        'Can override construction parameters with init';

    try {
        # TODO: Should this die earlier?
        PDL::DSP::Windows->new->samples;
        fail 'Did not die';
    }
    catch {
        like $_, qr/(?:undefined value|string .*) as a subroutine ref(?:erence)?/,
            'Calling ->samples on uninitialised window dies';
    };

    try {
        # TODO: Should this die earlier?
        PDL::DSP::Windows->new->init->samples;
        fail 'Did not die';
    }
    catch {
        like $_, qr/at least two elements in dimension for xlinvals/,
            'Calling ->samples on incomplete window dies';
    };
};

subtest 'Samples accesors' => sub {
    my $window = PDL::DSP::Windows->new(10);

    is $window->{samples}, undef,
        'Samples begins as undef';

    delete $window->{samples};
    is ref $window->get_samples, 'PDL',
        '->get_samples defines value';

    delete $window->{samples};
    is ref $window->get('samples'), 'PDL',
        '->get("samples") defines value';

    delete $window->{samples};
    is ref $window->samples, 'PDL',
        '->samples defines value';

    $window->{samples} = [];

    is ref $window->get_samples, 'ARRAY',
        '->get_samples does not redefine value';

    is ref $window->get('samples'), 'ARRAY',
        '->get("samples") does not redefine value';

    is ref $window->samples, 'PDL',
        '->samples redefines value';
};

done_testing;
