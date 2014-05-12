use strict;
package Kwim::Markup;
use Pegex::Base;
use base 'Kwim::Tree';
use XXX -with => 'YAML::XS';

has option => {};

use constant top_block_separator => '';

sub BUILD {
    $_[0]->{option} ||= {};
}

sub final {
    my ($self, $tree) = @_;
    $self->{stack} = [];
    $self->{bullet} = [];
    my $out = $self->render($tree);
    if ($self->option->{'render-complete'}) {
        if ($self->can('render_complete')) {
            $out = $self->render_complete($out);
        }
    }
    $out;
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
        my $sep = $self->at_top_level ? $self->top_block_separator : '';
        $out = join $sep, grep $_, map { $self->render($_) } @$node;
    }
    return $out;
}

sub render_node {
    my ($self, $hash) = @_;
    my ($name, $node) = each %$hash;
    my $number = $name =~ s/(\d)$// ? $1 : 0;
    my $method = "render_$name";
    push @{$self->{stack}}, $name;
    my $out = $self->$method($node, $number);
    pop @{$self->{stack}};
    $out;
}

sub at_top_level {
    @{$_[0]->{stack}} == 0
}

1;
