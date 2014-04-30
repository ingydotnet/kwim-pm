use lib '../pegex-pm/lib';
use lib '../testml-pm/lib';

use TestML;

TestML->new(
    testml => join('', <DATA>),
    bridge => 'main',
)->run;

use base 'TestML::Bridge';
use TestML::Util;
use Kwim::Grammar;
use Kwim::Byte;
use Kwim::HTML;
use XXX;

sub parse {
    my ($self, $kwim, $emitter) = @_;
    # local $ENV{PERL_PEGEX_DEBUG} = 1;
    $kwim = $kwim->{value};
    $kwim =~ s/^\\//gm;
    $emitter = $emitter->{value};
    my $parser = Pegex::Parser->new(
        grammar => 'Kwim::Grammar'->new,
        receiver => "Kwim::$emitter"->new,
        # debug => 1,
    );
    # XXX($parser->grammar->tree);
    str $parser->parse($kwim);
}

__DATA__

%TestML 0.1.0

# Diff = 1
# Plan = 4

Label = 'Kwim to ByteCode - $BlockLabel'
*kwim.parse('Byte') == *byte
Label = 'Kwim to HTML - $BlockLabel'
*kwim.parse('HTML') == *html

%Include comment.tml
%Include para.tml
%Include list.tml
%Include head.tml
%Include phrase.tml
