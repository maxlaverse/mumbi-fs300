module arduino(h = 1.1, l = 42, w = 18){
  l = 42;
  
  led_l = 2;
  led_w = 7.5;
  led_h = 0.75;
  led_offset = [12, 0, h/2 + led_h/2];
  
  reset_base_h = 1.5;
  reset_base_l = 6;
  reset_base_w = 3;
  reset_button_h = 1;
  reset_button_l = 2.5;
  reset_button_w = 1;
  reset_base_offset = [4 + reset_base_w/2, 0, h/2 + reset_base_h/2];
  reset_button_offset = [4 + reset_base_w/2, 0, h/2 + reset_base_h + reset_button_h/2];
  
  usb_l = 9;
  usb_w = 7;
  usb_h = 4;
  usb_offset = [-l/2 + 3, 0, h/2 + usb_h/2];
  
  capa_l = 3;
  capa_w = 1.5;
  capa_h = 1.5;
  
  
  reserved_w = 2;
  reserved_h = 3;
  
  digital_l = 5;
  digital_reserved_offset = [5.5, w/2 - reserved_w/2, 0];
  
  power_l = 8;
  power_reserved_offset = [12.5, -w/2 + reserved_w/2, 0];
  
  union()
  
  color("green")
  cube([l, w, h], center=true);
  
  translate(led_offset)
  color("grey")
  cube([led_l, led_w, led_h], center=true);
  
  translate(reset_base_offset)
  color("grey")
  cube([reset_base_w, reset_base_l, reset_base_h], center=true);
  
  translate(reset_button_offset)
  color("white")
  cube([reset_button_w, reset_button_l, reset_button_h], center=true);
  
  translate(usb_offset)
  color("grey")
  cube([usb_l, usb_w, usb_h], center=true);
  
  translate([-l/2 +2, 5, -t/2 - capa_h/2])
  color("orange")
  cube([capa_l, capa_w, capa_h], center=true);
  
  translate([l/2 -8, -3, -t/2 - capa_h/2])
  color("orange")
  cube([capa_l, capa_w, capa_h], center=true);
  
  translate(digital_reserved_offset)
  color("white")
  cube([digital_l, reserved_w, reserved_h], center=true);
  
  translate(power_reserved_offset)
  color("white")
  cube([power_l, reserved_w, reserved_h], center=true);
}

module tx(l = 19, w = 19, t = 1){  
  transmitter_h = 3;
  transmitter_r = 4.5;
  transmitter_offset = [0, 3, transmitter_h/2];
  
  coil1_h = 3;
  coil1_l = 6;
  coil1_offset = [-3, -5, coil1_h/2 + t/2];
  
  coil2_h = 3;
  coil2_l = 3;
  coil2_offset = [3, -5, coil1_h/2 + t/2];
  
  chip_l = 3;
  chip_w = 1.5;
  chip_h = 1.5;
  
  antenna_offset = [9, -8.2, 0];
  
  reserved_w = 2;
  reserved_h = 3;
  reserved_l = 5;
  digital_reserved_offset = [-w/2 + reserved_w/2, -l/2 + reserved_l/2 + 5, 0];
  
  translate([0, 0, t/2]){
    union()
  
    color("green")
    cube([l, w, t], center=true);
    
    translate(transmitter_offset)
    color("grey")
    cylinder(transmitter_h, transmitter_r, transmitter_r, center=true);
    
    translate(coil1_offset)
    color("red")
    rotate([0, 90, 75])
    cylinder(coil1_l, coil1_h/2, coil1_h/2, center=true, $fn = 100);
    
    translate(coil2_offset)
    color("red")
    rotate([0, 90, -15])
    cylinder(coil2_l, coil2_h/2, coil2_h/2, center=true, $fn = 100);
    
    translate([3, 2, - chip_h/2 - t/2])
    color("grey")
    cube([chip_l, chip_w, chip_h], center=true);
    
    translate(antenna_offset)
    rotate([180, 0, 90])
    color("red")
    antenna();
      
    translate(digital_reserved_offset)
    color("white")
    cube([reserved_w, reserved_l, reserved_h], center=true);
  }
}

module rx(l = 30, w = 13, h = 1){  
  coil_h = 3;
  coil_l = 3;
  coil_offset = [-l/2 + 3, -4, coil_h/2 + h/2];
  
  resistance_h = 4;
  resistance_l = 8;
  resistance_w = 2;
  resistance_offset = [-l/2 + 10, -2, resistance_h/2 + h/2];
  
  var_resistance_h = 6;
  var_resistance_l = 5;
  var_resistance_offset = [var_resistance_l/2, 0, var_resistance_h/2 + h/2];
  
  chip_l = 3;
  chip_w = 1.5;
  chip_h = 1.5;
  
  antenna_offset = [-15, -5.4, 0];
  
  reserved_w = 2;
  reserved_h = 3;
  reserved_l = 5;
  digital_reserved_offset = [l/2 - reserved_l/2 - 4, - w/2 + reserved_w/2, 0];
  
  translate([0, 0, h/2]){
    union()
    
    color("green")
    cube([l, w, t], center=true);
    
    translate(coil_offset)
    color("red")
    rotate([0, 90, 20])
    cylinder(coil_l, coil_h/2, coil_h/2, center=true, $fn = 100);
    
    translate(resistance_offset)
    color("grey")
    cube([resistance_w, resistance_l, resistance_h], center=true);
    
    translate(var_resistance_offset)
    color("grey")
    rotate([0, 0, 20])
    cube([var_resistance_l, var_resistance_l, var_resistance_h], center=true);
    
    translate([3, 2, - chip_h/2 - h/2])
    color("grey")
    cube([chip_l, chip_w, chip_h], center=true);
    
    translate(antenna_offset)
    rotate([0, 0, 90])
    color("red")
    antenna();
    
    translate(digital_reserved_offset)
    color("white")
    cube([reserved_l, reserved_w, reserved_h], center=true);
  }

}

module antenna(){
  antenna_l = 19;
  antenna_r = 3;
  antenna_tige = 8;
  
  translate([0, antenna_l/2 + antenna_tige, 0])
  rotate([90, 90, 0])
  {
    union()
    
    color("red")
    cylinder(antenna_l, antenna_r, antenna_r, center=true, $fn = 100);
    
    color("red")
    translate([0, 0, antenna_l/2 + antenna_tige/2])
    cylinder(antenna_tige, 0.3, 0.3, center=true, $fn = 100);
  }
}