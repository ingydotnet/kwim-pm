use Test::More tests => 1;

is `echo -n foo | ./bin/kwim`, "<p>foo</p>\n",
    "Trailing newline not needed";
