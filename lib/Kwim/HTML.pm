use strict;
package Kwim::HTML;
use base 'Kwim::Markup';
use XXX -with => 'YAML::XS';

use HTML::Escape;

use constant top_block_separator => "\n";

my $document_title = '';
my $info = {
    verse => {
        tag => 'p',
        style => 'block',
        transform => 'transform_verse',
        attrs => ' class="verse"',
    },
};

sub render_text {
    my ($self, $text) = @_;
    chomp $text;
    $text =~ s/\n/ /g;
    escape_html($text);
}

sub render_para {
    my ($self, $node) = @_;
    my $out = $self->render($node);
    chomp $out;
    my $spacer = $out =~ /\n/ ? "\n" : '';
    "<p>$spacer$out$spacer</p>\n";
}

sub render_blank {
    "<br/>\n";
}

sub render_list {
    my ($self, $node) = @_;
    my $out = $self->render($node);
    chomp $out;
    "<ul>\n$out\n</ul>\n";
}

sub render_item {
    my ($self, $node) = @_;
    my $out = $self->render($node);
    $out =~ s/(.)(<(?:ul|pre|p)(?: |>))/$1\n$2/;
    my $spacer = $out =~ /\n/ ? "\n" : '';
    "<li>$out$spacer</li>\n";
}

sub render_pref {
    my ($self, $node) = @_;
    my $out = escape_html($node);
    "<pre><code>$out\n</code></pre>\n";
}

sub render_title {
    my ($self, $node) = @_;
    my $out = $self->render($node);
    chomp $out;
    my ($name, $text) = ref $node ? @$node : (undef, $node);
    if (defined $text) {
        $document_title = "$name - $text";
        "<h1 class=\"title\">$name</h1>\n\n<p>$text</p>\n";
    }
    else {
        $document_title = "$name";
        my $spacer = $name =~ /\n/ ? "\n" : '';
        "<h1 class=\"title\">$spacer$name$spacer</h1>\n";
    }
}

sub render_head {
    my ($self, $node, $number) = @_;
    my $out = $self->render($node);
    chomp $out;
    "<h$number>$out</h$number>\n";
}

sub render_comment {
    my ($self, $node) = @_;
    my $out = escape_html($node);
    if ($out =~ /\n/) {
        "<!--\n$out\n-->\n";
    }
    else {
        "<!-- $out -->\n";
    }
}

sub render_code {
    my ($self, $node) = @_;
    my $out = $self->render($node);
    "<code>$out</code>";
}

sub render_bold {
    my ($self, $node) = @_;
    my $out = $self->render($node);
    "<strong>$out</strong>";
}

sub render_emph {
    my ($self, $node) = @_;
    my $out = $self->render($node);
    "<em>$out</em>";
}

sub render_del {
    my ($self, $node) = @_;
    my $out = $self->render($node);
    "<del>$out</del>";
}

sub render_hyper {
    my ($self, $node) = @_;
    my ($link, $text) = @{$node}{qw(link text)};
    $text = $link if not length $text;
    "<a href=\"$link\">$text</a>";
}

sub render_link {
    my ($self, $node) = @_;
    my ($link, $text) = @{$node}{qw(link text)};
    $text = $link if not length $text;
    "<a href=\"$link\">$text</a>";
}

sub render_complete {
    my ($self, $out) = @_;
    chomp $out;
    <<"..."
<!DOCTYPE html>
<html>
<head>
  <meta http-equiv="content-type" content="text/html;charset=UTF-8" />
  <title>$document_title</title>
  <link href="//kwim.org/assets/default.css" rel="stylesheet" type="text/css">
</head>
<body>
<div class="kwim content">

$out

</div>
</body>
</html>
...
}

1;
