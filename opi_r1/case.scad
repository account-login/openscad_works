echo(version=version());

// thickness
shell_thick = 2;
board_thick = 1.57;

// distance between hole centers
x_inner = 42.111;
y_inner = 40.111;

// from hole center to vertical inner surface
x_right = 9.944 + 4.661 + 0.5;
x_left = 2.944 + 2.6 + 1.5;
y_top = 2.944 + 4;
y_bot = y_top;

// from inner bottom surface to board buttom surface (big column)
base_height = 3;
// hole
hole_radius = 1.5;
// from board buttom surface to column top (small column)
col_height = 5;
// wall
wall_height = 21.5;
// 2 rj45
rj45_y = 33.3;
rj45_z = 13.5;
// from nw hole center to microusb axis
usb_jack_pos = 3.197 + 7.600/2;
// height of the microusb jack
usb_jack_height = 3;
// microusb hole size
usb_hole_y = 10 + 2;
usb_hole_z = 4.5 + 2;

// smooth
$fn = 90;
// ensure overlapping
epsilon = 0.0005;
// cooling hole is slow
enable_cooling_hole = true;

module shell() {
  // dimension of inner surface
  x_outer = x_inner + x_left + x_right;
  y_outer = y_inner + y_top + y_bot;

  translate([-x_left -x_inner/2, -y_bot - y_inner/2, shell_thick]) {
    difference() {
      // outer surface
      minkowski() {
        cube([x_outer, y_outer, wall_height]);
        sphere(r=shell_thick);
      }
      // inner surface
      minkowski() {
        translate([shell_thick, shell_thick, shell_thick])
          cube([x_outer - 2*shell_thick, y_outer - 2*shell_thick, wall_height - 2*shell_thick]);
        sphere(r=shell_thick);
      }
    }
  }
}

module case_bottom() {
  // shell
  color("red") {
    difference() {
      shell();
      // cut top
      translate([-100, -100, wall_height]) {
        cube([200, 200, 10]);
      }
      // holes
      wall_holes();
    }
  }

  // 4 columns
  color("green") {
    for (i = [1, -1]) {
      for (j = [1, -1]) {
        translate([i*x_inner/2, j*y_inner/2, shell_thick])
          col_bot();
      }
    }
  }
}

module case_top() {
  // shell
  color("blue") {
    difference() {
      shell();
      // cut bottom
      translate([-100, -100, 0]) {
        cube([200, 200, wall_height]);
      }
      // top cooling hole
      top_hole_pos = [
        [-16, 10], [4, 10], [24, 10],
        [-16, 0], [4, 0], [24, 0],
        [-16, -10], [4, -10], [24, -10],
      ];
      for (xy = top_hole_pos) {
        translate([xy[0], xy[1], wall_height + 1.5*shell_thick])
          cooling_hole();
      }
      // text
      font = "Source Sans Pro Black";
      translate([0, 0, wall_height + 2*shell_thick - 0.5])
        linear_extrude(height=1) {
          translate([6.6, -25, 0])
            text("LAN", font=font);
          translate([33, 25, 0])
            rotate([0, 0, 180])
              text("WAN", font=font);
          translate([-20, -25, 0])
            text("R1", font=font);
          translate([2, 25, 0])
            rotate([0, 0, 180])
              text("2020-06-29", font=font, size=4);
          translate([2, 19, 0])
            rotate([0, 0, 180])
              text("001", font=font, size=4);
        }
    }
  }
  // 4 columns
  color("yellow") {
    for (i = [1, -1]) {
      for (j = [1, -1]) {
        translate([i*x_inner/2, j*y_inner/2, shell_thick + base_height + board_thick])
          #col_top();
      }
    }
  }
  // snap fit
  translate([0, -y_inner/2 - y_bot, snap_height + snap_z/2])
    rotate([90, 0, 0])
      snap_arm();
  translate([0, y_inner/2 + y_top, snap_height + snap_z/2])
    rotate([90, 0, 180])
      snap_arm();
  // slugs
  slug_move_y = y_inner/2 + y_top - 2*shell_thick;
  slug_move_z = shell_thick + wall_height;
  slug_move_e = x_inner/2 + x_right - 2*shell_thick;
  slug_move_w = -x_inner/2 - x_left + 2*shell_thick;
  translate([slug_move_e, slug_move_y, slug_move_z])
    top_slug();
  translate([slug_move_w, slug_move_y, slug_move_z])
    rotate([0, 0, 90])
      top_slug();
  translate([slug_move_w, -slug_move_y, slug_move_z])
    rotate([0, 0, 180])
      top_slug();
  translate([slug_move_e, -slug_move_y, slug_move_z])
    rotate([0, 0, 270])
      top_slug();
}

// main
module main() {
  translate([0, 0, 1])
    case_top();
  case_bottom();
}

main();

// snap fix size
snap_x = 10;
snap_z = 5;
// bottom of snap hole
snap_height = shell_thick + base_height + board_thick;
scap_scale = (snap_z - 1) / snap_z;

module snap_cutter() {
  translate([0, 0, 1])
    cube([snap_x * scap_scale, snap_z * scap_scale, 4], center=true);
  linear_extrude(height=1, scale=scap_scale)
    square([snap_x, snap_z], center=true);
  guide_z = 9;
  guide_depth = 0.5;
  translate([-snap_x/2, wall_height - snap_height - snap_z/2 - guide_z, -1])
    rotate([atan(guide_depth/guide_z), 0, 0])
      cube([snap_x, 10, 1]);
}

module snap_arm() {
  linear_extrude(height=1, scale=scap_scale)
    square([snap_x, snap_z], center=true);
  // arm
  arm_len = wall_height + shell_thick - snap_height;
  translate([-snap_x/2, -snap_z/2, -2])
    cube([snap_x, arm_len, 2]);
  translate([snap_x/2, arm_len - snap_z/2, -shell_thick - 2])
    rotate([0, 90, 270])
      edge(snap_x);
}

module wall_holes() {
  // snap fit
  translate([0, -y_inner/2 - y_bot, snap_height + snap_z/2])
    rotate([90, 0, 0])
      snap_cutter();
  translate([0, y_inner/2 + y_top, snap_height + snap_z/2])
    rotate([90, 0, 180])
      snap_cutter();
  // 2 rj45 hole
  translate([x_inner/2 + x_right + 2, 0, shell_thick + base_height + rj45_z/2]) {
    difference() {
      cube([10, rj45_y, rj45_z], center=true);
      col_y = 3;
      cube([20, col_y, rj45_z + 10], center=true);
    }
  }
  // antenna hole
  antenna_d = 5;
  x_move = x_inner/2 + x_right - 5;
  y_move = -rj45_y/2 - antenna_d/2;
  translate([x_move, y_move, shell_thick + base_height])
    cube([10, antenna_d, antenna_d]);
  translate([x_move, y_move, shell_thick + base_height + antenna_d/2])
    rotate([0, 90, 0])
      cylinder(h=10, r=antenna_d/2);
  translate([x_move + 10, -rj45_y/2 - shell_thick, shell_thick + base_height + antenna_d])
    rotate([0, 0, -90])
      edge(10);
  // microusb hole
  usb_off = 2;
  translate([-x_inner/2 - x_left - 5, y_inner/2 - usb_jack_pos, shell_thick + base_height + usb_jack_height/2])
    rotate([90, 0, 90])
      linear_extrude(height=10)
        offset(usb_off)
          square([usb_hole_y - 2*usb_off, usb_hole_z - 2*usb_off], center=true);
  // bottom cooling holes
  bot_hole_pos = [
    [-16, 10], [4, 10], [24, 10],
    [-16, 0], [4, 0], [24, 0],
    [-16, -10], [4, -10], [24, -10],
  ];
  for (xy = bot_hole_pos) {
    translate([xy[0], xy[1], shell_thick/2])
      cooling_hole();
  }
  // n/s cooling holes
  ns_hole_pos = [-20, -10, 10, 20];
  for (x = ns_hole_pos) {
    for (ysign = [1, -1]) {
      translate([x, ysign * (-y_inner/2 - y_bot - shell_thick/2), shell_thick + wall_height/2])
        rotate([90, 90, 0])
          cooling_hole(w=3, l=6);
    }
  }
  // w cooling holes
  w_hole_pos = [-5, -15];
  for (y = w_hole_pos) {
    translate([-x_inner/2 - x_left - shell_thick/2, y, shell_thick + wall_height/2])
      rotate([90, 90, 90])
        cooling_hole(w=3, l=6);
  }
}

// column module
module col_bot() {
  linear_extrude(height=base_height)
    circle(r=2.5);
  translate([0, 0, base_height])
    linear_extrude(height=col_height, scale=0.8)
      circle(r=hole_radius);
}

module col_top() {
  h = wall_height - base_height - board_thick;
  linear_extrude(height=h) {
    difference() {
      circle(r=3);
      circle(r=hole_radius);
    }
  }
}

// rounded edge module
module edge(size) {
  cube_tr = shell_thick + epsilon;
  cube_size = shell_thick + 2*epsilon;
  translate([0, 0, shell_thick]) rotate([90, 0, 0]) linear_extrude(height=size)
    difference() {
      translate([-cube_tr, -cube_tr, -cube_tr])
        square(cube_size);
      circle(shell_thick);
    }
}

// cooling hole
module cooling_hole(w=3, l=10) {
  if (enable_cooling_hole) {
    translate([l/2, 0, 0])
      cooling_hole_ring(w);
    translate([-l/2, 0, 0])
      cooling_hole_ring(w);
    cooling_hole_body(w, l);
  }
}

cooling_hole_thick = shell_thick + 0.01;

module cooling_hole_body(w, l) {
  translate([-l/2, 0, 0]) rotate([0, 90, 0]) linear_extrude(height=l)
    difference() {
      square([cooling_hole_thick, w + cooling_hole_thick], center=true);
      translate([0, w/2 + cooling_hole_thick/2, 0])
        circle(r=cooling_hole_thick/2, $fn=16);
      translate([0, -w/2 - cooling_hole_thick/2, 0])
        circle(r=cooling_hole_thick/2, $fn=16);
    }
}

module cooling_hole_ring(w) {
  rotate_extrude($fn=16)
    difference() {
      translate([0, -cooling_hole_thick/2, 0])
        square([w/2 + cooling_hole_thick/2, cooling_hole_thick], center=false);
      translate([w/2 + cooling_hole_thick/2, 0, 0])
        circle(r=cooling_hole_thick/2, $fn=16);
    }
}

// slug height
slug_height = 4;

module top_slug() {
  slug_scale = (2*shell_thick + 0.2) / (2*shell_thick);
  translate([0, 0, -slug_height])
    linear_extrude(height=slug_height, scale=slug_scale)
      intersection() {
        difference() {
          offset(shell_thick)
            square([2*shell_thick, 2*shell_thick], center=true);
          circle(r=shell_thick);
        }
        square([2*shell_thick, 2*shell_thick]);
      }
}
