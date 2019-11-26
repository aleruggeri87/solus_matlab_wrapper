    classdef SOLUS_Optode_analog
    % SOLUS_Optode_analog
    %
    %   Author(s):  Alessandro RUGGERI
    %   Revision:   1.0 
    %   Date:       26/11/2019
    %
    %   Copyright 2019  Micro Photon Devices
    %   
    %   Usage:
    %   oa = SOLUS_Optode_analog(); initialize and fill all the parameters with 0
    %   oa = SOLUS_Optode_analog(ld_struct); initialize and fill with data from the struct. 
    %   oa = SOLUS_Optode_analog();
    %       initialize and fill data with given parameters.
    %
    %   Rev 1.0-26/11/2019: first issue
    
    properties(SetAccess = private)
        gsipmSPADcurrent=0;
        gsipmCoreCurrent=0;
        laserCurrent=0;
        gsipmSPADvoltage=0;
        gsipmCoreVoltage=0;
        laserVoltage=0;
        picTemperature=0;
        gsipmTemperature=0;
        bandgap=0;
    end
    
    properties(Constant, Access = private)
        fields={'gsipmSPADcurrent','gsipmCoreCurrent','laserCurrent',...
                'gsipmSPADvoltage','gsipmCoreVoltage','laserVoltage',...
                'picTemperature','gsipmTemperature','bandgap'};
    end
    
    methods
        % constructor / inizializator
        function obj = SOLUS_Optode_analog(struct)
            if nargin ~= 0 && nargin ~= 1
                error('SOLUS_Optode_analog:wrongArgs',...
                    'SOLUS_Optode_analog must be called with 0 or 1 argument');
            end
            if nargin == 1
                obj=obj.fromStruct(struct);
            end
        end
        
        % convert class to struct
        function str = toStruct(obj)
            for k=1:length(obj.fields);
                str.(obj.fields{k})=obj.(obj.fields{k});
            end
        end
        %% convert from struct
        function obj = fromStruct(obj, str)
            % convert struct to class
            if isa(str,'struct')
                ok=true;
                for k=1:length(obj.fields);
                    if ~isfield(str,obj.fields{k})
                        ok=false;
                        break;
                    end
                end
                if ok
                    for k=1:length(obj.fields)
                        obj.(obj.fields{k})=str.(obj.fields{k});
                    end
                else
                    error('SOLUS_Optode_analog:wrongArgs',...
                    'Input argument of SOLUS_Optode_analog does not contains all the expected fields');
                end
            else
                error('SOLUS_Optode_analog:wrongArgs',...
                    'Input argument of SOLUS_Optode_analog must be a struct');
            end
        end
    end
end