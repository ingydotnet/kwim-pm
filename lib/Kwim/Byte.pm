use strict;
package Kwim::Byte;
use base 'Kwim::Markup';
use XXX -with => 'YAML::XS';

sub render_node {
    my ($self, $hash) = @_;
    my ($tag, $node) = each %$hash;
    if ($self->can("render_$tag")) {
        my $method = "render_$tag";
        return $self->$method($node);
    }
    if (not defined $node) {
        "=$tag\n"
    }
    else {
        "+$tag\n" . $self->render($node) . "-$tag\n";
    }
}

sub render_text {
    my ($self, $node) = @_;
    $node =~ s/\n/\\n/g;
    " $node\n";
}

sub render_hyper {
    my ($self, $node) = @_;
    my ($link, $text) = @{$node}{qw(link text)};
    (length $text == 0)
    ? "=hyper $link\n"
    : "+hyper $link\n $text\n-hyper\n";
}

1;
