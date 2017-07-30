use <components.scad>

main(
  arduino_l = 43,
  arduino_w = 18,
  
  tx_l = 19,
  tx_w = 19,
  
  rx_l = 30,
  rx_w = 13,
  

  case_h = 7,
  case_t = 1.5,
  case_small_l = 25,
  case_big_l = 38,
  
  usb_l = 7.8,
  usb_h = 4,
  usb_d = 1.5,
   
  antenna_hole_h = 4,
  antenna_hole_l = 1.5,
      
  clip_l =5,
  clip_w = 2,
  clip_h = 0.75   , 

  rf_support_h = 2,
  sep_rx_tx = 14,
  superposition_tx = 12,
  
  arduino_support_outer_h = 2,
  arduino_support_l = 3,
  arduino_support_outer_w = 1,
  arduino_support_inner_w = 1,
  arduino_support_inner_h = 1,
  
  arduino_support_h = 2,
  
  rf_double_extra_support_w = 2,
  rf_double_support_l = 2,
  arduino_support_front_l = 2,
  arduino_support_front_w = 1,
  arduino_support_middle_l = 4,
  arduino_support_middle_w = 1
);

module main(){
  case_big_w = tx_w + rx_w + sep_rx_tx;
  case_small_w = arduino_w;
  
  union()
    // Box
    box(l_b = case_big_l,
        l_s = case_small_l,
        w_s = case_small_w,
        w_b = case_big_w,
        t = case_t,
        h = case_h);
  
    // Support Arduino left front
    translate([arduino_support_front_l/2, arduino_w/2-arduino_support_front_w/2, arduino_support_h/2])
    cube([arduino_support_front_l, arduino_support_front_w, arduino_support_h], center=true);

    // Support Arduino right front
    translate([arduino_support_front_l/2, -arduino_w/2+arduino_support_front_w/2, arduino_support_h/2])
    cube([arduino_support_front_l, arduino_support_front_w, arduino_support_h], center=true);   
      
    // Support Arduino middle left
    support_middle_offset = 2;
    translate([case_small_l-arduino_support_middle_l/2 - support_middle_offset, arduino_w/2-arduino_support_front_w/2, arduino_support_h/2])
    cube([arduino_support_middle_l, arduino_support_middle_w, arduino_support_h], center=true);   

    // Support Arduino middle right
    translate([case_small_l-arduino_support_middle_l/2 - support_middle_offset, -arduino_w/2+arduino_support_front_w/2, arduino_support_h/2])
    cube([arduino_support_middle_l, arduino_support_middle_w, arduino_support_h], center=true);   
            
    // Clip Arduino right
    translate([case_small_l-4-support_middle_offset,-arduino_w/2, 3.5])
    rotate([0, 0, 90])
    clip(h=0.5, w=2, l=4);
 
    // Clip Arduino left
    translate([case_small_l-support_middle_offset,+arduino_w/2, 3.5])
    rotate([0, 0, 270])
    clip(h=0.5, w=2, l=4);
   
    // Block Arduino left
    translate([arduino_l, arduino_w/2])
    rotate([0, 0, 90])
    arduino_support(l = arduino_support_l,
            outer_w = arduino_support_outer_w,
            outer_h = arduino_support_outer_h,
            inner_w = arduino_support_inner_w,
            inner_h = arduino_support_inner_h,
            d = 1);    
         
    // Block Arduino right  
    translate([arduino_l, -arduino_w/2])
    mirror()
    rotate([0, 0, 270])
    arduino_support(l = arduino_support_l,
            outer_w = arduino_support_outer_w,
            outer_h = arduino_support_outer_h,
            inner_w = arduino_support_inner_w,
            inner_h = arduino_support_inner_h,
            d = 1);   
  
     // Arduino
     translate([arduino_l/2, 0, arduino_support_inner_h +1+ 1.25/2])
     arduino(l = arduino_l, w = arduino_w, t = 1.25);
     
     // RX
     translate([case_big_l+case_small_l-rx_l/2, -case_big_w/2 + rx_w/2, rf_support_h])
     rotate([0, 180, 0])
     rx(l = rx_l, w = rx_w, t = 1.25);
     
     // TX
     translate([case_big_l+case_small_l-tx_l/2, case_big_w/2 - tx_w/2, rf_support_h])
     rotate([180, 0, 0])
     tx(l = tx_l, w = tx_w, t = 1.25);
     
     // Support TX/RX wall
     translate([case_big_l+case_small_l-rf_double_support_l/2, case_big_w/2 - tx_w - sep_rx_tx/2, 1/2])
     rf_double_support( h = rf_support_h,
                        extra_h = 1,
                        w = sep_rx_tx,
                        extra_w = rf_double_extra_support_w,
                        l = rf_double_support_l);
     
     // Support TX/RX inner
     translate([arduino_l+0.5, case_big_w/2 - tx_w - sep_rx_tx/2, 1/2])
     rf_double_support( h = rf_support_h,
                        extra_h = 1,
                        w = sep_rx_tx,
                        extra_w = rf_double_extra_support_w,
                        l = rf_double_support_l);
     
    // Support RX wall
    translate([case_small_l, -case_small_w, 0])
    cube([1, (case_big_w - case_small_w)/2, rf_support_h]);
     
    // Add a wall between small and big to block arduino and support RX
    // Support TX wall left
    translate([tx_l/2+26+0.5, case_big_w/2 - 2/2, 1/2])
    {
      rotate([0, 0, -90])
      rf_simple_support(h = rf_support_h,
                        extra_h = 1,
                        w = 2,
                        extra_w = 2,
                        l = 2);
    }
    
}

module rf_double_support(){
  translate([0, 0, h/2])
  difference(){
    cube([l,w+extra_w,h+extra_h], center=true);
    
    translate([0,w/2+extra_w/4,h/2])
    cube([l+0.01,extra_w/2+0.01,extra_h+0.01], center=true);
  }
}

module rf_simple_support(){
  translate([0, 0, h/2])
  difference(){
    cube([l,w+extra_w,h+extra_h], center=true);
    
    translate([0,w/2,h/2])
    cube([l+0.01,extra_w+0.01,extra_h+0.01], center=true);
  }
}

module arduino_support(
  d = 0){
  rotate(90)
  translate([0, 0, (outer_h + inner_h)/2])
  difference(){
    cube([l, outer_w + inner_w, outer_h + inner_h], center=true);
    translate([d, outer_w/2, outer_h/2]){
      cube([l + 0.01 - d, inner_w + 0.01, inner_h + 0.01], center=true);
    }
  } 
}

module box(){
  r = 2;
  translate([-t, 0, -t])
  difference(){
    linear_extrude(h)
    plaque3(l_b = l_b + 2*t,
      l_s = l_s,
      w_s = w_s + 2*t,
      w_b = w_b + 2*t,
      r = r
    );
    
    translate([t, 0, t])
    linear_extrude(h)
    plaque3(l_b = l_b,
      l_s = l_s,
      w_s = w_s,
      w_b = w_b,
      r = 0
    );
  }
}

module plaque3(){
  difference(){
    polygon(points=[[0,-w_s/2],[l_s,-w_s/2],[l_s,-w_b/2],[l_s+l_b,-w_b/2],[l_b+l_s,w_b/2],[l_s,w_b/2],[l_s,w_s/2],[0,w_s/2]]);
    
    translate([r/2, w_s/2 - r/2])
    rotate([0, 0, 90])
    angle2(r=r);
    
    translate([r/2, - w_s/2 + r/2])
    rotate([0, 0, -180])
    angle2(r=r);
    
    translate([r/2 + l_s, w_b/2 - r/2])
    rotate([0, 0, 90])
    angle2(r=r);
    
    translate([r/2 + l_s, -w_b/2 + r/2])
    rotate([0, 0, -180])
    angle2(r=r);
    
    translate([-r/2 + l_b + l_s, +w_b/2 - r/2])
    rotate([0, 0, 0])
    angle2(r=r);
    
    translate([-r/2 + l_b + l_s, -w_b/2 + r/2])
    rotate([0, 0, 270])
    angle2(r=r);
  }
}

module angle2(){
  intersection(){
    difference(){
      square([r + 0.01, r + 0.01], center=true);
      circle(r/2, r/2, center=true, $fn=100);
    }
    translate([r/2, r/2]){
      square([r, r], center=true);
    }
  }
}


module clip(){
  r = ((w/2)*(w/2) + h*h) / (2*h);
  translate([0, -w, 0])
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
