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
  clip_h = 0.75        
);


module main(){

  translate([-4, 0, -1]){
    rotate([0, 180]){
      wall_tx(
        case_w = case_w,
        case_h = case_h,
        case_t = case_t,
        rf_support_h = rf_support_h,
        rf_support_l = rf_support_l,
        arduino_w = arduino_w,
        arduino_support_h = arduino_support_h,
        rf_support_wall_inner = rf_support_wall_inner);
    }
  }
  
  difference(){
    union(){
      box(
        l = case_l,
        w = case_w,
        h = case_h,
        t = case_t
      );
      translate([0, 0, -case_h/2 + arduino_support_h/2 + 0.1]){
        arduino_support(
          arduino_l = arduino_l,
          arduino_w = arduino_w,
          arduino_h = arduino_h,
          inner = arduino_support_inner,
          outer = arduino_support_outer,
          h = arduino_support_h,
          plot_l = arduino_support_plot_l
        );
      }
      translate([0, 0, -case_h/2]){
        union(){
          inner_rx_offset_1 = 3;
          inner_tx_offset_1 = 8;
          inner_rx_offset_2 = 19;
          inner_tx_offset_2 = 29;
          inner_clip_offset = 6;
           
          //Clips
          translate([0, 0, rf_support_h + rf_support_board_t + clip_w/2 - 0.2]){
            translate([-case_l/2, -case_w/2 + inner_clip_offset, 0]){
              clip(
                l = clip_l,
                w = clip_w,
                h = clip_h);
            }

            // Clip middle
            translate([-case_l/2, 0, 0]){
              clip(
                l = clip_l,
                w = clip_w,
                h = clip_h);
            }
        
            // Clip TX
            translate([-case_l/2, case_w/2 -inner_clip_offset, 0]){
              clip(
                l = clip_l,
                w = clip_w,
                h = clip_h);
            }
          }
          
          // Support TX angle
          translate([-case_l/2 + rf_support_l/2 + inner_rx_offset_1, -case_w/2 + rf_support_l/2, rf_support_h/2]){
            cube([rf_support_l, rf_support_l, rf_support_h], center=true);
          }

          // Support TX
          translate([-case_l/2 - rf_support_l + inner_rx_offset_2, -case_w/2 + rf_support_l/2]){
            rf_support(
              h = rf_support_h,
              l = rf_support_l,
              t = rf_support_board_t,
              wall_d = rf_support_wall_inner
            );
          }
          
          // Mirror support RX for TX
          translate([-case_l/2 - rf_support_l + inner_rx_offset_2, case_w/2 - rf_support_l/2]){
            rotate([0, 0, 180]){
              mirror(){
                rf_support(
                  h = rf_support_h,
                  l = rf_support_l,
                  t = 0,
                  wall_d = rf_support_wall_inner,
                  handle_h = 0
                );
              }
            }
          }
          
          // Support central
          translate([-case_l/2 + rf_support_l/2, 0, rf_support_h/2]){
            cube([1, rf_support_l*2, rf_support_h], center=true);
          }
          
          // Support RX angle
          translate([-case_l/2 + rf_support_l/2 + inner_tx_offset_1, case_w/2 - rf_support_l/2, rf_support_h/2]){
            cube([rf_support_l, rf_support_l, rf_support_h], center=true);
          }
          
          // Support RX
          translate([-case_l/2 - rf_support_l + inner_tx_offset_2, case_w/2 - rf_support_l/2]){
            rotate([0, 0, 180]){
              mirror(){
                rf_support(
                  h = rf_support_h,
                  l = rf_support_l,
                  t = rf_support_board_t,
                  wall_d = rf_support_wall_inner,
                  handle_h = 1
                );
              }
            }
          }
          
          // Mirror support TX for TX
          translate([-case_l/2 - rf_support_l + inner_tx_offset_2, -case_w/2 + rf_support_l/2]){
            rf_support(
              h = rf_support_h + rf_support_board_t,
              l = rf_support_l,
              handle_h = 0,
              wall_d = rf_support_wall_inner,
              t = 0
            );
          }
        }
      }
    }
    translate([case_l/2 + usb_d/2, 0, -case_h/2 + usb_h/2]){
      cube([usb_d + 2*0.01, usb_l, usb_h], center = true);
    }
    translate([case_l/2 - reset_offset_board, 0, -case_h/2 - case_t/2]){
      reset_hole(
        h = case_t,
        d = reset_d
      );
    }
    translate([case_l/2 - led_offset_board, 0, -case_h/2 - case_t/2]){
      led_hole(
        l = led_hole_l,
        w = led_hole_w,
        h = case_t
      );
    }
    antenna_offset_side = 1;
    translate([-case_l/2 - case_t/2, -case_w/2 + antenna_hole_l/2 + antenna_offset_side, rf_support_h - case_h/2 + antenna_hole_h/2]){
      antenna_hole(
        h = antenna_hole_h, 
        l = antenna_hole_l,
        d = case_t
      );
    }
    translate([-case_l/2 - case_t/2, case_w/2 - antenna_hole_l/2 - antenna_offset_side, rf_support_h - case_h/2 + antenna_hole_h/2]){
     antenna_hole(
        h = antenna_hole_h, 
        l = antenna_hole_l,
        d = case_t
      );
    }
    
    larg = 3;
    haut = case_h - rf_support_h + case_t;
    translate([0,0, case_h/2 - haut/2 + case_t]){
      translate([-case_l/2 + larg/2, case_w/2  - larg/2, 0]){
        cube([larg, larg, haut], center=true);
      }
      translate([-case_l/2 + larg/2, -case_w/2  + larg/2, 0]){
        cube([larg, larg, haut], center=true);
      }
    }
  }
}

module led_hole(){
  cube([w, l, h + 2*0.01], center=true);
}

module reset_hole(){
  cylinder(h + 2*0.01, 1, 1, center=true);
}

module antenna_hole(){
  cube([d + 0.01 * 200, l, h], center=true);
}

module arduino_support(){
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
  union(){
    rounded_cube([l, w, h, t]);
    f=3;
    e=1;
    intersection(){
      translate([t/2, t/2, -t/2]){
        rounded_cube([l-3*t, w-3*t, h-t, t/2]);
      }
      translate([l/2 - t/2 -f/2, w/2 - t/2 -f/2]){
        cube([f, f, h + 2*t], center=true);
      }
    }
    translate([l/2-e/2, -w/2 + f+0.25, -t/2]){
      cube([e, e, h], center=true);
    }
    translate([l/2-f-0.25 , -w/2 +e/2, -t/2]){
      cube([e, e, h], center=true);
    }
    translate([l/2-e/2, +w/2 - f-0.25, -t/2]){
      cube([e, e, h], center=true);
    }
    translate([l/2-f-0.25 , w/2 -e/2, -t/2]){
      cube([e, e, h], center=true);
    }
    intersection(){
      translate([t/2, -t/2, -t/2]){
        rounded_cube([l-3*t, w-3*t, h-t, t/2]);
      }
      translate([l/2 - t/2 -f/2, -w/2 + t/2 + f/2]){
        cube([f, f, h + 2*t], center=true);
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