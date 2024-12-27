#!/usr/bin/perl
#
# THE DIRECTOR by Sleber Eid
# Released at Alternative Party 2003
# 10th-12th January 2003 at Gloria, Helsinki, Finland
#
# Code and music by Mikko "Ravel" Tuomela <mikko@tuomela.net>
#
# Requires Perl 5 with HiRes.pm and a VT100 compatible terminal
#
# The files:
# --------------------------------------------------------------------
# TheDirector.pl      This file; the code
# demorc              Configuration file, the order of effects
# picture.pgm         The picture to be used with rotozoomer
# font.txt            Font file
#
# Usage:
# % ./demo.pl <x> <y> <aspectratio>

use strict;
use Time::HiRes qw(usleep gettimeofday tv_interval);

######################################################################
#
# Uncomment to suit to your OS:
#
# UNIX(R)/Linux/whatever:
my $cat = "cat";
#
# Microsoft(R) Windows(R):
#my $cat = "type";
#
######################################################################

######################################################################
#
# The command to execute the MP3 player:
my $startmusic = "mpg123 music.mp3 &";
#
# No music:
#my $startmusic = "";
#
######################################################################

######################################################################
#
# The amount of stars in the star effects:
my $amount = 500;
#
######################################################################


$| = 1;
my $pi = 3.141592654;                      # constant!

my $cols = $ARGV[0] - 2;
my $rows = $ARGV[1] - 2;
my $aspectratio = $ARGV[2];
if($aspectratio eq "" || $aspectratio == 0) {
    $aspectratio = 1;
}

if($cols eq "" || $rows eq "") {
    print "Not enough parameters!\n";
    die;
}

# load font
my $line;
my %font;
my $temp;
print "Loading font...\n";
open(FONT, "font.txt") or die "$!";
while($line = <FONT>) {
    chomp($line);
    if($line eq "END") {
	last;
    } else {
	for my $i (0 .. 6) {
	    $temp = <FONT>; chomp($temp);
	    $temp .= " " x (8 - length($temp));
	    $font{$line}[$i] = $temp;
	}
    }
}
close FONT;
$font{' '} = (["        ","        ","        ","        ","        ","        ","        "]);

my @emptyscreen;                           # this is slow...
my @fullscreen;
my $empty;
for my $i (0 .. $rows) {
    $emptyscreen[$i] = " " x ($cols + 2);
    $fullscreen[$i] = "O" x ($cols + 2);
    $empty .= $emptyscreen[$i] . "\n";
}
my @screen = @emptyscreen;
my @screenarray;

my $depth = 150;                           # "depth" of the 3d space

# calculate zoom factors for 3d
print "Precalc phase 1...\n";
my $basezoom = 20;                         # 10-30 is good
my @zoom;
for my $z (1 .. $depth * 20) {
    $zoom[$z] = $basezoom / ($z / 10);
#    print "$z: $zoom[$z]\n";
}
$zoom[0] = 100000;                         # bugfix

# precalc rotation
print "Precalc phase 2...\n";
my @rotate;
for my $degree (0 .. 360) {
    $rotate[$degree][0] = sin($degree * $pi / 180);
    $rotate[$degree][1] = cos($degree * $pi / 180);
}

# precalc hypothenuses
print "Precalc phase 3...\n";
my @dist;
for my $y (0 .. 4 * $cols) {
    for my $x (0 .. 4 * $rows) {
        $dist[$x][$y] = int(sqrt($x ** 2 + $y ** 2));
    }
}

# precalc light
print "Precalc phase 4...\n";
my @light;
for my $y (0 .. $cols) {
    for my $x (0 .. 4 * $rows) {
	if($x == 0 && $y == 0) {
	    $light[$x][$y] = 1;
	} else {
	    $light[$x][$y] = 1 / ($x ** 2 + $y ** 2);
	}
    }
}
my @stars;
#@stars = ("\240", "\240", "\240", "\240", "\240", 
#	  "\240", "\240", "\240", "\240", "\240");
#@stars = (" ", " ", " ", " ", " ", " ", " ", " ", " ", " ");
my @star;                                  # star array
my @base;                                  # stars' start position
my @speed;                                 # speed array
my $x;                                     # screen x coordinate
my $y;                                     # screen y coordinate
my $dest = $depth / 10;                    # factor to choose stars
my $rcols = int($cols / 2);                # half the screen
my $rrows = int($rows / 2);                # half the screen
my $sdepth;                                # speeds things up
my @min;
my @max;
my @room;
my $bordercheck;
my $rotation_speed = 0;
my $degree;
my $degree_start;
my $flash = 999999;
my $motionblur = 0;
my $eightbitdepth = 255 / $depth;

print "Executing MP3 player...";
#`$startmusic`;
system("mpg123 music.mp3 &");

sleep 1;

print &terminal_reset;

@stars = (".", ".", ".", ".", "o", "o", "*", "*", "O", "O");

# start timing
my $deadline = 0;
my $time = [gettimeofday];

##########################################################
eval `$cat demorc.pl`;                     # do everything
##########################################################

# reset the terminal after the demo ends
#print &terminal_reset;

# write possible output to a file
# ----------------------------------------------------------------------
sub k {
    my $endtime = tv_interval($time);
    `echo $endtime > output.txt`;
    die;
}

# do nothing
# -----------------------------------------------------------------------
sub do_nothing {
    my ($duration) = @_;
    print &terminal_reset . $empty;
    $deadline += $duration;
    nap();
}

# take a nap until the end of the time reserved for the effect
# ------------------------------------------------------------------------
sub nap {
    print &terminal_reset . $empty;
    my $naptime = 1000000 * ($deadline - tv_interval($time));
    if($naptime > 0) {
	usleep $naptime;
    }
}

# parts
# -----------------------------------------------------------------------
# blobs
sub part_blobs {
    my ($blobs, $duration) = @_;
    my $text = "slebereid";
    my $tempchar;

    my @bg;
    for my $frame (0 .. 3) {
    	for my $y (0 .. $rows) {
    	    for my $x (0 .. $cols) {
        		$tempchar = substr($text, $x % length($text), 1);
        		if(rand 10 < 5) {
        		    $bg[$frame][$x][$y] = lc($tempchar);
        		} else {
        		    $bg[$frame][$x][$y] = uc($tempchar);
        		}
    	    }
    	}			
    }

    my @coords;
    for my $blob (0 .. $blobs) {
    	$coords[$blob] = [rand $cols, 
    			  rand $rows, 
    			  5 - rand 10, 
    			  5 - rand 10, 
    			  0, 
    			  0];
    	$coords[$blob][4] = int($coords[$blob][0]);
    	$coords[$blob][5] = int($coords[$blob][1]);
    }

    my $height;
    my $picture;
    my $frame = 0;
    my $neg = -1;
    my $t0;
    my $t1;
    my $now;
    my $timeperframe;
    my $i = 1;
    my $fps;
    my $timeleft;

    print &terminal_reset;

    $t0 = [gettimeofday];
    $now = tv_interval($time);
    $t1 = 0;

    $deadline += $duration;

    while($now < $deadline) {
    	$picture = "";
    	for my $y (0 .. $rows) {
    	    for my $x (0 .. $cols) {
        		$height = 0;
        		for my $blob (0 .. $blobs) {
        		    $height += $neg * ($blob + 2) * 
        			$dist[abs($x - $coords[$blob][4])]
        			     [abs($y - $coords[$blob][5])];
        		    $neg = -$neg;
        		}
        		if($height < -70 || abs($height) < 20) {
        		    $picture .= " ";
        		} else {
        		    $picture .= $bg[$frame][$x][$y];
        		}
    	    }
    	    $picture .= "\n";
    	}
    	print &terminal_home . $picture;
    	
    	for my $blob (0 .. $blobs) {
    	    $coords[$blob][0] += $coords[$blob][2];
    	    $coords[$blob][1] += $coords[$blob][3];
    	    if($coords[$blob][0] < 0 || $coords[$blob][0] > $cols) {
    		    $coords[$blob][2] = -$coords[$blob][2];
    	    }
    	    if($coords[$blob][1] < 0 || $coords[$blob][1] > $rows) {
    		    $coords[$blob][3] = -$coords[$blob][3];
    	    }
    	    $coords[$blob][4] = int($coords[$blob][0]);
    	    $coords[$blob][5] = int($coords[$blob][1]);
    	}
    	$t1 = tv_interval($t0);
    	$now = tv_interval($time);
    	$timeperframe = $t1 / $i;
    	$timeleft = $deadline - $now;
    	if($timeperframe > $timeleft) {
    	    last;
    	}
    	$frame++;
    	$frame = $frame % 4;
    
    	$i++;
    }
    nap();
}

# scrolltext
sub part_scrolltext {
    my ($text, $depth, $wavespeed, $duration) = @_;
    my $factor = $rows / 7;
    my @lines = make_text($text . " " x ($cols / $factor / 8));
    my $picture;
    my $maxoffset = $factor * 8 * length($text);
    my $wave;
    my $xoffset = 0;
    my $scrollspeed;

    my $t0;
    my $t1;
    my $now;

    print &terminal_reset;

    $t0 = [gettimeofday];
    $now = tv_interval($time);
    $t1 = 0;

    $deadline += $duration;

#    $wavespeed *= $rows / 50;
    $depth *= $aspectratio;

    while($now < $deadline) {
    	$picture = "";
    	$wave = 5 * $xoffset % 360;
    	for my $y (0 .. $rows) {
    	    for my $x (0 .. $cols) {
        		$picture .= substr($lines[$y / $factor], 
        				    ($x + $xoffset + $rotate[$wave][0] * 
        				     $depth) / $factor, 
        				    1);
    	    }
    	    $picture .= "\n";
    	    $wave += $wavespeed;
    	    if($wave > 359) {
    		    $wave -= 360;
    	    }
    	}
    	print &terminal_home . $picture;
    
    	$t1 = tv_interval($t0);
    	$now = tv_interval($time);
    	$xoffset = ($t1 / $duration) * $maxoffset;
    }
    nap();
}

# cube
sub part_cube {
    my ($duration) = @_;
    print &terminal_reset;
    @min  = (-20 * $cols, -20 * $rows, 1);
    @max  = ( 20 * $cols,  20 * $rows, $depth - 1);
    @room = ( 40 * $cols,  40 * $rows, $depth - 1);    
    initialize_cube();
    $bordercheck = 0;
    $degree = $degree_start = 0;
    $rotation_speed = 0;
    for my $frame (0 .. $duration) {
    	refresh();
    	move();
    }
}

# explosion
sub part_explosion {
    my ($duration) = @_;
    print &terminal_reset;
    @min  = (-20 * $cols, -20 * $rows, 1);
    @max  = ( 20 * $cols,  20 * $rows, $depth - 1);
    @room = ( 40 * $cols,  40 * $rows, $depth - 1);    
    initialize_explosion();
    $bordercheck = 0;
    $degree = $degree_start = 0;
    $rotation_speed = 0;
    my $t0 = [gettimeofday];
    my $now = tv_interval($time);
    my $t1 = 0;
    $deadline += $duration;
    while ($now < $deadline) {
	refresh();
	$t1 = tv_interval($t0);
	$now = tv_interval($time);
	move($t1);
    }
    nap();
}

# star tunnel
sub part_tunnel {
    my ($duration) = @_;
    print &terminal_reset;
    @min  = (-2 * $cols, -2 * $rows, 1);
    @max  = ( 2 * $cols,  2 * $rows, $depth - 1);
    @room = ( 4 * $cols,  4 * $rows, $depth - 1);    
    initialize_tunnel();
    $bordercheck = 1;
    $degree = $degree_start = 0;
    $rotation_speed = -30;
    my $t0 = [gettimeofday];
    my $now = tv_interval($time);
    my $t1 = 0;
    $deadline += $duration;
    while ($now < $deadline) {
    	refresh();
    	$t1 = tv_interval($t0);
    	$now = tv_interval($time);
    	move($t1);
    }
    nap();
}

# star tunnel2
sub part_tunnel2 {
    my ($duration) = @_;
    print &terminal_reset;
    @min  = (-2 * $cols, -2 * $rows, 1);
    @max  = ( 2 * $cols,  2 * $rows, $depth - 1);
    @room = ( 4 * $cols,  4 * $rows, $depth - 1);    
    initialize_tunnel2();
    $bordercheck = 1;
    $degree = $degree_start = 0;
    $rotation_speed = 90;
    my $t0 = [gettimeofday];
    my $now = tv_interval($time);
    my $t1 = 0;
    $deadline += $duration;
    while ($now < $deadline) {
    	refresh();
    	$t1 = tv_interval($t0);
    	$now = tv_interval($time);
    	move($t1);
    }
    nap();
}

# dot tunnel
sub part_dottunnel {
    my ($duration) = @_;
    print &terminal_reset;
    @min  = (-2 * $cols, -2 * $rows, 1);
    @max  = ( 2 * $cols,  2 * $rows, $depth - 1);
    @room = ( 4 * $cols,  4 * $rows, $depth - 1);    
    initialize_dottunnel();
    $bordercheck = 1;
    $degree = $degree_start = 0;
    $rotation_speed = -135;
    my $t0 = [gettimeofday];
    my $now = tv_interval($time);
    my $t1 = 0;
    $deadline += $duration;
    while ($now < $deadline) {
    	refresh();
    	$t1 = tv_interval($t0);
    	$now = tv_interval($time);
    	move($t1);
    }
    nap();
}

# 2001 floors
sub part_floors {
    my ($duration) = @_;
    print &terminal_reset;
    @min  = (-4 * $cols, -2 * $rows, 1);
    @max  = ( 4 * $cols,  2 * $rows, $depth - 1);
    @room = ( 8 * $cols,  4 * $rows, $depth - 1);    
    initialize_floors();
    $bordercheck = 1;
    $degree = $degree_start = 90;
    $rotation_speed = -22.5;
    my $t0 = [gettimeofday];
    my $now = tv_interval($time);
    my $t1 = 0;
    $deadline += $duration;
    while ($now < $deadline) {
    	refresh();
    	$t1 = tv_interval($t0);
    	$now = tv_interval($time);
    	move($t1);
    }
    nap();
#    $degree = 90 * cos($frame / 100);
}

# 2001 floors2
sub part_floors2 {
    my ($duration) = @_;
    print &terminal_reset;
    @min  = (-4 * $cols, -2 * $rows, 1);
    @max  = ( 4 * $cols,  2 * $rows, $depth - 1);
    @room = ( 8 * $cols,  4 * $rows, $depth - 1);    
    initialize_floors();
    $bordercheck = 1;
    $degree = $degree_start = 90;
    $rotation_speed = -180;
    my $t0 = [gettimeofday];
    my $now = tv_interval($time);
    my $t1 = 0;
    $deadline += $duration;
    while ($now < $deadline) {
    	refresh();
    	$t1 = tv_interval($t0);
    	$now = tv_interval($time);
    	move($t1);
    }
    nap();
}

# traditional 3d stars
sub part_stars {
    my ($duration) = @_;
    print &terminal_reset;
    @min  = (-2 * $cols, -2 * $cols, 1);
    @max  = ( 2 * $cols,  2 * $cols, $depth - 1);
    @room = ( 4 * $cols,  4 * $cols, $depth - 1);    
    initialize_stars();
    $bordercheck = 1;
    $degree = $degree_start = 0;
    $rotation_speed = 0;
    my $t0 = [gettimeofday];
    my $now = tv_interval($time);
    my $t1 = 0;
    $deadline += $duration;
    while ($now < $deadline) {
    	refresh();
    	$t1 = tv_interval($t0);
    	$now = tv_interval($time);
    	move($t1);
    }
    nap();
}

# initialize 3d star effects
# -------------------------------------------------------------------------
# rotating cube
sub initialize_cube {
    my $side = int($amount ** (1/3));
    my $i = 0;
    for my $z (0 .. $side - 1) {
    	for my $y (0 .. $side - 1) {
    	    for my $x (0 .. $side - 1) {
    		$star[$i][0] = -20 + $x * (40 / ($side - 1));
    		$star[$i][1] = -20 + $y * (40 / ($side - 1));
    		$star[$i][2] =  20 + $z * (40 / ($side - 1));
    		$speed[$i][0] = 0;
    		$speed[$i][0] = 0;
    		$speed[$i][0] = 0;
    		$i++;
    	    }
    	}
    }
    for my $j ($i .. $amount) {
    	$star[$j][0] = 999999;
    	$star[$j][1] = 999999;
    	$star[$j][2] = 999999;
    	$speed[$j][0] = 0;
    	$speed[$j][0] = 0;
    	$speed[$j][0] = 0;
    }
}
# 2001-style "floors"
sub initialize_floors {
    for my $i (0 .. $amount) {
        $star[$i][0] = $base[$i][0] = int(rand (4 * $cols) - 2 * $cols);
        $star[$i][1] = $base[$i][1] = (-1) ** int(rand 2) * 30;
        $star[$i][2] = $base[$i][2] = 1 + int(rand $depth - 1);
    	$speed[$i][0] = 0;
    	$speed[$i][1] = 0;
    	$speed[$i][2] = -2;
    }
}
# star tunnel
sub initialize_tunnel {
    my $d;
    my $radius = $rows;
    for my $i (0 .. $amount) {
    	$d = rand 360;
    	$star[$i][0] = $base[$i][0] = int($radius * $rotate[$d][0]); 
    	$star[$i][1] = $base[$i][1] = int($radius * $rotate[$d][1]);
    	$star[$i][2] = $base[$i][2] = int(1 + rand $depth);
    	$speed[$i][0] = 0;
    	$speed[$i][1] = 0;
    	$speed[$i][2] = 2;
    }
}
# star tunnel2
sub initialize_tunnel2 {
    my $d;
    my $radius = $rows;
    for my $i (0 .. $amount) {
    	$d = int(rand 360);
    	$star[$i][0] = $base[$i][0] = int($radius * $rotate[$d][0]); 
    	$star[$i][1] = $base[$i][1] = int($radius * $rotate[$d][1]);
    	$star[$i][2] = $base[$i][2] = int(1 + rand $depth);
    	$speed[$i][0] = 0;
    	$speed[$i][1] = 0;
    	$speed[$i][2] = -5;
    }
}
# dot tunnel
sub initialize_dottunnel {
    my $radius = $rows;
    my $circleamount = int($amount / 15);
    my $i;
    my $dotcount = 0;
    for my $circle (0 .. 14) {
    	for my $dot (0 .. $circleamount - 1) {
    	    $i = $circle * $circleamount + $dot;
    	    $star[$i][0] = $base[$i][0] = 
    		    $cols * sin(2 * $pi * $circle * 10 / 150) + 
    		    int($radius * $rotate[$dot * 360 / $circleamount][0]);
    	    $star[$i][1] = $base[$i][1] = 
    		    .5 * $rows * cos(2 * $pi * $circle * 10 / 75) +
    		    int($radius * $rotate[$dot * 360 / $circleamount][1]);
    	    $star[$i][2] = $base[$i][2] = $circle * 10 + 5;
    	    $speed[$i][0] = 0;
    	    $speed[$i][1] = 0;
    	    $speed[$i][2] = -3;
    	    $dotcount++;
    	}
    }
    for my $i ($dotcount .. $amount) {
    	$star[$i][0] = 0;
    	$star[$i][1] = 0;
    	$star[$i][2] = 0;
    	$speed[$i][0] = 0;
    	$speed[$i][0] = 0;
    	$speed[$i][0] = 0;
    }
}
# explosion
sub initialize_explosion {
    my $d;
    my $e;
    my $f;
    for my $i (0 .. $amount) {
    	$star[$i][0] = $base[$i][0] = int(15 - rand 30);
    	$star[$i][1] = $base[$i][1] = int(15 - rand 30);
    	$star[$i][2] = $base[$i][2] = int(15 - rand 30) + int($depth / 2) - 10;
    	$speed[$i][0] = (-1) ** int(rand 2) * (4 + rand 2);
    	$speed[$i][1] = (-1) ** int(rand 2) * (4 + rand 2);
    	$speed[$i][2] = (-1) ** int(rand 2) * (4 + rand 2);
    	if(sqrt($speed[$i][0] ** 2 + 
    		$speed[$i][1] ** 2 + 
    		$speed[$i][2] ** 2) > 6) {
    	    $speed[$i][0] *= .5 * rand 1;
    	    $speed[$i][1] *= .5 * rand 1;
    	    $speed[$i][2] *= .5 * rand 1;
    	}
    }
}
# 3d stars
sub initialize_stars {
    for my $i (0 .. $amount) {
    	$star[$i][0] = $base[$i][0] = int(rand (4 * $cols) - 2 * $cols);
    	$star[$i][1] = $base[$i][1] = int(rand (4 * $cols) - 2 * $cols);
    	$star[$i][2] = $base[$i][2] = 1 + int(rand $depth - 1);
    	$speed[$i][0] = 0;
    	$speed[$i][1] = 0;
    	$speed[$i][2] = -3;
    }
}

# refresh 3d star screen
# ----------------------------------------------------------------------
sub refresh {
    my $pixel;
    my $picture = "";
    my $white = 0;
    my @blank = ("O", " ");
    if(rand $flash < 1) {
	    $white = 0;
    } else {
	    $white = 1;
    }

    if($motionblur == 0) {
    	# normal
    	if($white == 0) {
    	    @screen = @fullscreen;
    	} else {
    	    @screen = @emptyscreen;
    	}
    	for my $i (0 .. $amount) {
    	    $sdepth = $star[$i][2];             # speed up things
    	    if($degree == 0) {
        		$x = $rcols + $aspectratio * $zoom[$sdepth * 10] 
        		    * $star[$i][0];             # screen x
        		$y = $rrows + $zoom[$sdepth * 10]
        		    * $star[$i][1];             # screen y
    	    } else {
        		$x = $rcols + $aspectratio * $zoom[$sdepth * 10] * 
        		    ($star[$i][0] * $rotate[$degree][1] -
        		     $star[$i][1] * $rotate[$degree][0]);    # screen x
        		$y = $rrows + $zoom[$sdepth * 10] * 
        		    ($star[$i][0] * $rotate[$degree][0 * 10] +
        		     $star[$i][1] * $rotate[$degree][1]);    # screen y
    	    }
    	    if(0 < $x && $x < $cols && 0 < $y && $y < $rows){# fits on screen?
        		substr($screen[$y], $x, 1) = 
        		    $stars[($depth - $sdepth) / $dest];
    	    }
    	}
    	for my $i (0 .. $rows) {
    	    $picture .= $screen[$i] . "\n";
    	}
    } elsif($motionblur > 0) {
    	# motion blur
    
    	# calculate pixels
    	for my $i (0 .. $amount) {
    	    $sdepth = $star[$i][2];
    	    if($degree == 0) {
        		$x = $rcols + $aspectratio * $zoom[$sdepth * 10] 
        		     * $star[$i][0];                          # screen x
        		$y = $rrows + $zoom[$sdepth * 10] 
        		     * $star[$i][1];                          # screen y
    	    } else {
        		$x = $rcols + $aspectratio * $zoom[$sdepth * 10] * 
        		     ($star[$i][0] * $rotate[$degree][1] -
        		      $star[$i][1] * $rotate[$degree][0]);    # screen x
        		$y = $rrows + $zoom[$sdepth * 10] * 
        		     ($star[$i][0] * $rotate[$degree][0] +
        		      $star[$i][1] * $rotate[$degree][1]);    # screen y
    	    }
    	    if(0 < $x && $x < $cols && 0 < $y && $y < $rows) {
        		$pixel = $screenarray[$x][$y];
        		$pixel += 255 - $eightbitdepth * ($sdepth - 1);
        		if($pixel > 255) {
        		    $pixel = 255;
        		}
        		$screenarray[$x][$y] = $pixel;
    	    }
    	}
    	# compile a picture from the data
    	for my $y (0 .. $rows) {
    	    for my $x (0 .. $cols) {
        		$pixel = $screenarray[$x][$y];
        		if($pixel > 1) {
        		    $picture .= $stars[$pixel / 25.6];
        		    $pixel -= $motionblur;
        		} else {
        		    $picture .= $blank[$white];
        		}
        		if($pixel < 0) {
        		    $pixel = 0; 
        		}
        		$screenarray[$x][$y] = $pixel;
    	    }
    	    $picture .= "\n";
    	}
    }
    print &terminal_home . $picture;
}

# move 3d stars
# -----------------------------------------------------------------------
sub move {
    my ($t1) = @_;
    my $instance;
    my $mbslow = 1 / (1 + 2 * ($motionblur > 0)); 
    for my $i (0 .. $amount) {
    	for my $n (0 .. 2) {
    	    $instance = $base[$i][$n] + $mbslow * 50 * $t1 * $speed[$i][$n];
    	    if($bordercheck == 1) {
        		$instance = $min[$n] + (($instance - $min[$n]) 
        					% $room[$n]);
    	    } elsif($instance < $min[$n] or $instance > $max[$n]) {
        		$instance = 1;
        		$speed[$i][$n] = 0;
    	    }
    	    $star[$i][$n] = $instance;
    	}
    }
    $degree = $degree_start + $t1 * $rotation_speed;
    $degree = $degree % 360;
}

# make text from font
# -----------------------------------------------------------------------
sub make_text {
    my ($text) = @_;
    my @result;
    for my $line (0 .. 6) {
    	for my $i (0 .. length($text) - 1) {
    	    $result[$line] .= $font{substr($text, $i, 1)}[$line];
    	}
    }
    @result;
}

# (un)zoom text
# -----------------------------------------------------------------------
sub zoom_text {
    my ($text, $speed, $duration) = @_;
    my @lines = make_text($text);
    my $width;
    my $height;
    my $xmin;
    my $ymin;
    my $xmax;
    my $ymax;
    my $xpixel;
    my $ypixel;
    my $picture;
    my $start;
    my $end;
    my $z;

    my $t0;
    my $t1;
    my $now;

    print &terminal_reset;

    if($speed < 0) {
    	$start = $depth - 1;
    	$end = 1;
    } else {
    	$start = 1;
    	$end = $depth;
    }
    $z = $start;

    $t0 = [gettimeofday];
    $now = tv_interval($time);
    $t1 = 0;

    $deadline += $duration;

    while($now < $deadline && $z > 0 && $z < $depth ) {
    	$width = 4 * $zoom[$z * 10] * length($lines[0]);
    	$height = 4 * $zoom[$z * 10] * 7;
    	$xmin = $rcols - $width / 2;
    	$ymin = $rrows - $height / 2;
    	$xmax = $rcols + $width / 2;
    	$ymax = $rrows + $height / 2;
    	
    	$picture = "";
    
    	for my $y (0 .. $rows) {
    	    for my $x (0 .. $cols) {
        		if($x > $xmin && $x < $xmax && 
        		   $y > $ymin && $y < $ymax) {
        		    $picture .= substr(@lines
        				       [($y - $ymin) / $zoom[$z * 10] / 4], 
        				       ($x - $xmin) / $zoom[$z * 10] / 4, 1);
        		} else {
        		    $picture .= " ";
        		}
    	    }
    	    $picture .= "\n";
    	}
    	print &terminal_home . $picture;
    
    	$t1 = tv_interval($t0);
    	$now = tv_interval($time);
    	$z = $start + $t1 * ($end - $start) / $duration;
    }
    nap();
}
# directions
sub in { -1; }
sub out { 1; }

# pixmap zoom (with motion blur)
#------------------------------------------------------------------------
sub zoom_pixmap {
    my ($filename, $duration) = @_;
    my @lines;
    my @picturearray = read_pgm($filename);
    my @screenarray;
    my $size = scalar(@picturearray);
    my $side;

    my @shades = (" ", ".", ":", "O");

    my $picture;
    my $piczoom = 4;
    my $picxzoom = 1;
    my $picyzoom = $aspectratio;

    my $z;
    my $degree;

    my $tempx;
    my $tempy;
    my $pixel;
    my $movex;
    my $movey;

    my $t0;
    my $t1;
    my $timeperframe;
    my $now;
    my $i = 1;

    print &terminal_reset;

    $t0 = [gettimeofday];
    $now = tv_interval($time);
    $t1 = 0;

    $deadline += $duration;

    while($now < $deadline) {
    	if($motionblur == 0) {	
    	    if($t1 < 5) {
    		    $z = $t1 * 60;
    	    } else {
        		$degree = (15 * $t1 - 75) % 360;
        		$z = 170 + 130 * $rotate[(18 * $t1 - 93.75) % 360][1];
    	    }
    	} else {
    	    $degree += $timeperframe * 4 * 
    		$rotate[(10 * $t1) % 360][0];
    	    $z = 170 - 130 * $rotate[(18 * $t1) % 360][1];
    	}
    	$side = $piczoom * $zoom[$z * 10] * $size;
    
    	$picture = "";
    
    	if($motionblur == 0) {
    	    $movex = 50 * $rotate[(20 * $t1 - 100) % 360][0];
    	    $movey = 50 * $rotate[(18 * $t1 -  90) % 360][0];
    	} else {
    	    $movex = 50 * $rotate[(10 * $t1) % 360][0];
    	    $movey = 50 * $rotate[(9 * $t1) % 360][0];
    	}
    
    	for my $y (0 .. $rows) {
    	    for my $x (0 .. $cols) {
        		if($t1 < 5 && $motionblur == 0) {
        		    $tempx = $x * $picxzoom - $rcols;
        		    $tempy = $y * $picyzoom - $rrows * $aspectratio;
        		} else {
        		    $tempx = $x * $picxzoom - $rcols + $movex;
        		    $tempy = $y * $picyzoom - $rrows * $aspectratio + $movey;
        		}
        		if($motionblur == 0) {
        		    # no motion blur
        		    if($degree == 0) {
            			$picture .= 
            			    $shades[$picturearray
            				    [modulus($tempx, $side) / $zoom[$z * 10] 
            				     / $piczoom]
            				    [modulus($tempy, $side) / $zoom[$z * 10] 
            				     / $piczoom] 
            				    / 64];
        		    } else {
            			$picture .= 
            			    $shades[$picturearray
            				    [modulus(($rotate[$degree][1] * $tempx -
            					      $rotate[$degree][0] * $tempy), 
            					     $side) / 
            				     $zoom[$z * 10] / $piczoom]
            				    [modulus(($rotate[$degree][0] * $tempx +
            					      $rotate[$degree][1] * $tempy),
            					     $side) /
            				     $zoom[$z * 10] / $piczoom]
            				    / 64];
        		    }
        		} else {
        		    # with motion blur
        		    $pixel = $screenarray[$x][$y];
        		    $pixel -= $motionblur;
        #		    $pixel *= .68; # alternative motion blur
        		    if($pixel < 0) {
        			    $pixel = 0;
        		    }
        		    if($degree == 0) {
            			$pixel += .28 *
            			    $picturearray
            				[modulus($tempx, $side) / $zoom[$z * 10] 
            				 / $piczoom]
            				[modulus($tempy, $side) / $zoom[$z * 10] 
            				 / $piczoom];
        		    } else {
            			$pixel += .28 *
            			    $picturearray
            				[modulus(($rotate[$degree][1] * $tempx -
            					  $rotate[$degree][0] * $tempy), 
            					 $side) /
            				 $zoom[$z * 10] / $piczoom]
            				[modulus(($rotate[$degree][0] * $tempx +
            					  $rotate[$degree][1] * $tempy), 
            					 $side) / 
            				 $zoom[$z * 10] / $piczoom];
        		    }
        		    if($pixel > 255) {
        			    $pixel = 255;
        		    }
        		    $picture .= $shades[$pixel / 64];
        		    $screenarray[$x][$y] = $pixel;
        		}
    	    }
    	    $picture .= "\n";
    	}
    	print &terminal_home . $picture;
    
    	$t1 = tv_interval($t0);
    	$now = tv_interval($time);
            $timeperframe = $t1 / $i;
    	if($now + $timeperframe > $deadline) {
    	    last;
    	}
    	$i++;
    }
    nap();
}

# float modulus
sub modulus {
    my ($a, $b) = @_;
    ($a * 1000) % ($b * 1000) / 1000;
}

# read file
# -------------------------------------------------------------------
sub read_file {
    my ($filename) = @_;
    my @lines;
    my $line;
    my $n = 0;
    my $maxlength = 0;

    open(FILE, $filename) or die "$!";
    while($line = <FILE>) {
    	chomp($line);
    	$lines[$n] = $line;
    	if(length($line) > $maxlength) {
    	    $maxlength = length($line);
    	}
    	$n++;
    }
    close FILE;
    
    $n--;
    
    for my $i (0 .. $n) {
    	$lines[$i] .= " " x ($maxlength - length($lines[$i]));
    }
    @lines;
}

# read pgm picture, return @picturearray
# ----------------------------------------------------------------------
sub read_pgm {
    my ($filename) = @_;
    my $pixel;
    my @picturearray;

    open(FILE, $filename) or die "$!";
    <FILE>;
    my ($xmax, $ymax) = split /\ /, <FILE>;
    <FILE>;
    binmode FILE;
    read(FILE, my $file, $xmax * $ymax);
    close FILE;

    my $offset = $xmax / 2;

    for my $y (0 .. $ymax - 1) {
    	for my $x (0 .. $xmax - 1) {
    	    $picturearray
    		[($x + $offset) % $xmax]
    		[($y + $offset) % $ymax] 
    		    = ord(substr($file, $y * $xmax + $x, 1));
    	}
    }
    
    @picturearray;
}

# vt100 codes
# ---------------------------------------------------------------------
sub terminal_home { "\033[H"; }
sub terminal_reset { "\033c"; }
