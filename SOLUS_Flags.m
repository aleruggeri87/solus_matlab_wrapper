classdef SOLUS_Flags
    % SOLUS_Flags 
    %
    %   Author(s):  Alessandro RUGGERI
    %   Revision:   1.0 
    %   Date:       26/11/2019
    %
    %   Copyright 2019  Micro Photon Devices
    %   
    %   Usage:
    %   flags = SOLUS_Flags(); initialize and fill all the parameters with 0
    %   flags = SOLUS_Flags(int16); initialize and fill with data from the int32. 
    %
    %   Rev 1.0-26/11/2019: first issue
    
    properties
        FORCE_LASER_OFF@logical = false;
        AUTOCAL@logical = false;
        OVERRIDE_MAP@logical = false;
        GSIPM_GATE_OFF_AFTER_MEAS@logical = false;
        LASER_OFF_AFTER_MEAS@logical = false;
        TURNOFF_UNUSED_LD@logical = false;
        TRIM_METHOD@logical = false;
        DISABLE_INTERLOCK@logical = false;
    end
    
    methods
        % constructor / inizializator
        function obj = SOLUS_Flags(num)
            if nargin ~= 0 && nargin ~= 1
                error('SOLUS_Flags:wrongArgs',...
                    'SOLUS_Flags must be called with 0 or 1 argument');
            end
            if nargin == 1
                obj=obj.fromInt(num);
            end
        end
        
        % convert class to int
        function int = toInt(obj)
            int=uint16(obj.FORCE_LASER_OFF+obj.AUTOCAL*2+obj.OVERRIDE_MAP*4+...
                obj.GSIPM_GATE_OFF_AFTER_MEAS*8+obj.LASER_OFF_AFTER_MEAS*16+...
                obj.TURNOFF_UNUSED_LD*32+obj.TRIM_METHOD*64+obj.DISABLE_INTERLOCK*256);
        end
        %% convert from int
        function obj = fromInt(obj, num)
            if isa(num,'uint16')
                obj.FORCE_LASER_OFF=bitget(num,1);
                obj.AUTOCAL=bitget(num,2);
                obj.OVERRIDE_MAP=bitget(num,3);
                obj.GSIPM_GATE_OFF_AFTER_MEAS=bitget(num,4);
                obj.LASER_OFF_AFTER_MEAS=bitget(num,5);
                obj.TURNOFF_UNUSED_LD=bitget(num,6);
                obj.TRIM_METHOD=uint16(sum(bitget(num,7:8).*uint16([1 2])));
                obj.DISABLE_INTERLOCK=bitget(num,9);
            else
                error('SOLUS_Flags:wrongArgs',...
                    'Input argument of SOLUS_Flags must be a uint16');
            end
        end
    end
end