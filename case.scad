main(
  case_l = 43,
  case_w = 33,
  case_h = 10,
  case_t = 1.5,
  
  usb_l = 7.8,
  usb_h = 4,
  usb_d = 1.5,
  
  arduino_l = 43,
  arduino_w = 18,
  arduino_h = 1,
  
  arduino_support_h = 4,
  arduino_support_inner = 1,
  arduino_support_outer = 2,
  arduino_support_plot_l = 6,

  antenna_hole_h = 4,
  antenna_hole_l = 1.5,
  
  reset_d = 1,
  reset_offset_board = 25,
  
  led_hole_l = 5,
  led_hole_w = 1,
  led_offset_board = 32.5,
  
  rf_support_h = 8,
  rf_support_l = 1.5,
  rf_support_board_t = 1,
  rf_support_wall_inner = 0.75,
  
  clip_l =5,
  clip_w = 2,
  clip_h = 0.75   , 

  tx_l = 19,
  tx_w = 19,
  
  rx_l = 30,
  rx_w = 13,
  
  sep_rx_tx = 2,
  superposition_tx = 12,
  
  arduino_support_outer_h = 2,
  arduino_support_l = 3,
  arduino_support_outer_w = 1,
  arduino_support_inner_w = 1,
  arduino_support_inner_h = 1
);

module main(){
  closing_h = rf_support_h+rf_support_board_t+1;
  case_l = superposition_tx + arduino_l;
  case_w = rx_w + tx_w + sep_rx_tx;
  case_t = 1;
  case_h = 10;
  
  difference(){
    union(){
      box(  l = case_l,
            w = case_w,
            t = case_t,
            h = case_h);
   
      // Support Arduino
      translate([0, 0, -case_h/2 + arduino_support_outer_h/2 + arduino_support_inner_h/2])
      {
        for (x = [0, arduino_l], y = [-1, 1])
        translate([case_l/2 - arduino_support_l/2 - x, y * (arduino_w/2 + arduino_support_outer_w), 0])
        rotate([0, 0, max(0, y) * 180])
        arduino_support(l = arduino_support_l,
                outer_w = arduino_support_outer_w,
                outer_h = arduino_support_outer_h,
                inner_w = arduino_support_inner_w,
                inner_h = arduino_support_inner_h);     
      }
    }
    
    // Usb
    translate([case_l/2 + usb_d/2, 0, -case_h/2 + usb_h/2 + arduino_support_outer_h + arduino_h])
    cube([usb_d + 0.02, usb_l, usb_h], center = true);
  }
}

module arduino_support(){
  difference(){
    cube([l, outer_w + inner_w, outer_h + inner_h], center=true);
    translate([0, outer_w/2, outer_h/2]){
      cube([l + 0.01, inner_w + 0.01, inner_h + 0.01], center=true);
    }
  } 
}

module rf_support(
    handle_h = 1
    ){

  translate([0, 0, (h + t + handle_h)/2]){
    difference(){
      cube([l*2, l, h + t + handle_h], center=true);
      translate([-l/2-wall_d/2,0, h/2]){
        cube([l+0.01, l+0.01, t + handle_h + 0.01], center=true);
      }
      translate([-l/2, 0, h/2 + l -handle_h - t]){
        cube([l+0.01, l+0.01, t+0.01], center=true);
      }
      // For wall slide
      translate([0,l/2-wall_d/2]){
        cube([wall_d + 0.01, wall_d + 0.01, h + t + handle_h + 0.01], center=true);
      }
    }
  }
}

module antenna_hole(){
  cube([d + 0.01 * 200, l, h], center=true);
}

module arduino_support2(){
  difference(){
    cube([arduino_l, arduino_w + 2*(outer - inner), h + arduino_h], center = true);
    cube([arduino_l + 2*0.01, arduino_w - 2*inner, h + arduino_h + 0.01], center = true);
    cube([arduino_l - plot_l, arduino_w + 2*(outer - inner) + 0.01, h + arduino_h + 0.01], center = true);
    translate([0, 0, h/2 + 0.01/2]){
        cube([arduino_l, arduino_w, arduino_h + 0.01], center = true);
    }
  }
}

module box(){
  rounded_cube([l, w, h, t]);
}

module support_closing(){
  union(){
    width_rounded_clip=3;
    e=1;
    intersection(){
      translate([t/2, t/2, -t/2]){
        rounded_cube([l-3*t, w-3*t, h, t/2]);
      }
      translate([l/2 - t/2 -width_rounded_clip/2, w/2 - t/2 -width_rounded_clip/2]){
        cube([width_rounded_clip, width_rounded_clip, h + 2*t], center=true);
      }
    }
    intersection(){
      translate([t/2, -t/2, -t/2]){
        rounded_cube([l-3*t, w-3*t, h, t/2]);
      }
      translate([l/2 - t/2 -width_rounded_clip/2, -w/2 + t/2 + width_rounded_clip/2]){
        cube([width_rounded_clip, width_rounded_clip, h + 2*t], center=true);
      }
    }
    translate([l/2-e/2, -w/2 + width_rounded_clip+0.25]){
      cube([e, e, h], center=true);
    }
    translate([l/2-width_rounded_clip-0.25 , -w/2 +e/2]){
      cube([e, e, h], center=true);
    }
    translate([l/2-e/2, +w/2 - width_rounded_clip-0.25]){
      cube([e, e, h], center=true);
    }
    translate([l/2-width_rounded_clip-0.25 , w/2 -e/2]){
      cube([e, e, h], center=true);
    }
    translate([-0.61, -w/2 -2+ width_rounded_clip, 0]){
      difference(){
        cube([6*e, 2*e, h], center=true);
        translate([0, -e/2, 0]){
          cube([4*e, e+0.01, h+0.01], center=true);
        }
      }
    }
    translate([9.38, w/2 +2 - width_rounded_clip, 0]){
      difference(){
        cube([6*e, 2*e, h], center=true);
        translate([0, e/2, 0]){
          cube([4*e, e+0.01, h+0.01], center=true);
        }
      }
    }
  }
}

module rounded_cube(size){
  union(){
    difference(){
      plaque( l = size[0] + 2*size[3],
              w = size[1] + 2*size[3],
              h = size[2] + 2*size[3]);
      plaque(l = size[0], w = size[1],  h = size[2] + 2*size[3] + 0.02);
    }
    translate([0, 0, -size[2]/2 -size[3] +size[3]/2]){
      plaque(l=size[0], w=size[1], h=size[3]);
    }
  }
}

module plaque(r=3){
  difference(){
    cube([l, w, h], center = true);
  
    // Angles
    translate([l/2 - r/2, w/2 - r/2, 0]){
      angle(r, h);
    }
    translate([- l/2 + r/2, w/2 - r/2, 0]){
      rotate([0, 0, 90]){
        angle(r, h + 0.02);
      }
    }
    translate([- l/2 + r/2, - w/2 + r/2, 0]){
      rotate([0, 0, 180]){
        angle(r, h + 0.02);
      }
    }
    translate([l/2 - r/2, - w/2 + r/2, 0]){
      rotate([0, 0, 270]){
        angle(r, h + 0.02);
      }
    }
  }
}


module angle(
  r = 5,
  h = 10
  ){
  intersection(){
    difference(){
      cube([r + 0.01, r + 0.01, h + 0.01], center=true);
      cylinder(h + 0.01, r/2, r/2, center=true, $fn=100);
    }
    translate([r/2, r/2, 0]){
      cube([r, r, h + 0.01], center=true);
    }
  }
}

module clip(){
  r = ((w/2)*(w/2) + h*h) / (2*h);
  rotate([90,0,0]){
    translate([-r+h/2,0,0]){
      intersection(){
        cylinder(l, r, r, center=true, $fn=100);
        translate([r,0,0]){
          cube([h, w, l], center=true);
        }
      }
    }
  }
}

module wall_tx(){
  haut = case_h - rf_support_h + case_t-1;
  union(){
    difference(){
      cube([rf_support_wall_inner-0.01, case_w - 2*rf_support_l + 2*rf_support_wall_inner-0.02, rf_support_h], center=true);
      translate([0, 0, 2]){
        cube([rf_support_wall_inner + 0.01, arduino_w + 0.01, rf_support_h - arduino_support_h], center=true);
      }
    }
    translate([-rf_support_wall_inner/4, 0, -rf_support_h/2]){
      cube([rf_support_wall_inner/2-0.01, 4, 2], center=true);
    }
    translate([0, 0, -rf_support_h/2-haut/2-1]){
      cube([rf_support_wall_inner-0.01, 4, haut], center=true);
    }
  }
}