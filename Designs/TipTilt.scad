//Tip/Tilt stage, Author TEM01*
//A WIP basic tip/tilt kinematic mount for 3d printing optical equipment. Intent is low cost, "educational grade".
//Using M3 threaded balls interfacing with 3d printed slopes for a kinematic mount. This is not perfect, as the printed surfaces tend to have stiction problems, along with creep and wear. The threaded balls in a maxwellian mount was inspired by Joshua Vasquez's Jubilee 3d printer toolchanging project. In his case, using inserted metal rods solved this problem. something to think about. 3-30-25
//Further thoughts on precision, as I test this rewrite. This will never have the perfect smooth motion that the machined versions do, but thats okay, as long as once something is adjusted it stays there and the adjustment is intuitive enough that the human copntrol loop doesn't get frustrated. With this in mind, the most stable version of this mount is a 120° even angular separation maxwell kinematic mount. I will leave the much smoother operating kelvin mount in this code, but I think its sensitivity to print tolerances and vibration make it ill advised. A modification for future stability would be to replace the center pivot of a maxwellian mount with a 3DOF socket, although that is technically an overconstraint. 4-7-25
//Rewritten in OpenScad for easier distribution. This is not a program I am familiar with yet, so it will be messy.

$fn = 50;

/*[General Parameters]*/
//Generate the "TiltBase", the "OpticMount", or "Both" components.
generate = "Both";
//Clearance is used for fillets and clearance between moving parts. It is intended to be 1mm.
clearance = 1;
//Width is the overall x/y width of the optical mount.
Width = 50;
//Thickness is the z thickness of each part.
Thickness = 12;

/*[Hardware Parameters]*/
//Diameter of the balls used for the coupling
kinematic_ball_diameter = 8;
//Heated insert diameter for the kinematic. Set to the thread diameter if you prefer to directly tap the plastic.
kinematic_thermal_insert_diameter = 5;
//Spring Diameter
spring_diameter = 8;
//Spring distance from center
spring_offset = 28;
//Spring retention pin diameter
spring_pin = 2;
//Spring pin head
spring_pin_head = 4;
//Mounting through hole - 5mm for a 10-32 screw
mount_bolt_hole = 5;
//Bolt head cutout
mount_bolthead_hole = 8;
//Bolt Location
mount_location = 24;

/*[Optic Mount Parameters]*/
//Currently only "Circle", "Plate", or "None"
optic_style = "Circle";
optic_diameter = 25.5;
//Type of kinematic coupling. "Kelvin" or "Maxwell"
kinematic_style = "Maxwell";


if(generate == "TiltBase"){TiltBase(Width,Thickness);}
else if(generate == "OpticMount"){OpticMount(Width,Thickness);}
else if(generate == "Both"){
    translate([0,-Thickness,0]){
        TiltBase(Width,Thickness);
    }
    translate([0,Thickness,0]){
        OpticMount(Width,Thickness);
    }
}

module TiltBase(width, thi){
    difference(){
        minkowski(){
            union(){
                cube([width-2*clearance,thi-2*clearance,thi-2*clearance]);
                cube([thi-2*clearance,thi-2*clearance,width-2*clearance]);
            }
            translate([1,1,1]){
                sphere(clearance);
            }
        };
        //Insert Holes
        translate([thi/2,0,thi/2]){
            rotate([-90,0,0]){
                cylinder(thi,d=kinematic_thermal_insert_diameter);
            }
        }
        translate([thi/2,0,width-thi/2]){
            rotate([-90,0,0]){
                cylinder(thi,d=kinematic_thermal_insert_diameter);
            }
        }
        translate([width-thi/2,0,thi/2]){
            rotate([-90,0,0]){
                cylinder(thi,d=kinematic_thermal_insert_diameter);
            }
        }
        //Spring Holes
        translate([thi/2,0,spring_offset+thi/2]){
            rotate([-90,0,0]){
                cylinder(thi,d=spring_diameter);
            }
        }

        translate([spring_offset+thi/2,0,thi/2]){
            rotate([-90,0,0]){
                cylinder(thi,d=spring_diameter);
            }
        }
        SpringPins(thi);
        //Mounting Hole
        translate([mount_location,thi/2,0]){
            union(){
                cylinder(thi,d=mount_bolt_hole);
                translate([0,0,thi/2]){
                    cylinder(thi/2,d=mount_bolthead_hole);
                }
            }
        }  
    }
}


module OpticMount(width, thi){
    difference(){
        if(optic_style == "Circle"){CircleMount(width,thi);}
        else if(optic_style == "Plate"){PlateMount(width,thi);}
        else if(optic_style == "None"){BasicMount(width,thi);}

        if (kinematic_style == "Kelvin") {KelvinNegatives(width,thi);}
        else if(kinematic_style == "Maxwell") {MaxwellianNegatives(width,thi);}
        //Spring Holes
        translate([thi/2,0,spring_offset+thi/2]){
            rotate([-90,0,0]){
                cylinder(thi,d=spring_diameter);
            }
        }
        translate([spring_offset+thi/2,0,thi/2]){
            rotate([-90,0,0]){
                cylinder(thi,d=spring_diameter);
            }
        }
        translate([0,thi/2,0]){
            SpringPins(thi);
        }
    }
}
module OneDOF(){
    rotate([-90,0,0]){
        cylinder(kinematic_ball_diameter,d=kinematic_ball_diameter+clearance,center=true);
    }
}

module TwoDOF(){
    rotate([0,45,0]){
        rotate([0,0,45]){
            intersection(){
                intersection(){
                    rotate([0,0,45]){
                        cube([kinematic_ball_diameter+1,kinematic_ball_diameter+1,3*kinematic_ball_diameter],center=true);
                    }
                    cube([kinematic_ball_diameter,kinematic_ball_diameter,3*kinematic_ball_diameter],center=true);
                }
                sphere(d=kinematic_ball_diameter+4*clearance);
            }
        }
    }
}

module ThreeDOF(){
    union(){
        sphere(kinematic_ball_diameter/2);
        rotate([-90,0,0]){
            translate([0,0,kinematic_ball_diameter/2]){
                cylinder(2,d=kinematic_ball_diameter-clearance,center=true);
            }
        }
    }
}

module MaxwellianNegatives(width,thi){
    translate([thi/2,0,thi/2]){
        TwoDOF();
    }
    translate([thi/2,0,width-thi/2]){
        rotate([0,120,0]){
            TwoDOF();
        }
    }
        translate([width-thi/2,0,thi/2]){
        rotate([0,-120,0]){
            TwoDOF();
        }
    }
}

module KelvinNegatives(width,thi){
    translate([thi/2,0,thi/2]){
        ThreeDOF();
    }
    translate([thi/2,0,width-thi/2]){
        OneDOF();
    }
        translate([width-thi/2,0,thi/2]){
        rotate([0,-90,0]){
            TwoDOF();
        }
    }
}

module CircleMount(width,thi){
    difference(){
        minkowski(){
            union(){
                cube([width-2*clearance,thi-2*clearance,thi-2*clearance]);
                cube([thi-2*clearance,thi-2*clearance,width-2*clearance]);
                intersection(){
                    rotate([-90,0,0]){
                            cylinder(thi-2*clearance,r=width);
                    }
                    cube([width,thi-2*clearance,width]);
                }
            }
            translate([1,1,1]){
                sphere(clearance);
            }
        };
        translate([width/2,0,width/2]){
            rotate([-90,0,0]){
                cylinder(thi,d=optic_diameter);
            }
        }
        translate([width/2,thi/2,width/2]){
            rotate([0,45,0]){
                cylinder(width,d=2.5);
            }
        }
    }
}

module PlateMount(width,thi){
    cube([width,thi,width]);
}

module BasicMount(width,thi){
    minkowski(){
        union(){
            cube([width-2*clearance,thi-2*clearance,thi-2*clearance]);
            cube([thi-2*clearance,thi-2*clearance,width-2*clearance]);
        }
        translate([1,1,1]){
            sphere(clearance);
        }
    } 
}

module SpringPins(thi){
    translate([spring_offset+thi,spring_pin/2+1.5,0]){
        rotate([0,-45,0]){
            cylinder(thi*2.828,d=spring_pin,center=true);
        }
    }
    translate([0,spring_pin/2+1.5,spring_offset+thi]){
        rotate([0,-45,0]){
            cylinder(thi*2.828,d=spring_pin,center=true);
        }
    }
    translate([spring_offset+thi,spring_pin/2+1.5,0]){
        rotate([0,-45,0]){
            cylinder(spring_pin_head,d=spring_pin_head,center=true);
        }
    }
    translate([0,spring_pin/2+1.5,spring_offset+thi]){
        rotate([0,-45,0]){
            cylinder(spring_pin_head,d=spring_pin_head,center=true);
        }
    }
}
