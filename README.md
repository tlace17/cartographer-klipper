# Software Requirements:

* **<span style="text-decoration:underline;">Root access -> Moonraker & Fluidd OR Mainsail (having both installed may cause issues / mcu timeout)</span>**
* **<span style="text-decoration:underline;">Updated klipper from Zarboz : [Found here](https://discord.com/channels/1154500511777693819/1168928848419766372)</span>**
* **<span style="text-decoration:underline;">Guppyscreen with De-creality (suggested to lower MCU utilization) : [Found Here](https://github.com/ballaswag/guppyscreen)</span>** 
 <br><br/>
1. Pull the repo and run the installer: \

    ```
    git clone https://github.com/K1-Klipper/cartographer-klipper.git
    ```
    then:
    ```
    cd cartographer-klipper && sh ./k1_installer.sh
    ```
<br><br/>
2. Open an ssh connection and type:
```
    ls /dev/serial/by-id/
```
   **Copy the output from this into a notepad for later.**
     <br><br/>
<br><br/>
3. Add the following to your printer.cfg includes if it does not already exist:

     [include KAMP_Settings.cfg]
    
<br><br/>

4. Inside your printer.cfg remove anything related to PRtouch (ie. [prtouch_v2], [prtouch default]) , this includes anything below the save config section. (the section that looks like #*#)
   <br><br/>
   <br><br/>
5. Add the following mcu at the top of printer.cfg but below the [mcu_rpi] section filling in the *(ID YOU NOTED EARLIER)* with the output from step 2: 
   ```
    [cartographer]
    serial: /dev/serial/by-id/(ID YOU NOTED EARLIER)   # change this line to have your cartographer id.
    speed: 40.                      #   Z probing dive speed.
    lift_speed: 5.                  #   Z probing lift speed.
    backlash_comp: 0.5              #   Backlash compensation distance for removing Z backlash before measuring the sensor response.
    x_offset: 0.                    #   X offset of cartographer from the nozzle.
    y_offset: 16.86                 #   Y offset of cartographer from the nozzle.
    trigger_distance: 2.            #   cartographer triggers distance for homing.
    trigger_dive_threshold: 1.5     #   Threshold for range vs dive mode probing. Beyond `trigger_distance + trigger_dive_threshold` a dive will be used.
    trigger_hysteresis: 0.006       #   Hysteresis on trigger threshold for un triggering, as a percentage of the trigger threshold.
    cal_nozzle_z: 0.1               #   Expected nozzle offset after completing manual Z offset calibration.
    cal_floor: 0.1                  #   Minimum z bound on sensor response measurement.
    cal_ceil:5.                     #   Maximum z bound on sensor response measurement.
    cal_speed: 1.0                  #   Speed while measuring response curve.
    cal_move_speed: 10.             #   Speed while moving to position for response curve measurement.
    default_model_name: default     #   Name of default cartographer model to load.
    mesh_main_direction: x          #   Primary travel direction during mesh measurement.
    #mesh_overscan: -1              #   Distance to use for direction changes at mesh line ends. Omit this setting and a default will be calculated from line spacing and available travel.
    mesh_cluster_size: 1            #   Radius of mesh grid point clusters.
    mesh_runs: 2                    #   Number of passes to make during mesh scan.
    ```
   <br><br/>
6. In printer.cfg under [stepper_z] edit the endstop pin to the following:
 
    Remove the following:
     ```
    endstop_pin: tmc2209_stepper_z:virtual_endstop# PA15   #probe:z_virtual_endstop 
    position_endstop: 0
     ```
    Replace with the following:
     ```
    endstop_pin: probe:z_virtual_endstop # use cartographer as virtual endstop
    homing_retract_dist: 0 # cartographer needs this to be set to 0
     ```
<br><br/>
7. Inside printer.cfg remove your [bed_mesh] section and replace it with EITHER of the following:

     ```
    [bed_mesh]              # K1
    zero_reference_position: 112,112
    speed: 135              # recommended max 150 - absolute max 180. Going above 150 will cause mcu hanging / crashing or inconsistent spikey meshes due to bandwidth limitation.  
    mesh_min: 30,25         # up to 30x30 if you have a weird spike bottom left of mesh
    mesh_max: 210,210       # 210 max before hitting rear plate screws on stock bed
    probe_count: 20,20      # tested 100x100 working
    algorithm: bicubic      # required for above 5x5 meshing
    bicubic_tension: 0.1
     ```
   <br><br/>
**OR**
   <br><br/>
   
     ```
    [bed_mesh]              # K1
    zero_reference_position: 112,112
    speed: 135              # recommended max 150 - absolute max 180. Going above 150 will cause mcu hanging / crashing or inconsistent spikey meshes due to bandwidth limitation.  
    mesh_min: 30,25         # up to 30x30 if you have a weird spike bottom left of mesh
    mesh_max: 210,210       # 210 max before hitting rear plate screws on stock bed
    probe_count: 20,20      # tested 100x100 working
    algorithm: bicubic      # required for above 5x5 meshing
    bicubic_tension: 0.1
    ```
<br><br/>
# First Steps and Calibration:
1. Move your bed plate 2-3 mm away from the nozzle \
<br><br/>
2. On the homescreen of your web UIX, press the CARTO_CALIBRATE macro and wait for the Z offset wizard to pop up.
<br><br/>
Follow the [Paper Test Method](https://www.klipper3d.org/Bed_Level.html#the-paper-test) 
<br><br/>
Upon completion ```SAVE_CONFIG```
<br><br/>
<br><br/>
    **IMPORTANT SAFETY CHECK**
<br><br/>
<br><br/>
3. While your motors are disabled manually move the bed away from the nozzle (at least a fist away) and type into klipper’s console: ```M119```
 <br><br/>
If your Z endstop is “OPEN” you are safe to continue however if it is “TRIGGERED” re-do step 2 or begin troubleshooting.
 <br><br/>
 <br><br/>
4. If you have verified that your Z endstop is functioning correctly, please home all. If the nozzle crashes please e-stop the printer and re-try from step 1.
<br><br/>
<br><br/>
5. You may now run CARTO_BED_MESH to produce your first mesh! Save this one complete, make any tramming adjustments you require to make the bed flat. It is expected you will have up to 1.4mm variance from PRTouch as there is a known issue with their mesh accuracy.
<br><br/>
<br><br/>
6. Once you have your first bed mesh you will need to change your machine settings in your slicer Start GCODE to the following:
    ```
    M104 S0 ; Stops OrcaSlicer from sending temp waits separately

    M140 S0

    SET_GCODE_VARIABLE MACRO=PRINT_START VARIABLE=bed_temp VALUE=[first_layer_bed_temperature] 

    SET_GCODE_VARIABLE MACRO=PRINT_START VARIABLE=extruder_temp \
    VALUE=[first_layer_temperature] 

    print_start EXTRUDER_TEMP=[first_layer_temperature] BED_TEMP=[first_layer_bed_temperature] CHAMBER=[chamber_temperature]
    ```
<br><br/>
8. You may now start your first print! 
<br><br/>
<br><br/>
***Special Thanks to Zarboz, Shima, BootyCall Jones, and Destinal for their contributions to this project***
