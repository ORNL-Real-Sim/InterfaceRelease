% initialization of vehicle data subscription setup before runnning any
% simulink files. A config.yaml needs to present to read the vehicle data
% subscription setup.

% clear
function [VehicleMessageFieldDefInputVec, VehDataBus, TrafficLayerIP, TrafficLayerPort] = RealSimInitSimulink(configFilename)

	% % add path of YAML file
	% addpath(genpath('.\YAMLMatlab_0.4.3'))

	% read configuration file
	Config = ReadYaml(configFilename);          

	% create vehicle data subscription vector
	% currently support 27 data identifier
	%[id, type, speed, acceleration, positionX, positionY, positionZ, heading,
	%color, linkId, laneId, distanceTravel, speedDesired, accelerationDesired,
	%hasPrecedingVehicle, precedingVehicleId, precedingVehicleDistance,
	%precedingVehicleSpeed, signalLightId, signalLightDistance, signalLightColor, speedLimit,
	%speedLimitNext, speedLimitChangeDistance, linkIdNext, grade, activeLaneChange]

	VehicleMessageFieldDefInputVec = zeros(1, 28);
	for i = 1:numel(Config.SimulationSetup.VehicleMessageField)
	%     curMsgId = ;
		switch Config.SimulationSetup.VehicleMessageField{i}
			case 'id'
				VehicleMessageFieldDefInputVec(1) = 1;
			case 'type'
				VehicleMessageFieldDefInputVec(2) = 1;
			case 'speed'
				VehicleMessageFieldDefInputVec(3) = 1;
			case 'acceleration'
				VehicleMessageFieldDefInputVec(4) = 1;
			case 'positionX'
				VehicleMessageFieldDefInputVec(5) = 1;
			case 'positionY'
				VehicleMessageFieldDefInputVec(6) = 1;
			case 'positionZ'
				VehicleMessageFieldDefInputVec(7) = 1;
			case 'heading'
				VehicleMessageFieldDefInputVec(8) = 1;
			case 'color'
				VehicleMessageFieldDefInputVec(9) = 1;
			case 'linkId'
				VehicleMessageFieldDefInputVec(10) = 1;
			case 'laneId'
				VehicleMessageFieldDefInputVec(11) = 1;
			case 'distanceTravel'
				VehicleMessageFieldDefInputVec(12) = 1;
			case 'speedDesired'
				VehicleMessageFieldDefInputVec(13) = 1;
			case 'accelerationDesired'
				VehicleMessageFieldDefInputVec(14) = 1;
			case 'hasPrecedingVehicle'
				VehicleMessageFieldDefInputVec(15) = 1;
			case 'precedingVehicleId'
				VehicleMessageFieldDefInputVec(16) = 1;
			case 'precedingVehicleDistance'
				VehicleMessageFieldDefInputVec(17) = 1;
			case 'precedingVehicleSpeed'
				VehicleMessageFieldDefInputVec(18) = 1;
            case 'signalLightId'
                VehicleMessageFieldDefInputVec(19) = 1;
            case 'signalLightHeadId'
                VehicleMessageFieldDefInputVec(20) = 1;
            case 'signalLightDistance'
				VehicleMessageFieldDefInputVec(21) = 1;
			case 'signalLightColor'
				VehicleMessageFieldDefInputVec(22) = 1;
			case 'speedLimit'
				VehicleMessageFieldDefInputVec(23) = 1;
			case 'speedLimitNext'
				VehicleMessageFieldDefInputVec(24) = 1;
			case 'speedLimitChangeDistance'
				VehicleMessageFieldDefInputVec(25) = 1;
			case 'linkIdNext'
				VehicleMessageFieldDefInputVec(26) = 1;
			case 'grade'
				VehicleMessageFieldDefInputVec(27) = 1;
			case 'activeLaneChange'
				VehicleMessageFieldDefInputVec(28) = 1;
			otherwise
				fprintf('\nERROR! Vehicle message id not supported! Check configuration yaml file!\n')
		end
		
	end

	% if use bitwise , this is the integer corresponding to the setup. NOT CURRENTLY used
	VehicleMessageFieldDefInputBitwise = uint32(bin2dec(sprintf('%d',VehicleMessageFieldDefInputVec)));

    % get input arguments to the s-function
    if Config.XilSetup.EnableXil
        if length(Config.XilSetup.VehicleSubscription) <= 0
            fprintf('\nERROR! must specify at least one vehicle subscription for XilSetup!\n')
        else
            TrafficLayerIP = Config.XilSetup.VehicleSubscription{1,1}.ip{1};
            TrafficLayerPort = Config.XilSetup.VehicleSubscription{1,1}.port{1};
        end
    elseif Config.ApplicationSetup.EnableApplicationLayer && ~Config.XilSetup.EnableXil
        if length(Config.ApplicationSetup.VehicleSubscription) <= 0
            fprintf('\nERROR! must specify at least one vehicle subscription for ApplicationSetup!\n')
        else
            TrafficLayerIP = Config.ApplicationSetup.VehicleSubscription{1,1}.ip{1};
            TrafficLayerPort = Config.ApplicationSetup.VehicleSubscription{1,1}.port{1};
        end
    else
        error('Real-Sim: must at least enable Application layer or Xil layer!')
    end
    
	% clean up not needed variables
	clear i


    
    %% create Simulink Bus
    temp = struct('id', uint8(zeros(50,1)), 'idLength', 0, 'type', uint8(zeros(50,1)), 'typeLength', 0, ...
                    'speed', 0, 'acceleration', 0, 'positionX', 0, 'positionY', 0, 'positionZ', 0, ...
                    'heading', 0, 'color', 0, 'linkId', uint8(zeros(50,1)), 'linkIdLength', 0, 'laneId', 0, ...
                    'distanceTravel', 0, 'speedDesired', 0, 'accelerationDesired', 0, ...
                    'hasPrecedingVehicle', 0, 'precedingVehicleId', uint8(zeros(50,1)), 'precedingVehicleIdLength', 0, 'precedingVehicleDistance', 0, 'precedingVehicleSpeed', 0, ...
                    'signalLightId', 0, 'signalLightHeadId', 0, 'signalLightDistance', 0, 'signalLightColor', 0, ...
                    'speedLimit', 0, 'speedLimitNext', 0, 'speedLimitChangeDistance', 0, ...
                    'linkIdNext', uint8(zeros(50,1)), 'linkIdNextLength', 0, 'grade', 0, 'activeLaneChange', 0);
    tempnames = fieldnames(temp);

    VehDataBus= Simulink.Bus;
    VehDataBus.Elements = [];
    for i = 1:numel(tempnames)
        ele=Simulink.BusElement;
        ele.Name = tempnames{i};
        ele.Dimensions = max(numel(temp.(ele.Name)),1);
%         if strcmpi(class(temp.(ele.Name)),'string')
%             ele.DataType = 'stringtype(50)';
% %             ele.DataType = 'string';
%         else
        ele.DataType = class(temp.(ele.Name));
%         end
        VehDataBus.Elements = [VehDataBus.Elements; ele];
    end
    
    