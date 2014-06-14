use strict;
package Kwim::Pod;

use base 'Kwim::Markup';

# use XXX -with => 'YAML::XS';

use constant top_block_separator => "\n";

sub render_text {
    my ($self, $text) = @_;
    $text =~ s/\n/ /g;
    return $text;
}

sub render_comment {
    my ($self, $node) = @_;
    if ($node !~ /\n/) {
        "=for comment $node\n";
    }
    elsif ($node !~ /\n\n/) {
        "=for comment\n$node\n";
    }
    else {
        "=begin comment\n$node\n=end\n";
    }
}

sub render_para {
    my ($self, $node) = @_;
    my $out = $self->render($node);
    if ($self->option->{'wrap'}) {
        require Text::Autoformat;
        if ($out !~ /^=for /) {
            $out = Text::Autoformat::autoformat($out, {right => 78});
        }
        chomp $out;
        return $out;
    }
    return "$out\n";
}

sub render_blank { '' }

sub render_title {
    my ($self, $node, $number) = @_;
    my ($name, $abstract) = ref $node ? @$node : (undef, $node);
    my $label = $self->option->{'pod-upper-head'} ? 'NAME' : 'Name';
    $name = $self->render($name);
    if (defined $abstract) {
        $abstract = $self->render($abstract);
        "=head1 $label\n\n$name - $abstract\n";
    }
    else {
        "=head1 $name\n";
    }
}

sub render_head {
    my ($self, $node, $number) = @_;
    my $out = $self->render($node);
    $out = uc($out) if $number eq '1' and $self->option->{'pod-upper-head'};
    "=head$number $out\n";
}

sub render_pref {
    my ($self, $node) = @_;
    my $out = $node;
    chomp $out;
    $out =~ s/^(.)/    $1/gm;
    "$out\n";
}

sub render_bold {
    my ($self, $node) = @_;
    my $out = $self->render($node);
    $self->render_phrase(B => $out);
}

sub render_emph {
    my ($self, $node) = @_;
    my $out = $self->render($node);
    $self->render_phrase(I => $out);
}

sub render_code {
    my ($self, $node) = @_;
    my $out = $self->render($node);
    $self->render_phrase(C => $out);
}

sub render_hyper {
    my ($self, $node) = @_;
    my ($link, $text) = @{$node}{qw(link text)};
    (length $text == 0)
    ? $self->render_phrase(L => $link)
    : $self->render_phrase(L => "$text|$link");
}

sub render_link {
    my ($self, $node) = @_;
    my ($link, $text) = @{$node}{qw(link text)};
    (length $text == 0)
    ? $self->render_phrase(L => $link)
    : $self->render_phrase(L => "$text|$link");
}

sub render_phrase {
    my ($self, $code, $text) = @_;
    ($text !~ /[<>]/) ? "$code<$text>" :
    ($text !~ /(<< | >>)/) ? "$code<< $text >>" :
    ($text !~ /(<<< | >>>)/) ? "$code<<< $text >>>" :
    ($text !~ /(<<<< | >>>>)/) ? "$code<<<< $text >>>>" :
    ($text !~ /(<<<<< | >>>>>)/) ? "$code<<<<< $text >>>>>" :
    $text;
}

sub render_list {
    my ($self, $node) = @_;
    my $out = $self->render($node);
    "=over\n\n$out=back\n";
}

sub render_item {
    my ($self, $node) = @_;
    my $item = shift @$node;
    my $out = "=item * " . $self->render($item) . "\n\n";
    $out .= $self->render($node) . "\n" if @$node;
    $out;
}

sub render_data {
    my ($self, $node) = @_;
    my $out = "=over\n\n";
    for my $item (@$node) {
        my ($term, $def, $rest) = @$item;
        $term = $self->render($term);
        $out .= "=item $term\n\n";
        if (length $def) {
            $out .= $self->render($def) . "\n\n";
        }
        if ($rest) {
            $out .= $self->render($rest, "\n") . "\n";
        }
    }
    $out . "=back\n";
}

sub render_complete {
    my ($self, $out) = @_;
    chomp $out;
    <<"..."
=pod

=for comment
DO NOT EDIT. This Pod was generated by Kwim.
See http://github.com/ingydotnet/kwim-pm#readme

=encoding utf8

$out

=cut
...
}

1;
