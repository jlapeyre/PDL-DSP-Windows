# -*-Perl-*-     # for emacs

use strict;
use warnings;
use Test::More 0.96;

use PDL::LiteF;
use PDL::NiceSlice;
use PDL::DSP::Windows qw( window chebpoly ) ;

eval { require PDL::LinearAlgebra::Special };
my $HAVE_LinearAlgebra = 1 if !$@;

eval { require PDL::GSLSF::BESSEL; };
my $HAVE_BESSEL = 1 if !$@;

sub tapprox {
    my( $got, $expected, $message, $precision ) = @_;

    $message   //= '';
    $precision //= 8;

    if (ref $got) {
        is  0 + sprintf( "%.${precision}f", $got->sum ),
            0 + sprintf( "%.${precision}f", pdl($expected)->sum ),
            $message
            or print STDERR $got;
    }
    else {
        is  sprintf( "%.${precision}f", $got ),
            sprintf( "%.${precision}f", $expected ),
            $message
            or print STDERR '# ', $got;
    }
}

# Most of these were checked with Octave
subtest 'explict values of windows.' => sub {
    tapprox(
        window( 4, 'hamming' ),
        [ 0.08, 0.77, 0.77, 0.08 ],
        'hamming',
    );

    tapprox(
        window( 4, 'hann' ),
        [ 0, 0.75, 0.75, 0 ],
        'hann',
    );

    tapprox(
        window( 4, 'hann_matlab' ),
        [ 0.3454915,  0.9045085,  0.9045085,  0.3454915 ],
        'hann_matlab',
    );

    tapprox(
        window( 6, 'bartlett_hann' ),
        [ 0, 0.35857354, 0.87942646, 0.87942646, 0.35857354, 0 ],
        'bartlett_hann',
    );

    tapprox(
        window( 6, 'bohman' ),
        [ 0, 0.17912389, 0.83431145, 0.83431145, 0.17912389, 0 ],
        'bohman',
        6,
    );

    tapprox(
        window( 6, 'triangular' ),
        [ 0.16666667, 0.5, 0.83333333, 0.83333333, 0.5, 0.16666667 ],
        'triangular',
    );

    tapprox(
        window( 6, 'welch' ),
        [ 0, 0.64, 0.96, 0.96, 0.64, 0 ],
        'welch',
    );

    tapprox(
        window( 6, 'blackman_harris4' ),
        [ 6e-05, 0.10301149, 0.79383351, 0.79383351, 0.10301149, 6e-05 ],
        'blackman_harris4',
    );

    tapprox(
        window( 6, 'blackman_nuttall' ),
        [ 0.0003628, 0.11051525, 0.7982581, 0.7982581, 0.11051525, 0.0003628 ],
        'blackman_nuttall',
    );

    tapprox(
        window( 6, 'flattop' ),
        [ -0.000421051, -0.067714252, 0.60687215, 0.60687215, -0.067714252, -0.000421051 ],
        'flattop',
        6,
    );

    SKIP: {
        skip 'PDL::GSLSF::BESSEL not installed', 1 unless $HAVE_BESSEL;
        tapprox(
            window( 6, 'kaiser', 0.5 / 3.1415926 ),
            [ 0.94030619, 0.97829624, 0.9975765, 0.9975765, 0.97829624, 0.94030619 ],
            'kaiser',
            7,
        )
    }

    tapprox(
        window( 10, 'tukey', 0.4 ),
        [ 0, 0.58682409, 1, 1, 1, 1, 1, 1, 0.58682409, 0 ],
        'tukey',
        6,
    );

    tapprox(
        window( 8, 'chebyshev', 10 ),
        [ 1, 0.45192476, 0.5102779, 0.54133813, 0.54133813, 0.5102779, 0.45192476, 1 ],
        'chebyshev',
        6,
    );

    tapprox(
        window( 9, 'chebyshev', 10 ),
        [ 1, 0.39951163, 0.44938961, 0.48130908, 0.49229345, 0.48130908, 0.44938961, 0.39951163, 1 ],
        'chebyshev',
        6,
    );
};

subtest 'relations between windows.' => sub {
    tapprox(
        window( 6, 'rectangular' ),
        window( 6, 'cos_alpha', 0 ),
        'rectangular window is equivalent to cos_alpha 0',
    );

    tapprox(
        window( 6, 'cosine' ),
        window( 6, 'cos_alpha', 1 ),
        'cosine window is equivalent to cos_alpha 1',
    );

    tapprox(
        window( 6, 'hann' ),
        window( 6, 'cos_alpha', 2 ),
        'hann window is equivalent to cos_alpha 2',
    );
};

subtest 'enbw of windows.' => sub {
    my $Nbw = 16384;
    my $win = PDL::DSP::Windows->new;

    for (
        # The following agree with Thomas Cokelaer's python package
        [ [ $Nbw, 'hamming'                 ], 1.36288566       => 5 ],
        [ [ $Nbw, 'rectangular'             ], 1.0              => 5 ],
        [ [ $Nbw, 'triangular'              ], 4 / 3            => 5 ],
        [ [ $Nbw * 10, 'hann'               ], 1.5              => 4 ],
        [ [ $Nbw, 'blackman'                ], 1.72686276895347 => 5 ],
        [ [ $Nbw, 'blackman_harris4'        ], 2.0044752407     => 5 ],
        [ [ $Nbw, 'bohman'                  ], 1.78584987506    => 5 ],
        [ [ $Nbw, 'cauchy', 3               ], 1.489407730      => 5 ],
        [ [ $Nbw, 'poisson', 2              ], 1.31307123       => 5 ],
        [ [ $Nbw, 'hann_poisson', 0.5       ], 1.6092559        => 5 ],
        [ [ $Nbw, 'lanczos'                 ], 1.29911199       => 5 ],
        [ [ $Nbw, 'tukey', 0.25             ], 1.1021080        => 5 ],
        [ [ $Nbw, 'parzen'                  ], 1.917577         => 5 ],
        # These agree with other values found on web
        [ [ $Nbw, 'flattop'                 ], 3.77             => 3 ],
    ) {
        my ( $args, $expected, $precision ) = @{$_};
        my ( undef, $name ) = @{$args};
        tapprox( $win->init( @{$args} )->enbw, $expected, $name, $precision );
    }

    SKIP: {
        skip 'PDL::GSLSF::BESSEL not installed', 1 unless $HAVE_BESSEL;
        tapprox(
            $win->init( $Nbw, 'kaiser', 8.6 / 3.1415926 )->enbw,
            1.72147863,
            'kaiser',
            5,
        );
    }
};

subtest 'relation between periodic and symmetric.' => sub {
    for my $N (100, 101) {
        my $Nm = $N - 1;

        my %tests = (
            bartlett_hann    => [],
            bartlett         => [],
            blackman         => [],
            blackman_bnh     => [],
            blackman_ex      => [],
            blackman_harris  => [],
            blackman_harris4 => [],
            blackman_nuttall => [],
            bohman           => [],
            cosine           => [],
            exponential      => [],
            flattop          => [],
            hamming          => [],
            hamming_ex       => [],
            hann             => [],
            lanczos          => [],
            nuttall          => [],
            nuttall1         => [],
            parzen           => [],
            rectangular      => [],
            triangular       => [],
            welch            => [],
            blackman_gen3    => [ 0.42, 0.5, 0.08 ],
            blackman_gen4    => [ 0.35875, 0.48829, 0.14128, 0.01168 ],
            blackman_gen     => [ 0.5 ],
            cauchy           => [ 3 ],
            kaiser           => [ 0.5 ],
            cos_alpha        => [ 2 ],
            hamming_gen      => [ 0.5 ],
            gaussian         => [ 1 ],
            poisson          => [ 1 ],
            tukey            => [ 0.4 ],
            dpss             => [ 4 ],
            blackman_gen5    => [
                0.21557895, 0.41663158, 0.277263158, 0.083578947, 0.006947368
            ],
        );

        for my $name ( keys %tests ) {
            # diag $name;

            SKIP: {
                skip 'PDL::GSLSF::BESSEL not installed', 1
                    if $name eq 'kaiser' and not $HAVE_BESSEL;

                skip 'PDL::LinearAlgebra::Special not installed', 1
                    if $name eq 'dpss' and not $HAVE_LinearAlgebra;

                my %args;
                $args{params} = $tests{$name} if @{ $tests{$name} };

                my $window = window( $N + 1, $name, { %args } );
                tapprox(
                    $window->slice("0:$Nm"),
                    window( $N, $name, { per => 1, %args } ),
                    $name,
                );
            }
        }
    }
};

subtest 'chebpoly.' => sub {
    tapprox(
        chebpoly( 3, pdl( [ 0.5, 1, 1.2 ] ) ),
        [ -1, 1, 3.312 ],
        'chebpoly takes piddle'
    );

    tapprox(
        chebpoly( 3, [ 0.5, 1, 1.2 ] ),
        [ -1, 1, 3.312 ],
        'chebpoly takes arrayref',
    );

    is chebpoly( 3, 1.2 ), 3.312, 'chebpoly takes plain scalar';
};

subtest 'modfreqs.' => sub {
    is +PDL::DSP::Windows->new({ N => 10 })->modfreqs->nelem, 1000,
        'modfreqs defaults to 1000 bins';

    is +PDL::DSP::Windows->new({ N => 10 })
        ->modfreqs({ min_bins => 100 })->nelem, 100,
        'can pass bin number to modfreqs with hashref';
};

done_testing;
