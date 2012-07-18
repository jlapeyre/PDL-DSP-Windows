#!/usr/bin/env perl

use strict;
use warnings;

use PDL;
use PDL::DSP::Windows;

my $win = new PDL::DSP::Windows(50,'hamming');
$win->plot;
$win->plot_freq;
