use strict;
package Kwim::Markdown;

use base 'Kwim::Markup';

# use XXX -with => 'YAML::XS';

use constant top_block_separator => "\n";

sub render_text {
    my ($self, $text) = @_;
    chomp $text;
    $text =~ s/\n/ /g;
    return $text;
}

sub render_para {
    my ($self, $node) = @_;
    my $out = $self->render($node);
    return "$out\n";
}

sub render_title {
    my ($self, $node) = @_;
    my $out = $self->render($node);
    my $len = length $out;
    return "$out\n" . ('=' x $len) . "\n";
}

sub render_head {
    my ($self, $node, $number) = @_;
    my $out = $self->render($node);
    my $len = length $out;
    ('#' x $number) . " $out\n";
}



sub render_list {
    my ($self, $node) = @_;
    push @{$self->{bullet}}, '*';
    my $out = $self->render($node);
    pop @{$self->{bullet}};
    $out;
}

sub render_item {
    my ($self, $node) = @_;
    my $item = shift @$node;
    my $bullet = $self->{bullet}[-1];
    my $out = "$bullet " . $self->render($item) . "\n";
    $out .= $self->render($node);
    my $indent = '  ' x (@{$self->{bullet}} - 1);
    $out =~ s/^/$indent/gm;
    $out;
}

sub render_pref {
    my ($self, $node) = @_;
    return '' if @{$self->{bullet}};
    my $out = "$node\n";
    $out =~ s/^/    /gm;
    $out;
}

sub render_blank { '' }

sub render_comment { '' }

sub render_bold {
    my ($self, $node) = @_;
    my $out = $self->render($node);
    "**$out**";
}

sub render_emph {
    my ($self, $node) = @_;
    my $out = $self->render($node);
    "_$out\_";
}

sub render_code {
    my ($self, $node) = @_;
    my $out = $self->render($node);
    "`$out`";
}

sub render_hyper {
    my ($self, $node) = @_;
    my ($link, $text) = @{$node}{qw(link text)};
    (length $text == 0)
    ? "<$link>"
    : "[$text]($link)";
}

sub render_link {
    my ($self, $node) = @_;
    my ($link, $text) = @{$node}{qw(link text)};
    (length $text == 0)
    ? "[$link]($link)"
    : "[$text]($link)";
}

1;
