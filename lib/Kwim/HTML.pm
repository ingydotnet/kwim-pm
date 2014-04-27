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
        style => 'pref',
    },
    comment => {
        render => 'render_comment',
    },
    list => {
        tag => 'ul',
        style => 'block',
    },
    item => {
        tag => 'li',
        style => 'item',
    },
    para => {
        tag => 'p',
        style => 'para',
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
        my $inside = $self->render($node);
        chomp $inside;
        "<$tag$attrs>\n$inside\n</$tag>\n";
    }
    elsif ($style eq 'para') {
        my $inside = $self->render($node);
        chomp $inside;
        my $spacer = '';
        if ($inside =~ /\n/) {
            $spacer = "\n";
        }
        "<$tag$attrs>$spacer$inside$spacer</$tag>\n";
    }
    elsif ($style eq 'block-line') {
        "<$tag$attrs>" . $self->render($node) . "</$tag>\n";
    }
    elsif ($style eq 'item') {
        my $inside = $self->render($node);
        $inside =~ s/(.)(<(?:ul|pre|p)(?: |>))/$1\n$2/;
        my $spacer = '';
        if ($inside =~ /\A</) {
            $spacer = "\n";
        }
        "<$tag$attrs>$spacer$inside$spacer</$tag>\n";
    }
    elsif ($style eq 'pref') {
        chomp $node;
        "<$tag>$node\n</$tag>\n";
    }
    elsif ($style eq 'phrase') {
        my $inside = $self->render($node);
        "<$tag$attrs>$inside</$tag>";
    }
    else {
        die "No handler for style '$style'";
    }
}

sub render_text {
    my ($self, $text) = @_;
    chomp $text;
    $text =~ s/\n/ /g;
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
