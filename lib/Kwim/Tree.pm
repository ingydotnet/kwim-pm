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
    chomp $text;
    $text =~ s/^  //gm;
    $self->add("pref" => $text);
}

sub got_block_list_bullet {
    my ($self, $text) = @_;
    my @items = map {s/^  //gm; $_} split /^\*\ /m, $text;
    shift @items;
    my $items = [
        map {
            my $item = $self->add_parse(item => $_, 'block-list-item');
            if ($item->{item}[0]{para}) {
                $item->{item}[0] = $item->{item}[0]{para};
            }
            $item;
        } @items
    ];
    +{ list => $items };
}

sub got_block_list_data {
    my ($self, $text) = @_;
    my @items = map {s/^  //gm; $_} split /^\-\ /m, $text;
    shift @items;
    my $items = [
        map {
            my ($term, $def, $rest);
            if (s/(.*?)\s*::\s*(\S.*)\n//) {
                ($term, $def, $rest) = ($1, $2, $_);
                $def = $self->collapse($self->parse($def));
            }
            else {
                s/(.*)\n//;
                ($term, $def, $rest) = ($1, '', $_);
            }
            $term = $self->collapse($self->parse($term));
            my $result = [$term, $def];
            if (length $rest) {
                push @$result, $self->parse($rest, 'block-list-item');
            }
            $result;
        } @items
    ];
    +{ data => $items };
}

sub got_block_title {
    my ($self, $pair) = @_;
    my ($name, $text) = @$pair;
    if (defined $text) {
        chomp $name;
        chomp $text;
        $text = $self->collapse($self->parse($text))->[0];
        +{title => [ $name, $text ]};
    }
    else {
        $self->add_parse(title => $name);
    }
}

sub got_block_verse {
    my ($self, $text) = @_;
    $self->add_parse(verse => $text);
}

sub got_block_para {
    my ($self, $text) = @_;
    $self->add_parse(para => $text);
}

sub got_phrase_func {
    my ($self, $content) = @_;
    +{func => [split ' ', $content, 2]};
}

sub got_phrase_code {
    my ($self, $content) = @_;
    $self->add(code => $content);
}

sub got_phrase_bold {
    my ($self, $content) = @_;
    $self->add(bold => $content);
}

sub got_phrase_emph {
    my ($self, $content) = @_;
    $self->add(emph => $content);
}

sub got_phrase_del {
    my ($self, $content) = @_;
    $self->add(del => $content);
}

sub got_phrase_hyper_named {
    my ($self, $content) = @_;
    my ($text, $link) = @$content;
    { hyper => { link => $link, text => $text } };
}

sub got_phrase_hyper_explicit {
    my ($self, $content) = @_;
    { hyper => { link => $content, text => '' } };
}

sub got_phrase_hyper_implicit {
    my ($self, $content) = @_;
    { hyper => { link => $content, text => '' } };
}

sub got_phrase_link_named {
    my ($self, $content) = @_;
    my ($text, $link) = @$content;
    { link => { link => $link, text => $text } };
}

sub got_phrase_link_plain {
    my ($self, $content) = @_;
    { link => { link => $content, text => '' } };
}

#------------------------------------------------------------------------------
sub add {
    my ($self, $tag, $content) = @_;
    if (ref $content) {
        $content = $content->[0];
        if (@$content == 1) {
            $content = $content->[0]
        }
        elsif (@$content > 1) {
            $content = $self->collapse($content);
        }
    }
    +{ $tag => $content }
}

sub add_parse {
    my ($self, $tag, $text, $start) = @_;
    +{ $tag => $self->collapse($self->parse($text, $start)) };
}

sub parse {
    my ($self, $text, $start) = @_;
    if (not $start) {
        $start = 'text-markup';
        chomp $text;
    }
    my $debug = $self->{parser}{debug} || undef;
    my $parser = Pegex::Parser->new(
        grammar => 'Kwim::Grammar'->new(start => $start),
        receiver => 'Kwim::Tree'->new,
        debug => $debug,
    );
    $parser->parse($text, $start);
}

sub collapse {
    my ($self, $content) = @_;
    for (my $i = 0; $i < @$content; $i++) {
        next if ref $content->[$i];
        while ($i + 1 < @$content and not ref $content->[$i + 1]) {
            $content->[$i] .= splice(@$content, $i + 1, 1);
        }
    }
    $content;
}

1;
