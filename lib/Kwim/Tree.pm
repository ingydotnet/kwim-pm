use strict;
package Kwim::Tree;
use base 'Pegex::Tree';
use XXX -with => 'YAML::XS';

sub got_block_comment {
    my ($self, $text) = @_;
    $self->add(comment => $text);
}

sub got_line_comment {
    my ($self, $text) = @_;
    $self->add(comment => $text);
}

sub got_block_head {
    my ($self, $got) = @_;
    my $marker = shift @$got;
    my ($text) = grep defined, @$got;
    chomp $text;
    my $level = length $marker;
    $self->add("head$level" => $text);
}

sub got_block_pref {
    my ($self, $text) = @_;
    $text =~ s/^  //gm;
    $self->add("pref" => $text);
}

sub got_block_title {
    my ($self, $text) = @_;
    $self->add_parse(title => $text);
}

sub got_block_verse {
    my ($self, $text) = @_;
    $self->add_parse(verse => $text);
}

sub got_block_para {
    my ($self, $text) = @_;
    $self->add_parse(para => $text);
}

sub got_phrase_bold {
    my ($self, $content) = @_;
    $self->add(bold => $content);
}

sub got_phrase_code {
    my ($self, $content) = @_;
    $self->add(code => $content);
}

#------------------------------------------------------------------------------
sub add {
    my ($self, $tag, $content) = @_;
    if (ref $content) {
        $content = $content->[0];
        $content = $content->[0] if @$content == 1;
    }
    +{ $tag => $content }
}

sub add_parse {
    my ($self, $tag, $text) = @_;
    +{ $tag => $self->parse($text) };
}

sub parse {
    my ($self, $text, $start) = @_;
    chomp $text;
    $start ||= 'text-markup';
    my $parser = Pegex::Parser->new(
        grammar => 'Kwim::Grammar'->new(start => $start),
        receiver => 'Kwim::Tree'->new,
        # debug => 1,
    );
    $parser->parse($text, $start);
}

#------------------------------------------------------------------------------
sub render {
    my ($self, $node) = @_;
    my $out;
    if (not ref $node) {
        $out = $self->render_text($node);
    }
    elsif (ref($node) eq 'HASH') {
        $out = $self->render_tag($node);
    }
    else {
        $out .= $self->render($_) for @$node;
    }
    return $out;
}

1;
