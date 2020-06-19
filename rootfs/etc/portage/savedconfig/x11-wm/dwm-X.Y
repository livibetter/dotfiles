/* See LICENSE file for copyright and license details. */

/* appearance */
static const unsigned int borderpx  = 2;      /* border pixel of windows */
static const unsigned int snap      = 8;      /* snap pixel */
static const int showbar            = 1;      /* 0 means no bar */
static const int topbar             = 1;      /* 0 means bottom bar */
static const char *fonts[]          = { "Envy Code R:pixelsize=14" };
static const char *colors[][3]      = {
	/*               fg         bg         border   */
	[SchemeNorm] = { "#808080", "#303030", "#303030" },
	[SchemeSel]  = { "#cccccc", "#303030", "#80c080" },
};

/* function declarations */
// customized
void self_restart(const Arg *arg);
void togglebar_dzen(const Arg *arg);
// patches
#include "push.c"
static void pushup(const Arg *arg);
static void pushdown(const Arg *arg);

/* tagging */
static const char *tags[] = { "1", "2", "3", "q", "w", "e", "a", "s", "d" };

/* rules can not be const if using toggle_rules() */
static Rule rules[] = {
  // In xprop output:
  // WM_CLASS(STRING) = "Instance", "Class"
  /* class          instance      title       tags mask isfloating  monitor */
  // Stuff need to be floating
  { "Sxiv",         NULL,         NULL,       0,        True,       -1 },
  // Make sure Firefox's pop out dialog/windows floating
  { "Firefox",      "Browser",    NULL,       0,        True,       -1 },
  { "Firefox",      "Dialog",     NULL,       0,        True,       -1 },
  { "Firefox",      "Places",     NULL,       0,        True,       -1 },
  
  { "mpv",          NULL,         NULL,       0,        True,       -1 },
  
  // Tag row #1
  { "Firefox",      "Navigator",  NULL,       1,        False,      -1 },

  // Tag row #2
  { "st-256color",  "st-writing", NULL,       1<<4,     False,      -1 },
  { "libreoffice-startcenter",
                    NULL,         NULL,       1<<4,     False,      -1 },
  { "libreoffice-writer",
                    NULL,         NULL,       1<<4,     False,      -1 },

  { "Gimp",         NULL,         NULL,       1<<5,     True,       -1 },
  { "Timeline",     NULL,         NULL,       1<<5,     False,      -1 },

  // Tag row #3
  { "libreoffice-calc",
                    NULL,         NULL,       1<<6,     False,      -1 },

  { "st-256color",  "st-256color",
                                  NULL,       1<<7,     False,      -1 },
};

/* layout(s) */
static const float mfact     = 0.55; /* factor of master area size [0.05..0.95] */
static const int nmaster     = 1;    /* number of clients in master area */
static const int resizehints = 1;    /* 1 means respect size hints in tiled resizals */

static const Layout layouts[] = {
  /* symbol   arrange function */
  { "[]=",    tile },  /* first entry is default */
  { "><>",    NULL },  /* no layout function means floating behavior */
  { "[M]",    monocle },
};

/* key definitions */
#define MODKEY Mod4Mask
#define TAGKEYS(KEY,TAG) \
  { MODKEY,                       KEY,  view,       {.ui = 1 << TAG} }, \
  { MODKEY|ControlMask,           KEY,  toggleview, {.ui = 1 << TAG} }, \
  { MODKEY|ShiftMask,             KEY,  tag,        {.ui = 1 << TAG} }, \
  { MODKEY|ControlMask|ShiftMask, KEY,  toggletag,  {.ui = 1 << TAG} },

#define SHCMD(cmd) { "/bin/sh", "-c", cmd, NULL }

/* commands */
static char dmenumon[2] = "0"; /* component of dmenucmd, manipulated in spawn() */
static const char *dmenucmd[] = { NULL };

static const char *st_tmux_cmd[]        = { "st", "tmux", NULL };
static const char *st_tmux_attach_cmd[] = { "st", "tmux", "attach", NULL };
static const char *st_cmd[]             = { "st", NULL };

static const char *xsnap_cmd[]      = SHCMD("xsnap -file \"$HOME/.local/tmp/ss/`date +'%Y-%m-%d--%H:%M:%S.png'`\"");
static const char *xsnap_full_cmd[] = SHCMD("xsnap -file \"$HOME/.local/tmp/ss/`date +'%Y-%m-%d--%H:%M:%S.png'`\" -region \"`xwininfo -root | sed '/\\(Width\\|Height\\)/ {s/[ :a-z-]//gi;p} ; d' | tr '\\n' ' ' | cut -d ' ' -f1-2 | tr ' ' 'x'`+0+0\"");

static const char *monitor_off_cmd[] = SHCMD("sleep 0.5 ;  xset dpms force off");

static const char *ts_cmd[] = SHCMD("xdotool keyup t ; xdotool type --clearmodifiers $(date --utc +%Y-%m-%dT%H:%M:%SZ)");

static Key keys[] = {
  /* modifier                     key         function        argument */
  { MODKEY,                       XK_Return,  spawn,          {.v = st_tmux_cmd } },
  { MODKEY|Mod1Mask,              XK_Return,  spawn,          {.v = st_tmux_attach_cmd } },
  { MODKEY|ControlMask,           XK_Return,  spawn,          {.v = st_cmd } },
  
  { 0,                            XK_Print,   spawn,          {.v = xsnap_cmd} },
  { MODKEY,                       XK_Print,   spawn,          {.v = xsnap_full_cmd} },
  
  { MODKEY,                       XK_F1,      spawn,          {.v = monitor_off_cmd} },

  { MODKEY|ShiftMask,             XK_t,       spawn,          {.v = ts_cmd} },

  { MODKEY,                       XK_b,       togglebar_dzen, {0} },

  { Mod1Mask,                     XK_Tab,     focusstack,     {.i = +1 } },
  { MODKEY,                       XK_j,       focusstack,     {.i = +1 } },
  { MODKEY,                       XK_k,       focusstack,     {.i = -1 } },
  { MODKEY|ShiftMask,             XK_j,       pushdown,       {.i = +1 } },
  { MODKEY|ShiftMask,             XK_k,       pushup,         {.i = -1 } },

  // nmaster
  { MODKEY|ControlMask|ShiftMask, XK_j,       incnmaster,     {.i = +1 } },
  { MODKEY|ControlMask|ShiftMask, XK_k,       incnmaster,     {.i = -1 } },
        
  { MODKEY,                       XK_h,       setmfact,       {.f = -0.05} },
  { MODKEY,                       XK_l,       setmfact,       {.f = +0.05} },
  { MODKEY|ShiftMask,             XK_h,       setmfact,       {.f = -0.01} },
  { MODKEY|ShiftMask,             XK_l,       setmfact,       {.f = +0.01} },

  { MODKEY,                       XK_Return,  zoom,           {0} },
  { MODKEY,                       XK_Tab,     view,           {0} },

  { Mod1Mask,                     XK_F4,      killclient,     {0} },

  // layouts
  // NOTE: really need a cycling helper.
  { MODKEY,                       XK_t,       setlayout,      {.v = &layouts[0]} },
  { MODKEY,                       XK_f,       setlayout,      {.v = &layouts[1]} },
  { MODKEY,                       XK_m,       setlayout,      {.v = &layouts[2]} },
  { MODKEY,                       XK_space,   setlayout,      {0} },
  
  { MODKEY|ShiftMask,             XK_space,   togglefloating, {0} },

  { MODKEY,                       XK_0,       view,           {.ui = ~0 } },
  { MODKEY|ShiftMask,             XK_0,       tag,            {.ui = ~0 } },
  { MODKEY,                       XK_comma,   focusmon,       {.i = -1 } },
  { MODKEY,                       XK_period,  focusmon,       {.i = +1 } },
  { MODKEY|ShiftMask,             XK_comma,   tagmon,         {.i = -1 } },
  { MODKEY|ShiftMask,             XK_period,  tagmon,         {.i = +1 } },

  TAGKEYS(                        XK_1,                       0)
  TAGKEYS(                        XK_2,                       1)
  TAGKEYS(                        XK_3,                       2)
  TAGKEYS(                        XK_q,                       3)
  TAGKEYS(                        XK_w,                       4)
  TAGKEYS(                        XK_e,                       5)
  TAGKEYS(                        XK_a,                       6)
  TAGKEYS(                        XK_s,                       7)
  TAGKEYS(                        XK_d,                       8)
  
  { MODKEY|ShiftMask,             XK_F10,     self_restart,   {0} },
  { MODKEY|ControlMask|ShiftMask, XK_F10,     quit,           {0} },
};

/* button definitions */
/* click can be a tag number (starting at 0),
 * ClkLtSymbol, ClkStatusText, ClkWinTitle, ClkClientWin, or ClkRootWin */
static Button buttons[] = {
  /* click        event mask  button    function        argument */
  { ClkLtSymbol,  0,          Button1,  setlayout,      {0} },
  { ClkLtSymbol,  0,          Button3,  setlayout,      {.v = &layouts[2]} },
  { ClkWinTitle,  0,          Button2,  zoom,           {0} },
  { ClkClientWin, MODKEY,     Button1,  movemouse,      {0} },
  { ClkClientWin, MODKEY,     Button2,  togglefloating, {0} },
  { ClkClientWin, MODKEY,     Button3,  resizemouse,    {0} },
  { ClkTagBar,    0,          Button1,  view,           {0} },
  { ClkTagBar,    0,          Button3,  toggleview,     {0} },
  { ClkTagBar,    MODKEY,     Button1,  tag,            {0} },
  { ClkTagBar,    MODKEY,     Button3,  toggletag,      {0} },
};

/* ********************
 * Customized functions
 * *********************/

/* toggle bar and dzen */
void
togglebar_dzen(const Arg *arg) {
  const Arg dzen_spawn = {.v = (const char *[]) { "dzen-status", NULL } };
  const Arg dzen_kill  = {.v = (const char *[]) { "killall", "dzen-status", NULL } };
  togglebar(arg);
  spawn(selmon->showbar ? &dzen_spawn : &dzen_kill);
}

/* self-restart */
void
self_restart(const Arg *arg) {
  const char *p = "/usr/bin/dwm";
  execv(p, (char *const[]) {p, NULL});
}

// vim:filetype=c:sw=2:sts=2:et:smarttab
