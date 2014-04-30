use strict;
package Kwim::Byte;
use base 'Kwim::Tree';
use XXX -with => 'YAML::XS';

sub final {
    my ($self, $tree) = @_;
    $self->render($tree);
}

sub render_tag {
    my ($self, $hash) = @_;
    my ($tag, $node) = each %$hash;
    if (not defined $node) {
        "=$tag\n"
    }
    else {
        "+$tag\n" . $self->render($node) . "-$tag\n";
    }
}

sub render_text {
    my ($self, $text) = @_;
    chomp $text;
    $text =~ s/\n/\\n/g;
    " $text\n";
}

1;
