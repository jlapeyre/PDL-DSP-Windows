use 5.008;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'PDL::DSP::Windows',
    AUTHOR              => q{John Lapeyre <jlapeyre@cpan.org>},
    VERSION_FROM        => 'lib/PDL/DSP/mkwindows.pl',
    ABSTRACT_FROM       => 'lib/PDL/DSP/mkwindows.pl',
    LICENSE=> 'perl',
    PL_FILES            => {},
    PM => {
        'lib/PDL/DSP/Windows.pm' => '$(INST_LIBDIR)/Windows.pm'
    },
    PREREQ_PM => {
        'Test::More' => 0,
        'PDL' => 0
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'PDL-DSP-Windows-* lib/PDL/DSP/Windows.pm' },
);

sub MY::postamble {
    '

lib/PDL/DSP/Windows.pm:
	cd lib/PDL/DSP && $(PERL) ./mkwindows.pl
'    
};
 
# reroute the main POD into a separate README.pod if requested. This is here
# purely to generate a README.pod for the github front page
my $POD_header = <<EOF;
PDL-DSP-Windows is Copyright (C) 2012, John Lapeyre.

=head1 OVERVIEW

A module for PDL providing window functions for signal processing.
This module is currently not on CPAN.

=cut

EOF

if(exists $ARGV[0] && $ARGV[0] eq 'README.pod')
{
  open MOD, 'lib/PDL/DSP/Windows.pm' or die "Couldn't open main module";
  open README, '>README.pod'              or die "Couldn't open README.pod";

  print README $POD_header;

  while (<MOD>)
  {
    if (/^=/../^=cut/)
    { print README; }
  }
}
