use strict;
package Kwim::Tree;
use base 'Pegex::Tree';
use XXX -with => 'YAML::XS';

sub got_block_blank {
    my ($self, $text) = @_;
    $self->add('blank');
}

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

sub got_block_list {
    my ($self, $text) = @_;
    my @items = map {s/^  //gm; $_} split /^\*\ /m, $text;
    shift @items;
    my $items = [
        map {
            my $item = $self->add_parse(item => $_, 'block-list-item');
            if ($item->{item}[0]{para}) {
                $item->{item}[0] = $item->{item}[0]{para}[0];
            }
            $item;
        } @items
    ];
    +{ list => $items };
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
    my ($self, $tag, $text, $start) = @_;
    +{ $tag => $self->parse($text, $start) };
}

sub parse {
    my ($self, $text, $start) = @_;
    if (not $start) {
        $start = 'text-markup';
        chomp $text;
    }
    my @debug = ();
    # @debug = (debug => 1);
    # @debug = (debug => 1) if $start eq 'block-list-item';
    my $parser = Pegex::Parser->new(
        grammar => 'Kwim::Grammar'->new(start => $start),
        receiver => 'Kwim::Tree'->new,
        @debug,
    );
    $parser->parse($text, $start);
}

1;
