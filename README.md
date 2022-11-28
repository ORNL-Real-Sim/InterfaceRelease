# InterfaceRelease
This is the repo of "black box" Real-Sim Flexible Interface for X-in-the-loop Simulation (FIX), i.e., compiled .exe, .dll.

## Contacts
Yunli Shao\
Oak Ridge National Laboratory\
shaoy@ornl.gov

Table of Contents
=======================
* [Preface](#preface)
* [General Setups](#general-setups)
    * [VISSIM Specific Setups](#vissim-specific-setup)
    * [SUMO Specific Setups](#sumo-specific-setup)
* [Run Simulation Manually](#run-simulation-manually)
    * [Start Simulation](#start-simulation)
    * [Stop Simulation](#stop-simulation)
* [Run Simulation with Automation Script](#run-simulation-with-automation-script)
    * [Start Simulation](#start-simulation-1)
    * [Stop Simulation](#stop-simulation-1)
    * [Run Multiple Co-simulations](#run-multiple-co-simulations)
* [Specific Features for VISSIM Co-simulation](#specific-features-for-vissim-co-simulation)
    * [Control Initial States of An Ego Vehicle](#control-initial-states-of-an-ego-vehicle)
    * [Enforce 'Go Straight' of An Ego Vehicle](#enforce-go-straight-of-an-ego-vehicle)
    * [Get Speed Limit from VISSIM](#get-speed-limit-from-vissim)
* [Specific Features for SUMO Co-simulation](#specific-features-for-sumo-co-simulation)
* [Compatibility to Previous Versions](#compatibility-to-previous-versions)
    * [RealSimDepack Output](#realsimdepack-output)
* [VISSIM and SUMO comparison](#vissim-and-sumo-comparison)
* [Troubleshooting](#troubleshooting)
* [Appendix](#appendix)
    * [Vehicle Message Field Specifications](#vehicle-message-field-specifications)

## Preface
Before testing the Real-Sim interface, please 
- read through this README
- check comments in config.yaml which specifies how to properly write/modify the configuration file
- check annotations in the Simulink template which specifies how to properly use each block
- RealSimPack.m and RealSimDepack.m files are currently open-source. check the comments before modifying.  

## General Setups
1. Select the message data fields, ip address and port of the TrafficLayer, vehicle id of interest in the config.yaml. In this example, vehicle id '8' is selected, ip address is '127.0.0.1', port is 2333.  
    ![](doc/img/ConfigSetup.png)
1. Modify the RealSimInitSimulink.m to read the config.yaml from the correct path.  
    ![](doc/img/SimulinkScriptSetup.png)
1. Modify the RealSimDepack.m if necessary, e.g., to output additional message fields.   
<!--
1. Setup vehicle id in the RealSimPack to be the same id selected in the config.yaml. In this example, vehicle id '8' is selected.  
![](doc/img/PackSetup.png)
1. Make sure the ip address and port of RealSimSocket are the same as those specified in config.yaml. In this example, ip address is '127.0.0.1', port is 2333.  
![](doc/img/SocketSetup.png)
-->

### VISSIM Specific Setup
1. Open the VISSIM network file wants to simulate, for all the vehicle types of interest, enable driver model dll, select the RealSimDriverModel.dll and config.yaml.  
    ![](doc/img/VissimDrivermodelSetup.png)
1. Create an empty subdirectory DriverModelData\ in the directory of vissim.exe if it does not exit.  

### SUMO Specific Setup
To be filled...

## Run Simulation Manually
### Start Simulation
1. Start a cmd window, change path to where TrafficLayer.exe locates, then execute as ``TrafficLayer.exe -f PATH\CONFIG_FILENAME``, for example, ``TrafficLayer.exe -f .\config.yaml``
1. Start the Simulink simulation
1. Start VISSIM simulation. It could be a manual click from the VISSIM GUI or from COM interface. If there is any VISSIM pre-simulation setups, it should be executed first (e.g., through COM) before starting the simulation. 

### Stop Simulation
1. Stop Simulink Simulation manually. 
1. Stop VISSIM manually.
1. The cmd window running TrafficLayer.exe will stop automatically after the first two steps. NOTE: The cmd window might pop an error message which is not indeed an error but part of the shutdown procedure.

## Run Simulation With Automation Script
### Start Simulation
Use the ``main_autoRealSim.m`` as the template to build your own automation script applications. The startup order is similar to manual procedure as in section above, i.e., 
1. start ``TrafficLayer.exe``; 
1. start Simulink application; 
1. start VISSIM simulation. 

``main_autoRealSim.m`` must call a ``RealSimInitSimulink.m`` script to initialize the vehicle message field specification based on a .yaml configuration file. 

``main_autoRealSim.m`` will start VISSIM through VISSIM COM through a second instance of Matlab. This process is automated and a script ``startVissim.m`` will be executed, use it as the template to setup customized VISSIM simulation. 

Make sure modify the ``main_autoRealSim.m`` and ``startVissim.m`` as needed, especially path of programs and simulation files. Below are all snapshots from the ``main_autoRealSim.m``:

**main_autoRealSim.m**

1. Define simulation stop time, after which co-simulation will automatically stops, e.g., define a variable 'stopTime':
    ```matlab
    %% Genearl Simulation Setups
    stopTime = 200; % simulation stop time in seconds. co-simulation will automatically stop after this seconds
    ```
1. Modify the ``RealSimInitSimulink.m`` to read the correct .yaml configuration file, then call the script within ``main_autoRealSim.m``:
    ```matlab
    %% Initialize RealSim for Simulink, Read yaml file
    RealSimInitSimulink
    ```
1. set the path and configuration file name of the ``TrafficLayer.exe``:
    ```matlab
    % start RealSim interface
    % !!! specify the followings: 
    %   1) path of TrafficLayer.exe
    %   2) name of .yaml configuration file
    realSimPath = 'D:\src_ornl\RealSimInterface\';
    system(['cd "', realSimPath, '" &; ".\TrafficLayer.exe" -f ".\config.yaml" &']);
    ```
1. setup second Matlab instance to start VISSIM simulation:
    ```matlab
    % start Vissim in second Matlab window
    % this Matlab window will be closed automatically after simulation ends
    % !!! specify the followings: 
    %   1) path of matlab.exe, 
    %   2) path of VISSIM COM script, 
    %   3) VISSIM COM script name and input arguments
    system([' "C:\Program Files\MATLAB\R2019a\bin\matlab.exe" -nodesktop -nosplash -r ', ...
        '"cd(''D:\src_ornl\RealSimInterface\CommonLib''); ', ...
        sprintf('startVissim(''..\\VISSIMfiles\\VissimNetwork.inpx'', %f); ', stopTime), ...
        'quit; " '])
    ```
1. setup Simulink model to run:
    ```matlab
    % start simulink model
    % !!! specify the followings: 
    %   1) simulink model name
    %   2) stopTime of the simulink model
    simModelName = 'RealSimTemplate';
    load_system(simModelName)
    set_param(simModelName,'StopTime',num2str(stopTime));
    set_param(simModelName, 'SimulationCommand', 'start');
    % simout = sim(simModelName); % alternatively can use 'sim' command
    ```

### Stop Simulation
Simulation will automatically stop after Simulink model reaches the 'StopTime' (see where this variable can be defined in section above), VISSIM file simulation seconds/periods should be larger or equal to this 'StopTime'. Adjust these simulation stops time as needed.

To automatically close the command window runs ``TrafficLayer.exe``, need to know the pid of that command window instance then use ``taskkill`` to close it. 
1. right after starting ``TrafficLayer.exe``, getting pid using:
    
    **main_autoRealSim.m**

    ```matlab
    % get an image of cmd.exe pid after start a new one
    pidListPost = getCmdPid();

    % get pid of the RealSim interface cmd.exe
    pidToKill = setdiff(pidListPost, pidListPrior);
    ```
    where ``getCmdPid()`` is a function:
    ```matlab
    function pidList = getCmdPid()
        [~,pidString]=system('tasklist /FI "IMAGENAME eq cmd.exe" /FO LIST | find "PID:"');
        pidCell=split(strrep(replace(pidString,newline,''),' ',''), 'PID:'); % remove newline symbol and spaces, split into PID list
        pidList=cellfun(@str2num,pidCell(2:end-1)); % remove first empty pid and last one (last pid appears to change every time, not sure meaning of it)
    end
    ```
1. uncomment these commands in  ``main_autoRealSim.m``:

    **main_autoRealSim.m**

    ```matlab
    %% RealSim Shutdown Procedure
    % !!! uncomment to auto-close TrafficLayer.exe after simulation finishes
    % kill RealSim cmd.exe
    if numel(pidToKill) == 1
        system(['taskkill /F /PID ', num2str(pidToKill)]);
        fprintf('TrafficLayer.exe has been killed!\n');
    else
        fprintf('Warning: cannot kill RealSim TrafficLayer.exe, please close it manually\n');
    end
    ```

### Run Multiple Co-simulations
Check ```runRealSim.bat``` for an example to run multiple co-simulations simultaneously. A separate configuration .yaml file is needed to configure each co-simulation. The .yaml file now supports two new fields to define IP and Port of the Traffic Simulator (VISSIM):
excerpt of a .yaml file
```yaml
SimulationSetup:
    # if not specified, default will be localhost
    TrafficSimulatorIP: "127.0.0.1"
    
    # if not specified, default will be 1337
    TrafficSimulatorPort: 1337
``` 
```yaml
ApplicationSetup:
    EnableApplicationLayer: true

    VehicleSubscription: 
    -   type: ego
        attribute: {id: ['6'], radius: [0]}
        ip: ["127.0.0.1"]
        port: [2333]
```
The ```TrafficSimulatorPort``` and VehicleSubscription port **MUST** be different for each co-simulation. The IP can be same or different for each co-simulation.


## Specific Features for VISSIM Co-simulation
### Control Initial States of An Ego Vehicle
VISSIM does not provide an out-of-box approach to precisely control just an ego vehicle. The workaround is 
1. create a dedicated vehicle type and vehicle class for the ego vehicle

    create dedicated vehicle type, id ``1000`` in this example, do not forget to select external driver model and configuration file:
    ![](doc/img/VissimDedicatedVehicleType.png)

    create dedicated vehicle class, id ``70`` in this example, and assign the vehicle type ``1000`` we define to this vehicle class:
    ![](doc/img/VissimDedicatedVehicleClass.png)

1. use COM commands to add that vehicle to VISSIM simulation at a particular simulation on a particular link, lane, and initial speed. When using automation script, the commands shall be part of the ``startVissim.m``. Essentially, break VISSIM simulation at the simulation time you want the ego vehicle enters the simulation, start the simulation until it breaks, then add ego vehicle. For example:

    **startVissim.m**

    ```matlab
    % break at XXX seconds to add ego vehicle
    set(Vissim.Simulation, 'AttValue', 'SimBreakAt', 10);
    Vissim.Simulation.RunContinuous

    % add ego vehicle
    vehicle_type = 1000; % use type specified in the config.yaml
    desired_speed = 13*2.23694; % unit according to the user setting in Vissim [km/h or mph]
    link = 6;
    lane = 3;
    xcoordinate = 1; % unit according to the user setting in Vissim [m or ft]
    interaction = true; % please select 'true'
    egoVehicle = Vissim.Net.Vehicles.AddVehicleAtLinkPosition(vehicle_type, link, lane, xcoordinate, desired_speed, interaction);
    ```

1. use the interface to get all vehicle of this particular vehicle type (which essentially the vehicle type only has one vehicle), for example:

    **config.yaml**

    ```yaml
    VehicleSubscription: 
    -   type: vehicleType
        attribute: {id: ['1000'], radius: [0]}
        ip: ["127.0.0.1"]
        port: [2333]
    ```

### Enforce 'Go Straight' of An Ego Vehicle
For vehicles that enter the network as part of 'Vehicle Inputs' of VISSIM, the route will be determined by VISSIM and it will NOT follow external lane change command if it must make a left or right turn due to its route. If want to let one ego vehicle always go straight in VISSIM, the workaround is as the follows:

1. Define a specific vehicle type and vehicle class for that ego vehicle, following steps as section above

1. Make exemption for that particular vehicle class from all 'static route decisions'. The ``setVissimStaticRouteExemption.py`` is an example script showing how to do it programmatically. You do need to make changes based on the specific vehicle class id and VISSIM files to use. Say the particular ego vehicle class is with id ``70``, Figure below shows what it should look like in VISSIM after this vehicle class exempted from 'static route decisions'. 

    ![](doc/img/VissimStaticRouteExemptedBeforeAfter.png)

    **NOTE:** VISSIM manual says that if using command ``Vissim.Net.Vehicles.AddVehicleAtLinkPosition``, ``A vehicle placed this way doesn't travel with a specific path, so it will use only connectors with direction "All" before it passes a routing decision.``. My experience is that it may still make a turn in some cases. This static route exemption approach is more reliable. 

1. Now can add a 'Go Straight' ego vehicle following steps as section above using VISSIM COM command ``Vissim.Net.Vehicles.AddVehicleAtLinkPosition``, the vehicle added will always go straight until exited the VISSIM network. 

### Get Speed Limit from VISSIM
Before simulation, getVissimNetworkInfo.py needs to be run. Three tables will be generated LinkGeometryTable.csv has the link topology of VISSIM network; DesSpdDistr2SpeedLimitMap.csv has a map from desired speed decisions to speed limit definition; SpeedLimitTable.csv is the actual lookup table for a link, lane, vehicle type to each speed limit point (desired speed decision point). 

VISSIM does not have a true speed limit concept, rather, desired speed decisions are used to control the desired speed of each vehicle which equivalent to a speed limit change. Desired speed decisions are not defined as a fixed value but defined using desired speed distributions, essentially a cumulative probability density function. Therefore, users need to assign a corresponding speed limit for each desired speed distribution. 

The getVissimNetworkInfo.py will attempt to interpret the speed limit from name of desired speed distributions, but users **MUST** check the DesSpdDistr2SpeedLimitMap.csv manually to make sure it is correct.

In addition, VISSIM does not have a complete route concept for each vehicle, rather, each vehicle will be assigned a decision at each static route decision point. Hence, it is infeasible to obtain all following routes and links a vehicle will be driven until it travels to each static route decision point. To counter this, users **MUST** supply a Routes.yaml file to specify routes of vehicles of interest. This Routes.yaml **MUST** be in the same folder as VISSIM .inpx files. Examples of route definitions (download [here](Routes.yaml)):
```yaml
Routes:
# example route 1
-   id: [6]
    vehicleType: [100]
    link: [1,10002,4,10011,11,10000,2,10001,3]
    lane: [3]
    initialSpeedLimit: [13.89]
# example route 2
-   id: [36]
    vehicleType: [100]
    link: [1,10002,4,10011,11,10003,6,10007,8,10008,9,10009,10]
    lane: [2,2,2,1,1,1,1,1,2,1,1,1,1]
    initialSpeedLimit: [13.89]
# example route 3
-   vehicleType: [100]
    link: [1,10002,4,10011,11,10000,2,10001,3]
    lane: [3]
    initialSpeedLimit: [13.89]
# example route 4
-   id: [3, 5]
    vehicleType: [100, 100]
    link: [1,10002,4,10011,11,10000,2,10001,3]
    lane: [2]
    initialSpeedLimit: [13.89]
```

Notes:
1. ```link``` and ```lane``` should be vector of same length. The only exception is if ```link``` is a vector and ```lane``` is a scalar. In this case, it is assumed that the vehicle will stay on the same lane for the entire route. see example route 1 and example route 2. lane is needed since VISSIM definie desired speed decisions with respective to each lane. 
1. if ```id``` field is omitted, it is assumed that the route is defined for entire vehicle type. This is useful if a dedicated vehicle type is defined for ego CAVs. see example route 3
1. if multiple vehicles will travel the same route, ```id``` and ```vehicleType``` can be a vector holds id and vehicle type of each vehicle on this same route. see example route 4
1. ```initialSpeedLimit``` is needed to define the speed limit the vehicle is following when first entering the VISSIM network, it should be scalar since each route should have one single initial speed limit. Unit: m/s. see example route 4

## Specific Features for SUMO Co-simulation
To be filled...

## Compatibility to Previous Versions
Here are potential compatibility issues with different versions

### RealSimDepack Output
Instead of multiple outputs, now RealSimDepack will output one single bus signal,

## VISSIM and SUMO comparison
To be filled...

## Troubleshooting
- If in any case an issue occurs when using the interface, first try to restart VISSIM and MATLAB and try again.

- If issue persists, turn on the EnableVerboseLog in the config.yaml, enable log of the RealSimSocket s-function, repeat the simulation that causes the issue. Then locate the following logs and error reports and check them (some of the logs will be overwritten when a new simulation starts): 
    - TrafficLayer.err in the directory of TrafficLayer.exe
    - Copy/Screenshot the outputs displaying from the cmd window running the TrafficLayer.exe
    - DriverModelError.txt and DriverModelLog.txt in the directory of the VISSIM network file
    - Copy/Screenshot outputs from the 'Diagnostic Viewer' of the Simulink. 

## Appendix
### Vehicle Message Field Specifications
This is a full list of vehicle message field
```cpp
std::string id; // VISSIM id is integer and will be converted to string, e.g., (int) 8 ==> (string) "8"
std::string type; // VISSIM type is integer and will be converted to string, e.g., (int) 100 ==> (string) "100"
float speed; // m/s
float acceleration; // m/s^2
float positionX; // m, position based on the coordinates defined in VISSIM/SUMO
float positionY; // m
float positionZ; // m
float heading; // heading in degree, north is 0 degree, then increasing clockwise. i.e., east is 90 degree.
uint32_t color;  // combined bits in order of r,g,b,a, each is 8-bit, i.e., leftmost 8-bit is r
std::string linkId; // VISSIM linkId is integer and will be converted to string, e.g., (int) 10001 ==> (string) "10001"
int32_t laneId; // lane id convention is consistent to VISSIM, with rightmost lane to be 1
float distanceTravel; // m, cumulative driving distance of each vehicle since entering VISSIM network
float speedDesired; // m/s
float accelerationDesired; // m/s^2
int8_t hasPrecedingVehicle; // 1: has preceding vehicle, 0: no preceding vehicle
std::string precedingVehicleId; // 
float precedingVehicleDistance; // m, distance to preceding vehicle (front pump of ego to rear pump of front), -1 if no preceding vehicle
float precedingVehicleSpeed; // m/s, absolute speed of preceding vehicle, -1 if no preceding vehicle
int32_t signalLightId; // index of signal controller in VISSIM
float signalLightDistance; // m, distance to next signal light, no nearby signal light = -1;
int8_t signalLightColor; // color of next signal light, red = 1, amber = 2, green = 3, red / amber = 4, amber flashing = 5, off = 6, other = 0, no nearby signal light = -1;
float speedLimit; // m/s, VISSIM speed limit is defined in terms of reduced speed area, desired speed decision. If neither exists, this value will be -1. Similarly for speedLimitNext.
float speedLimitNext; // m/s, -1 if no speed limit ahead. 
float speedLimitChangeDistance; // m, -1 if no speed limit ahead.
std::string linkIdNext; // 
float grade; // angle in radians, positive climbing up hill
int8_t activeLaneChange; // 1 to the left, -1 to the right, 0 stay on the lane, 
```

<!--
<img src="docs/images/Flowchart.PNG" align="middle" width="500"/>
--[]([url](url))>
