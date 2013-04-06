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


import subprocess
from docutils import nodes
from docutils.parsers.rst import Directive, directives
from xml.sax.saxutils import escape

from bpy.handlers.rst import register_directive, register_role


@register_directive('precode')
class PreCode(Directive):
  """Generate HTML as <pre><code> style for highlight.js"""
  optional_arguments = 1
  option_spec = {'class': directives.unchanged}
  has_content = True

  @staticmethod
  def _run(code, lang=None, options=None):
    if options is None:
      options = {}

    if lang:
      tmpl = '<code class="%s">%%s</code>' % lang
    else:
      tmpl = '<code>%s</code>'

    if 'class' in options:
      tmpl = ('<pre class="%s">' % options['class']) + tmpl + '</pre>'
    else:
      tmpl = '<pre>' + tmpl + '</pre>'

    html = tmpl % escape(code)
    return html

  def run(self):

    lang = self.arguments[0] if len(self.arguments) else None
    raw = nodes.raw(
      '',
      self._run('\n'.join(self.content), lang, self.options),
      format='html'
    )
    return [raw]


@register_directive('pyrun')
class PyRun(Directive):
  """Append the output of Python code

  The encoding definition may be required when use Unicode characters:

    # -*- coding: utf-8 -*-
  """
  # TODO expand this to arbitrary command
  option_spec = {'command': directives.unchanged,
                 'class': directives.unchanged,
                 }
  has_content = True

  def _generate_std(self, content, stdtype=''):

    content = escape(content.decode('utf-8'))
    return nodes.raw(
      '',
      '<pre class="pyrun %s">%s</pre>' % (stdtype or 'stdout', content),
      format='html'
    )

  def run(self):
    code = '\n'.join(self.content)

    cmd = 'python'
    if 'command' in self.options:
      cmd = self.options['command']
    proc = subprocess.Popen((cmd, '-'),
                            stdin=subprocess.PIPE,
                            stdout=subprocess.PIPE,
                            stderr=subprocess.PIPE)
    stdout, stderr = proc.communicate(code.encode('utf-8'))

    raws = [nodes.raw(
      '',
      PreCode._run(code, self.options.get('class', 'python'), self.options),
      format='html'
    )]
    if not stdout:
      stdout = '*** NO OUTPUT ***'
    raws.append(self._generate_std(stdout))
    if stderr:
      raws.append(self._generate_std(stderr, 'stderr'))
    return raws


@register_role('kbd')
def kbd(name, rawtext, text, lineno, inliner, options=None, content=None):
  """Generate kbd element"""

  return [nodes.raw('', '<kbd>%s</kbd>' % text, format='html')], []


blog = 3803541356848955053

handlers = {
  'Markdown': {
    'options': {
      'config': {
        'extensions': ['footnotes', 'toc'],
      },
    },
  },
  'reStructuredText': {
    'options': {
      'markup_prefix': '.. sectnum::\n\n',
      'id_affix': '',
      'settings_overrides': {
      },
      'smartypants': True,
    },
  },
}
