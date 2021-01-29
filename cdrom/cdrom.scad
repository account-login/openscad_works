
top_front_x = 123;
top_back_x = 103;
top_y = 126;
left_z = 13;
right_z = 6;
slope_dist = 12;

blf_pos = [-top_front_x / 2, -top_y / 2, 0];


module cdrom() {
    translate(blf_pos) {
        cube([top_back_x, top_y, left_z]);
    }

    translate(blf_pos + [top_back_x, 0, left_z - right_z]) {
        cube([20, top_y - slope_dist - 20, right_z]);
    }

    translate(blf_pos + [top_back_x, top_y - slope_dist - 40, left_z - right_z]) {
        rotate([0, 0, 45])
            cube([20 * sqrt(2), 20 * sqrt(2), right_z]);
    }

    color("black")
        translate(blf_pos + [5.6, top_y, 2])
            cube([31, 0.01, 8]);
}

cdrom();
