use strict;
package Kwim::Markup;
use base 'Kwim::Tree';
use XXX -with => 'YAML::XS';

sub final {
    my ($self, $tree) = @_;
    $self->render($tree);
}

sub render {
    my ($self, $node) = @_;
    my $out;
    if (not ref $node) {
        $out = $self->render_text($node);
    }
    elsif (ref($node) eq 'HASH') {
        $out = $self->render_node($node);
    }
    else {
        $out .= $self->render($_) for @$node;
    }
    return $out;
}

sub render_node {
    my ($self, $hash) = @_;
    my ($name, $node) = each %$hash;
    my $number = $name =~ s/(\d)$// ? $1 : 0;
    my $method = "render_$name";
    return $self->$method($node, $number);
}

1;
