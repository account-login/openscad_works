
$fn = 100;
epsilon = 0.0005;

inner_x = 39.6;
inner_y = 23.0;
inner_z = 8;
shell_thick = 2;
board_z = 2;
board_thick = 1.57;
// from board top surface to pin
pin_height = 3.0;
// jumper wire connector
pin_conn_size = 2.54;
// from usb bottom surface to board top surface
usb_sink = 1.5;
// from voltage jumper to north edge
v_jumper_y_dist = 3.8;
// from middle voltage jumper to east edge
v_jumper_x_dist = 15.4;
//
v_jumper_height = 8.5;
// from power led to south edge
power_led_y_dist = 9;
// from power led to east edge
power_led_x_dist = 7.3;
// from tx/rx led to west edge
sig_led_x_dist = 10;
// from tx/rx led to south/north edge
sig_led_y_dist = 10.5;

module shell() {
  difference() {
    outer_space();
    inner_space();
  }
}

// the bottom inner surface is at z=0
module outer_space() {
  translate([0, 0, inner_z/2])
    minkowski() {
      cube([inner_x, inner_y, inner_z], center=true);
      sphere(r=shell_thick);
    }
}

module inner_space() {
  translate([0, 0, inner_z/2])
    minkowski() {
      sub = 2*shell_thick;
      cube([inner_x - sub, inner_y - sub, inner_z - sub], center=true);
      sphere(r=shell_thick);
    }
}

module shell_bottom() {
  difference() {
    union() {
      shell();
      strips();
    }
    // cut top
    translate([0, 0, board_z + board_thick + pin_height + 10])
      cube([100, 100, 20], center=true);
    // west hole
    jumper_hole_cutter();
    // east hole
    usb_cutter();
    // snap fit
    translate([0, -inner_y/2, 0])
      snap_cutter();
    translate([0, inner_y/2, 0])
      rotate([0, 0, -180])
        snap_cutter();
  }
  // board supporter at 4 corners
  translate([-inner_x/2, -inner_y/2, 0])
    board_supporter();
  translate([-inner_x/2, inner_y/2, 0])
    rotate([0, 0, -90])
      board_supporter();
  translate([inner_x/2, inner_y/2, 0])
    rotate([0, 0, -180])
      board_supporter();
  translate([inner_x/2, -inner_y/2, 0])
    rotate([0, 0, -270])
      board_supporter();
}

module jumper_hole_cutter() {
  translate([-inner_x/2, 0, board_z + board_thick + pin_height])
    cube([10, 5*pin_conn_size + 0.2, pin_conn_size], center=true);
}

module usb_cutter() {
  usb_z = 4.5;
  usb_y = 12;
  translate([inner_x/2, 0, usb_z/2 + board_z + board_thick - usb_sink])
    minkowski() {
      cube([10, usb_y, usb_z], center=true);
      sphere(r=0.2);
    }
}

module board_supporter() {
  translate([0, 0, board_z/2])
    slug(board_z);
}

module slug(height) {
  color("red")
    intersection() {
      rotate([0, 0, 45])
        cube([2*sqrt(2) * shell_thick, 2*sqrt(2) * shell_thick, height], center=true);
      translate([0, 0, -10])
        cube([100, 100, 20]);
    }
}

module shell_top() {
  difference() {
    union() {
      shell();
      strips();
    }
    // cut bottom
    translate([0, 0, board_z + board_thick + pin_height - 10])
      cube([100, 100, 20], center=true);
    // west pins
    jumper_hole_cutter();
    // east usb
    usb_cutter();
    // top jumper
    jumper_cutter();
    // power led hole
    translate([inner_x/2 - power_led_x_dist, -inner_y/2 + power_led_y_dist, 0])
      cylinder(r=1, h=20);
    // tx/rx led hole
    translate([-inner_x/2 + sig_led_x_dist, 0, 0])
      cylinder(r=2, h=20);
    // text
    top_text();
  }
  // snap fit
  snap_arm();
  rotate([0, 0, 180])
    snap_arm();
  // slugs
  intersection() {
    minkowski() {
      sub = 2*shell_thick + 0.5;
      cube([inner_x - sub, inner_y - sub, 20], center=true);
      sphere(r=shell_thick);
    }
    union() {
      slug_height = inner_z - board_z - board_thick;
      translate([-inner_x/2, -inner_y/2, inner_z - 0.5*slug_height])
        slug(height=slug_height);
      translate([-inner_x/2, inner_y/2, inner_z - 0.5*slug_height])
        rotate([0, 0, -90])
          slug(height=slug_height);
      translate([inner_x/2, inner_y/2, inner_z - 0.5*slug_height])
        rotate([0, 0, -180])
          slug(height=slug_height);
      translate([inner_x/2, -inner_y/2, inner_z - 0.5*slug_height])
        rotate([0, 0, -270])
          slug(height=slug_height);
    }
  }
}

module draw_line_2d(points, width) {
  for (i = [1:len(points)-1]) {
    p1 = points[i - 1];
    p2 = points[i];
    x1 = p1[0];
    y1 = p1[1];
    x2 = p2[0];
    y2 = p2[1];
    dx = x2 - x1;
    dy = y2 - y1;
    angle = atan2(dy, dx);

    len = sqrt(dx*dx + dy*dy);
    translate([x1, y1, 0])
      rotate(angle) {
        translate([len/2, 0, 0])
          square([len, width], center=true);
        // circle(r=width/2);
        translate([len, 0, 0])
          circle(r=width/2);
      }
  }
}

module top_text() {
  font = "Source Sans Pro Black";
  translate([0, 0, inner_z + shell_thick - 0.5]) {
    linear_extrude(height=1) {
      width = 1;
      // GND
      draw_line_2d([
        [-inner_x/2 + 1, 2*pin_conn_size],
        [-inner_x/2 + 3, 2*pin_conn_size],
        [-inner_x/2 + 7, 2*pin_conn_size + 3],
      ], width);
      // RX
      draw_line_2d([
        [-inner_x/2 + 1, 1*pin_conn_size],
        [-inner_x/2 + 3, 1*pin_conn_size],
        [-inner_x/2 + 5, 1*pin_conn_size + 1.5],
        [-inner_x/2 + 11, 1*pin_conn_size + 1.5],
        [-inner_x/2 + 13, 1*pin_conn_size + 0],
      ], width);
      // TX
      draw_line_2d([
        [-inner_x/2 + 1, 0],
        [-inner_x/2 + 3, 0],
        [-inner_x/2 + 8, -3],
        [-inner_x/2 + 12, -3],
        [-inner_x/2 + 13.5, -2.5],
      ], width);
      // 5V
      draw_line_2d([
        [-inner_x/2 + 1, -2*pin_conn_size],
        [-inner_x/2 + 3, -2*pin_conn_size],
        [-inner_x/2 + 3 + 5/3, -2*pin_conn_size - 1],
      ], width);
      // 3V3
      draw_line_2d([
        [-inner_x/2 + 1, -1*pin_conn_size],
        [-inner_x/2 + 3, -1*pin_conn_size],
        [-inner_x/2 + 8 - 0.5, -1*pin_conn_size - 3 + 0.3],
        [-inner_x/2 + 12 - 0.5, -1*pin_conn_size - 3 + 0.3],
        [-inner_x/2 + 14.5 - 0.5, -1*pin_conn_size - 3 + 0.3 - 1],
      ], width);
      // left text
      translate([-inner_x/2 + 8, inner_y/2 - 3, 0])
        text("GND", font=font, size=4, valign="center");
      translate([-inner_x/2 + 14, inner_y/2 - 9, 0])
        text("RX", font=font, size=4, valign="center");
      translate([-inner_x/2 + 14, inner_y/2 - 14, 0])
        text("TX", font=font, size=4, valign="center");
      translate([-inner_x/2 + 10, inner_y/2 - 21, 0])
        text("3V3", font=font, size=4, valign="center");
      translate([-inner_x/2 + 2, inner_y/2 - 21, 0])
        text("5V", font=font, size=4, valign="center");
      // voltage jumper
      // 3V3
      draw_line_2d([
        [inner_x/2 - v_jumper_x_dist - 1*pin_conn_size, 5],
        [inner_x/2 - v_jumper_x_dist - 1*pin_conn_size, -8],
        [0, -9.5]
      ], width);
      // GND
      draw_line_2d([
        [inner_x/2 - v_jumper_x_dist, 5],
        [inner_x/2 - v_jumper_x_dist, 3],
      ], width);
      // 5V
      draw_line_2d([
        [inner_x/2 - v_jumper_x_dist + 1*pin_conn_size, 5],
        [inner_x/2 - v_jumper_x_dist + 1*pin_conn_size, -8],
        [9, -9.5],
      ], width);
      translate([inner_x/2 - 10, inner_y/2 - 21, 0])
        text("5V", font=font, size=4, valign="center");
    }
  }
}

module jumper_cutter() {
  translate([inner_x/2 - v_jumper_x_dist, inner_y/2 - v_jumper_y_dist, board_z + board_thick])
    linear_extrude(height=v_jumper_height)
      offset(0.25)
        square([3*pin_conn_size, pin_conn_size], center=true);
}

module board() {
  translate([0, 0, board_z])
    linear_extrude(height=board_thick)
      offset(2)
        square([inner_x - 4, inner_y - 4], center=true);
  jumper_cutter();
}

// width of snap arm
snap_x = 10;

module snap_cutter() {
  // guide
  translate([-snap_x/2, -1.5*shell_thick, -0.25*shell_thick])
    cube([snap_x, 0.75*shell_thick, inner_z + 1.25*shell_thick]);
  // for snap_arm
  translate([-snap_x/2, -shell_thick, inner_z])
    cube([snap_x, shell_thick, shell_thick]);
  // hook
  translate([-snap_x/2, -10 - 0.25*shell_thick, -10 - 0.25*shell_thick])
    translate([0, 10, 10]) rotate([-30, 0, 0]) translate([0, -10, -10])
      cube([snap_x, 10, 10]);
}

module snap_arm() {
  intersection() {
    translate([0, -0.5*shell_thick, 0])
      outer_space();
    translate([0, -inner_y/2, 0])
      snap_cutter();
    // reduce width
    cube([snap_x - 0.5, 100, 100], center=true);
  }
}

module strips() {
  intersection() {
    difference() {
      translate([0, 0, inner_z/2])
        minkowski() {
          cube([inner_x - 5, inner_y + 2, inner_z], center=true);
          sphere(r=shell_thick);
        }
      translate([0, 0, inner_z/2])
        cube([inner_x, inner_y + 2*shell_thick - 2, 30], center=true);
    }
    union() {
      translate([-12.5, 0, 0])
        cube([5, 30, 20], center=true);
      translate([+12.5, 0, 0])
        cube([5, 30, 20], center=true);
    }
  }
}

// main
shell_top();
color("green") {
  #board();
}
translate([0, 0, -5])
  shell_bottom();
