use strict;
package Kwim::HTML;
use base 'Kwim::Tree';

use HTML::Escape;

use XXX -with => 'YAML::XS';

my $lookup = {
    title => [ h1 => 1, 1 ],
    para => [ p => 1 ],
    bold => [ b => 0 ],
    emph => [ i => 0 ],
    code => [ tt => 0 ],
};

sub final {
    my ($self, $tree) = @_;
    $self->render($tree);
}

sub render_tag {
    my ($self, $hash) = @_;
    my ($tag, $node) = each %$hash;
    return $self->render_comment($node) if $tag eq 'comment';
    return $self->render_verse($node) if $tag eq 'verse';
    my ($name, $block, $class) = @{$lookup->{$tag} or die "Unknown tag: $tag"};
    my $space = $block ? "\n" : '';
    my $attrs = $class ? qq{ class="$tag"} : '';
    "<$name$attrs>$space" . $self->render($node) . "$space</$name>$space";
}

sub render_text {
    my ($self, $text) = @_;
    chomp $text;
    escape_html($text);
}

sub render_verse {
    my ($self, $text) = @_;
    $text = $text->[0];
    chomp $text;
    $text = escape_html($text);
    $text =~ s/(\s{2,})/'&nbsp;' x length($1)/ge;
    $text =~ s{\n}{<br/>\n}g;
    <<"..."
<p class="verse">
$text
</p>
...
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
