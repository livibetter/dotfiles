/* See LICENSE file for copyright and license details. */

/* appearance */
static const char font[]      = "-*-envy code r-medium-r-normal-*-12-*-*-*-*-*-*-*";
static const char normbordercolor[] = "#303030";
static const char normbgcolor[]   = "#303030";
static const char normfgcolor[]   = "#808080";
static const char selbordercolor[]    = "#80c080";
static const char selbgcolor[]    = "#303030";
static const char selfgcolor[]    = "#cccccc";
static const unsigned int borderpx    = 2;    /* border pixel of windows */
static const unsigned int snap    = 32;     /* snap pixel */
static const Bool showbar         = True;   /* False means no bar */
static const Bool topbar      = True;   /* False means bottom bar */

/* function declarations */
// customized
void enternotify_ffm(XEvent *e);
void self_restart(const Arg *arg);
void toggle_ffm(const Arg *arg);
void toggle_rules(const Arg *arg);
void togglebar_dzen(const Arg *arg);
// patches
void grid(Monitor *m);
static void bstack(Monitor *m);
static void bstackhoriz(Monitor *m);
static void pushup(const Arg *arg);
static void pushdown(const Arg *arg);

/* tagging */
static const char *tags[] = { "1", "2", "3", "q", "w", "e", "a", "s", "d" };

/* rules can not be const if using toggle_rules() */
static Rule rules[] = {
  /* class          instance      title       tags mask isfloating  monitor */
  // Stuff need to be floating
  { "feh",          NULL,         NULL,       0,        True,       -1 },
  // Make sure Firefox's pop out dialog/windows floating
  { "Firefox",      "Browser",    NULL,       0,        True,       -1 },
  { "Firefox",      "Dialog",     NULL,       0,        True,       -1 },
  { "Firefox",      "Places",     NULL,       0,        True,       -1 },
  
  { "Keepnote",     NULL,         "Find",     0,        True,       -1 },

  { "Key-mon",      NULL,         NULL,       ~0,       True,       -1 },
  
  { "Leafpad",      NULL,         NULL,       0,        True,       -1 },

  { "MPlayer",      NULL,         NULL,       0,        True,       -1 },
  { "Smplayer",     NULL,         NULL,       0,        True,       -1 },
  
  { "URxvt",        "bashrun",    NULL,       0,        True,       -1 },
  { "URxvt",        "dzen-status-sound",
                                  NULL,       0,        True,       -1 },
  { "URxvt",        "mc",         NULL,       0,        True,       -1 },
  { "URxvt",        "vimp-ext-editor",
                                  NULL,       0,        True,       -1 },
  
  { "VNC Viewer",   NULL,         NULL,       0,        True,       -1 },
  { "TigerVNC",     NULL,         NULL,       0,        True,       -1 },

  // Tag row #2
  // Programs with special initial tag
  { "Keepnote",     NULL,         "KeepNote", 1<<3,     False,      -1 },
  
  { "libreoffice",  NULL,         NULL,       1<<4,     False,      -1 },

  { "Geeqie",       NULL,         NULL,       1<<5,     False,      -1 },
  { "Gimp",         NULL,         NULL,       1<<5,     True,       -1 },

  // Tag row #3
  { "Firefox",      "Navigator",  NULL,       1<<6,     False,      -1 },
  { "URxvt",        "urxvt",      NULL,       1<<7,     False,      -1 },
};

/* layout(s) */
static const float mfact    = 0.55; /* factor of master area size [0.05..0.95] */
static const Bool resizehints = True; /* False means respect size hints in tiled resizals */

static const Layout layouts[] = {
  /* symbol   arrange function */
  { "[]=",    tile },  /* first entry is default */
  { "><>",    NULL },  /* no layout function means floating behavior */
  { "[M]",    monocle },
  { "HHH",    grid },
  { "TTT",    bstack },
  { "===",    bstackhoriz },
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
static const char *bashrun_cmd[]            = { "bashrun", NULL };
static const char *urxvtc_tmux_cmd[]        = { "urxvtc", "-sl", "0", "-e", "tmux", "-2", NULL };
static const char *urxvtc_tmux_attach_cmd[] = { "urxvtc", "-sl", "0", "-e", "tmux", "-2", "attach", NULL };
static const char *urxvtc_cmd[]             = { "urxvtc", NULL };
static const char *urxvt_cmd[]              = { "urxvt", NULL };

static const char *sound_vol_up_cmd[]   = { "amixer", "sset", "Master,0", "5%+", NULL };
static const char *sound_vol_down_cmd[] = { "amixer", "sset", "Master,0", "5%-", NULL };
static const char *sound_mute_cmd[]     = { "amixer", "sset", "Master,0", "toggle", NULL };

static const char *xsnap_cmd[]      = SHCMD("xsnap -file \"$HOME/tmp/ss/`date +'%Y-%m-%d--%H:%M:%S.png'`\"");
static const char *xsnap_full_cmd[] = SHCMD("xsnap -file \"$HOME/tmp/ss/`date +'%Y-%m-%d--%H:%M:%S.png'`\" -region \"`xwininfo -root | sed '/\\(Width\\|Height\\)/ {s/[ :a-z-]//gi;p} ; d' | tr '\\n' ' ' | cut -d ' ' -f1-2 | tr ' ' 'x'`+0+0\"");

static const char *monitor_off_cmd[]    = { "monitorOff.sh", NULL };
static const char *monitor_switch_cmd[] = { "monitorSwitch-xrandr", NULL };
static const char *monitor_expand_cmd[] = { "monitorExpand.sh", NULL };

static const char *lock_cmd[] = { "xlock", "-mode", "blank", "-startCmd", "monitorOff.sh", "-timeout", "15", "-dpmsoff", "1", NULL };

static Key keys[] = {
  /* modifier                     key         function        argument */
  { MODKEY,                       XK_p,       spawn,          {.v = bashrun_cmd } },

  { MODKEY|ShiftMask,             XK_Return,  spawn,          {.v = urxvtc_tmux_cmd } },
  { MODKEY|ShiftMask|Mod1Mask,    XK_Return,  spawn,          {.v = urxvtc_tmux_attach_cmd } },
  { MODKEY|ControlMask,           XK_Return,  spawn,          {.v = urxvtc_cmd } },
  { MODKEY|ControlMask|Mod1Mask,  XK_Return,  spawn,          {.v = urxvt_cmd } },
  
  // keysym XF86AudioRaiseVolume 0x1008ff13, keycode 123
  { 0,                            0x1008ff13, spawn,          {.v = sound_vol_up_cmd } },
  // keysym XF86AudioLowerVolume 0x1008ff11, keycode 122
  { 0,                            0x1008ff11, spawn,          {.v = sound_vol_down_cmd } },
  // keysym XF86AudioMute 0x1008ff12, keycode 121
  { 0,                            0x1008ff12, spawn,          {.v = sound_mute_cmd } },
  
  { 0,                            XK_Print,   spawn,          {.v = xsnap_cmd} },
  { MODKEY,                       XK_Print,   spawn,          {.v = xsnap_full_cmd} },
  
  { MODKEY|ControlMask,           XK_l,       spawn,          {.v = lock_cmd} },
  
  { MODKEY,                       XK_F1,      spawn,          {.v = monitor_off_cmd} },
  { MODKEY,                       XK_F2,      spawn,          {.v = monitor_switch_cmd} },
  { MODKEY,                       XK_F3,      spawn,          {.v = monitor_expand_cmd} },

  { MODKEY|ShiftMask,             XK_m,       toggle_ffm,     {0} },
  { MODKEY|ShiftMask,             XK_r,       toggle_rules,   {0} },

  { MODKEY,                       XK_b,       togglebar_dzen, {0} },

  { Mod1Mask,                     XK_Tab,     focusstack,     {.i = +1 } },
  { MODKEY,                       XK_j,       focusstack,     {.i = +1 } },
  { MODKEY,                       XK_k,       focusstack,     {.i = -1 } },
  { MODKEY|ShiftMask,             XK_j,       pushdown,       {.i = +1 } },
  { MODKEY|ShiftMask,             XK_k,       pushup,         {.i = -1 } },

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
  { MODKEY,                       XK_g,       setlayout,      {.v = &layouts[3]} }  ,
  { MODKEY,                       XK_v,       setlayout,      {.v = &layouts[4]} },
  { MODKEY,                       XK_n,       setlayout,      {.v = &layouts[5]} },
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

/* toggle focus-follows-mouse */
static Bool focus_follows_mouse = True;

void
enternotify_ffm(XEvent *e) {
  if (focus_follows_mouse)
    enternotify(e);
}

void
toggle_ffm(const Arg *arg) {
  // Swap EnterNotify handler when first toggle is occured.
  if (handler[EnterNotify] == enternotify)
    handler[EnterNotify] = enternotify_ffm;
  focus_follows_mouse = !focus_follows_mouse;
}

/* toggle rules */
// 2: uninitalized
// 0: off - tags are set to NULL
// 1: on  - restore original tags
static unsigned char rules_toggled = 2;
static unsigned int *saved_rules_tags;

void
toggle_rules(const Arg *arg) {
  int i;
  int len_rules;

  len_rules = LENGTH(rules);
  if (rules_toggled == 2) {
    saved_rules_tags = malloc(sizeof(unsigned int) * len_rules);
    for (i=0; i<len_rules; i++)
      saved_rules_tags[i] = rules[i].tags;
    rules_toggled = True;
  }

  rules_toggled = !rules_toggled;
  for (i=0; i<len_rules; i++)
    if (rules_toggled)
      rules[i].tags = saved_rules_tags[i];
    else
      rules[i].tags = 0;
}

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


/* *******
 * Patches
 * ********/

/* grid layout */
// http://dwm.suckless.org/patches/gridmode
// from 5.8.2 diff
#include "/etc/portage/savedconfig/x11-wm/dwm-5.8.2-gridmode.c"

/* bottom stack layouts */
// http://dwm.suckless.org/patches/bottom_stack
// from source for 5.9
#include "/etc/portage/savedconfig/x11-wm/dwm-5.9-bstack.c"

/* push patch */
// http://dwm.suckless.org/patches/push
// from patch for 5.7.1
#include "/etc/portage/savedconfig/x11-wm/dwm-5.7.1-push.c"

// vim:sw=2:sts=2:et:smarttab
