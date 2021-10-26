# NAME

PDL::DSP::Windows - Window functions for signal processing

# SYNOPSIS

    use PDL;
    use PDL::DSP::Windows('window');
    my $samples = window( 10, 'tukey', { params => .5 });

    use PDL;
    use PDL::DSP::Windows;
    my $win = PDL::DSP::Windows->new( 10, 'tukey', { params => .5 });
    print $win->coherent_gain, "\n";
    $win->plot;

# DESCRIPTION

This module provides symmetric and periodic (DFT-symmetric) window functions
for use in filtering and spectral analysis. It provides a high-level access
subroutine ["window"](#window). This functional interface is sufficient for getting
the window samples. For analysis and plotting, etc. an object oriented
interface is provided. The functional subroutines must be either explicitly
exported, or fully qualified. In this document, the word _function_ refers
only to the mathematical window functions, while the word _subroutine_ is
used to describe code.

Window functions are also known as apodization functions or tapering functions.
In this module, each of these functions maps a sequence of `$N` integers to
values called a **samples**. (To confuse matters, the word _sample_ also has
other meanings when describing window functions.) The functions are often
named for authors of journal articles. Be aware that across the literature
and software, some functions referred to by several different names, and some
names refer to several different functions. As a result, the choice of window
names is somewhat arbitrary.

The ["kaiser($N,$beta)"](#kaiser-n-beta) window function requires [PDL::GSLSF::BESSEL](https://metacpan.org/pod/PDL%3A%3AGSLSF%3A%3ABESSEL). The
["dpss($N,$beta)"](#dpss-n-beta) window function requires [PDL::LinearAlgebra](https://metacpan.org/pod/PDL%3A%3ALinearAlgebra). But the
remaining window functions may be used if these modules are not installed.

The most common and easiest usage of this module is indirect, via some
higher-level filtering interface, such as [PDL::DSP::Fir::Simple](https://metacpan.org/pod/PDL%3A%3ADSP%3A%3AFir%3A%3ASimple). The next
easiest usage is to return a pdl of real-space samples with the subroutine
["window"](#window). Finally, for analyzing window functions, object methods, such as
["new"](#new), ["plot"](#plot), ["plot\_freq"](#plot_freq) are provided.

In the following, first the functional interface (non-object oriented) is
described in ["'FUNCTIONAL INTERFACE'"](#functional-interface). Next, the object methods are
described in ["METHODS"](#methods). Next the low-level subroutines returning samples
for each named window are described in  ["'WINDOW FUNCTIONS'"](#window-functions). Finally, some
support routines that may be of interest are described in
["'AUXILIARY SUBROUTINES'"](#auxiliary-subroutines).

# FUNCTIONAL INTERFACE

## window

    $win = window({ OPTIONS });
    $win = window( $N, { OPTIONS });
    $win = window( $N, $name, { OPTIONS });
    $win = window( $N, $name, $params, { OPTIONS });
    $win = window( $N, $name, $params, $periodic );

Returns an `$N` point window of type `$name`. The arguments may be passed
positionally in the order `$N, $name, $params, $periodic`, or they may be
passed by name in the hash `OPTIONS`.

### EXAMPLES

    # Each of the following return a 100 point symmetric hamming window.

    $win = window(100);
    $win = window( 100, 'hamming' );
    $win = window( 100, { name => 'hamming' });
    $win = window({ N => 100, name => 'hamming' });

    # Each of the following returns a 100 point symmetric hann window.

    $win = window( 100, 'hann' );
    $win = window( 100, { name => 'hann' });

    # Returns a 100 point periodic hann window.

    $win = window( 100, 'hann', { periodic => 1 });

    # Returns a 100 point symmetric Kaiser window with alpha = 2.

    $win = window( 100, 'kaiser', { params => 2 });

### OPTIONS

The options follow default PDL::Options rules. They may be abbreviated, and
are case-insensitive.

- **name**

    (string) name of window function. Default: `hamming`. This selects one of
    the window functions listed below. Note that the suffix '\_per', for periodic,
    may be ommitted. It is specified with the option `periodic => 1`

- **params**

    ref to array of parameter or parameters for the  window-function subroutine.
    Only some window-function subroutines take parameters. If the subroutine takes
    a single parameter, it may be given either as a number, or a list of one
    number. For example `3` or `[3]`.

- **N**

    number of points in window function (the same as the order of the filter).
    No default value.

- **periodic**

    If value is true, return a periodic rather than a symmetric window function.
    Defaults to false, meaning "symmetric".

## list\_windows

    list_windows
    list_windows STR

`list_windows` prints the names all of the available windows.
`list_windows STR` prints only the names of windows matching the string `STR`.

# METHODS

## new

    my $win = PDL::DSP::Windows->new(ARGS);

Create an instance of a Windows object. If `ARGS` are given, the instance
is initialized. `ARGS` are interpreted in exactly the same way as arguments
the subroutine ["window"](#window).

For example:

    my $win1 = PDL::DSP::Windows->new( 8, 'hann' );
    my $win2 = PDL::DSP::Windows->new({ N => 8, name => 'hann' });

## init

    $win->init(ARGS);

Initialize (or reinitialize) a Windows object. `ARGS` are interpreted in
exactly the same way as arguments the subroutine ["window"](#window).

For example:

    my $win = PDL::DSP::Windows->new( 8, 'hann' );
    $win->init( 10, 'hamming' );

## samples

    $win->samples;

Generate and return a reference to the piddle of `$N` samples for the window
`$win`. This is the real-space representation of the window.

The samples are stored in the object `$win`, but are regenerated every time
`samples` is invoked. See the method ["get\_samples"](#get_samples) below.

For example:

    my $win = PDL::DSP::Windows->new( 8, 'hann' );
    print $win->samples, "\n";

## modfreqs

    $win->modfreqs;

Generate and return a reference to the piddle of the modulus of the fourier
transform of the samples for the window `$win`.

These values are stored in the object `$win`, but are regenerated every time
`modfreqs` is invoked. See the method ["get\_modfreqs"](#get_modfreqs) below.

### options

- min\_bins => MIN

    This sets the minimum number of frequency bins. Defaults to 1000. If necessary,
    the piddle of window samples are padded with zeroes before the fourier transform
    is performed.

## get

    my $windata = $win->get('samples');

Get an attribute (or list of attributes) of the window `$win`. If attribute
`samples` is requested, then the samples are created with the method
["samples"](#samples) if they don't exist.

For example:

    my $win = PDL::DSP::Windows->new( 8, 'hann' );
    print $win->get('samples'), "\n";

## get\_samples

    my $windata = $win->get_samples;

Return a reference to the pdl of samples for the Window instance `$win`. The
samples will be generated with the method ["samples"](#samples) if and only if they have
not yet been generated.

## get\_modfreqs

    my $winfreqs = $win->get_modfreqs;
    my $winfreqs = $win->get_modfreqs(OPTS);

Return a reference to the pdl of the frequency response (modulus of the DFT)
for the Window instance `$win`.

Options passed as a hash reference will be passed to the ["modfreqs"](#modfreqs). The
data are created with ["modfreqs"](#modfreqs) if they don't exist. The data are also
created even if they already exist if options are supplied. Otherwise the
cached data are returned.

### options

- min\_bins => MIN

    This sets the minimum number of frequency bins. See ["modfreqs"](#modfreqs). Defaults
    to 1000.

## get\_params

    my $params = $win->get_params;

Create a new array containing the parameter values for the instance `$win`
and return a reference to the array. Note that not all window types take
parameters.

## get\_name

    print  $win->get_name, "\n";

Return a name suitable for printing associated with the window `$win`. This is
something like the name used in the documentation for the particular window
function. This is static data and does not depend on the instance.

## plot

    $win->plot;

Plot the samples. Currently, only [PDL::Graphics::Gnuplot](https://metacpan.org/pod/PDL%3A%3AGraphics%3A%3AGnuplot) is supported. The
default display type is used.

## plot\_freq

Can be called like this

    $win->plot_freq;

Or this

    $win->plot_freq({ ordinate => ORDINATE });

Plot the frequency response (magnitude of the DFT of the window samples).
The response is plotted in dB, and the frequency (by default) as a fraction of
the Nyquist frequency. Currently, only [PDL::Graphics::Gnuplot](https://metacpan.org/pod/PDL%3A%3AGraphics%3A%3AGnuplot) is supported.
The default display type is used.

### options

- coord => COORD

    This sets the units of frequency of the co-ordinate axis. `COORD` must be one
    of `nyquist`, for fraction of the nyquist frequency (range `-1, 1`);
    `sample`, for fraction of the sampling frequncy (range `-0.5, 0.5`); or
    `bin` for frequency bin number (range `0, $N - 1`). The default value is
    `nyquist`.

- min\_bins => MIN

    This sets the minimum number of frequency bins. See ["get\_modfreqs"](#get_modfreqs).
    Defaults to 1000.

## enbw

    $win->enbw;

Compute and return the equivalent noise bandwidth of the window.

## coherent\_gain

    $win->coherent_gain;

Compute and return the coherent gain (the dc gain) of the window. This is just
the average of the samples.

## process\_gain

    $win->coherent_gain;

Compute and return the processing gain (the dc gain) of the window. This is
just the multiplicative inverse of the `enbw`.

## scallop\_loss

    $win->scallop_loss;

\*\*BROKEN\*\*.
Compute and return the scalloping loss of the window.

# WINDOW FUNCTIONS

These window-function subroutines return a pdl of `$N` samples. For most
windows, there are a symmetric and a periodic version. The symmetric versions
are functions of `$N` points, uniformly spaced, and taking values from x\_lo
through x\_hi. Here, a periodic function of ` $N ` points is equivalent to its
symmetric counterpart of `$N + 1` points, with the final point omitted. The
name of a periodic window-function subroutine is the same as that for the
corresponding symmetric function, except it has the suffix `_per`. The
descriptions below describe the symmetric version of each window.

The term 'Blackman-Harris family' is meant to include the Hamming family and
the Blackman family. These are functions of sums of cosines.

Unless otherwise noted, the arguments in the cosines of all symmetric window
functions are multiples of `$N` numbers uniformly spaced from `0` through
`2 pi`.

# Symmetric window functions

## bartlett($N)

The Bartlett window. (Ref 1). Another name for this window is the fejer window.
This window is defined by

    1 - abs(arr)

where the points in arr range from -1 through 1. See also
[triangular](#triangular-n).

## bartlett\_hann($N)

The Bartlett-Hann window. Another name for this window is the Modified
Bartlett-Hann window. This window is defined by

    0.62 - 0.48 * abs(arr) + 0.38 * arr1

where the points in arr range from -1/2 through 1/2, and arr1 are the cos of
points ranging from -PI through PI.

## blackman($N)

The 'classic' Blackman window. (Ref 1). One of the Blackman-Harris family, with coefficients

    a0 = 0.42
    a1 = 0.5
    a2 = 0.08

## blackman\_bnh($N)

The Blackman-Harris (bnh) window. An improved version of the 3-term
Blackman-Harris window given by Nuttall (Ref 2, p. 89). One of the
Blackman-Harris family, with coefficients

    a0 = 0.4243801
    a1 = 0.4973406
    a2 = 0.0782793

## blackman\_ex($N)

The 'exact' Blackman window. (Ref 1). One of the Blackman-Harris family, with
coefficients

    a0 = 0.426590713671539
    a1 = 0.496560619088564
    a2 = 0.0768486672398968

## blackman\_gen($N,$alpha)

The General classic Blackman window. A single parameter family of the 3-term
Blackman window. This window is defined by

    my $cx = arr;
    .5 - $alpha + ($cx * (-.5 + $cx * $alpha));

where the points in arr are the cos of points ranging from 0 through 2PI.

## blackman\_gen3($N,$a0,$a1,$a2)

The general form of the Blackman family. One of the Blackman-Harris family,
with coefficients

    a0 = $a0
    a1 = $a1
    a2 = $a2

## blackman\_gen4($N,$a0,$a1,$a2,$a3)

The general 4-term Blackman-Harris window. One of the Blackman-Harris family,
with coefficients

    a0 = $a0
    a1 = $a1
    a2 = $a2
    a3 = $a3

## blackman\_gen5($N,$a0,$a1,$a2,$a3,$a4)

The general 5-term Blackman-Harris window. One of the Blackman-Harris family,
with coefficients

    a0 = $a0
    a1 = $a1
    a2 = $a2
    a3 = $a3
    a4 = $a4

## blackman\_harris($N)

The Blackman-Harris window. (Ref 1). One of the Blackman-Harris family, with
coefficients

    a0 = 0.422323
    a1 = 0.49755
    a2 = 0.07922

Another name for this window is the Minimum three term (sample) Blackman-Harris
window.

## blackman\_harris4($N)

The minimum (sidelobe) four term Blackman-Harris window. (Ref 1). One of the
Blackman-Harris family, with coefficients

    a0 = 0.35875
    a1 = 0.48829
    a2 = 0.14128a3 = 0.01168

Another name for this window is the Blackman-Harris window.

## blackman\_nuttall($N)

The Blackman-Nuttall window. One of the Blackman-Harris family, with
coefficients

    a0 = 0.3635819
    a1 = 0.4891775
    a2 = 0.1365995
    a3 = 0.0106411

## bohman($N)

The Bohman window. (Ref 1). This window is defined by

    my $x = abs(arr);
    (1 - $x) * cos(PI * $x) + (1 / PI) * sin(PI * $x)

where the points in arr range from -1 through 1.

## cauchy($N,$alpha)

The Cauchy window. (Ref 1). Other names for this window are: Abel, Poisson.
This window is defined by

    1 / (1 + (arr * $alpha) ** 2)

where the points in arr range from -1 through 1.

## chebyshev($N,$at)

The Chebyshev window. The frequency response of this window has `$at` dB of
attenuation in the stop-band. Another name for this window is the
Dolph-Chebyshev window. No periodic version of this window is defined. This
routine gives the same result as the routine **chebwin** in Octave 3.6.2.

## cos\_alpha($N,$alpha)

The Cos\_alpha window. (Ref 1). Another name for this window is the
Power-of-cosine window. This window is defined by

    arr ** $alpha

where the points in arr are the sin of points ranging from 0 through PI.

## cosine($N)

The Cosine window. Another name for this window is the sine window. This
window is defined by

    arr

where the points in arr are the sin of points ranging from 0 through PI.

## dpss($N,$beta)

The Digital Prolate Spheroidal Sequence (DPSS) window. The parameter `$beta`
is the half-width of the mainlobe, measured in frequency bins. This window
maximizes the power in the mainlobe for given `$N` and `$beta`. Another
name for this window is the sleppian window.

## exponential($N)

The Exponential window. This window is defined by

    2 ** (1 - abs arr) - 1

where the points in arr range from -1 through 1.

## flattop($N)

The flat top window. One of the Blackman-Harris family, with coefficients

    a0 = 0.21557895
    a1 = 0.41663158
    a2 = 0.277263158
    a3 = 0.083578947
    a4 = 0.006947368

## gaussian($N,$beta)

The Gaussian window. (Ref 1). Another name for this window is the Weierstrass
window. This window is defined by

    exp (-0.5 * ($beta * arr )**2),

where the points in arr range from -1 through 1.

## hamming($N)

The Hamming window. (Ref 1). One of the Blackman-Harris family, with
coefficients

    a0 = 0.54
    a1 = 0.46

## hamming\_ex($N)

The 'exact' Hamming window. (Ref 1). One of the Blackman-Harris family, with
coefficients

    a0 = 0.53836
    a1 = 0.46164

## hamming\_gen($N,$a)

The general Hamming window. (Ref 1). One of the Blackman-Harris family, with
coefficients

    a0 = $a
    a1 = (1-$a)

## hann($N)

The Hann window. (Ref 1). One of the Blackman-Harris family, with coefficients

    a0 = 0.5
    a1 = 0.5

Another name for this window is the hanning window. See also
[hann\_matlab](#hann_matlab-n).

## hann\_matlab($N)

The Hann (matlab) window. Equivalent to the Hann window of N+2 points, with the
endpoints (which are both zero) removed. No periodic version of this window is
defined. This window is defined by

    0.5 - 0.5 * arr

where the points in arr are the cosine of points ranging from 2PI/($N+1)
through 2PI\*$N/($N+1). This routine gives the same result as the routine
**hanning** in Matlab. See also [hann](#hann-n).

## hann\_poisson($N,$alpha)

The Hann-Poisson window. (Ref 1). This window is defined by

    0.5 * (1 + arr1) * exp (-$alpha * abs arr)

where the points in arr range from -1 through 1, and arr1 are the cos of points
ranging from -PI through PI.

## kaiser($N,$beta)

The Kaiser window. (Ref 1). The parameter `$beta` is the approximate
half-width of the mainlobe, measured in frequency bins. Another name for this
window is the Kaiser-Bessel window. This window is defined by

    $beta *= PI;
    my @n = gsl_sf_bessel_In($beta * sqrt(1 - arr ** 2), 0);
    my @d = gsl_sf_bessel_In($beta, 0);
    $n[0] / $d[0];

where the points in arr range from -1 through 1.

## lanczos($N)

The Lanczos window. Another name for this window is the sinc window. This
window is defined by

    my $x = PI * arr;
    my $res = sin($x) / $x;
    my $mid;
    $mid = int($N / 2), $res->slice($mid) .= 1 if $N % 2;
    $res;

where the points in arr range from -1 through 1.

## nuttall($N)

The Nuttall window. One of the Blackman-Harris family, with coefficients

    a0 = 0.3635819
    a1 = 0.4891775
    a2 = 0.1365995
    a3 = 0.0106411

See also [nuttall1](#nuttall1-n).

## nuttall1($N)

The Nuttall (v1) window. A window referred to as the Nuttall window. One of the
Blackman-Harris family, with coefficients

    a0 = 0.355768
    a1 = 0.487396
    a2 = 0.144232
    a3 = 0.012604

This routine gives the same result as the routine **nuttallwin** in Octave 3.6.2.
See also [nuttall](#nuttall-n).

## parzen($N)

The Parzen window. (Ref 1). Other names for this window are: Jackson,
Valle-Poussin. This function disagrees with the Octave subroutine **parzenwin**,
but agrees with Ref. 1. See also [parzen\_octave](#parzen_octave-n).

## parzen\_octave($N)

The Parzen window. No periodic version of this window is defined. This routine
gives the same result as the routine **parzenwin** in Octave 3.6.2. See also
[parzen](#parzen-n).

## poisson($N,$alpha)

The Poisson window. (Ref 1). This window is defined by

    exp(-$alpha * abs(arr))

where the points in arr range from -1 through 1.

## rectangular($N)

The Rectangular window. (Ref 1). Other names for this window are: dirichlet,
boxcar.

## triangular($N)

The Triangular window. This window is defined by

    1 - abs(arr)

where the points in arr range from -$N/($N-1) through $N/($N-1).
See also [bartlett](#bartlett-n).

## tukey($N,$alpha)

The Tukey window. (Ref 1). Another name for this window is the tapered cosine
window.

## welch($N)

The Welch window. (Ref 1). Other names for this window are: Riez, Bochner,
Parzen, parabolic. This window is defined by

    1 - arr**2

where the points in arr range from -1 through 1.

# AUXILIARY SUBROUTINES

These subroutines are used internally, but are also available for export.

## cos\_mult\_to\_pow

Convert Blackman-Harris coefficients. The BH windows are usually defined via
coefficients for cosines of integer multiples of an argument. The same windows
may be written instead as terms of powers of cosines of the same argument.
These may be computed faster as they replace evaluation of cosines with
multiplications. This subroutine is used internally to implement the
Blackman-Harris family of windows more efficiently.

This subroutine takes between 1 and 7 numeric arguments  a0, a1, ...

It converts the coefficients of this

    a0 - a1 cos(arg) + a2 cos(2 * arg) - a3 cos(3 * arg)  + ...

To the cofficients of this

    c0 + c1 cos(arg) + c2 cos(arg)**2 + c3 cos(arg)**3  + ...

## cos\_pow\_to\_mult

This function is the inverse of ["cos\_mult\_to\_pow"](#cos_mult_to_pow).

This subroutine takes between 1 and 7 numeric arguments  c0, c1, ...

It converts the coefficients of this

    c0 + c1 cos(arg) + c2 cos(arg)**2 + c3 cos(arg)**3  + ...

To the cofficients of this

    a0 - a1 cos(arg) + a2 cos( 2 * arg) - a3 cos( 3 * arg)  + ...

## chebpoly

    chebpoly($n,$x)

Returns the value of the `$n`-th order Chebyshev polynomial at point `$x`.
$n and $x may be scalar numbers, pdl's, or array refs. However, at least one
of $n and $x must be a scalar number.

All mixtures of pdls and scalars could be handled much more easily as a PP
routine. But, at this point PDL::DSP::Windows is pure perl/pdl, requiring no
C/Fortran compiler.

# REFERENCES

1. Harris, F.J. `On the use of windows for harmonic analysis with the discrete
Fourier transform`, _Proceedings of the IEEE_, 1978, vol 66, pp 51-83.
2. Nuttall, A.H. `Some windows with very good sidelobe behavior`, _IEEE
Transactions on Acoustics, Speech, Signal Processing_, 1981, vol. ASSP-29,
pp. 84-91.

# AUTHOR

John Lapeyre, `<jlapeyre at cpan.org>`

# MAINTAINER

José Joaquín Atria, `<jjatria at cpan.org>`

# ACKNOWLEDGMENTS

For study and comparison, the author used documents or output from: Thomas
Cokelaer's spectral analysis software; Julius O Smith III's Spectral Audio
Signal Processing web pages; André Carezia's chebwin.m Octave code; Other code
in the Octave signal package.

# LICENSE AND COPYRIGHT

Copyright 2012-2021 John Lapeyre.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

This software is neither licensed nor distributed by The MathWorks, Inc.,
maker and liscensor of MATLAB.
