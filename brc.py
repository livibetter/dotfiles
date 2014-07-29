# Copyright (C) 2011-2013 by Yu-Jie Lin
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.


from docutils import nodes

from bpy.handlers.rst import register_role


@register_role('kbd')
def kbd(name, rawtext, text, lineno, inliner, options=None, content=None):
  """Generate kbd element"""

  return [nodes.raw('', '<kbd>%s</kbd>' % text, format='html')], []


service = 'blogger'
service_options = {
  'blog': 3803541356848955053
}

handlers = {
  'Markdown': {
    'options': {
      'config': {
        'extensions': ['footnotes', 'toc'],
      },
      'smartypants': True,
    },
  },
  'reStructuredText': {
    'options': {
      'markup_prefix': '.. sectnum::\n\n',
      'id_affix': '',
      'settings_overrides': {
        'math_output': 'MathML',
        'syntax_highlight': 'short',
      },
      'smartypants': True,
    },
  },
}
