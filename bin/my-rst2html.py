#!/usr/bin/env python
# Yu-Jie Lin. MIT License.

import subprocess
import sys
from docutils import nodes
from docutils.core import publish_parts
from docutils.parsers.rst import Directive, directives, roles
from xml.sax.saxutils import escape

from smartypants import smartyPants


def register_directive(dir_name):
  """For lazy guys
  
  @register_directive(name)
  class MyDirective(Directive):
    [...]
  """
  def _register_directive(directive):
    directives.register_directive(dir_name, directive)
    return directive
  return _register_directive


def register_role(role_name):

  def _register_role(role):

    roles.register_canonical_role(role_name, role)
    return role

  return _register_role


# YouTube video embedding by Jason Stitt. MIT License
# http://countergram.com/youtube-in-rst
# TODO convert to class style, so it will read a bit cleaner
# TODO support iframe style
def youtube(name, args, options, content, lineno,
            contentOffset, blockText, state, stateMachine):
    """ Restructured text extension for inserting youtube embedded videos """
    CODE = """\
    <object type="application/x-shockwave-flash"
            width="%(width)s"
            height="%(height)s"
            class="youtube-embed"
            data="http://www.youtube.com/v/%(yid)s">
        <param name="movie" value="http://www.youtube.com/v/%(yid)s"></param>
        <param name="wmode" value="transparent"></param>%(extra)s
    </object>
    """

    PARAM = """\n    <param name="%s" value="%s"></param>"""

    if len(content) == 0:
        return
    string_vars = {
        'yid': content[0],
        'width': 425,
        'height': 344,
        'extra': ''
        }
    extra_args = content[1:] # Because content[0] is ID
    extra_args = [ea.strip().split("=") for ea in extra_args] # key=value
    extra_args = [ea for ea in extra_args if len(ea) == 2] # drop bad lines
    extra_args = dict(extra_args)
    if 'width' in extra_args:
        string_vars['width'] = extra_args.pop('width')
    if 'height' in extra_args:
        string_vars['height'] = extra_args.pop('height')
    if extra_args:
        params = [PARAM % (key, extra_args[key]) for key in extra_args]
        string_vars['extra'] = "".join(params)
    return [nodes.raw('', CODE % (string_vars), format='html')]
youtube.content = True
directives.register_directive('youtube', youtube)


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
    raw = nodes.raw('', self._run('\n'.join(self.content), lang, self.options), format='html')
    return [raw]


@register_directive('pyrun')
class PyRun(Directive):
  """Append the output of Python code"""
  # TODO expand this to arbitrary command
  option_spec = {'command': directives.unchanged,
                 'class': directives.unchanged,
                 }
  has_content = True
  
  def run(self):
    code = '\n'.join(self.content)
    
    cmd = 'python'
    if 'command' in self.options:
      cmd = self.options['command']
    proc = subprocess.Popen((cmd, '-'),
                            stdin=subprocess.PIPE,
                            stdout=subprocess.PIPE,
                            stderr=subprocess.PIPE)
    stdout, stderr = proc.communicate(code)

    raws = [nodes.raw('', PreCode._run(code, 'python', self.options), format='html')]
    if not stdout:
      stdout = '*** NO OUTPUT ***'
    raws.append(nodes.raw('', '<pre class="no-collapse">%s</pre>' % escape(stdout), format='html'))
    if stderr:
      raws.append(nodes.raw('', '<pre>%s</pre>' % escape(stderr), format='html'))
    return raws


@register_role('kbd')
def kbd(name, rawtext, text, lineno, inliner, options=None, content=None):
  """Generate kbd element"""

  return [nodes.raw('', '<kbd>%s</kbd>' % text, format='html')], []


def main():

  with open(sys.argv[1]) as f:
    source = f.read()

  doc_parts = publish_parts(
      source,
      settings_overrides={'output_encoding': 'utf8',
                          'initial_header_level': 2,
                          },
      writer_name="html")

  print smartyPants(doc_parts['fragment']).encode('utf-8')


if __name__ == '__main__':
  main()
