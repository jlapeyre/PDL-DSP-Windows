use Test::More;

use PDL::DSP::Windows;

subtest winpersubs => sub {
    for ( keys %PDL::DSP::Windows::winpersubs ) {
        ok +PDL::DSP::Windows->can("${_}_per"),
            "$_ points to defined periodic window";

        is ref $PDL::DSP::Windows::winsubs{$_}, 'CODE',
            "$_ is mapped to coderef";

        ok exists $PDL::DSP::Windows::window_definitions{$_},
            "$_ has defined metadata";
    }
};

subtest winsubs => sub {
    for ( keys %PDL::DSP::Windows::winsubs ) {
        ok +PDL::DSP::Windows->can($_),
            "$_ points to defined symmetric window";

        is ref $PDL::DSP::Windows::winsubs{$_}, 'CODE',
            "$_ is mapped to coderef";

        ok exists $PDL::DSP::Windows::window_definitions{$_},
            "$_ has defined metadata";
    }
};

subtest window_definitions => sub {
    for ( keys %PDL::DSP::Windows::window_definitions ) {
        ok +PDL::DSP::Windows->can($_),
            "$_ points to defined window";

        ok exists $PDL::DSP::Windows::winsubs{$_},
            "$_ window is in symmetric map";

        next unless PDL::DSP::Windows->can("${_}_per");

        ok exists $PDL::DSP::Windows::winpersubs{$_},
            "$_ window is in periodic map";
    }
};

done_testing;
