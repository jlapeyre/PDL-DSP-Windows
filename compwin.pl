#!/usr/bin/perl
use warnings; use strict;

# compare window functions between 
# PDL::Audio and PDL::DSP::Windows

use PDL;
use PDL::Audio qw( gen_fft_window );
use PDL::DSP::Windows qw( window );

my $N = 5;

foreach my $name ( ['hamming', 'hamming_ex'], 'hann', 'welch', 'bartlett' ){
    my ($name_aud, $name_dsp);
    if (ref($name)) {
        ($name_aud, $name_dsp) = @$name;
    }
    else {
        $name_aud = $name_dsp  = $name;
    }
    print "Name: $name_aud $name_dsp\n";

    my $w = gen_fft_window($N,$name_aud);
    print 'aud: ';
    print $w->nelem, ': ', $w, "\n";

    $w = window($N,$name_dsp, {per => 1});
    print 'dsp: ';
    print $w->nelem, ': ', $w, "\n";
}
