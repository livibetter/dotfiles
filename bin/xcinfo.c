/**
 * Written by Yu-Jie Lin on 9/11/2011
 * Public Domain
 *
 * Output is
 * 
 *   "x y sw sh cw ch cx cy\n"
 *
 * x , y  : cursor position
 * sw, sh : screen resolution
 * cw, ch : cursor image size
 * cx, cy : cursor hotspot position
 *
 * Written intentedly being used in shell script, e.g.
 *
 *   read x y sw sh cw ch cx cy <<< "$(xcinfo)"
 *
 * You can discard unneeded outputs, e.g.
 *
 *   read x y sw sh _ <<< "$(xcinfo)"
 */

#include <stdio.h>
#include <X11/Xlib.h>
#include <X11/extensions/Xfixes.h>

int
main(int argc, char **argv)
{
  Display *dpy;
  int scr;
  int sw, sh;
  int px, py, _;
  Window w, rt;
  XFixesCursorImage *ci;
  
  dpy = XOpenDisplay(NULL);
  scr = DefaultScreen(dpy);
  rt  = RootWindow   (dpy, scr);
  sw  = DisplayWidth (dpy, scr);
  sh  = DisplayHeight(dpy, scr);

  ci = XFixesGetCursorImage(dpy);
  printf("%d %d %d %d %d %d %d %d\n",
         ci->x, ci->y,
         sw, sh,
         ci->width, ci->height,
         ci->xhot,  ci->yhot);
  XFree(ci);

  XCloseDisplay(dpy);
}
