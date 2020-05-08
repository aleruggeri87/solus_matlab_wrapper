classdef SOLUS_Control_Parameters
    % SOLUS_Control_Parameters
    %
    %   Author(s):  Alessandro RUGGERI
    %   Revision:   1.0 
    %   Date:       21/11/2019
    %
    %   Copyright 2019  Micro Photon Devices
    %   
    %   Usage:
    %   cp = SOLUS_Control_Parameters(); initialize and fill all the  parameters with 0
    %   cp = SOLUS_Control_Parameters(ld_struct); initialize and fill with data from the struct. 
    %   cp = SOLUS_Control_Parameters();
    %       initialize and fill data with given parameters.
    %
    %   Rev 1.0-21/11/2019: first issue
    
    properties
        LD_Voltage=uint16(0);
        SPAD_Voltage=uint16(0);
        GSIPM3v3_Voltage=uint16(0);
        PAUSE_TIME=uint16(0);
        LD_CURRENT_LIMIT=uint16(0);
        LD_CURRENT_AVERAGE_LENGTH=uint16(0);
    end
    
    methods
        % constructor / inizializator
        function obj = SOLUS_Control_Parameters(LD_Voltage__struct,SPAD_Voltage,GSIPM3v3_Voltage, PAUSE_TIME, LD_CURRENT_LIMIT, LD_CURRENT_AVERAGE_LENGTH)
            if nargin ~= 0 && nargin ~= 1 && nargin ~= 6
                error('SOLUS_Control_Parameters:wrongArgs',...
                    'SOLUS_Control_Parameters must be called with 0, 1 or 6 arguments');
            end
            if nargin == 1
                obj=obj.fromStruct(en1__struct);
            elseif nargin == 3
                obj.LD_Voltage=LD_Voltage__struct;
                obj.SPAD_Voltage=SPAD_Voltage;
                obj.GSIPM3v3_Voltage=GSIPM3v3_Voltage;
                obj.PAUSE_TIME=PAUSE_TIME;
                obj.LD_CURRENT_LIMIT=LD_CURRENT_LIMIT;
                obj.LD_CURRENT_AVERAGE_LENGTH=LD_CURRENT_AVERAGE_LENGTH;
            end
        end
        
        % convert class to struct
        function LD_str = toStruct(obj)
            LD_str=struct('LD_Voltage', obj.LD_Voltage, 'SPAD_Voltage', obj.SPAD_Voltage,...
                'GSIPM3v3_Voltage', obj.GSIPM3v3_Voltage,'PAUSE_TIME',obj.PAUSE_TIME,'LD_CURRENT_LIMIT',obj.LD_CURRENT_LIMIT,'LD_CURRENT_AVERAGE_LENGTH',obj.LD_CURRENT_AVERAGE_LENGTH);
        end
        %% convert from struct
        function obj = fromStruct(obj, str)
            % convert struct to class
            if isa(str,'struct')
                fields={'LD_Voltage', 'SPAD_Voltage', 'GSIPM3v3_Voltage','PAUSE_TIME','LD_CURRENT_LIMIT','LD_CURRENT_AVERAGE_LENGTH'};
                ok=true;
                for k=1:length(fields);
                    if ~isfield(str,fields{k})
                        ok=false;
                        break;
                    end
                end
                if ok
                    obj.LD_Voltage=str.LD_Voltage;
                    obj.SPAD_Voltage=str.SPAD_Voltage;
                    obj.GSIPM3v3_Voltage=str.GSIPM3v3_Voltage;
                    obj.PAUSE_TIME=PAUSE_TIME;
                    obj.LD_CURRENT_LIMIT=LD_CURRENT_LIMIT;
                    obj.LD_CURRENT_AVERAGE_LENGTH=LD_CURRENT_AVERAGE_LENGTH;
                else
                    error('SOLUS_Control_Parameters:wrongArgs',...
                    'Input argument of SOLUS_Control_Parameters does not contains all the expected fields');
                end
            else
                error('SOLUS_Control_Parameters:wrongArgs',...
                    'Input argument of SOLUS_Control_Parameters must be a struct');
            end
        end
        % below functions to validate input parameters size
        % and convert to the desired type
        function obj = set.LD_Voltage(obj,val)
            if isscalar(val)
                obj.LD_Voltage=uint16(val);
            else
                SOLUS_Control_Parameters.printError(1);
            end
        end
        function obj = set.SPAD_Voltage(obj,val)
            if isscalar(val)
                obj.SPAD_Voltage=uint16(val);
            else
                SOLUS_Control_Parameters.printError(1);
            end
        end
        function obj = set.GSIPM3v3_Voltage(obj,val)
            if isscalar(val)
                obj.GSIPM3v3_Voltage=uint16(val);
            else
                SOLUS_Control_Parameters.printError(1);
            end
        end
        function obj = set.PAUSE_TIME(obj,val)
            if isscalar(val)
                obj.PAUSE_TIME=uint16(val);
            else
                SOLUS_Control_Parameters.printError(1);
            end
        end
        function obj = set.LD_CURRENT_LIMIT(obj,val)
            if isscalar(val)
                obj.LD_CURRENT_LIMIT=uint16(val);
            else
                SOLUS_Control_Parameters.printError(1);
            end
        end
        function obj = set.LD_CURRENT_AVERAGE_LENGTH(obj,val)
            if isscalar(val)
                obj.LD_CURRENT_AVERAGE_LENGTH=uint16(val);
            else
                SOLUS_Control_Parameters.printError(1);
            end
        end
    end
    
    methods(Static)
        function printError(size)
            if size==1
                str='A number is required';
            else
                str=['A vector with ' num2str(size) ' elements is required'];
            end
            error('SOLUS_Control_Parameters:badSize',str);
        end
    end
end