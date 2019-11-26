classdef SOLUS_Control_analog
    % SOLUS_Control_analog
    %
    %   Author(s):  Alessandro RUGGERI
    %   Revision:   1.0 
    %   Date:       26/11/2019
    %
    %   Copyright 2019  Micro Photon Devices
    %   
    %   Usage:
    %   ca = SOLUS_Control_analog(); initialize and fill all the parameters with 0
    %   ca = SOLUS_Control_analog(ld_struct); initialize and fill with data from the struct. 
    %   ca = SOLUS_Control_analog();
    %       initialize and fill data with given parameters.
    %
    %   Rev 1.0-26/11/2019: first issue
    
    properties(SetAccess = private)
        spadCurrent=int16(0);
        inputCurrent=int16(0);
        spadVoltage=uint16(0);
        inputVoltage=uint16(0);
        p5Volt=uint16(0);
    end
    
    properties(Constant, Access = private)
        fields={'spadCurrent','inputCurrent','spadVoltage',...
                'inputVoltage','p5Volt'};
    end
    
    methods
        % constructor / inizializator
        function obj = SOLUS_Control_analog(struct)
            if nargin ~= 0 && nargin ~= 1
                error('SOLUS_Control_analog:wrongArgs',...
                    'SOLUS_Control_analog must be called with 0 or 1 argument');
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
                    error('SOLUS_Control_analog:wrongArgs',...
                    'Input argument of SOLUS_Control_analog does not contains all the expected fields');
                end
            else
                error('SOLUS_Control_analog:wrongArgs',...
                    'Input argument of SOLUS_Control_analog must be a struct');
            end
        end
    end
end