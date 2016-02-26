# Copyright (C) 2011-2016 by Yu-Jie Lin
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

import json
import os
import re
from os import path

from docutils import nodes

from bpy.handlers.base import BaseHandler
from bpy.handlers.rst import register_role


@register_role('kbd')
def kbd(name, rawtext, text, lineno, inliner, options=None, content=None):
  """Generate kbd element"""

  return [nodes.raw('', '<kbd>%s</kbd>' % text, format='html')], []


def __check_category(fullpath):

  if '/series/SotD/' in fullpath:
    return 'SotD'
  if '/series/journal/' in fullpath:
    return 'journal'
  return None


def __generate(self, markup=None):

  fullpath = path.join(os.getcwdu(), self.filename.decode('utf8'))
  cat = __check_category(fullpath)
  if cat == 'SotD':
    self.options['markup_prefix'] += '''
.. _SotD: http://blog.yjl.im/SotD
.. _Song of the Day: http://blog.yjl.im/SotD

'''

  if markup is None:
    markup = self.markup

  return self.__generate(markup)


def __generate_title(self, title=None):

  prefix = ''

  if title is None:
    title = self.header.get('title', self.title)

  fullpath = path.join(os.getcwdu(), self.filename.decode('utf8'))
  cat = __check_category(fullpath)
  if cat == 'SotD':
    # check filename format
    RE_FILENAME = re.compile(r'.*/\d{4}-\d{2}-\d{2} \d{4} .+?\.rst')
    if not RE_FILENAME.match(self.filename):
      msg = 'The filename is not in the format of "YYYY-MM-DD NNNN TITLE.rst"'
      raise ValueError(msg)

    # remove date and number
    RE_TITLE = re.compile(r'^\d{4}-\d{2}-\d{2} \d{4} ')
    if RE_TITLE.match(title):
      title = title[16:]

    prefix = 'SotD: '
  elif cat == 'journal':
    # check filename format
    RE_FILENAME = re.compile(r'.*/(\d{4}-\d{2}-\d{2}) .+?\.rst')
    m = RE_FILENAME.match(self.filename)
    if not m:
      msg = 'The filename is not in the format of "YYYY-MM-DD TITLE.rst"'
      raise ValueError(msg)

    # remove date and number
    RE_TITLE = re.compile(r'^\d{4}-\d{2}-\d{2} ')
    if RE_TITLE.match(title):
      title = title[11:]

    prefix = 'Journal %s: ' % m.group(1)

  return self.__generate_title(prefix + title)


def __split_header_markup(self, source=None):

  header, markup = self.__split_header_markup(source)

  fullpath = path.join(os.getcwdu(), self.filename.decode('utf8'))
  cat = __check_category(fullpath)
  if cat == 'SotD':
    label = 'Song of the Day'
  elif cat == 'journal':
    label = 'journal'
  else:
    return header, markup

  if 'labels' not in header:
    header['labels'] = []
  if label not in header['labels']:
    header['labels'].append(label)

  return header, markup


def __update_source(self, header=None, markup=None, only_returned=False):

  if header is None:
    header = self.header

  fullpath = path.join(os.getcwdu(), self.filename.decode('utf8'))
  cat = __check_category(fullpath)
  if cat == 'SotD':
    label = 'Song of the Day'
  elif cat == 'journal':
    label = 'journal'
  else:
    self.__update_source(header, markup, only_returned)
    return

  if 'labels' not in header:
    header['labels'] = []
  if label in header['labels']:
    header['labels'].remove(label)

  self.__update_source(header, markup, only_returned)


BaseHandler.__generate_title = BaseHandler.generate_title
BaseHandler.generate_title = __generate_title
BaseHandler.__generate = BaseHandler.generate
BaseHandler.generate = __generate
BaseHandler.__split_header_markup = BaseHandler.split_header_markup
BaseHandler.split_header_markup = __split_header_markup
BaseHandler.__update_source = BaseHandler.update_source
BaseHandler.update_source = __update_source


service = 'blogger'

fn = path.join(path.dirname(path.realpath(__file__)), 'brc.py.blogger.json')
with open(fn) as f:
  data = json.load(f)
service_options = {
  'client_id': data['installed']['client_id'],
  'client_secret': data['installed']['client_secret'],
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
        'initial_header_level': 3,
        'math_output': 'MathML',
        'syntax_highlight': 'short',
      },
      'smartypants': True,
    },
  },
}
