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

    is ref $window->get_samples, 'PDL',
        '->get_samples does not die if samples is already a piddle';
};

subtest 'Modfreqs accesors' => sub {
    my $window = PDL::DSP::Windows->new(10);

    is $window->{modfreqs}, undef,
        'Modfreqs begins as undef';

    delete $window->{modfreqs};
    is ref $window->get_modfreqs, 'PDL',
        '->get_modfreqs defines value';

    delete $window->{modfreqs};
    try {
        is ref $window->get('modfreqs'), 'PDL',
            '->get("modfreqs") defines value';
    }
    catch {
        chomp( $error = $_ );
    }
    finally {
        local $TODO = 'Code calls undefined sub';
        is $error, undef;
        undef $error;
    };

    delete $window->{modfreqs};
    is ref $window->modfreqs, 'PDL',
        '->modfreqs defines value';

    $window->{modfreqs} = [];

    is ref $window->get_modfreqs, 'ARRAY',
        '->get_modfreqs does not redefine value';

    is ref $window->get('modfreqs'), 'ARRAY',
        '->get("modfreqs") does not redefine value';

    is ref $window->modfreqs, 'PDL',
        '->modfreqs redefines value';

    {
        $window->{modfreqs} = [];
        my $freq = $window->get_modfreqs( min_bins => 10_000 );
        is ref $freq, 'PDL',
            '->get_modfreqs redefines values if given parameters';
        # TODO Should this have warned?
        is $freq->nelem, 1_000,
            '->get_modfreqs ignores parameters if not in hashref';
    }

    is ref $window->get_modfreqs, 'PDL',
        '->get_modfreqs does not die if modfreqs is already a piddle';

    {
        $window->{modfreqs} = [];
        my $freq = $window->get_modfreqs({ min_bins => 10_000 });
        is ref $freq, 'PDL',
            '->get_modfreqs redefines values if given parameters';
        is $freq->nelem, 10_000,
            '->get_modfreqs accepts parameters if in hashref';
    }
};

done_testing;
