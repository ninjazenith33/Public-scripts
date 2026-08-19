#!/usr/bin/env perl

use strict;
use warnings;
use Time::HiRes qw(usleep time);

# ============================================================
#                         RFIRE
# ============================================================
#
#   rfire
#
# Usage:
#
#   rfire
#   rfire --run
#   rfire --run=5
#   rfire --run=5s
#   rfire --run=5m
#
# Images:
#
#   --image=flame
#   --image=fire
#   --image=triforce
#   --image=skull
#
# Colors:
#
#   --color=red
#   --color=orange
#   --color=yellow
#   --color=lime
#   --color=green
#   --color=teal
#   --color=cyan
#   --color=blue
#   --color=indigo
#   --color=violet
#   --color=purple
#   --color=magenta
#   --color=pink
#   --color=white
#   --color=black
#   --color=rainbow
#   --color=rgb
#
# ============================================================


# ============================================================
# CONFIGURATION
# ============================================================

my $WIDTH  = 45;
my $HEIGHT = 25;

my $IMAGE_WIDTH  = 90;
my $IMAGE_HEIGHT = 42;

my $FPS   = 20;
my $DELAY = int(1_000_000 / $FPS);

my $TITLE = "Rainbow Fire";


# ============================================================
# DEFAULTS
# ============================================================

my $run_seconds = undef;

my $color_mode = 'rainbow';

my $image_mode = 'flame';


# ============================================================
# ARGUMENT PARSING
# ============================================================

for my $arg (@ARGV) {

    # --------------------------------------------------------
    # Help
    # --------------------------------------------------------

    if ($arg eq '--help' || $arg eq '-h') {

        print <<"HELP";

Rainbow Fire

Usage:

    rfire
        Animated flame. Runs until Ctrl+C.

    rfire --run
        Animated flame. Runs until Ctrl+C.

    rfire --run=5
        Run for 5 seconds.

    rfire --run=5s
        Run for 5 seconds.

    rfire --run=5m
        Run for 5 minutes.


Images:

    --image=flame
        Animated flame (default).

    --image=fire
        Same as --image=flame.

    --image=triforce
        Triforce character image.

    --image=skull
        Skull character image.


Colors:

    --color=red
    --color=orange
    --color=yellow
    --color=lime
    --color=green
    --color=teal
    --color=cyan
    --color=blue
    --color=indigo
    --color=violet
    --color=purple
    --color=magenta
    --color=pink
    --color=white
    --color=black
    --color=rainbow
    --color=rgb


Examples:

    rfire --image=triforce

    rfire --image=skull --color=red

    rfire --image=triforce --color=cyan

    rfire --image=skull --color=purple --run=10s

HELP

        exit 0;
    }


    # --------------------------------------------------------
    # --run
    # --------------------------------------------------------

    if ($arg eq '--run') {

        $run_seconds = undef;

        next;
    }


    # --------------------------------------------------------
    # --run=...
    # --------------------------------------------------------

    if ($arg =~ /^--run=(.+)$/) {

        my $duration = $1;


        # Minutes
        if ($duration =~ /^(\d+(?:\.\d+)?)m$/i) {

            $run_seconds = $1 * 60;
        }


        # Seconds
        elsif ($duration =~ /^(\d+(?:\.\d+)?)s$/i) {

            $run_seconds = $1;
        }


        # Plain number = seconds
        elsif ($duration =~ /^(\d+(?:\.\d+)?)$/) {

            $run_seconds = $1;
        }


        else {

            die <<"ERROR";

Invalid --run value: $duration

Examples:

    --run=5
    --run=5s
    --run=5m

ERROR
        }

        next;
    }


    # --------------------------------------------------------
    # --color=...
    # --------------------------------------------------------

    if ($arg =~ /^--color=(.+)$/) {

        $color_mode = lc($1);

        next;
    }


    # --------------------------------------------------------
    # --image=...
    # --------------------------------------------------------

    if ($arg =~ /^--image=(.+)$/) {

        $image_mode = lc($1);

        next;
    }


    # --------------------------------------------------------
    # Unknown argument
    # --------------------------------------------------------

    die <<"ERROR";

Unknown option: $arg

Run:

    rfire --help

for usage information.

ERROR
}


# ============================================================
# IMAGE ALIASES
# ============================================================

if ($image_mode eq 'fire') {

    $image_mode = 'flame';
}


# ============================================================
# VALID IMAGES
# ============================================================

my %valid_images = (

    flame    => 1,
    triforce => 1,
    skull    => 1,

);


if (!exists $valid_images{$image_mode}) {

    die <<"ERROR";

Unknown image: $image_mode

Available images:

    flame
    fire
    triforce
    skull

ERROR
}


# ============================================================
# IMAGE CANVAS
# ============================================================

if (
    $image_mode eq 'triforce' ||
    $image_mode eq 'skull'
) {

    $WIDTH  = $IMAGE_WIDTH;
    $HEIGHT = $IMAGE_HEIGHT;
}


# ============================================================
# NAMED COLORS
# ============================================================

my %named_colors = (

    red => [
        255, 0, 0
    ],

    orange => [
        255, 128, 0
    ],

    yellow => [
        255, 255, 0
    ],

    lime => [
        128, 255, 0
    ],

    green => [
        0, 255, 0
    ],

    teal => [
        0, 200, 170
    ],

    cyan => [
        0, 255, 255
    ],

    blue => [
        0, 100, 255
    ],

    indigo => [
        75, 0, 255
    ],

    violet => [
        128, 0, 255
    ],

    purple => [
        180, 0, 255
    ],

    magenta => [
        255, 0, 255
    ],

    pink => [
        255, 105, 180
    ],

    white => [
        255, 255, 255
    ],

    black => [
        0, 0, 0
    ],

);


# ============================================================
# VALIDATE COLOR
# ============================================================

if (
    $color_mode ne 'rainbow' &&
    $color_mode ne 'rgb' &&
    !exists $named_colors{$color_mode}
) {

    die <<"ERROR";

Unknown color: $color_mode

Available colors:

    red
    orange
    yellow
    lime
    green
    teal
    cyan
    blue
    indigo
    violet
    purple
    magenta
    pink
    white
    black
    rainbow
    rgb

ERROR
}


# ============================================================
# ANSI
# ============================================================

my $RESET = "\e[0m";


sub rgb {

    my ($r, $g, $b) = @_;

    return "\e[38;2;${r};${g};${b}m";
}


# ============================================================
# RAINBOW TITLE
# ============================================================

sub print_rainbow_title {

    my ($text) = @_;

    my $length = length($text);


    for my $i (0 .. $length - 1) {

        my $char =
            substr(
                $text,
                $i,
                1
            );


        if ($char eq ' ') {

            print ' ';

            next;
        }


        my $hue;

        if ($length <= 1) {

            $hue = 0;

        } else {

            $hue =
                300 *
                (
                    $i /
                    ($length - 1)
                );
        }


        my ($r, $g, $b) =
            hsv_to_rgb(
                $hue,
                1,
                1
            );


        print rgb(
            $r,
            $g,
            $b
        );

        print $char;

        print $RESET;
    }


    print "\n";
}


# ============================================================
# COLOR HELPER
# ============================================================
#
# Returns the RGB color that should be used for a character.
#
# ============================================================

sub character_color {

    my (
        $x,
        $y,
        $time_value
    ) = @_;


    my ($r, $g, $b);


    # --------------------------------------------------------
    # Rainbow / RGB
    # --------------------------------------------------------

    if (
        $color_mode eq 'rainbow' ||
        $color_mode eq 'rgb'
    ) {

        my $hue =
            20
            +
            ($y * 7)
            +
            ($x * 4)
            +
            ($time_value * 55);


        $hue %= 360;


        (
            $r,
            $g,
            $b
        ) =
            hsv_to_rgb(
                $hue,
                1,
                1
            );
    }



    # --------------------------------------------------------
    # Named color
    # --------------------------------------------------------

    else {

        (
            $r,
            $g,
            $b
        ) =
            @{$named_colors{$color_mode}};
    }


    return (
        int($r),
        int($g),
        int($b)
    );
}


# ============================================================
# IMAGE OVERLAYS
# ============================================================

sub image_overlay {

    my ($image) = @_;

    my @lines;


    # ========================================================
    # TRIFORCE
    # ========================================================

    if ($image eq 'triforce') {

        @lines =
            make_triforce_overlay();
    }


    # ========================================================
    # SKULL
    # ========================================================

    elsif ($image eq 'skull') {

        @lines =
            make_skull_overlay();
    }


    return @lines;
}


# ============================================================
# SKULL OVERLAY
# ============================================================

sub make_skull_overlay {

    my @skull = (

        '              #####################              ',
        '           ###########################           ',
        '         ###############################         ',
        '        #################################        ',
        '       ###################################       ',
        '      #####################################      ',
        '     #######################################     ',
        '     #######################################     ',
        '    #########################################    ',
        '    #########       #########       #########    ',
        '    #######           #####           #######    ',
        '    ######             ###             ######    ',
        '    ######             ###             ######    ',
        '    #######           #####           #######    ',
        '    #########       #########       #########    ',
        '    #########################################    ',
        '     #################     #################     ',
        '     ################       ################     ',
        '      ###############       ###############      ',
        '       ###############     ###############       ',
        '        ################ ################        ',
        '         ###############################         ',
        '          #############################          ',
        '           ###########################           ',
        '            #####  #####  #####  #####           ',
        '           ######  #####  #####  ######          ',
        '           ######  #####  #####  ######          ',
        '          #######  #####  #####  #######         ',
        '          ###############################         ',
        '          ###############################         ',
        '          ##########         ##########          ',
        '          #########           #########          ',
        '           ########           ########           ',
        '            #########################            ',
        '             #######################             ',
        '              #####################              ',
        '                #################                ',
        '                  #############                  ',

    );


    return center_overlay(@skull);
}


sub center_overlay {

    my (@source) = @_;

    my $source_height =
        scalar(@source);

    my $top =
        int(
            ($HEIGHT - $source_height) / 2
        );

    $top = 0
        if $top < 0;


    my @lines =
        (' ' x $WIDTH) x $HEIGHT;


    for my $source_y (0 .. $#source) {

        my $target_y =
            $top +
            $source_y;

        last
            if $target_y >= $HEIGHT;


        my $line =
            $source[$source_y];

        my $left =
            int(
                ($WIDTH - length($line)) / 2
            );

        $left = 0
            if $left < 0;


        if ($left + length($line) > $WIDTH) {

            $line =
                substr(
                    $line,
                    0,
                    $WIDTH
                );
        }


        substr(
            $lines[$target_y],
            $left,
            length($line),
            $line
        );
    }


    return @lines;
}


# ============================================================
# TRIFORCE OVERLAY
# ============================================================

sub make_triforce_overlay {

    my $height = $HEIGHT;
    my $margin =
        int($WIDTH * 0.18);
    my $left   = $margin;
    my $right  = $WIDTH - $margin - 1;
    my $center = int($WIDTH / 2);
    my $middle =
        int($HEIGHT * 0.48);
    my $bottom =
        int($HEIGHT * 0.88);
    my $top_left =
        int(
            $center -
            ($right - $left) / 4
        );
    my $top_right =
        int(
            $center +
            ($right - $left) / 4
        );

    my @triangles = (

        [
            [$center, 0],
            [$top_left, $middle],
            [$top_right, $middle],
        ],

        [
            [$top_left, $middle],
            [$left, $bottom],
            [$center, $bottom],
        ],

        [
            [$top_right, $middle],
            [$center, $bottom],
            [$right, $bottom],
        ],

    );


    my @lines;


    for my $y (0 .. $height - 1) {

        my $line = '';


        for my $x (0 .. $WIDTH - 1) {

            my $filled = 0;


            for my $triangle (@triangles) {

                if (
                    point_in_triangle(
                        $x,
                        $y,
                        @{$triangle}
                    )
                ) {

                    $filled = 1;

                    last;
                }
            }


            $line .=
                $filled
                ? '#'
                : ' ';
        }


        push @lines, $line;
    }


    return @lines;
}


sub point_in_triangle {

    my (
        $x,
        $y,
        $a,
        $b,
        $c
    ) = @_;


    my $area =
        triangle_area(
            $a,
            $b,
            $c
        );


    my $area1 =
        triangle_area(
            [$x, $y],
            $b,
            $c
        );


    my $area2 =
        triangle_area(
            $a,
            [$x, $y],
            $c
        );


    my $area3 =
        triangle_area(
            $a,
            $b,
            [$x, $y]
        );


    return
        abs(
            $area -
            (
                $area1 +
                $area2 +
                $area3
            )
        )
        < 0.01;
}


sub triangle_area {

    my (
        $a,
        $b,
        $c
    ) = @_;


    return
        abs(
            $a->[0] * ($b->[1] - $c->[1]) +
            $b->[0] * ($c->[1] - $a->[1]) +
            $c->[0] * ($a->[1] - $b->[1])
        )
        / 2;
}


# ============================================================
# DRAW IMAGE OVER FLAME FRAME
# ============================================================

sub draw_image_over_flame {

    my (
        $flame,
        $image,
        $time_value
    ) = @_;


    my @overlay =
        image_overlay($image);


    my @image_color =
        $image eq 'triforce'
        ? (255, 215, 0)
        : (255, 255, 255);


    for my $y (0 .. $#{$flame}) {

        my $line =
            $flame->[$y];

        my $overlay_line =
            $overlay[$y] // '';


        for my $x (
            0 .. length($line) - 1
        ) {

            my $image_char =
                $x < length($overlay_line)
                ? substr(
                    $overlay_line,
                    $x,
                    1
                )
                : ' ';


            if (
                defined($image_char)
                &&
                $image_char ne ''
                &&
                $image_char ne ' '
            ) {

                print rgb(@image_color);
                print $image_char;
                print $RESET;

                next;
            }


            my $char =
                substr(
                    $line,
                    $x,
                    1
                );


            if ($char eq ' ') {

                print ' ';

                next;
            }


            my $flicker =
                0.75 +
                0.25 *
                sin(
                    $x * 1.7 +
                    $y * 2.1 +
                    $time_value * 8
                );


            my (
                $r,
                $g,
                $b
            ) =
                character_color(
                    $x,
                    $y,
                    $time_value
                );


            $r = int($r * $flicker);
            $g = int($g * $flicker);
            $b = int($b * $flicker);


            print rgb(
                $r,
                $g,
                $b
            );


            print $char;

            print $RESET;
        }


        print "\n";
    }
}


# ============================================================
# FLAME GENERATOR
# ============================================================

sub make_flame {

    my ($time_value) = @_;

    my $height = $HEIGHT;
    my $canvas_scale =
        $WIDTH / 45;
    my $image_flame_spread =
        (
            $image_mode eq 'triforce' ||
            $image_mode eq 'skull'
        )
        ? 1.95
        : 1;

    my @rows;


    for my $y (0 .. $height - 1) {

        my $p =
            $y / ($height - 1);


        # ----------------------------------------------------
        # Overall flame width
        # ----------------------------------------------------

        my $width =
            (
                15
                + 8 * $p
                - 7 * (1 - $p)
            )
            *
            $canvas_scale *
            $image_flame_spread;


        # ----------------------------------------------------
        # Natural side-to-side movement
        # ----------------------------------------------------

        my $lean =
            3.0 *
            $canvas_scale *
            sin(
                $time_value * 1.1 +
                $p * 2.0
            )
            *
            (1 - $p);


        # ----------------------------------------------------
        # Flame tongues
        # ----------------------------------------------------

        my $left_tongue =
            5.0 *
            $canvas_scale *
            exp(
                -(($p - 0.78) ** 2) /
                0.045
            )
            *
            sin(
                $time_value * 1.5
            );


        my $right_tongue =
            5.0 *
            $canvas_scale *
            exp(
                -(($p - 0.70) ** 2) /
                0.055
            )
            *
            sin(
                $time_value * 1.7 + 4
            );


        # ----------------------------------------------------
        # Flame center
        # ----------------------------------------------------

        my $center =
            ($WIDTH / 2)
            +
            $lean;


        my $half =
            $width / 2;


        # ----------------------------------------------------
        # Organic edge movement
        # ----------------------------------------------------

        my $edge_wave =
            1.8 *
            $canvas_scale *
            sin(
                $time_value * 2.0 +
                $p * 7.0
            )
            +
            1.0 *
            $canvas_scale *
            sin(
                $time_value * 3.7 +
                $p * 13.0
            );


        my $left =
            $center
            -
            $half
            +
            $edge_wave
            -
            $left_tongue *
            (1 - $p);


        my $right =
            $center
            +
            $half
            +
            $edge_wave
            +
            $right_tongue *
            (1 - $p);


        # ----------------------------------------------------
        # Separate tongues near the top
        # ----------------------------------------------------

        if ($p < 0.38) {

            my $tip_center =
                $center
                +
                3 *
                $canvas_scale *
                sin(
                    $time_value * 1.1
                );


            my $tip_width =
                (
                    2.5 +
                    6 * $p
                )
                *
                $canvas_scale;


            $left =
                $tip_center -
                $tip_width;


            $right =
                $tip_center +
                $tip_width;


            if (
                sin(
                    $time_value * 0.8
                )
                >
                0.35
            ) {

                my $split =
                    4 *
                    $canvas_scale *
                    sin(
                        ($p / 0.38) *
                        3.14159
                    );


                if ($y % 2 == 0) {

                    $left  -= $split;
                    $right += $split;
                }
            }
        }


        # ----------------------------------------------------
        # Round bottom
        # ----------------------------------------------------

        if ($p > 0.80) {

            my $round =
                sin(
                    (
                        ($p - 0.80) /
                        0.20
                    )
                    *
                    3.14159 / 2
                );


            $left  -= 2 * $round * $canvas_scale;
            $right += 2 * $round * $canvas_scale;
        }


        # ----------------------------------------------------
        # Build row
        # ----------------------------------------------------

        my $line = '';


        for my $x (0 .. $WIDTH - 1) {

            my $inside =
                (
                    $x >= $left &&
                    $x <= $right
                );


            if (!$inside) {

                $line .= ' ';

                next;
            }


            my $q =
                ($x - $left)
                /
                (($right - $left) || 1);


            # ------------------------------------------------
            # Internal flame movement
            # ------------------------------------------------

            my $local =
                sin(
                    $q * 8 +
                    $p * 10 +
                    $time_value * 2
                );


            my $local2 =
                sin(
                    $q * 17 -
                    $time_value * 2.5 +
                    $p * 6
                );


            my $gap =
                (
                    $local > 0.82 &&
                    $p < 0.75
                )
                ||
                (
                    $local2 > 0.94 &&
                    $p < 0.55
                );


            if ($gap) {

                $line .= ' ';

                next;
            }


            my @chars = (

                '/',
                '\\',
                '/',
                '\\',
                ')',
                '(',
                ')',
                '(',
                '~',
                '^',
                '*'

            );


            my $index =
                int(
                    abs(
                        sin(
                            $x * 3.1 +
                            $y * 1.7 +
                            $time_value * 4
                        )
                    )
                    *
                    scalar(@chars)
                );


            $index %=
                scalar(@chars);


            $line .=
                $chars[$index];
        }


        push @rows, $line;
    }


    return @rows;
}


# ============================================================
# DRAW FLAME FRAME
# ============================================================

sub draw_flame {

    my (
        $flame,
        $time_value
    ) = @_;



    for my $y (0 .. $#{$flame}) {

        my $line =
            $flame->[$y];


        for my $x (
            0 .. length($line) - 1
        ) {

            my $char =
                substr(
                    $line,
                    $x,
                    1
                );


            if ($char eq ' ') {

                print ' ';

                next;
            }


            my $flicker =
                0.75 +
                0.25 *
                sin(
                    $x * 1.7 +
                    $y * 2.1 +
                    $time_value * 8
                );


            my (
                $r,
                $g,
                $b
            ) =
                character_color(
                    $x,
                    $y,
                    $time_value
                );


            $r = int($r * $flicker);
            $g = int($g * $flicker);
            $b = int($b * $flicker);



            print rgb(
                $r,
                $g,
                $b
            );


            print $char;

            print $RESET;
        }


        print "\n";
    }
}


# ============================================================
# TERMINAL CLEANUP
# ============================================================

my $cleaning_up = 0;


sub cleanup {

    return if $cleaning_up;

    $cleaning_up = 1;


    # Reset colors.
    print "\e[0m";


    # Clear visible terminal and move cursor to top-left.
    print "\e[2J\e[H";


    # Restore cursor.
    print "\e[?25h";


    # Exit normally.
    exit 0;
}


$SIG{INT}  = \&cleanup;
$SIG{TERM} = \&cleanup;


# ============================================================
# STARTUP
# ============================================================

# Hide cursor.
print "\e[?25l";


# Start on a new line.
print "\n";


# Rainbow title.
print_rainbow_title($TITLE);


# Blank line.
print "\n";


# ============================================================
# TIMER
# ============================================================

my $start_time = time();


# ============================================================
# IMAGE MODES
# ============================================================

if (
    $image_mode eq 'triforce' ||
    $image_mode eq 'skull'
) {

    my $frame = 0;
    my $flame_height = $HEIGHT;

    while (1) {

        if (
            defined($run_seconds)
            &&
            (
                time() -
                $start_time
            )
            >=
            $run_seconds
        ) {

            last;
        }


        my $time_value =
            $frame / $FPS;


        my @flame =
            make_flame($time_value);


        draw_image_over_flame(
            \@flame,
            $image_mode,
            $time_value
        );


        print $RESET;


        print "\e[${flame_height}A";
        print "\r";


        $frame++;


        usleep($DELAY);
    }


    cleanup();
}


# ============================================================
# ANIMATED FLAME
# ============================================================

my $frame = 0;

my $flame_height = $HEIGHT;


while (1) {

    # --------------------------------------------------------
    # Check duration
    # --------------------------------------------------------

    if (
        defined($run_seconds)
        &&
        (
            time() -
            $start_time
        )
        >=
        $run_seconds
    ) {

        last;
    }


    my $time_value =
        $frame / $FPS;


    # --------------------------------------------------------
    # Generate frame
    # --------------------------------------------------------

    my @flame =
        make_flame($time_value);


    # --------------------------------------------------------
    # Draw frame
    # --------------------------------------------------------

    draw_flame(
        \@flame,
        $time_value
    );


    print $RESET;


    # --------------------------------------------------------
    # Return to beginning of flame area.
    # --------------------------------------------------------

    print "\e[${flame_height}A";
    print "\r";


    $frame++;


    usleep($DELAY);
}


# ============================================================
# NORMAL COMPLETION
# ============================================================

cleanup();


# ============================================================
# HSV → RGB
# ============================================================

sub hsv_to_rgb {

    my ($h, $s, $v) = @_;

    $h %= 360;


    my $c =
        $v * $s;


    my $x =
        $c *
        (
            1 -
            abs(
                ($h / 60) % 2 - 1
            )
        );


    my $m =
        $v - $c;


    my (
        $r,
        $g,
        $b
    );



    if ($h < 60) {

        ($r, $g, $b) =
            ($c, $x, 0);

    }

    elsif ($h < 120) {

        ($r, $g, $b) =
            ($x, $c, 0);

    }

    elsif ($h < 180) {

        ($r, $g, $b) =
            (0, $c, $x);

    }

    elsif ($h < 240) {

        ($r, $g, $b) =
            (0, $x, $c);

    }

    elsif ($h < 300) {

        ($r, $g, $b) =
            ($x, 0, $c);

    }

    else {

        ($r, $g, $b) =
            ($c, 0, $x);
    }


    return (

        255 * ($r + $m),
        255 * ($g + $m),
        255 * ($b + $m)

    );
}
