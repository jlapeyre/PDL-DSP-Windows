use 5.008;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'PDL::DSP::Windows',
    AUTHOR              => q{John Lapeyre <jlapeyre@cpan.org>},
    VERSION_FROM        => 'lib/PDL/DSP/mkwindows.pl',
#    ABSTRACT_FROM       => 'lib/PDL/DSP/Windows.pm',
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
