
// unit
mil = 0.0254;

// board_L = 64.8;
board_L = 2537.00 * mil;        // 64.44
// board_W = 56.0;
board_W = 2205.1 * mil;         // 56.01
board_T = 1.4;

// hole_d = 3.5;
hole_D = 135.648 * mil;             // 3.45
// hole_edge_to_board_top = 2.0;
hole_edge_to_board_top = 137.9 * mil - hole_D / 2;      // 1.78
// hole_edge_to_board_bot = 2.0;
hole_edge_to_board_bot = 137.6 * mil - hole_D / 2;      // 1.77
// hole_edge_to_board_right = 1.5;
hole_edge_to_board_right = 117.0 * mil - hole_D / 2;    // 1.25
// hole_edge_to_board_left = 2.0;
hole_edge_to_board_left = 137.0 * mil - hole_D / 2;     // 1.76

rj45_H = 14.9 - board_T;    // 13.5
rj45_W = 34.8;
rj45_L = 21.4;
rj45_gap = 2.6;
rj45_hang = 67.5 - board_L; // 2.7
// rj45_edge_to_board_bot = 7.5;
rj45_edge_to_board_bot = 297.422 * mil;     // 7.55

// sd_W = 14.0;
sd_W = 551.181 * mil;  // 14.00
// sd_L = 16.0;
sd_L = 627.953 * mil;  // 15.95
sd_T = 3.5 - board_T;       // 2.1
sd_hang = 2.0;
// sd_edge_to_board_top = 6.5;
sd_edge_to_board_top = 255.578 * mil;  // 6.49

usb3_W = 5.8;
usb3_outter_W = 7.4;
usb3_H = 13.7;
usb3_outter_H = 14.8;
usb3_L = 26.0;
// usb3_edge_to_board_bot = 8.7;
usb3_edge_to_board_bot = (314 / 2 + 291.461) * mil - usb3_W / 2;    // 8.49
usb3_hang = 66.0 - board_L;     // 1.2

pin_W = 2.54 * 2;
pin_L = 50.8;   // 2.54 * 20
pin_H = 8.6;
// pin_edge_to_board_left = 7.0;
pin_edge_to_board_left = 328.2 * mil - 1.27;    // 7.07

jack_D = 6.0;
jack_ring_top_to_board_bottom = 6.5;
// jack_edge_to_board_top = 21.0;
jack_edge_to_board_top = 831.2 * mil;    // 21.11

typec_W = 9.0;
typec_T = 3.2;
typec_L = 7.5;
// typec_edge_to_board_bot = 25.7 - typec_W;   // 16.7
typec_edge_to_board_bot = (664.742 + 340.158 / 2) * mil - typec_W / 2;  // 16.70
typec_hang = 0.4;

// the origin point is at bottom left
// the origin point is at the bottom of pcb

module pcb() {
    ox1 = hole_edge_to_board_left + hole_D / 2;
    oy1 = hole_edge_to_board_bot + hole_D / 2;
    ox2 = board_L - hole_edge_to_board_right - hole_D / 2;
    oy2 = board_W - hole_edge_to_board_top - hole_D / 2;
    delta = 0.01;

    difference() {
        union() {
            color("blue") linear_extrude(board_T)
                offset(1.5) translate([1.5, 1.5])
                    square([board_L - 3, board_W - 3]);
            // cube([board_L, board_W, board_T]);
            // hole pad
            color("gold") {
                translate([ox1, oy1, -delta])
                    cylinder(h=board_T + 2 * delta, d=6);
                translate([ox1, oy2, -delta])
                    cylinder(h=board_T + 2 * delta, d=6);
                translate([ox2, oy1, -delta])
                    cylinder(h=board_T + 2 * delta, d=6);
                translate([ox2, oy2, -delta])
                    cylinder(h=board_T + 2 * delta, d=6);
            }
        }
        // holes
        translate([ox1, oy1, -1])
            cylinder(h=4, d=hole_D);
        translate([ox1, oy2, -1])
            cylinder(h=4, d=hole_D);
        translate([ox2, oy1, -1])
            cylinder(h=4, d=hole_D);
        translate([ox2, oy2, -1])
            cylinder(h=4, d=hole_D);
    }
}

module rj45() {
    translate([board_L - rj45_L + rj45_hang, rj45_edge_to_board_bot, board_T]) {
        difference() {
            cube([rj45_L, rj45_W, rj45_H]);
            translate([-1, rj45_W / 2 - rj45_gap / 2, -1])
                cube([30, rj45_gap, 20]);
        }
    }
}

module pin2() {
    corner = 0.5;

    color("#555") linear_extrude(2.0)
        polygon([
            [0, corner], [corner, 0], [2.54 - corner, 0], [2.54, corner],
            [2.54, 5.08 - corner], [2.54 - corner, 5.08], [corner, 5.08], [0, 5.08 - corner],
        ]);
        // cube([2.54, 2 * 2.54, 2.0]);
    color("white") {
        translate([1.27, 1.27, pin_H / 2])
            cube([0.64, 0.64, pin_H], center=true);
        translate([1.27, 1.27 + 2.54, pin_H / 2])
            cube([0.64, 0.64, pin_H], center=true);
    }
}

module pin40() {
    translate([pin_edge_to_board_left, hole_edge_to_board_bot + hole_D / 2 - 2.54, board_T]) {
        for (i = [0:19]) {
            translate([i * 2.54, 0, 0])
                pin2();
        }
        // cube([pin_L, pin_W, pin_H]);
    }
}

module usb3() {
    translate([-usb3_hang, usb3_edge_to_board_bot, board_T]) {
        translate([0, -(usb3_outter_W - usb3_W) / 2, 0])
            cube([0.5, usb3_outter_W, usb3_outter_H]);
        difference() {
            cube([usb3_L, usb3_W, usb3_H]);
            translate([usb3_L, -1, usb3_H - 8]) rotate([0, -45, 0])
                cube(sqrt(2) * 8);
        }
    }
}

module jack() {
    translate([0, board_W - jack_edge_to_board_top - jack_D / 2, -jack_D / 2 + jack_ring_top_to_board_bottom])
        rotate([0, 90, 0])
            cylinder(d=jack_D, h=2.2);
}

module sd() {
    translate([-sd_hang , board_W - sd_edge_to_board_top - sd_W, -sd_T])
        cube([sd_L + sd_hang, sd_W, sd_T]);
}

module typec() {
    translate([-typec_hang, typec_edge_to_board_bot, board_T])
        cube([typec_L, typec_W, typec_T]);
}

module board() {
    $fn = 16;

    pcb();
    color("grey") {
        rj45();
        usb3();
        sd();
        typec();
    }
    pin40();
    color("gold")
        jack();
}

board();
