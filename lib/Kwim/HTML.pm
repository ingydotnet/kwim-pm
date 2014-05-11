use strict;
package Kwim::HTML;
use base 'Kwim::Markup';
use XXX -with => 'YAML::XS';

use HTML::Escape;

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
    my $spacer = '';
    if ($out =~ /\n/) {
        $spacer = "\n";
    }
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
    my $spacer = '';
    if ($out =~ /\A</) {
        $spacer = "\n";
    }
    "<li>$spacer$out$spacer</li>\n";
}

sub render_pref {
    my ($self, $node) = @_;
    my $out = $self->render($node);
    "<pre>$out\n</pre>\n";
}

sub render_title {
    my ($self, $node) = @_;
    my $out = $self->render($node);
    chomp $out;
    "<h1 class=\"title\">\n$out\n</h1>\n";
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

sub render_code {
    my ($self, $node) = @_;
    my $out = $self->render($node);
    "<code>$out</code>";
}

sub render_hyper {
    my ($self, $node) = @_;
    my ($link, $text) = @{$node}{qw(link text)};
    $text = $link if not length $text;
    "<a href=\"$link\">$text</a>";
}

1;
