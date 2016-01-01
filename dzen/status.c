// Copyright 2010-2012, 2014, 2016 Yu-Jie Lin
// BSD License

#include <alloca.h>
#include <locale.h>
#include <netdb.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/statvfs.h>
#include <sys/time.h>
#include <unistd.h>
#include <alsa/asoundlib.h>

#define SLEEP 100000

// What icon should be shown above the battery remaining capacity left
// Colors:
//   green is charged, yellow is discharing, blue is recharging,
//   red is unknown to this script,
//   yellow-red flashing is meaning battery capacity is low
//   yellow-cyan flashing is meaning battery capacity is low and charging
#define BAT_FULL 50
#define BAT_LOW 10
// On my laptop, /sys/class/power_supply/BAT0/... update interval is 15 seconds
// Normal update interval when capacity is more than low capacity
#define UI_BAT 5000000
// Flashing rate when in low capacity, the default is 500ms for red, 500ms for yellow/cyan
#define UI_BAT_FLASH 500000

// Showing red icon when resource is in low
#define CRITICAL_MEM 75

char old_dzen[2048];
char new_dzen[2048];

FILE *dzen;
uint64_t *update_ts;
char **tmp_dzen;


typedef void (*update_func_pointer) (int);
struct update_func
{
  uint32_t interval;
  update_func_pointer fp;
};
void update_cpu(int);
void update_mem(int);
void update_fs(int);
void update_net(int);
void update_thm(int);
void update_bat(int);
void update_sound(int);
void update_clock(int);
struct update_func update_funcs[] = {
  {1000000, &update_cpu},
  {5000000, &update_mem},
  {60000000, &update_fs},
  {5000000, &update_net},
  {10000000, &update_thm},
  {UI_BAT, &update_bat},
  {200000, &update_sound},
  {1000000, &update_clock}
};

int UPDATE_FUNCS = sizeof(update_funcs) / sizeof(struct update_func);

char *used_color(int v, int max, int color_max, int min)
{
  static char result[8];

  if (max == -1)
    max = 100;
  if (v > max)
    v = max;
  if (color_max == -1)
    color_max = 176;
  if (min == -1)
    min = 0;
  if (v < min)
    v = min;
  v = color_max - (v - min) * color_max / (max - min);

  sprintf(result, "#%02x%02x%02x", color_max, v, v);
  return result;
}

void update_cpu(int ID)
{
  FILE *f = fopen("/proc/stat", "r");
  static int ocpu_total = 0;
  static int ocpu_idle = 0;
  int ncpu_total = 0;
  int ncpu_idle = 0;
  int cpu_maxval, cpu_val, cpu_percentage;
  int i, n;
  char *dzen_str = tmp_dzen[ID];
  char *color;

  if (fscanf(f, "%*s") != 0)
  {
    goto err;
  }
  for (i = 0; i < 10; i++)
  {
    if (fscanf(f, "%d", &n) != 1)
    {
      goto err;
    }
    ncpu_total += n;
    if (i == 3)
      ncpu_idle = n;
  }
  fclose(f);

  cpu_maxval = ncpu_total - ocpu_total;
  cpu_val = cpu_maxval - (ncpu_idle - ocpu_idle);
  cpu_percentage = 100 * cpu_val / cpu_maxval;

  ocpu_idle = ncpu_idle;
  ocpu_total = ncpu_total;

  color = used_color(cpu_percentage, 75, -1, 10);
  sprintf(dzen_str,
          "^ca(1,./status-cpu.sh)^i(icons/cpu.xbm)^ca() ^fg(%s)%3d%%^fg()",
          color, cpu_percentage);
  return;
err:
  sprintf(dzen_str,
          "^fg(#fff)^bg(#f00)^ca(1,./status-cpu.sh)^i(icons/cpu.xbm)^ca() !!!%%^bg()^fg()");
}

void update_mem(int ID)
{
  FILE *f = fopen("/proc/meminfo", "r");
  int total, free, buffers, cached, used;
  int mem_percentage;
  char *dzen_str = tmp_dzen[ID];
  char *color;
  char key[32];

  if (fscanf(f, "%*s %d %*s", &total) != 1
      || fscanf(f, "%*s %d %*s", &free) != 1
      || fscanf(f, "%s %d %*s", key, &buffers) != 2)
  {
    goto err;
  }
  if (strstr(key, "MemAvailable") != NULL)
  {
    // the buffers is actually avaiable
    used = total - buffers;
  }
  else
  {
    if (fscanf(f, "%*s %d %*s", &cached) != 1)
    {
      goto err;
    }

    free += buffers + cached;
    used = total - free;
  }
  fclose(f);
  mem_percentage = 100 * used / total;

  color = used_color(used, 1024 * 1024, -1, 100 * 1024);

  sprintf(dzen_str, "^ca(1,./status-mem.sh)");
  if (mem_percentage >= CRITICAL_MEM)
    sprintf(dzen_str + strlen(dzen_str), "^fg(#f00)^i(icons/mem.xbm)^fg()");
  else
    sprintf(dzen_str + strlen(dzen_str), "^i(icons/mem.xbm)");
  sprintf(dzen_str + strlen(dzen_str), "^ca() ^fg(%s)%4dMB %2d%%^fg()", color,
          used / 1024, mem_percentage);
  return;
err:
  sprintf(dzen_str,
          "^fg(#fff)^bg(#f00)^ca(1,./status-mem.sh)^i(icons/mem.xbm)^ca() !!!!MB !!%%^bg()^fg()");
}

void update_fs(int ID)
{
  char *dzen_str = tmp_dzen[ID];
  char *color;
  struct statvfs root_fs;
  int used, total, percentage;

  statvfs("/", &root_fs);

  used =
    (root_fs.f_blocks -
     root_fs.f_bfree) * root_fs.f_bsize / 1024 / 1024 / 1024;
  total = root_fs.f_blocks * root_fs.f_bsize / 1024 / 1024 / 1024;
  percentage = 100 * used / total;

  color = used_color(percentage, 60, -1, 10);

  sprintf(dzen_str,
          "^ca(1,./status-fs.sh)^i(icons/diskette.xbm)^ca() ^fg(%s)%dGB %2d%%^fg()",
          color, used, percentage);
}

void update_net(int ID)
{
  char *dzen_str = tmp_dzen[ID];
  char rx_color[8];
  char *color;
  char is_wifi = 0;
  unsigned long n_rxb, n_txb, rx_rate, tx_rate;
  static unsigned long o_rxb, o_txb;
  FILE *f;
  if ((f = fopen("/sys/class/net/ppp0/statistics/rx_bytes", "r")) == NULL)
  {
    if ((f = fopen("/sys/class/net/ppp1/statistics/rx_bytes", "r")) == NULL)
    {
      sprintf(dzen_str,
              "^fg(#a00)^i(icons/net_wired.xbm) ---/---- KB/s ^fg()");
      return;
    }
    else
      is_wifi = 1;
  }
  if (fscanf(f, "%ld", &n_rxb) != 1)
  {
    goto err;
  }
  fclose(f);
  if ((f = fopen("/sys/class/net/ppp0/statistics/tx_bytes", "r")) == NULL)
    if ((f = fopen("/sys/class/net/ppp1/statistics/tx_bytes", "r")) == NULL)
      return;
  if (fscanf(f, "%ld", &n_txb) != 1)
  {
    goto err;
  }
  fclose(f);

  // rate in bytes
  rx_rate =
    (unsigned long) ((n_rxb - o_rxb) /
                     (1.0 * update_funcs[ID].interval / 1000000));
  tx_rate =
    (unsigned long) ((n_txb - o_txb) /
                     (1.0 * update_funcs[ID].interval / 1000000));
  o_rxb = n_rxb;
  o_txb = n_txb;

  // to Kbytes
  rx_rate /= 1024;
  tx_rate /= 1024;

  color = used_color(rx_rate, 500, -1, -1);
  strcpy(rx_color, color);
  color = used_color(tx_rate, 200, -1, -1);

  if (is_wifi)
    sprintf(dzen_str, "^i(icons/wifi_02.xbm)");
  else
    sprintf(dzen_str, "^i(icons/net_wired.xbm)");
  sprintf(dzen_str + strlen(dzen_str),
          " ^fg(%s)%3ld^fg()/^fg(%s)%4ld^fg() KB/s", color, tx_rate, rx_color,
          rx_rate);
  return;
err:
  sprintf(dzen_str,
          "^fg(#fff)^bg(f00)^i(icons/net_wired.xbm) !!!/!!!! KB/s ^bg()^fg()");
}

void update_thm(int ID)
{
  char *dzen_str = tmp_dzen[ID];
  char *color;
  int thm;

  FILE *f;
  if ((f = fopen("/sys/class/thermal/thermal_zone0/temp", "r")) != NULL)
  {
    if (fscanf(f, "%d", &thm) != 1)
    {
      goto err;
    }
    thm /= 1000;
  }
  else
  {
    sprintf(dzen_str, "^fg(#a00)^i(icons/temp.xbm) --°C^fg()");
    return;
  }
  fclose(f);

  color = used_color(thm, 70, -1, 40);
  sprintf(dzen_str, "^i(icons/temp.xbm) ^fg(%s)%d°C^fg()", color, thm);
  return;
err:
  sprintf(dzen_str, "^fg(#fff)^bg(#f00)^i(icons/temp.xbm) !!°C^bg()^fg()");
}

void update_bat(int ID)
{
  char *dzen_str = tmp_dzen[ID];
  char *color;
  int full, remaining = 0, percentage;
  char state[32] = "";
  static char flashed = 0;
  FILE *f;

  if (!(f = fopen("/sys/class/power_supply/BAT0/charge_full", "r"))
      || fscanf(f, "%d", &full) != 1)
  {
    goto err;
  }
  fclose(f);
  if (!(f = fopen("/sys/class/power_supply/BAT0/charge_now", "r"))
      || fscanf(f, "%d", &remaining) != 1)
  {
    goto err;
  }
  fclose(f);
  if (remaining > full)
  {
    remaining = full;
  }
  percentage = 100 * remaining / full;

  if (!(f = fopen("/sys/class/power_supply/BAT0/status", "r"))
      || fscanf(f, "%s", state) != 1)
  {
    goto err;
  }
  fclose(f);

  // Formating icon
  if (state == strstr(state, "Full"))
  {
    sprintf(dzen_str, "^fg(#0a0)");
    percentage = 100;
  }
  else if (state == strstr(state, "Charging"))
    sprintf(dzen_str, "^fg(#0aa)");
  else if (state == strstr(state, "Discharging"))
    sprintf(dzen_str, "^fg(#aa0)");
  else
    sprintf(dzen_str, "^fg(#a00)");

  update_funcs[ID].interval = UI_BAT;
  if (percentage >= BAT_FULL)
    sprintf(dzen_str + strlen(dzen_str), "^i(icons/bat_full_01.xbm)");
  else if (percentage > BAT_LOW)
    sprintf(dzen_str + strlen(dzen_str), "^i(icons/bat_low_01.xbm)");
  else
  {
    update_funcs[ID].interval = UI_BAT_FLASH;
    if (flashed)
      sprintf(dzen_str + strlen(dzen_str), "^fg(#a00)");
    flashed = !flashed;
    sprintf(dzen_str + strlen(dzen_str), "^i(icons/bat_empty_01.xbm)");
  }
  sprintf(dzen_str + strlen(dzen_str), "^fg()");

  color = used_color(100 - percentage, -1, -1, -1);

  sprintf(dzen_str + strlen(dzen_str), " ^fg(%s)%3d%%^fg()", color,
          percentage);
  return;
err:
  sprintf(dzen_str,
          "^fg(#fff)^bg(#f00)^i(icons/bat_empty_01.xbm) !!!%%^bg()^fg()");
}

// get sockaddr, IPv4 or IPv6:
void *get_in_addr(struct sockaddr *sa)
{
  if (sa->sa_family == AF_INET)
    return &(((struct sockaddr_in *) sa)->sin_addr);
  return &(((struct sockaddr_in6 *) sa)->sin6_addr);
}

void update_sound(int ID)
{
  char *dzen_str = tmp_dzen[ID];
  // http://code.google.com/p/yjl/source/browse/Miscellaneous/get-volume.c
  const char *ATTACH = "default";
  const snd_mixer_selem_channel_id_t CHANNEL = SND_MIXER_SCHN_FRONT_LEFT;
  const char *SELEM_NAME = "Master";
  long vol, vol_min, vol_max;
  int percentage;
  int switch_value;

  static snd_mixer_t *h_mixer = NULL;
  static snd_mixer_selem_id_t *sid = NULL;
  static snd_mixer_elem_t *elem = NULL;

  if (!elem)
  {
    snd_mixer_open(&h_mixer, 1);
    snd_mixer_attach(h_mixer, ATTACH);
    snd_mixer_selem_register(h_mixer, NULL, NULL);
    snd_mixer_load(h_mixer);

    snd_mixer_selem_id_alloca(&sid);
    snd_mixer_selem_id_set_index(sid, 0);
    snd_mixer_selem_id_set_name(sid, SELEM_NAME);

    elem = snd_mixer_find_selem(h_mixer, sid);
  }

  // Crap, next line stole one hour of my life.
  // It's important for mixer's properties to be updated.
  snd_mixer_handle_events(h_mixer);
  snd_mixer_selem_get_playback_volume(elem, CHANNEL, &vol);
  snd_mixer_selem_get_playback_volume_range(elem, &vol_min, &vol_max);
  snd_mixer_selem_get_playback_switch(elem, CHANNEL, &switch_value);
  // when an ends comes, it's the end, nothing else matter.
  // you don't need to return the rent book when 2012 comes.
  // snd_mixer_close(h_mixer);
  percentage = 100 * vol / vol_max;

  sprintf(dzen_str,
          "^ca(1,urxvtc -name 'dzen-status-sound' -title 'Sound Mixer' -geometry 160x40 -e alsamixer)^i(icons/spkr_01.xbm)^ca() ");
  if (switch_value)
    sprintf(dzen_str + strlen(dzen_str), "^fg(#%02xaaaa)%3d%%^fg()",
            176 - percentage * 176 / 100, percentage);
  else
    sprintf(dzen_str + strlen(dzen_str), "^fg(#a00)%3d%%^fg()", percentage);

  const int width = 40;
  sprintf(dzen_str + strlen(dzen_str),
          "^ib(1)^fg(#aaa)^p(_BOTTOM)^p(-%d;-3)^p(_LOCK_X)^ro(%dx3)^fg(#aaa)^p(1;1)^r(%dx1)^p(_UNLOCK_X)^p(%d)^p()^ib(0)",
          width + 2, width, width * percentage / 100, width - 1);
}

void update_clock(int ID)
{
  time_t t;
  struct tm *tmp;
  char *dzen_str = tmp_dzen[ID];

  t = time(NULL);
  tmp = localtime(&t);
  strftime(dzen_str, 256,
           "^ca(1,./status-clock.sh)^i(icons/clock.xbm)^ca() %A, %B %d, %Y %H:%M:%S",
           tmp);
}

void update_next_ts(int ID)
{
  struct timeval t;
  gettimeofday(&t, NULL);

  update_ts[ID] = t.tv_sec * 1000000 + t.tv_usec + update_funcs[ID].interval;
}

void clean_up()
{
  free(update_ts);
  pclose(dzen);
}

void sig_handler(int sig)
{
  (void) sig;

  clean_up();
  signal(sig, SIG_DFL);
  raise(sig);
}

int main(void)
{
  int i;
  uint64_t ts_current;
  struct timeval t;
  struct timespec req = {
    .tv_sec = 0,
    .tv_nsec = SLEEP * 1000
  };

  // http://www.cl.cam.ac.uk/~mgk25/unicode.html#c
  if (!setlocale(LC_CTYPE, ""))
  {
    fprintf(stderr, "Can't set the specified locale! "
            "Check LANG, LC_CTYPE, LC_ALL.\n");
    return 1;
  }

  signal(SIGINT, sig_handler);
  signal(SIGKILL, sig_handler);
  signal(SIGTERM, sig_handler);

  if (chdir("/home/livibetter/.dzen") == -1
      || (dzen =
          fopen("/home/livibetter/.config/dzen-status/dzen", "r")) == NULL
      || fgets(old_dzen, sizeof old_dzen, dzen) == NULL)
  {
    return 2;
  }
  fclose(dzen);
  dzen = popen(old_dzen, "w");
  if (!dzen)
  {
    fprintf(stderr, "can not open dzen2.\n");
    return 1;
  }

  update_ts = (uint64_t *) malloc(UPDATE_FUNCS * sizeof(uint64_t));
  tmp_dzen = (char **) malloc(UPDATE_FUNCS * sizeof(char *));
  for (i = 0; i < UPDATE_FUNCS; i++)
  {
    tmp_dzen[i] = (char *) malloc(320);
    // initalizing
    update_funcs[i].fp(i);
  }

  for (;;)
  {
    gettimeofday(&t, NULL);
    ts_current = t.tv_sec * 1000000 + t.tv_usec;

    for (i = 0; i < UPDATE_FUNCS; i++)
    {
      if (ts_current >= update_ts[i])
      {
        update_funcs[i].fp(i);
        update_next_ts(i);
      }
    }

    new_dzen[0] = 0;
    for (i = 0; i < UPDATE_FUNCS; i++)
    {
      if (i > 0)
        strcat(new_dzen, " ");
      strcat(new_dzen, tmp_dzen[i]);
    }
    strcat(new_dzen,
           " ^ca(1,./status-misc.sh)^ca(3,./status-clouds.sh)^i(icons/info_01.xbm)^ca()^ca() ");

    if (strcmp(old_dzen, new_dzen))
    {
      fprintf(dzen, "%s\n", new_dzen);
      fflush(dzen);
      strcpy(old_dzen, new_dzen);
    }
    nanosleep(&req, NULL);
  }

  clean_up();
  return EXIT_SUCCESS;
}
