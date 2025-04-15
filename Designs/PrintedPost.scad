//A Optics Post mount, loosely based on the conventional post in tube style seen in most optical systems.
//Author TEM01*

$fn = 50;

/*[General Parameters]*/
//Generate the "Post", the "Socket", or "Both" components.
generate = "Both";
//Clearance is used for fillets and clearance between moving parts. It is intended to be 1mm.
clearance = 1;
//Tolerance is used for printer tolerancing for snug fit parts
tolerance = 0.1;

/*[Hardware Parameters]*/
//Top post connection type "Heatset" or "Threaded" Threaded not implemented yet
top_thread = "Heatset";
//Top post heatset diameter
top_hsert_dia = 5;
//Top post heatset depth
top_hsert_depth = 12;

//Bottom Socket connection type "Heatset" or "Threaded" Threaded not implemented yet
bot_thread = "Heatset";
//Bottom post heatset diameter
bot_hsert_dia = 8;
//Bottom post heatset depth
bot_hsert_depth = 8;

//Post Height
post_height = 50;
//Post Diameter
post_dia = 12.5;

//Socket Height
socket_height = 50;
//Socket Outer Diameter
socket_dia = 28;

//Key type. Currently only "Flat" or "None"
key = "Flat";

//Fixing Bolt Hole Diameter
fix_hole = 5.5;

if(generate == "Post"){Post();}
else if(generate == "Socket"){Socket();}
else if(generate == "Both"){
    translate([0,0,0]){
        Socket();
    }
    translate([0,0,bot_hsert_dia]){
        Post();
    }
}

module Post(){
    difference(){
        union(){
            intersection(){
                PostOrSocketHole(post_height,post_dia);
                translate([0,0,post_height-post_dia/4]){
                    cylinder(h = post_dia/4-clearance, d1 = post_dia, d2 = post_dia-post_dia/2+2*clearance);
                }
            }
            PostOrSocketHole(post_height-post_dia/4,post_dia);
        };
        translate([0,0,post_height-top_hsert_depth]){
            cylinder(top_hsert_depth,d=top_hsert_dia);
        }
    }
}

module Socket(){
    difference(){
        cylinder(socket_height, d = socket_dia);
        translate([0,0,bot_hsert_dia]){
            PostOrSocketHole(post_height,post_dia+2*tolerance);
        }
        cylinder(bot_hsert_depth, d = bot_hsert_dia);
        translate([0,0,socket_height-fix_hole]){
            rotate([0,90,0]){
                cylinder(socket_dia, d = fix_hole);
                translate([0,0,socket_dia/2.2]){
                    cylinder(socket_dia, d = 2*socket_height);
                }
            }
        }
    }
}

module PostOrSocketHole(height, diameter){
    difference(){
        cylinder(height, d = diameter);
        if(key == "Flat"){
            translate([0.4*diameter,-0.5*diameter,0]){ //flat is 90% of the circle
                cube([diameter,diameter,height]);
            }
        }
    }
}