use Test::More;

use PDL::DSP::Windows;

my @warnings;
local $SIG{__WARN__} = sub { push @warnings, @_ };

sub caught_warnings {
    my @w = @warnings;
    @warnings = ();
    return @w;
}

subtest winpersubs => sub {
    for my $key ( keys %PDL::DSP::Windows::winpersubs ) {
        ok +PDL::DSP::Windows->can("${key}_per"),
            "$key points to defined periodic window";

        is ref $PDL::DSP::Windows::winsubs{$key}, 'CODE',
            "$key is mapped to coderef";

        ok exists $PDL::DSP::Windows::window_definitions{$key},
            "$key has defined metadata";

        my @warns = caught_warnings;

        is scalar @warns, 2, 'Caught two warnings';
        like $_, qr/Package variables .* are deprecated .* attempt to read/,
            'window_definitions warned on read' for @warns;
    }
};

subtest winsubs => sub {
    for my $key ( keys %PDL::DSP::Windows::winsubs ) {
        ok +PDL::DSP::Windows->can($key),
            "$key points to defined symmetric window";

        is ref $PDL::DSP::Windows::winsubs{$key}, 'CODE',
            "$key is mapped to coderef";

        ok exists $PDL::DSP::Windows::window_definitions{$key},
            "$key has defined metadata";

        my @warns = caught_warnings;

        is scalar @warns, 2, 'Caught two warnings';
        like $_, qr/Package variables .* are deprecated .* attempt to read/,
            'window_definitions warned on read' for @warns;

    }
};

subtest window_definitions => sub {
    for my $key ( keys %PDL::DSP::Windows::window_definitions ) {
        my @warns;

        ok +PDL::DSP::Windows->can($key),
            "$key points to defined window";

        ok exists $PDL::DSP::Windows::winsubs{$key},
            "$key window is in symmetric map";

        @warns = caught_warnings;

        is scalar @warns, 1, 'Caught a single warning';
        like $_, qr/Package variables .* are deprecated .* attempt to read/,
            'window_definitions warned on read' for @warns;

        next unless PDL::DSP::Windows->can("${key}_per");

        ok exists $PDL::DSP::Windows::winpersubs{$key},
            "$key window is in periodic map";

        @warns = caught_warnings;

        is scalar @warns, 1, 'Caught a single warning';
        like $_, qr/Package variables .* are deprecated .* attempt to read/,
            'window_definitions warned on read' for @warns;
    }
};

subtest writes => sub {
    $PDL::DSP::Windows::window_definitions{'hamming'} = 1;
    $PDL::DSP::Windows::winsubs{'hamming'} = 1;
    $PDL::DSP::Windows::winpersubs{'hamming'} = 1;

    my @warns = caught_warnings;

    is scalar @warns, 3, 'Caught three warnings';
    like $_, qr/Package variables .* are deprecated .* attempt to write/,
        'window_definitions warned on write' for @warns;
};

done_testing;
