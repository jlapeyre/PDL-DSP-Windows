use strict;
use warnings;

use Test::More;

unless ( eval { require PDL::Graphics::Gnuplot; 1 } ) {
    plan skip_all => 'Need PDL::Graphics::Gnuplot to run plot tests';
}

use PDL::DSP::Windows;
use File::Temp;

sub do_test {
    my ( $win, $checks ) = @_;

    no strict 'refs';
    no warnings 'redefine';

    my $temp = File::Temp->new('PDL-DSP-Windows-plot-XXXXXXX');

    my $plot = PDL::Graphics::Gnuplot->can('plot');
    local *{'PDL::Graphics::Gnuplot::plot'} = sub {
        $plot->( @_, { device => $temp->filename . '/latex' } );
    };

    $win->plot;

    my $svg = do { local $/; <$temp> };

    like $svg, $checks->{$_}, $win->get_name . ": $_" for keys %{$checks};
}

subtest plot => sub {
    do_test( PDL::DSP::Windows->new(10), {
        title   => qr/Hamming window/,
        x_label => qr/Time \(samples\)/,
        y_label => qr/amplitude/,
    });

    do_test( PDL::DSP::Windows->new( 10, 'blackman_gen3', [1, 2, 3] ), {
        title => qr/Blackman family. : a0 = 1, a1 = 2, a2 = 3/,
    });
};

done_testing;
