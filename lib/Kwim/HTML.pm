use strict;
package Kwim::HTML;
use base 'Kwim::Tree';

use HTML::Escape;

use XXX -with => 'YAML::XS';

my $info = {
    title => {
        tag => 'h1',
        style => 'block',
        attrs => ' class="title"',
    },
    head1 => {
        tag => 'h1',
        style => 'block-line',
        transform => 'transform_head',
    },
    head2 => {
        tag => 'h2',
        style => 'block-line',
        transform => 'transform_head',
    },
    head3 => {
        tag => 'h3',
        style => 'block-line',
        transform => 'transform_head',
    },
    head4 => {
        tag => 'h4',
        style => 'block-line',
        transform => 'transform_head',
    },
    pref => {
        tag => 'pre',
        style => 'block',
    },
    comment => {
        render => 'render_comment',
    },
    para => {
        tag => 'p',
        style => 'block',
    },
    verse => {
        tag => 'p',
        style => 'block',
        transform => 'transform_verse',
        attrs => ' class="verse"',
    },
    bold => {
        tag => 'b',
        style => 'phrase',
    },
    emph => {
        tag => 'i',
        style => 'phrase',
    },
    code => {
        tag => 'tt',
        style => 'phrase',
    },
};

sub final {
    my ($self, $tree) = @_;
    $self->render($tree);
}

sub render_tag {
    my ($self, $hash) = @_;
    my ($name, $node) = each %$hash;
    my $info = $info->{$name}
        or die "Unknown content name: $name";
    my ($tag, $style, $transform, $attrs);
    if (ref $info) {
        if (my $method = $info->{render}) {
            return $self->$method($node);
        }
        $tag = $info->{tag};
        $style = $info->{style};
        $transform = $info->{transform};
        $attrs = $info->{attrs};
    }
    if ($transform) {
        $node = $self->$transform($node);
    }
    if ($style eq 'block') {
        "<$tag$attrs>\n" . $self->render($node) . "\n</$tag>\n";
    }
    elsif ($style eq 'block-line') {
        "<$tag$attrs>" . $self->render($node) . "</$tag>\n";
    }
    elsif ($style eq 'phrase') {
        "<$tag$attrs>" . $self->render($node) . "</$tag>";
    }
    else {
        die;
    }
}

sub render_text {
    my ($self, $text) = @_;
    chomp $text;
    escape_html($text);
}

sub transform_verse {
    my ($self, $text) = @_;
    $text = $text->[0];
    chomp $text;
    $text = escape_html($text);
    $text =~ s/(\s{2,})/'&nbsp;' x length($1)/ge;
    $text =~ s{\n}{<br/>\n}g;
    return $text;
}

sub transform_head {
    my ($self, $text) = @_;
    chomp $text;
    $text = escape_html($text);
    $text =~ s/\n/ /g;
    return $text;
}

sub render_comment {
    my ($self, $text) = @_;
    $text = escape_html($text);
    if ($text =~ /\n/) {
        "<!--\n$text\n-->\n";
    }
    else {
        "<!-- $text -->\n";
    }
}

1;
