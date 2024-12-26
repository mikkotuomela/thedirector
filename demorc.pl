# This is the "demorc" file, it defines which effects to show.
# Any perl code is, of course, allowed here.
#
# all coding by Mikko "Ravel" Tuomela, <mikko@tuomela.net>


# AVAILABLE EFFECTS
# #################
#
# TEXT ZOOMER
# Synopsis:
#     zoom_text(text, direction, duration);
# Example:
#     zoom_text("WELCOME", out, 3);
# Notes:
# - available directions are in and out
#
# SCROLLTEXT
# Synopsis:
#     part_scrolltext(text, sinuswavedepth, sinuswavespeed, duration);
# Example: 
#     part_scrolltext("WELCOME TO MY DEMO", 5, 12, 7.5);
#
# BLOBS
# Synopsis:
#     part_blobs(numberofblobs, duration);
# Example:
#     part_blobs(3, 20);
# Notes:
# - the number of blobs should be even
#
# PIXMAP ROTOZOOMER (WITH MOTION BLUR)
# Synopsis:
#     zoom_pixmap(filename, duration);
# Example:
#     zoom_pixmap("babe.pgm", 30);
# Notes:
# - the picture must be in type 5 PGM format with 256 grays
# - the picture should be an exact square
# - if $motionblur > 0 then motion blur is used
# - the best value for $motionblur might be 49
#
# 3D STAR EFFECTS (WITH MOTION BLUR)
#   3D Star Tunnel:
#     part_tunnel(duration);
#   3D Star Tunnel 2:
#     part_tunnel2(duration);
#   3D Starfield:
#     part_stars(duration);
#   Explosion:
#     part_explosion(duration);
#   2001 Style Floors:
#     part_floors(duration);
#   2001 Style Floors 2:
#     part_floors2(duration);
#   Dot Tunnel:
#     part_dottunnel(duration);
# Notes:
# - if $motionblur > 0 then motion blur is used
# - the best value for $motionblur might be 49
# - the screen has 1 / $flash probability to flash with inverse background
# - $flash = 1      => inverse bg all the time
# - $flash = 999999 => (almost) no flashing
#
# DO NOTHING
# Synopsis:
#     do_nothing(duration);
# Example:
#     do_nothing(2);
# Notes:
# - also clears the screen

# set the default motion blur value
my $mb = 49;

# set the initial flash rate
$flash = 5;

# t = 0:00
zoom_text("P E R L",       in,  5);
# ---------------------------------
#                               5 s

# t = 0:05
part_scrolltext("   PERL5 + VT100 - ALL YOU NEED!", 
                        3, 10, 15);
part_scrolltext("   AAARRGH!!!", 
		        6, 15, 10);
# ---------------------------------
#                              25 s

# t = 0:30
zoom_text("SLEBER EID",    out, 5);
zoom_text("PRESENTS",      out, 1);
zoom_text("AT",            out, 1);
zoom_text("ALTERNATIVE",   out, 1);
zoom_text("PARTY",         out, 1);
zoom_text("2003",          out, 1);
do_nothing(                     1);
zoom_text("THE DIRECTOR",  out, 5);
do_nothing(                     1);
zoom_text("CODE BY",       out, 1);
zoom_text("RAVEL",         out, 1);
do_nothing(                     1);
# ---------------------------------
#                              20 s

# t = 0:50
part_blobs(3,                  15);
# ---------------------------------
#                              15 s

# t = 1:05
zoom_text("MEET",          in,  2);
zoom_text("ANSKULI!",      in,  2);
zoom_pixmap("picture.pgm",     41);
# ---------------------------------
#                              45 s

# t = 1:50
zoom_text("SHE IS ",       in,  1);
zoom_text("EVEN",          in,  1);
zoom_text("CUTER",         in,  1);
zoom_text("WITH",          in,  1);
zoom_text("MOTION",        in,  1);
zoom_text("BLUR!!!",       in,  1);
$motionblur = $mb;
zoom_pixmap("picture.pgm",     44);
$motionblur = 0;
# ---------------------------------
#                              50 s

# t = 2:40
zoom_text("ENOUGH",        in,  1);
zoom_text("SLOW",          in,  1);
zoom_text("MOTION?",       in,  1);
part_tunnel2(                   1);
part_explosion(                .2);
part_explosion(                .4);
part_explosion(                .2);
part_explosion(               1.5);
part_explosion(                .2);
part_explosion(               5.5);
# ---------------------------------
#                              12 s

# t = 2:52
zoom_text("TRUTH",         in,  1);
part_tunnel2(                   2);
part_dottunnel(                 5);
part_stars(                     1);
# ---------------------------------
#                               9 s

# t = 3:01
zoom_text("CAN",           in,  1);
part_dottunnel(                 5);
part_tunnel2(                   1);
part_tunnel(                   .5);
part_tunnel2(                  .5);
part_tunnel(                   .5);
part_tunnel2(                  .5);
# ---------------------------------
#                               9 s

# t = 3:10
zoom_text("BE",            in,  1);
part_stars(                     3);
$flash = 3;
part_floors2(                   1);
$flash = 5;
part_floors(                    4);
# ---------------------------------
#                               9 s

# t = 3:19
zoom_text("FOUND",         in,  1);
part_tunnel2(                   2);
part_stars(                     3);
part_dottunnel(                 1);
part_tunnel(                   .5);
part_tunnel2(                  .5);
part_explosion(                 1);
# ---------------------------------
#                               9 s

# t = 3:28
zoom_text("IN",             in, 1);
part_floors(                    8);
# ---------------------------------
#                               9 s

# t = 3:37
zoom_text("SCENE",         in,  1);
$motionblur = $mb;
part_floors2(                   1);
part_floors(                    1);
$motionblur = 0;
part_dottunnel(                 2);
part_tunnel(                    4);  
# ---------------------------------
#                               9 s

# t = 3:46
zoom_text("POETRY!",       in,  1);
$motionblur = $mb;
$flash = 3;
part_tunnel2(                   2);
part_floors(                    2);
$flash = 3;
part_tunnel(                    5);
$flash = 5;
part_floors2(                   3);
part_floors(                    5);
part_dottunnel(                 3);
part_tunnel2(                   1);
part_tunnel(                    1);
part_tunnel2(                   1);
part_tunnel(                    1);
part_tunnel2(                   1);
$flash = 10;
part_tunnel(                   10);
$flash = 999999;
part_tunnel2(                  .5);
$flash = 1;
part_tunnel2(                  .5);
$flash = 999999;
part_tunnel2(                  .5);
$flash = 1;
part_tunnel2(                  .5);
$flash = 999999;
part_tunnel2(                  .5);  
$flash = 1;
part_tunnel2(                  .5);
$flash = 999999;
part_tunnel2(                  .5);
$flash = 5;
part_floors2(                 4.5);
# ---------------------------------
#                              44 s  

# t = 4:30
zoom_text("MEMBERS",       out, 1);
zoom_text("OF",            out, 1);
zoom_text("SLEBER EID",    out, 1);
zoom_text("ARE:",          out, 1);
zoom_text("SETOK",         out, 1);
zoom_text("RAVEL",         out, 1);
zoom_text("JYRGEN",        out, 1);
zoom_text("HURU-UKKO",     out, 1);
zoom_text("GFANREND",      out, 1);
zoom_text("MSK",           out, 1);
# ---------------------------------
#                              10 s

# t = 4:40
$flash = 999999;
$motionblur = $mb;
part_floors(                   12);
$motionblur = 0;
# ---------------------------------
#                              12 s

# t = 4:52
zoom_text("GREETINGS TO:", out, 2);
zoom_text("UBBU",          out, 1);
zoom_text("TAAT",          out, 1);
zoom_text("AGGRESSION",    out, 1);
zoom_text("PWP",           out, 1);
zoom_text("BYTERAPERS",    out, 1);
zoom_text("DEKADENCE",     out, 1);
zoom_text("CNCD",          out, 1);
zoom_text("MFX",           out, 1);
zoom_text("ARMADA",        out, 1);
zoom_text("LIMBO",         out, 1);
zoom_text("MARS",          out, 1);
zoom_text("LLAMASOFT",     out, 1);
zoom_text("KASVUA",        out, 1);
zoom_text("SCENEBOYLOVE",  out, 1);
do_nothing(                     1);
# ---------------------------------
#                              17 s

# t = 5:09
zoom_text("THANKS TO:",    out, 2);
zoom_text("ANSKULI",       out, 1);
zoom_text("FISHPOOL",      out, 1);
# ---------------------------------
#                               4 s

do_nothing(                     1);
zoom_text("MUSIC BY",      out, 1);
zoom_text("RAVEL",         out, 1);
do_nothing(                     1);

# t = 5:13
do_nothing(                     1);
zoom_text("POMOT!",        in,  5);
# ---------------------------------
#                               6 s

# Total time:
# t = 5:19
