/*
 * Multi-color and Vim-like abbreviated working directory PS1
 * using Bash loadable builtin
 * Copyright (C) 2011-2014 Yu-Jie Lin
 * This is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 */

#include <config.h>

#if defined (HAVE_UNISTD_H)
#  include <unistd.h>
#endif

#include <stdio.h>

#include "builtins.h"
#include "shell.h"

#include "common.h"
#include "cvs.h"
#include "git.h"
#include "hg.h"
#include "svn.h"
#include "fossil.h"

vccontext_t* probe_dirs(vccontext_t** contexts, int num_contexts);
void print_result(vccontext_t *context, options_t *options, result_t *result);

#define S_CTLESC "\001"
#define S_CTLNUL "\177"

// \\[ and \\] don't work, dunno why.
#define _PROMPT_START_IGNORE "\001\001"
#define _PROMPT_END_IGNORE   "\001\002"
#define CF _PROMPT_START_IGNORE "\033[1;%dm" _PROMPT_END_IGNORE

// sprintf
#define SPF(p, ...) {\
  sprintf(p, __VA_ARGS__);\
  p += strlen(p);\
}\

// colors
#define color_dir  32
#define color_home 35
#define color_sep  31
#define color_abbr 37

options_t options = {
  .debug         = 0,
  .format        = "[%n:%b%m%u] ",
  .show_branch   = 1,
  .show_revision = 0,
  .show_unknown  = 1,
  .show_modified = 1,
  .show_features = 0,
};

vccontext_t *(*func_contexts[])(options_t *) = {
  get_cvs_context,
  get_git_context,
  get_hg_context,
  get_svn_context,
  get_fossil_context,
};

static int num_contexts = -1;

vccontext_t **contexts;

void print_vcprompt() {
  // has vcprompt initialized?
  if (num_contexts == -1) {
    set_options(&options);

    num_contexts = sizeof(func_contexts) / sizeof(void *);
    contexts = malloc(num_contexts * sizeof(vccontext_t *));

    for (int i = 0; i < num_contexts; i++)
      contexts[i] = (*func_contexts[i])(&options);
  }

  result_t* result = NULL;
  vccontext_t* context = NULL;

  context = probe_dirs(contexts, num_contexts);
  if (context == NULL)
    return;

  result = context->get_info(context);
  if (result != NULL) {
    print_result(context, &options, result);
    free_result(result);
  }
}

int vimps1_builtin (WORD_LIST *list) {
  char *term_str, *pwd_str;
  int max_length = 3;  // length of shortened dir names

  char ps1[255]  = ""; // this got to be enough, or Oops!
  char *p_ps1    = ps1;
  char *p_pwd;
  int  dir_count = 0;  // only for the first dir

  int color_user = 34;

  // The mighty root?
  if (current_user.user_name == 0)
    get_current_user_info();
  if (current_user.uid == 0)
    color_user = 31;

  // Get $TERM
  term_str = get_string_value("TERM");
  if (strcmp(term_str, "linux") == 0)
    max_length = 2;

  // Get $PWD
  pwd_str = get_string_value("PWD");
  
  //
  // Start to compile the PS1
  //

  // Error code
  if (list && *list->word->word != '0') {
    int columns;

    columns = atoi(get_string_value("COLUMNS"));
    SPF(p_ps1, "\033[41;1;37m");
    memset(p_ps1, ' ', columns);
    p_ps1 += columns;
    *p_ps1 = '\0';
    SPF(p_ps1, "\033[%zuG%s\033[0m\n" _PROMPT_START_IGNORE "\033[\e[0m" _PROMPT_END_IGNORE,
           (columns - strlen(list->word->word)) / 2,
           list->word->word
           );
    }

  p_pwd = pwd_str;
  SPF(p_ps1, " ");
  // Substitute $HOME
  if (strstr(p_pwd, current_user.home_dir) == p_pwd) {
    SPF(p_ps1, CF "~", color_home);
    p_pwd += strlen(current_user.home_dir);
    dir_count++;
    }

  while (p_pwd[0] == '/') {
    char *p_dir_end;

    p_dir_end = strstr(p_pwd + 1, "/");
    if (p_dir_end) {
      *p_dir_end = '\0';
      if (dir_count++ == 0 || (p_dir_end - p_pwd - 1) <= max_length) {
        SPF(p_ps1, CF "/" CF "%s", color_sep, color_dir, p_pwd + 1);
        }
      else {
        char tmp_char;

        tmp_char = *(p_pwd + 1 + max_length);
        *(p_pwd + 1 + max_length) = '\0';
        SPF(p_ps1, CF "/" CF "%s", color_sep, color_abbr, p_pwd + 1);
        *(p_pwd + 1 + max_length) = tmp_char;
        }
      *p_dir_end = '/';
      p_pwd = p_dir_end;
      }
    else {
      // last one
      SPF(p_ps1, CF "/" CF "%s", color_sep, color_dir, p_pwd + 1);
      break;
      }
    }

  fputs(ps1, stdout);
  p_ps1 = ps1;
  fprintf(stdout, " " CF, 37);
  print_vcprompt();

  // user role indicator
  if (strcmp(term_str, "screen") == 0)
    SPF(p_ps1, _PROMPT_START_IGNORE "\033k\033\\" _PROMPT_END_IGNORE);
  SPF(p_ps1, CF "$ " _PROMPT_START_IGNORE "\033[0m" _PROMPT_END_IGNORE, color_user);

  printf("%s", ps1);
  fflush (stdout);
  
  return (EXECUTION_SUCCESS);
  }

char *vimps1_doc[] = {
  "Vim-like directory PS1.",
  "",
  "Multi-color and Vim-like abbreviated working directory",
  (char *)NULL
  };

struct builtin vimps1_struct = {
  "vimps1",
  vimps1_builtin,
  BUILTIN_ENABLED,
  vimps1_doc,
  "vimps1",
  0
  };
