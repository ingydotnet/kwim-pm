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
    ($parser->grammar->tree);
    str $parser->parse($kwim);
}

__DATA__

%TestML 0.1.0

Title = "Ingy's Test";
# Plan = 4;

Label = 'Kwim to ByteCode - $BlockLabel'
*kwim.parse('Byte') == *byte
Label = 'Kwim to HTML - $BlockLabel'
*kwim.parse('HTML') == *html

=== Title and Paragraph
--- kwim
My Title
\========

O HAI
FREND
--- byte
+title
 My Title
-title
+para
 O HAI\nFREND
-para
--- html
<h1 class="title">
My Title
</h1>
<p>
O HAI
FREND
</p>

=== Line Comment
--- kwim
\# This is a comment line.
\# Another. Eat next blank line.

Paragraph text.
--- byte
+comment
 This is a comment line.
-comment
+comment
 Another. Eat next blank line.
-comment
+para
 Paragraph text.
-para
--- html
<!-- This is a comment line. -->
<!-- Another. Eat next blank line. -->
<p>
Paragraph text.
</p>

=== Block Comment
--- kwim
\###

Comment line 1


  Comment line 2

\###

Paragraph
--- byte
+comment
 \nComment line 1\n\n\n  Comment line 2\n
-comment
+para
 Paragraph
-para
--- html
<!--

Comment line 1


  Comment line 2


-->
<p>
Paragraph
</p>

=== Bold Phrase
--- kwim
I *like* pie.
--- byte
+para
 I 
+bold
 like
-bold
  pie.
-para
--- html
<p>
I <b>like</b> pie.
</p>

=== Bold Code Phrase
--- kwim
I like *`pi`*.
--- byte
+para
 I like 
+bold
+code
 pi
-code
-bold
 .
-para
--- html
<p>
I like <b><tt>pi</tt></b>.
</p>

=== Headers
--- kwim
== Level 2 Header ==
Paragraph text.

\=== Level 3 Header
Multi Line

Paragraph text

\==== Level 4 Header
  preformatted text
--- byte
+head2
 Level 2 Header
-head2
+para
 Paragraph text.
-para
+head3
 Level 3 Header\nMulti Line
-head3
+para
 Paragraph text
-para
+head4
 Level 4 Header
-head4
+pref
 preformatted text
-pref

--- html
<h2>Level 2 Header</h2>
<p>
Paragraph text.
</p>
<h3>Level 3 Header Multi Line</h3>
<p>
Paragraph text
</p>
<h4>Level 4 Header</h4>
<pre>
preformatted text
</pre>
