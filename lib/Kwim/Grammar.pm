package Kwim::Grammar;
use base 'Pegex::Grammar';

use constant file => 'share/kwim.pgx';

use constant start_rules => [
    'document',
    'text-markup',
    'block-list-item',
];

sub make_treeXXX {
  {
    '+toprule' => 'document',
    'block_blank' => {
      '.rgx' => qr/\G(?:\ *\r?\n)/
    },
    'block_comment' => {
      '.rgx' => qr/\G\#\#\#\r?\n((?:.*?\r?\n)*?)\#\#\#\r?\n(?:\ *\r?\n)?/
    },
    'block_head' => {
      '.rgx' => qr/\G(={1,4})\ +(?:(.+?)\ +=+\r?\n|(.+\n(?:[^\s].*\r?\n)*[^\s].*?)\ +=+\r?\n|(.+\n(?:[^\s].*\r?\n)*)(?=[\ \*==]|\r?\n|\z))(?:\ *\r?\n)?/
    },
    'block_list' => {
      '.rgx' => qr/\G(\*\ .*\r?\n(?:\*\ .*\r?\n|(?:\ *\r?\n)*\ \ .*\r?\n)*(?:\ *\r?\n)?)/
    },
    'block_list_item' => {
      '+min' => 0,
      '.any' => [
        {
          '.ref' => 'block_blank'
        },
        {
          '.ref' => 'block_comment'
        },
        {
          '.ref' => 'line_comment'
        },
        {
          '.ref' => 'block_head'
        },
        {
          '.ref' => 'block_pref'
        },
        {
          '.ref' => 'block_list'
        },
        {
          '.ref' => 'block_title'
        },
        {
          '.ref' => 'block_verse'
        },
        {
          '.ref' => 'block_para'
        }
      ]
    },
    'block_para' => {
      '.rgx' => qr/\G((?:[^\ \*==\n].*\n)+)(?:\ *\r?\n)?/
    },
    'block_pref' => {
      '.rgx' => qr/\G((?:(?:\ *\r?\n)*\ \ .*\r?\n)+)(?:\ *\r?\n)?/
    },
    'block_title' => {
      '.rgx' => qr/\G((?:[^\ \*==\n].*\n))={3,}\r?\n(?:\ *\r?\n)?/
    },
    'block_top' => {
      '.any' => [
        {
          '.ref' => 'block_blank'
        },
        {
          '.ref' => 'block_comment'
        },
        {
          '.ref' => 'line_comment'
        },
        {
          '.ref' => 'block_head'
        },
        {
          '.ref' => 'block_pref'
        },
        {
          '.ref' => 'block_list'
        },
        {
          '.ref' => 'block_title'
        },
        {
          '.ref' => 'block_verse'
        },
        {
          '.ref' => 'block_para'
        }
      ]
    },
    'block_verse' => {
      '.rgx' => qr/\G\.\n((?:[^\ \*==\n].*\n)+)(?:\ *\r?\n)?/
    },
    'char_bold' => {
      '.rgx' => qr/\G\*/
    },
    'char_emph' => {
      '.rgx' => qr/\G\//
    },
    'char_escape' => {
      '.rgx' => qr/\G\\(.)/
    },
    'document' => {
      '+min' => 0,
      '.ref' => 'block_top'
    },
    'line_comment' => {
      '.rgx' => qr/\G\#\ ?(.*?)\r?\n(?:\ *\r?\n)?/
    },
    'phrase_bold' => {
      '.all' => [
        {
          '.ref' => 'char_bold'
        },
        {
          '+min' => 1,
          '.all' => [
            {
              '+asr' => -1,
              '.ref' => 'char_bold'
            },
            {
              '.ref' => 'phrase_markup'
            }
          ]
        },
        {
          '.ref' => 'char_bold'
        }
      ]
    },
    'phrase_code' => {
      '.rgx' => qr/\G`([^`]*?)`/
    },
    'phrase_emph' => {
      '.all' => [
        {
          '.ref' => 'char_emph'
        },
        {
          '+min' => 1,
          '.all' => [
            {
              '+asr' => -1,
              '.ref' => 'char_emph'
            },
            {
              '.ref' => 'phrase_markup'
            }
          ]
        },
        {
          '.ref' => 'char_emph'
        }
      ]
    },
    'phrase_markup' => {
      '.any' => [
        {
          '.ref' => 'char_escape'
        },
        {
          '.ref' => 'phrase_text'
        },
        {
          '.ref' => 'phrase_bold'
        },
        {
          '.ref' => 'phrase_emph'
        },
        {
          '.ref' => 'phrase_code'
        }
      ]
    },
    'phrase_text' => {
      '.rgx' => qr/\G([^\*\/`]+)/
    },
    'text_markup' => {
      '+min' => 1,
      '.ref' => 'phrase_markup'
    }
  }
}

1;
