
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
jack_ring_top_to_board_back = 6.5;
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

module rj45_cutter() {
    gap = 1.0;
    translate([board_L - rj45_L + rj45_hang, rj45_edge_to_board_bot, board_T] + [0, -gap, -gap]) {
        cube([rj45_L, rj45_W, rj45_H] + [10, 2 * gap, 2 * gap]);
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

module usb3_cutter() {
    $fn = 16;
    gap = 1.3;
    translate([10, usb3_edge_to_board_bot, board_T] + [0, -0.5, 0]) {
        rotate([0, -90, 0])
        linear_extrude(20)
            offset(gap) square([usb3_H, usb3_W + 1.0]);
    }
}

module jack() {
    translate([0, board_W - jack_edge_to_board_top - jack_D / 2, -jack_D / 2 + jack_ring_top_to_board_back])
        rotate([0, 90, 0])
            cylinder(d=jack_D, h=2.2);
}

module jack_cutter() {
    $fn = 32;
    gap = 1;
    translate([-10, board_W - jack_edge_to_board_top - jack_D / 2, -jack_D / 2 + jack_ring_top_to_board_back])
        rotate([0, 90, 0])
            cylinder(d=jack_D + 2 * gap, h=20);
}

module sd() {
    translate([-sd_hang , board_W - sd_edge_to_board_top - sd_W, -sd_T])
        cube([sd_L + sd_hang, sd_W, sd_T]);
}

module typec() {
    translate([-typec_hang, typec_edge_to_board_bot, board_T]) {
        // type_c socket
        color("grey") cube([typec_L, typec_W, typec_T]);
        // type_c plug
        color("black") translate([-22, -13 / 2 + typec_W / 2, -6 / 2 + typec_T / 2])
            cube([20, 13, 6]);
    }
}

module typec_cutter() {
    $fn = 16;
    gap = 0.8;
    translate([-typec_hang, typec_edge_to_board_bot, board_T]) {
        translate([10, -13 / 2 + typec_W / 2, -6 / 2 + typec_T / 2]) {
            rotate([0, -90, 0])
                linear_extrude(20) {
                    offset(gap) {
                        square([6 + 10, 13]);
                    }
                    // cut the near by jack hole
                    square([6, 13 + 3]);
                }
            // cube([20, 13, 6]);
        }
    }
}

module board() {
    $fn = 16;

    pcb();
    color("grey") {
        rj45();
        usb3();
        sd();
    }
    typec();
    pin40();
    color("gold")
        jack();
}

case_T = 2.0;
case_gap_left = 2.5;
case_gap_right = 1.5;
case_gap_top = 1.0;
case_gap_bot = 1.0;
case_gap_back = 2.5;
case_gap_front = 15.0;

case_inner_round_R = 1.5;
case_outer_round_R = 3.0;

case_inner_L = board_L + case_gap_left + case_gap_right;
case_inner_W = board_W + case_gap_top + case_gap_bot;
case_inner_H = case_gap_back + board_T + case_gap_front;
case_inner_dim = [case_inner_L, case_inner_W, case_inner_H];

case_inner_translate = [-case_gap_left, -case_gap_bot, -case_gap_back];

module box_inner() {
    translate(case_inner_translate)
        cube(case_inner_dim);
}

module box_outer() {
    translate(case_inner_translate - [case_T, case_T, case_T])
        cube(case_inner_dim + 2 * [case_T, case_T, case_T]);
}

module box() {
    difference() {
        union() {
            difference() {
                box_outer();
                box_inner();
            }
            // inner round edge
            translate(case_inner_translate)
                round_edge_12(case_inner_round_R, case_inner_dim);
        }
        // outer round edge
        epsilon = 0.1;
        translate(case_inner_translate - [case_T, case_T, case_T] - [epsilon, epsilon, epsilon])
            round_edge_12(
                case_outer_round_R,
                case_inner_dim + 2 * [case_T, case_T, case_T] + 2 * [epsilon, epsilon, epsilon]
            );
        // TODO: outer round corner
        ;
        // holes
        rj45_cutter();
        usb3_cutter();
    }
}

module round_edge(h, r) {
    $fn = 32;
    difference() {
        cube([r, r, h]);
        translate([0, 0, h / 2 + 1])
            cylinder(h=h + 4, r=r, center=true);
    }
}

module round_edge_front_back(r, dim) {
    x = dim[0];
    y = dim[1];
    z = dim[2];
    translate([x - r, y - r, 0])
        round_edge(z, r);
    translate([x - r, r, 0]) rotate([0, 0, -90])
        round_edge(z, r);
    translate([r, r, 0]) rotate([0, 0, -180])
        round_edge(z, r);
    translate([r, y - r, 0]) rotate([0, 0, -270])
        round_edge(z, r);
}

module round_edge_12(r, dim) {
    x = dim[0];
    y = dim[1];
    z = dim[2];
    round_edge_front_back(r, [x, y, z]);
    rotate([90, 0, 0]) rotate([0, 90, 0])
        round_edge_front_back(r, [y, z, x]);
    rotate([0, 0, -90]) rotate([0, -90, 0])
        round_edge_front_back(r, [z, x, y]);
}

case_split_z = board_T + case_gap_front - 2.0;

module case_front() {
    difference() {
        box();
        translate([-10, -10, -30 + case_split_z])
            cube([case_inner_L, case_inner_W, 30] + [20, 20, 0]);
    }
}

module case_back() {
    difference() {
        box();
        translate([-10, -10, case_split_z])
            cube([case_inner_L, case_inner_W, 30] + [20, 20, 0]);
        // holes
        typec_cutter();
        jack_cutter();
    }
}

module case() {
    case_front();
    case_back();
}

board();
// case_front();
case_back();
