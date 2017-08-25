use <components.scad>

main(
  arduino_l = 42.5+0.5,
  arduino_w = 18,
  arduino_t = 1.1,
  
  tx_l = 19+0.5-0.25,
  tx_w = 19+0.5-0.25,
  tx_antenna_offset_x = 0.5,
  
  rx_l = 30+1-0.5,
  rx_w = 13+0.75+0.5-0.25,
  rx_antenna_offset_x = 0.5,
  
  antenna_hole_l = 1.5,

  usb_l = 7.8,
  usb_h = 4,
  usb_d = 1.5,
  usb_offset_z = 3.2+0.5,


  case_h = 13,
  case_t = 1.5,
  sep_arduino_rx = 0.5,
  sep_arduino_tx = 1,

  support_h = 2,
  support_extra_h = 2,
  
  arduino_support_front_l = 2,
  arduino_support_front_w = 1,
  
  arduino_support_middle_l = 4,
  arduino_support_middle_w = 1,
  
  rf_double_extra_support_w = 2,
  rf_double_support_l = 1,
  
  rf_simple_support_l = 1,
  rf_simple_support_w = 2,
  
  rx_support_extra_w = 1
);

module main(){
  sep_rx_tx = sep_arduino_rx + rx_w;
  case_big_w = tx_w + rx_w + sep_rx_tx;
  case_small_w = arduino_w;
  case_l = arduino_l + tx_l + sep_arduino_tx;
  case_big_l = rx_l + rx_support_extra_w;
  case_small_l = case_l - case_big_l;
 
  // Cover
  !cover(l_b = case_big_l,
      l_s = case_small_l,
      w_s = case_small_w,
      w_b = case_big_w,
      t = case_t,
      h = case_h);
  
  union()
  
    difference(){
      // Box
      box(l_b = case_big_l,
          l_s = case_small_l,
          w_s = case_small_w,
          w_b = case_big_w,
          t = case_t,
          h = case_h);
      
      translate([20, 0, -1])
      *cube([38,15,3], center=true);

      translate([37, 0, -1])
      *cube([6,45,3], center=true);

      translate([53, 0, -1])
      *cube([13,45,3], center=true);
      
      translate([53, 0, case_h - 3])
      *cube([95,60,5], center=true);

      // Antennas
      antenna_offset_z = case_h/2 + case_t/2 + 0.25;
      antenna_size = [case_t + 0.02, antenna_hole_l, case_h - support_h - case_t -1.5 + 0.01];
      
      // RX antenna
      translate([case_l + case_t/2, case_big_w/2 - tx_w+antenna_hole_l/2 + tx_antenna_offset_x, antenna_offset_z])
      antenna_hole(antenna_size);

      // TX antenna
      translate([case_l + case_t/2, -case_big_w/2 + rx_w - antenna_hole_l/2 - rx_antenna_offset_x, antenna_offset_z])
      antenna_hole(antenna_size);
      
      // Screw hole
      translate([(arduino_l + case_l)/2, 0, 0])
      cylinder(10,1,1, $fn=100, center=true);

      // Hole for head of screw
      translate([(arduino_l + case_l)/2, 0, -1])
      cylinder(1.01, 4, 3, $fn=100, center=true);
     
      // USB
      translate([-case_t-0.01, 0, usb_offset_z])
      rotate([90, 0, 90])
      scale(1.3)
      linear_extrude(case_t + 0.02){
        usb();
      }
    }
    
    // Support vis
    translate([(arduino_l + case_l)/2, 0, 1])
    difference(){
    cube([9,9, 2], center=true);
    cylinder(2+0.02,1,1, $fn=100, center=true);}
    
    // Support Arduino left front
    translate([arduino_support_front_l/2+8, arduino_w/2-arduino_support_front_w/2, support_h/2])
    cube([arduino_support_front_l, arduino_support_front_w, support_h], center=true);

    // Support Arduino right front
    translate([arduino_support_front_l/2+8, -arduino_w/2+arduino_support_front_w/2, support_h/2])
    cube([arduino_support_front_l, arduino_support_front_w, support_h], center=true);   

    // Support Arduino middle left
    support_middle_offset = 5;
    translate([case_small_l-arduino_support_middle_l/2 - support_middle_offset, arduino_w/2-arduino_support_front_w/2, support_h/2])
    cube([arduino_support_middle_l, arduino_support_middle_w, support_h], center=true);   

    // Support Arduino middle right
    translate([case_small_l-arduino_support_middle_l/2 - support_middle_offset, -arduino_w/2+arduino_support_front_w/2, support_h/2])
    cube([arduino_support_middle_l, arduino_support_middle_w, support_h], center=true);   

    // Block Arduino + RX/TX
    translate([arduino_l + sep_arduino_tx/2, 0, 0])
    block_arduino(
      w = sep_arduino_tx,
      l = arduino_w - 4,
      h = support_h,
      extra_h = support_extra_h,
      inner_w = 1,
      tx_inner_offset = 3.5); //Parametrise
  
    // Support TX/RX wall
    translate([case_big_l+case_small_l-rf_double_support_l/2-0.5, case_big_w/2 - tx_w - sep_rx_tx/2])
    difference(){
      rf_double_support( h = support_h,
                        extra_h = support_extra_h,
                        w = sep_rx_tx,
                        extra_w = rf_double_extra_support_w,
                        l = rf_double_support_l+1);
      translate([-0.5,0,(support_extra_h + support_h)/2])
      cube([1 + 0.01,sep_rx_tx-2 + 0.01,support_extra_h + support_h + 0.01], center=true);
    }

    // Support TX wall right front
    translate([case_big_l+case_small_l-4, -case_big_w/2 + 2/2])
    rf_simple_support(h = support_h,
                    extra_h = 0,
                    w = 1,
                    extra_w = 1,
                    l = 2);
                    
    // Support TX wall right end
    inner_su = 2;
    translate([case_big_l+case_small_l-rx_l-rx_support_extra_w/2+inner_su/2, -case_big_w/2 +rx_w/2])
    union(){
      rf_simple_support(h = support_h,
                        extra_h = support_extra_h,
                        w = rx_support_extra_w,
                        extra_w = inner_su,
                        l = rx_w);
      translate([0, rx_w/2+1/2, (support_h+support_extra_h)/2])
      cube([rx_support_extra_w+inner_su,1,support_h+support_extra_h], center=true);
    }

    // Support RX wall left end
    rf_simple_support_extra_w = 2;
    translate([case_l-tx_l-rf_simple_support_l/2+rf_simple_support_extra_w/2, case_big_w/2 - rf_simple_support_w/2])
    rf_simple_support(h = support_h,
                    extra_h = support_extra_h,
                    w = rf_simple_support_l,
                    extra_w = rf_simple_support_extra_w,
                    l = rf_simple_support_w);
    
    // Support RX wall left front
    translate([case_big_l+case_small_l-4, case_big_w/2 - 2/2])
    rf_simple_support(h = support_h,
                    extra_h = 0,
                    w = 1,
                    extra_w = 1,
                    l = 2);

     // Arduino
    translate([arduino_l/2, 0, support_h+ arduino_t/2])
    *arduino(l = arduino_l, w = arduino_w, t = arduino_t);

    // RX
    translate([case_big_l+case_small_l-rx_l/2, -case_big_w/2 + rx_w/2, support_h])
    rotate([0, 0, 180])
    *rx(l = rx_l, w = rx_w, t = 1);

    // TX
    translate([case_big_l+case_small_l-tx_l/2, case_big_w/2 - tx_w/2, support_h])
    *tx(l = tx_l, w = tx_w, t = 1);
}

module block_arduino(){
  translate([inner_w/2, 0, extra_h/2 +h/2])
  {
    rotate([0, 0, 90])
    union(){
      difference(){
         cube([l, w + 3*inner_w, h + extra_h], center=true);
        
         translate([0, w/2 + inner_w, h/2])
         cube([l + 0.01, inner_w + 0.01, extra_h + 0.01], center=true);
        
         translate([0, -w, h/2])
         cube([l + 0.01, 2*inner_w + 0.01 , extra_h + 0.01], center=true);
      }
    }
    translate([0,tx_inner_offset,-(h+extra_h)/2])
    cube([2,w,h+extra_h]);
  }
}

module rf_double_support(){
  translate([0, 0, (h+extra_h)/2])
  difference(){
    cube([l,w+extra_w,h+extra_h], center=true);
    
    translate([0,w/2+extra_w/4,h/2])
    cube([l+0.01,extra_w/2+0.01,extra_h+0.01], center=true);
    
    translate([0,-w/2-extra_w/4,h/2])
    cube([l+0.01,extra_w/2+0.01,extra_h+0.01], center=true);
  }
}

module rf_simple_support(){
  translate([0, 0, (h+extra_h)/2])
  rotate([0, 0, -90])
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

module cover(){
  r = 2;
  translate([-t, 0, -t])
  union(){
    linear_extrude(1)
    plaque3(l_b = l_b + 2*t,
      l_s = l_s,
      w_s = w_s + 2*t,
      w_b = w_b + 2*t,
      r = r
    );
    
    translate([t, 0, t/2])
    linear_extrude(2)
    difference()
    {
      plaque3(l_b = l_b,
        l_s = l_s,
        w_s = w_s,
        w_b = w_b,
        r = 0
      );
      translate([t/2, 0, 0])
      plaque3(l_b = l_b-t,
        l_s = l_s,
        w_s = w_s-t,
        w_b = w_b-t,
        r = 0
      );
    }
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

module antenna_hole(antenna_size){
  hull(){
    cube(antenna_size, center=true);
      translate([0, 0, -antenna_size[2]/2])
    rotate([0, 90, 0])
    cylinder(antenna_size[0], antenna_size[1]/2, antenna_size[1]/2, $fn=100, center=true);
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
