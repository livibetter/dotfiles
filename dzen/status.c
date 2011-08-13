// Copyright 2010, 2011 Yu-Jie Lin
// BSD License
// gcc -lasound -o status status.c
#include <locale.h>
#include <netdb.h>
#include <netinet/in.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/statvfs.h>
#include <sys/time.h>
#include <time.h>
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
// On my laptop, /proc/acpi/battery/... update interval is 15 seconds
// Normal update interval when capacity is more than low capacity
#define UI_BAT 5000000
// Flashing rate when in low capacity, the default is 500ms for red, 500ms for yellow/cyan
#define UI_BAT_FLASH 500000

char old_dzen[2048];
char new_dzen[2048];

uint64_t *update_ts;
char **tmp_dzen;


typedef void (*update_func_pointer)(int);
struct update_func {
	uint32_t interval;
	update_func_pointer fp;
	};
void update_cpu(int);
void update_mem(int);
void update_fs(int);
void update_net(int);
void update_thm(int);
void update_bat(int);
void update_mpd(int);
void update_sound(int);
void update_clock(int);
struct update_func update_funcs[] = {
	{ 1000000, &update_cpu},
	{ 5000000, &update_mem},
	{60000000, &update_fs},
	{ 5000000, &update_net},
	{10000000, &update_thm},
	{  UI_BAT, &update_bat},
	{  500000, &update_mpd},
	{  200000, &update_sound},
	{ 1000000, &update_clock}
	};
int UPDATE_FUNCS = sizeof(update_funcs) / sizeof(struct update_func);

char *used_color (int v, int max, int color_max, int min) {
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
	v = color_max-(v-min)*color_max/(max-min);
	
	sprintf(result, "#%02x%02x%02x", color_max, v, v);
	return result;
	}

void update_cpu(int ID) {
	FILE *f = fopen("/proc/stat", "r");
	static int ocpu_total = 0;
	static int ocpu_idle = 0;
	int ncpu_total = 0;
	int ncpu_idle = 0;
	int cpu_maxval, cpu_val, cpu_percentage;
	int i, n;
	char *dzen_str = tmp_dzen[ID];
	char *color;

	fscanf(f, "%*s");
	for (i=0; i<10; i++) {
		fscanf(f, "%d", &n);
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
	sprintf(dzen_str, "^ca(1,./status-cpu.sh)^i(icons/cpu.xbm)^ca() ^fg(%s)%3d%%^fg()", color, cpu_percentage);
	}

void update_mem(int ID) {
	FILE *f = fopen("/proc/meminfo", "r");
	int total, free, buffers, cached, used;
	int mem_percentage;
	char *dzen_str = tmp_dzen[ID];
	char *color;

	fscanf(f, "%*s %d %*s", &total);
	fscanf(f, "%*s %d %*s", &free);
	fscanf(f, "%*s %d %*s", &buffers);
	fscanf(f, "%*s %d %*s", &cached);
	fclose(f);
	
	free += buffers + cached;
	used = total - free;
	mem_percentage = 100 * used / total;

	color = used_color(used, 1024 * 1024, -1, 100 * 1024);

	sprintf(dzen_str, "^ca(1,./status-mem.sh)^i(icons/mem.xbm)^ca() ^fg(%s)%4dMB %2d%%^fg()", color, used / 1024, mem_percentage);
	}

void update_fs(int ID) {
	char *dzen_str = tmp_dzen[ID];
	char *color;
	struct statvfs root_fs;
	int used, total, percentage;

	statvfs("/", &root_fs);

	used = (root_fs.f_blocks - root_fs.f_bfree) * root_fs.f_bsize / 1024 / 1024 / 1024;
	total = root_fs.f_blocks * root_fs.f_bsize / 1024 / 1024 / 1024;
	percentage = 100 * used / total;

	color = used_color(percentage, 60, -1, 10);
	
	sprintf(dzen_str, "^ca(1,./status-fs.sh)^i(icons/diskette.xbm)^ca() ^fg(%s)%dGB %2d%%^fg()", color, used, percentage);
	}

void update_net(int ID) {
	char *dzen_str = tmp_dzen[ID];
	char rx_color[8];
	char *color;
	char is_wifi = 0;
	unsigned long n_rxb, n_txb, rx_rate, tx_rate;
	static unsigned long o_rxb, o_txb;
	FILE *f;
	if ((f = fopen("/sys/class/net/ppp0/statistics/rx_bytes", "r"))==NULL) {
		if ((f = fopen("/sys/class/net/ppp1/statistics/rx_bytes", "r"))==NULL) {
			sprintf(dzen_str, "^fg(#a00)^i(icons/net_wired.xbm) ---/---- KB/s ^fg()");
			return;
			}
		else
			is_wifi = 1;
		}
	fscanf(f, "%ld", &n_rxb);
	fclose(f);
	if ((f = fopen("/sys/class/net/ppp0/statistics/tx_bytes", "r"))==NULL)
		if ((f = fopen("/sys/class/net/ppp1/statistics/tx_bytes", "r"))==NULL)
			return;
	fscanf(f, "%ld", &n_txb);
	fclose(f);
	
	// rate in bytes
	rx_rate = (unsigned long) ((n_rxb - o_rxb) / (1.0 * update_funcs[ID].interval / 1000000));
	tx_rate = (unsigned long) ((n_txb - o_txb) / (1.0 * update_funcs[ID].interval / 1000000));
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
	sprintf(dzen_str+strlen(dzen_str), " ^fg(%s)%3ld^fg()/^fg(%s)%4ld^fg() KB/s", color, tx_rate, rx_color, rx_rate);
	}

void update_thm(int ID) {
	char *dzen_str = tmp_dzen[ID];
	char *color;
	int thm;

	FILE *f;
	if ((f = fopen("/proc/acpi/thermal_zone/THM/temperature", "r")) != NULL) {
		fscanf(f, "%*s %d", &thm);
		}
	// kernel 2.6.37+ doesn't have /proc/acpi/thermal_zone
	else if ((f = fopen("/sys/class/thermal/thermal_zone0/temp", "r")) != NULL) {
		fscanf(f, "%d", &thm);
		thm /= 1000;
		}
	else {
		sprintf(dzen_str, "^fg(#a00)^i(icons/temp.xbm) --°C^fg()");
		return;
		}
	fclose(f);

	color = used_color(thm, 70, -1, 40);
	sprintf(dzen_str, "^i(icons/temp.xbm) ^fg(%s)%d°C^fg()", color, thm);
	}

void update_bat(int ID) {
	char *dzen_str = tmp_dzen[ID];
	char *color;
	int full, remaining = 0, percentage;
	char state[32] = "";
	char line[128];
	static char flashed = 0;
	FILE *f;

	f = fopen("/proc/acpi/battery/BAT0/info", "r");
	while (fgets(line, sizeof(line), f) != NULL) {
		if (strstr(line, "last full capacity") != NULL) {
			sscanf(line, "last full capacity: %d", &full);
			break;
			}
		}
	fclose(f);

	f = fopen("/proc/acpi/battery/BAT0/state", "r");
	while (fgets(line, sizeof(line), f) != NULL) {
		if (strstr(line, "charging state") != NULL)
			sscanf(line, "charging state: %s", state);
		if (strstr(line, "remaining capacity") != NULL)
			sscanf(line, "remaining capacity: %d", &remaining);
		if (remaining != 0 && state[0] != 0)
			break;
		}
	fclose(f);

	percentage = 100*remaining/full;
	
	// Formating icon
	if (state == strstr(state, "charged")) {
		sprintf(dzen_str, "^fg(#0a0)");
		percentage=100;
		}
	else if (state == strstr(state, "charging"))
		sprintf(dzen_str, "^fg(#0aa)");
	else if (state == strstr(state, "discharging"))
		sprintf(dzen_str, "^fg(#aa0)");
	else
		sprintf(dzen_str, "^fg(#a00)");
	
	update_funcs[ID].interval = UI_BAT;
	if (percentage >= BAT_FULL)
		sprintf(dzen_str+strlen(dzen_str), "^i(icons/bat_full_01.xbm)");
	else if (percentage > BAT_LOW)
		sprintf(dzen_str+strlen(dzen_str), "^i(icons/bat_low_01.xbm)");
	else {
		update_funcs[ID].interval = UI_BAT_FLASH;
		if (flashed)
			sprintf(dzen_str+strlen(dzen_str), "^fg(#a00)");
		flashed = !flashed;
		sprintf(dzen_str+strlen(dzen_str), "^i(icons/bat_empty_01.xbm)");
		}
	sprintf(dzen_str+strlen(dzen_str), "^fg()");
	
	color = used_color(100 - percentage, -1, -1, -1);
	
	sprintf(dzen_str+strlen(dzen_str), " ^fg(%s)%3d%%^fg()", color, percentage);
	}

// get sockaddr, IPv4 or IPv6:
void *get_in_addr(struct sockaddr *sa) {
	if (sa->sa_family == AF_INET)
		return &(((struct sockaddr_in*)sa)->sin_addr);
	return &(((struct sockaddr_in6*)sa)->sin6_addr);
	}

int mpd_send(int sockfd, char *data) {
	int numbytes;
	return send(sockfd, data, strlen(data), 0);
	}

char *mpd_recv(int sockfd) {
	#define MAXDATASIZE 1024
	static char buf[MAXDATASIZE];
	int numbytes;
	
	if ((numbytes = recv(sockfd, buf, MAXDATASIZE-1, 0)) == -1)
		return NULL;
	buf[numbytes] = '\0';
	return buf;
	}


int mpd_connect() {
	const char *MPD_HOST = "localhost";
	const char *MPD_PORT = "6600";
	struct addrinfo hints, *servinfo, *p;
	int sockfd, rv, numbytes;
	char s[INET6_ADDRSTRLEN];

	memset(&hints, 0, sizeof hints);
	hints.ai_family = AF_UNSPEC;
	hints.ai_socktype = SOCK_STREAM;

	if ((rv = getaddrinfo(MPD_HOST, MPD_PORT, &hints, &servinfo)) != 0) {
		freeaddrinfo(servinfo);
		return -1;
		}
	// loop through all the results and connect to the first we can
	for(p = servinfo; p != NULL; p = p->ai_next) {
		if ((sockfd = socket(p->ai_family, p->ai_socktype, p->ai_protocol)) == -1)
			continue;

		if (connect(sockfd, p->ai_addr, p->ai_addrlen) == -1) {
			close(sockfd);
			continue;
			}
		break;
		}

	if (p == NULL) {
		freeaddrinfo(servinfo);
		return -1;
		}

	inet_ntop(p->ai_family, get_in_addr((struct sockaddr *)p->ai_addr), s, sizeof s);
	freeaddrinfo(servinfo); // all done with this structure
	// get connected message
	mpd_recv(sockfd);

	return sockfd;
	}

void update_mpd(int ID) {
	char *dzen_str = tmp_dzen[ID];
	char *buf = NULL;
	static int sockfd = -1;
	char *idx;
	size_t len;
	#define title_size 64
	#define artist_size 64
	wchar_t title[title_size] = L"", artist[artist_size] = L"";
	#define text_size 128
	wchar_t new_text[text_size] = L"";
	static wchar_t mpd_text[text_size];
	static int pos = 0;
	int t_pos;
	static char dir = 0;
	const int MPD_TEXT_SIZE = 20;
	wchar_t t_text[MPD_TEXT_SIZE+1];
	int time_pos, time_total;
	FILE *fp;
	char is_lf_submit = 0;

	if ((fp = fopen("/tmp/lf-submit.sh.currentsong", "r")) != NULL) {
		is_lf_submit = -1;
		
		getline(&buf, &len, fp);		// first line is track
		mbstowcs(title, buf, title_size - 1);
		title[wcslen(title)-1] = L'\0';		// remove the newline
		
		getline(&buf, &len, fp);		// second line is artist
		mbstowcs(artist, buf, artist_size - 1);
		artist[wcslen(artist)-1] = L'\0';	// remove the newline
		
		// Clean up
		free(buf);
		buf = NULL;
		fclose(fp);
		}

	if (!is_lf_submit && sockfd == -1)
		sockfd = mpd_connect();
	if (!is_lf_submit && mpd_send(sockfd, "currentsong\n") == -1) {
		sockfd = -1;
		mpd_text[0] = L'\0';
		sprintf(dzen_str, "^ca(1,mpd;mpdscribble)^fg(#aaa)^i(icons/note.xbm)^fg()^ca()");
		}
	else {
		if (!is_lf_submit && ((buf = mpd_recv(sockfd)) == NULL || strlen(buf) <= 0)) {
			sockfd = -1;
			mpd_text[0] = L'\0';
			sprintf(dzen_str, "^ca(1,mpd;mpdscribble)^fg(#aaa)^i(icons/note.xbm)^fg()^ca()");
			return;
			}
		if (!is_lf_submit) {
			// find title
			idx = strstr(buf, "Title: ");
			if (idx != NULL) {
				idx += strlen("Title: ");
				*strstr(idx, "\n") = '\0';
				title[mbstowcs(title, idx, title_size - 1)] = L'\0';
				idx[strlen(idx)] = '\n';
				}
			// find artist
			idx = strstr(buf, "Artist: ");
			if (idx != NULL) {
				idx += strlen("Artist: ");
				*strstr(idx, "\n") = '\0';
				artist[mbstowcs(artist, idx, artist_size - 1)] = L'\0';
				idx[strlen(idx)] = '\n';
				}
			}
		wcscpy(new_text, artist);
		wcscat(new_text, L" - ");
		wcscat(new_text, title);
//printf("%s\n", new_text);
		if (wcscmp(new_text, mpd_text)) {
			system("killall status-mpd.sh &>/dev/null");
			system("itch-music.sh &");
			system("./status-mpd.sh 10 &");
			wcscpy(mpd_text, new_text);
			pos = 0;
			dir = 0;
			}
		t_pos = 0;
		if (wcslen(mpd_text) > MPD_TEXT_SIZE) {
			if (dir) {
				if (++pos >= wcslen(mpd_text) + 5 - MPD_TEXT_SIZE) {
					pos = wcslen(mpd_text) - MPD_TEXT_SIZE;
					dir = !dir;
					}
				}
			else {
				if (--pos <= -5) {
					pos = 0;
					dir = !dir;
					}
				}
			t_pos = (pos < 0) ? 0 : pos;
			if (t_pos > wcslen(mpd_text) - MPD_TEXT_SIZE)
				t_pos = wcslen(mpd_text) - MPD_TEXT_SIZE;
			}
		wcsncpy(t_text, mpd_text + t_pos, MPD_TEXT_SIZE);
		len = wcslen(mpd_text + t_pos);
		if (len > MPD_TEXT_SIZE)
			len = MPD_TEXT_SIZE;
		t_text[len] = L'\0';

		swprintf(new_text, text_size, L"%-20ls", t_text);
		sprintf(dzen_str, "^ca(1,./status-mpd.sh)%s^ca() ^fg(#aa0)%ls^fg()",
			is_lf_submit
				? "^fg(#0a0)^i(icons/note.xbm)^fg()"
				: "^ca(3,bash -c 'killall status-mpd.sh &>/dev/null ; mpd --kill ; killall mpdscribble')^i(icons/note.xbm)^ca()"
			, new_text);
		}
	if (!is_lf_submit && mpd_send(sockfd, "status\n") != -1) {
		if ((buf = mpd_recv(sockfd)) == NULL || strlen(buf) <= 0)
			return;
		// find time
		idx = strstr(buf, "time: ");
		if (idx != NULL) {
			idx += strlen("time: ");
			len = strstr(idx, "\n") - idx;
			*(idx+len) = 0;
			*(strstr(idx, ":")) = 0;
			time_pos = atoi(idx);
			time_total = atoi(idx+strlen(idx) + 1);
			const int width = 136;
			sprintf(dzen_str+strlen(dzen_str), "^ib(1)^fg(#aaa)^p(_BOTTOM)^p(-%d;-3)^p(_LOCK_X)^ro(%dx3)^fg(#aaa)^p(1;1)^r(%dx1)^p(_UNLOCK_X)^p(%d)^p()^ib(0)", width+2, width, width*time_pos/time_total, width-1);
			}
		}
	}


void update_sound(int ID) {
	char *dzen_str = tmp_dzen[ID];
	// http://code.google.com/p/yjl/source/browse/Miscellaneous/get-volume.c
	const char *ATTACH = "default";
	const snd_mixer_selem_channel_id_t CHANNEL = SND_MIXER_SCHN_FRONT_LEFT;
	const char *SELEM_NAME = "Master";
	long vol, vol_min, vol_max;
	int percentage;
	int switch_value;
	
	snd_mixer_t *h_mixer;
	snd_mixer_selem_id_t *sid;
	snd_mixer_elem_t *elem ;

	snd_mixer_open(&h_mixer, 1);
	snd_mixer_attach(h_mixer, ATTACH);
	snd_mixer_selem_register(h_mixer, NULL, NULL);
	snd_mixer_load(h_mixer);

	snd_mixer_selem_id_alloca(&sid);
	snd_mixer_selem_id_set_index(sid, 0);
	snd_mixer_selem_id_set_name(sid, SELEM_NAME);

	elem = snd_mixer_find_selem(h_mixer, sid);

	snd_mixer_selem_get_playback_volume(elem, CHANNEL, &vol);
	snd_mixer_selem_get_playback_volume_range(elem, &vol_min, &vol_max);
	snd_mixer_selem_get_playback_switch(elem, CHANNEL, &switch_value);
	snd_mixer_close(h_mixer);
	percentage = 100 * vol / vol_max;
	
	sprintf(dzen_str, "^ca(1,urxvtc -name 'dzen-status-sound' -title 'Sound Mixer' -geometry 160x40 -e alsamixer)^i(icons/spkr_01.xbm)^ca() ");
	if (switch_value) 
		sprintf(dzen_str+strlen(dzen_str), "^fg(#%02xaaaa)%3d%%^fg()", 176-percentage*176/100, percentage);
	else
		sprintf(dzen_str+strlen(dzen_str), "^fg(#a00)%3d%%^fg()", percentage);

	const int width = 40;
	sprintf(dzen_str+strlen(dzen_str), "^ib(1)^fg(#aaa)^p(_BOTTOM)^p(-%d;-3)^p(_LOCK_X)^ro(%dx3)^fg(#aaa)^p(1;1)^r(%dx1)^p(_UNLOCK_X)^p(%d)^p()^ib(0)", width+2, width, width*percentage/100, width-1);
	}

void update_clock(int ID) {
	time_t t;
	struct tm *tmp;
	char *dzen_str = tmp_dzen[ID];

	t = time(NULL);
	tmp = localtime(&t);
	strftime(dzen_str, 256, "^ca(1,./status-clock.sh)^i(icons/clock.xbm)^ca() %A, %B %d, %Y %H:%M:%S", tmp);
	}

void update_next_ts(int ID) {
	struct timeval t;
	gettimeofday(&t, NULL);

	update_ts[ID] = t.tv_sec*1000000 + t.tv_usec + update_funcs[ID].interval;
	}

int main(void) {
	int i;
	uint64_t ts_current;
	struct timeval t;
	FILE *dzen;

	// http://www.cl.cam.ac.uk/~mgk25/unicode.html#c
	if (!setlocale(LC_CTYPE, "")) {
		fprintf(stderr, "Can't set the specified locale! "
			"Check LANG, LC_CTYPE, LC_ALL.\n");
		return 1;
		}

	chdir("/home/livibetter/.dzen");
	
	dzen = popen("dzen2 -bg '#303030' -fg '#aaa' -fn 'Envy Code R-9' -x 840 -y 0 -w 840 -h 17 -ta right -e 'button3='", "w");
	if (!dzen) {
		fprintf (stderr, "can not open dzen2.\n");
		return 1;
		}

	update_ts = (uint64_t *)malloc(UPDATE_FUNCS * sizeof(uint64_t));
	tmp_dzen = (char **)malloc(UPDATE_FUNCS * sizeof(char *));
	for (i=0; i< UPDATE_FUNCS; i++) {
		tmp_dzen[i] = (char *)malloc(320);
		// initalizing
		update_funcs[i].fp(i);
		}

	for (;;) {
		gettimeofday(&t, NULL);
		ts_current = t.tv_sec*1000000 + t.tv_usec;

		for (i=0; i<UPDATE_FUNCS; i++) {
			if (ts_current >= update_ts[i]) {
				update_funcs[i].fp(i);
				update_next_ts(i);
				}
			}

		new_dzen[0] = 0;
		for (i=0; i<UPDATE_FUNCS; i++) {
//			printf("%d: %d\n", i, (unsigned int) strlen(tmp_dzen[i]));
			if (i>0)
				strcat(new_dzen, " ");
			strcat(new_dzen, tmp_dzen[i]);
			}
		strcat(new_dzen, " ^ca(1,./status-misc.sh)^ca(3,./status-clouds.sh)^i(icons/info_01.xbm)^ca()^ca() ");
//		printf("*: %d\n", (unsigned int) strlen(new_dzen));

		if (strcmp(old_dzen, new_dzen)) {
			fprintf(dzen, "%s\n", new_dzen);
			fflush(dzen);
			strcpy(old_dzen, new_dzen);
			}
		usleep(SLEEP);
		}
	// pclose(dzen);
	// free(update_ts);
	// ...
	}
