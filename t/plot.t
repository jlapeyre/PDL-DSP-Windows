use strict;
use warnings;

use Test::More;
use Try::Tiny;

unless ( eval { require PDL::Graphics::Gnuplot; 1 } ) {
    plan skip_all => 'Need PDL::Graphics::Gnuplot to run plot tests';
}

use PDL::DSP::Windows;
use File::Temp;

sub dies (&$$) {
    my ( $code, $check, $message ) = @_;

    my $error;
    try { $code->() } catch { chomp( $error = $_ ) }
    finally {
        $error //= '';
        like $error, $check, $message;
    };
}

sub do_test {
    my ( $method, $win, $args, $checks ) = @_;

    no strict 'refs';
    no warnings 'redefine';

    my $temp = File::Temp->new('PDL-DSP-Windows-plot-XXXXXXX');

    my $sub = PDL::Graphics::Gnuplot->can('plot');
    local *{'PDL::Graphics::Gnuplot::plot'} = sub {
        $sub->( @_, { device => $temp->filename . '/latex' } );
    };

    $win->$method($args);

    my $svg = do { local $/; <$temp> };

    like $svg, $checks->{$_}, $win->get_name . ": $_" for keys %{$checks};
}

subtest plot => sub {
    do_test( plot => PDL::DSP::Windows->new(10) => {}, {
        title   => qr/Hamming window/,
        x_label => qr/Time \(samples\)/,
        y_label => qr/amplitude/,
    });

    do_test( plot => PDL::DSP::Windows->new( 10, 'blackman_gen3', [1, 2, 3] ) => {}, {
        title => qr/Blackman family. : a0 = 1, a1 = 2, a2 = 3/,
    });
};

subtest plot_freq => sub {
    note 'Default';
    do_test( plot_freq => PDL::DSP::Windows->new(10) => {}, {
        title   => qr/Hamming window, frequency response. ENBW=1.468/,
        x_label => qr/Fraction of Nyquist frequency/,
        y_label => qr/freqeuncy response \(dB\)/,
    });

    note 'Samples';
    do_test( plot_freq => PDL::DSP::Windows->new(10) => { coord => 'sample' }, {
        title   => qr/Hamming window, frequency response. ENBW=1.468/,
        x_label => qr/Fraction of sampling freqeuncy/,
        y_label => qr/freqeuncy response \(dB\)/,
    });

    note 'bin';
    do_test( plot_freq => PDL::DSP::Windows->new(10) => { coord => 'bin' }, {
        title   => qr/Hamming window, frequency response. ENBW=1.468/,
        x_label => qr/bin/,
        y_label => qr/freqeuncy response \(dB\)/,
    });

    note 'Nyquist';
    do_test( plot_freq => PDL::DSP::Windows->new(10) => { coord => 'nyquist' }, {
        title   => qr/Hamming window, frequency response. ENBW=1.468/,
        x_label => qr/Fraction of Nyquist frequency/,
        y_label => qr/freqeuncy response \(dB\)/,
    });

    note 'Invalid';
    dies { PDL::DSP::Windows->new(10)->plot_freq({ coord => 'foo' }) }
        qr/Unknown ordinate unit specification/i,
        'plot_freq dies with unknown coord spec';

    note 'With params';
    do_test( plot_freq => PDL::DSP::Windows->new( 10, 'blackman_gen3', [1, 2, 3] ) => {}, {
        title => qr/Blackman family. : a0 = 1, a1 = 2, a2 = 3, frequency response. ENBW=/,
    });
};

done_testing;
