package Kwim::Grammar;
use base 'Pegex::Grammar';

use constant file => '../kwim-pgx/kwim.pgx';

use constant start_rules => [
    'document',
    'text-markup',
    'block-list-item',
];

sub make_tree {
  {
    '+grammar' => 'kwim',
    '+toprule' => 'document',
    '+version' => '0.0.1',
    'block_blank' => {
      '.ref' => 'line_blank'
    },
    'block_comment' => {
      '.rgx' => qr/\G\#\#\#\r?\n((?:.*?\r?\n)*?)\#\#\#\r?\n(?:\ *\r?\n)?/
    },
    'block_head' => {
      '.rgx' => qr/\G(={1,4})\ +(?:(.+?)\ +=+\r?\n|(.+\r?\n(?:[^\s].*\r?\n)*[^\s].*?)\ +=+\r?\n|(.+\r?\n(?:[^\s].*\r?\n)*)(?=[\ \*=\#]|\r?\n|\z))(?:\ *\r?\n)?/
    },
    'block_list' => {
      '.any' => [
        {
          '.ref' => 'block_list_bullet'
        },
        {
          '.ref' => 'block_list_number'
        },
        {
          '.ref' => 'block_list_data'
        }
      ]
    },
    'block_list_bullet' => {
      '.rgx' => qr/\G(\*\ .*\r?\n(?:\*\ .*\r?\n|(?:\ *\r?\n)*\ \ .*\r?\n)*(?:\ *\r?\n)?)/
    },
    'block_list_data' => {
      '.rgx' => qr/\G(\-\ .*\r?\n(?:\-\ .*\r?\n|(?:\ *\r?\n)|\ \ .*\r?\n)*)/
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
    'block_list_number' => {
      '.rgx' => qr/\G(\+\ .*\r?\n(?:\+\ .*\r?\n|(?:\ *\r?\n)*\ \ .*\r?\n)*(?:\ *\r?\n)?)/
    },
    'block_para' => {
      '.rgx' => qr/\G((?:(?![\ \*=\#\n]\ ).*\S.*(?:\r?\n|\z))+)(?:\ *\r?\n)?/
    },
    'block_pref' => {
      '.rgx' => qr/\G((?:(?:\ *\r?\n)*\ \ .*\r?\n)+)(?:\ *\r?\n)?/
    },
    'block_title' => {
      '.rgx' => qr/\G((?:(?![\ \*=\#\n]\ ).*\S.*(?:\r?\n|\z)))={3,}\r?\n(?:(?:\ *\r?\n)((?:(?![\ \*=\#\n]\ ).*\S.*(?:\r?\n|\z)))(?=(?:\ *\r?\n)|\z))?(?:\ *\r?\n)?/
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
      '.rgx' => qr/\G\.\r?\n((?:(?![\ \*=\#\n]\ ).*\S.*(?:\r?\n|\z))+)(?:\ *\r?\n)?/
    },
    'document' => {
      '+min' => 0,
      '.ref' => 'block_top'
    },
    'line_blank' => {
      '.rgx' => qr/\G(?:\ *\r?\n)/
    },
    'line_comment' => {
      '.rgx' => qr/\G\#\ ?(.*?)\r?\n(?:\ *\r?\n)?/
    },
    'marker_bold' => {
      '.rgx' => qr/\G\*/
    },
    'marker_del' => {
      '.rgx' => qr/\G\-\-/
    },
    'marker_emph' => {
      '.rgx' => qr/\G\//
    },
    'marker_escape' => {
      '.rgx' => qr/\G\\(.)/
    },
    'marker_next' => {
      '.rgx' => qr/\G([\s\S])/
    },
    'phrase_bold' => {
      '.all' => [
        {
          '.rgx' => qr/\G\*(?=\S[^\*])/
        },
        {
          '+min' => 1,
          '.all' => [
            {
              '+asr' => -1,
              '.ref' => 'marker_bold'
            },
            {
              '.ref' => 'phrase_markup'
            }
          ]
        },
        {
          '.ref' => 'marker_bold'
        }
      ]
    },
    'phrase_code' => {
      '.rgx' => qr/\G`([^`]*?)`/
    },
    'phrase_del' => {
      '.all' => [
        {
          '.rgx' => qr/\G\-\-(?=\S)(?!\-\-)/
        },
        {
          '+min' => 1,
          '.all' => [
            {
              '+asr' => -1,
              '.ref' => 'marker_del'
            },
            {
              '.ref' => 'phrase_markup'
            }
          ]
        },
        {
          '.ref' => 'marker_del'
        }
      ]
    },
    'phrase_emph' => {
      '.all' => [
        {
          '.rgx' => qr/\G\/(?=\S[^\/])/
        },
        {
          '+min' => 1,
          '.all' => [
            {
              '+asr' => -1,
              '.ref' => 'marker_emph'
            },
            {
              '.ref' => 'phrase_markup'
            }
          ]
        },
        {
          '.ref' => 'marker_emph'
        }
      ]
    },
    'phrase_func' => {
      '.rgx' => qr/\G<([^\>]+)\>/
    },
    'phrase_hyper' => {
      '.any' => [
        {
          '.ref' => 'phrase_hyper_named'
        },
        {
          '.ref' => 'phrase_hyper_explicit'
        },
        {
          '.ref' => 'phrase_hyper_implicit'
        }
      ]
    },
    'phrase_hyper_explicit' => {
      '.rgx' => qr/\G\[(https?:\S*?)\]/
    },
    'phrase_hyper_implicit' => {
      '.rgx' => qr/\G(https?:\S+)/
    },
    'phrase_hyper_named' => {
      '.rgx' => qr/\G"([^"]+)"\[(https?:\S*?)\]/
    },
    'phrase_link' => {
      '.any' => [
        {
          '.ref' => 'phrase_link_named'
        },
        {
          '.ref' => 'phrase_link_plain'
        }
      ]
    },
    'phrase_link_named' => {
      '.rgx' => qr/\G"([^"]+)"\[(\S*?)\]/
    },
    'phrase_link_plain' => {
      '.rgx' => qr/\G\[(\S*?)\]/
    },
    'phrase_markup' => {
      '.any' => [
        {
          '.ref' => 'phrase_text'
        },
        {
          '.ref' => 'marker_escape'
        },
        {
          '.ref' => 'phrase_func'
        },
        {
          '.ref' => 'phrase_code'
        },
        {
          '.ref' => 'phrase_bold'
        },
        {
          '.ref' => 'phrase_emph'
        },
        {
          '.ref' => 'phrase_del'
        },
        {
          '.ref' => 'phrase_hyper'
        },
        {
          '.ref' => 'phrase_link'
        },
        {
          '.ref' => 'marker_next'
        }
      ]
    },
    'phrase_text' => {
      '.rgx' => qr/\G((?:(?![<`\*\/\-\-"\[\\]|https?:)[\s\S])+)/
    },
    'text_markup' => {
      '+min' => 1,
      '.ref' => 'phrase_markup'
    }
  }
}

1;
