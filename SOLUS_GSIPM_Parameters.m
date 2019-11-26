classdef SOLUS_GSIPM_Parameters
    % SOLUS_GSIPM_Parameters 
    %
    %   Author(s):  Alessandro RUGGERI
    %   Revision:   1.0 
    %   Date:       20/11/2019
    %
    %   Copyright 2019  Micro Photon Devices
    %   
    %   Usage:
    %   gp = SOLUS_GSIPM_Parameters(); initialize and fill all the  parameters with 0
    %   gp = SOLUS_GSIPM_Parameters(ld_struct); initialize and fill with data from the struct. 
    %   gp = SOLUS_GSIPM_Parameters(en1,en2,en3,en4,stop,gate_close,gate_open);
    %       initialize and fill data with given parameters.
    %
    %   Rev 1.0-20/11/2019: first issue
    
    properties
        en1=uint8(0);
        en2=uint8(0);
        en3=uint8(0);
        en4=uint8(0);
        stop=uint8(0);
        gate_close=uint8(0);
        gate_open=uint8(0);
    end
    
    methods
        % constructor / inizializator
        function obj = SOLUS_GSIPM_Parameters(en1__struct,en2,en3,en4,stop,gate_close,gate_open)
            if nargin ~= 0 && nargin ~= 1 && nargin ~= 7
                error('SOLUS_GSIPM_Parameters:wrongArgs',...
                    'SOLUS_GSIPM_Parameters must be called with 0, 1 or 7 arguments');
            end
            if nargin == 1
                obj=obj.fromStruct(en1__struct);
            elseif nargin == 7
                obj.en1=en1__struct;
                obj.en2=en2;
                obj.en3=en3;
                obj.en4=en4;
                obj.stop=stop;
                obj.gate_close=gate_close;
                obj.gate_open=gate_open;
            end
        end
        
        % convert class to struct
        function LD_str = toStruct(obj)
            LD_str=struct('EN_QUADRANT_1', obj.en1, 'EN_QUADRANT_2', obj.en2,...
                'EN_QUADRANT_3', obj.en3, 'EN_QUADRANT_4', obj.en4,...
                'STOP', obj.stop,...
                'GATE_CLOSE', obj.gate_close, 'GATE_OPEN', obj.gate_open);
        end
        %% convert from struct
        function obj = fromStruct(obj, str)
            % convert struct to class
            if isa(str,'struct')
                fields={'EN_QUADRANT_1', 'EN_QUADRANT_2', 'EN_QUADRANT_3', 'EN_QUADRANT_4', 'STOP', 'GATE_CLOSE', 'GATE_OPEN'};
                ok=true;
                for k=1:length(fields);
                    if ~isfield(str,fields{k})
                        ok=false;
                        break;
                    end
                end
                if ok
                    obj.en1=str.EN_QUADRANT_1;
                    obj.en2=str.EN_QUADRANT_2;
                    obj.en3=str.EN_QUADRANT_3;
                    obj.en4=str.EN_QUADRANT_4;
                    obj.stop=str.STOP;
                    obj.gate_close=str.GATE_CLOSE;
                    obj.gate_open=str.GATE_OPEN;
                else
                    error('SOLUS_GSIPM_Parameters:wrongArgs',...
                    'Input argument of SOLUS_GSIPM_Parameters does not contains all the expected fields');
                end
            else
                error('SOLUS_GSIPM_Parameters:wrongArgs',...
                    'Input argument of SOLUS_GSIPM_Parameters must be a struct');
            end
        end
        % below functions to validate input parameters size
        % and convert to the desired type
        function obj = set.en1(obj,val)
            if isscalar(val)
                obj.en1=uint8(val);
            else
                SOLUS_GSIPM_Parameters.printError(1);
            end
        end
        function obj = set.en2(obj,val)
            if isscalar(val)
                obj.en2=uint8(val);
            else
                SOLUS_GSIPM_Parameters.printError(1);
            end
        end
        function obj = set.en3(obj,val)
            if isscalar(val)
                obj.en3=uint8(val);
            else
                SOLUS_GSIPM_Parameters.printError(1);
            end
        end
        function obj = set.en4(obj,val)
            if isscalar(val)
                obj.en4=uint8(val);
            else
                SOLUS_GSIPM_Parameters.printError(1);
            end
        end
        
        function obj = set.stop(obj,val)
            if isscalar(val)
                obj.stop=uint8(val);
            else
                SOLUS_GSIPM_Parameters.printError(1);
            end
        end
        function obj = set.gate_close(obj,val)
            if isscalar(val)
                obj.gate_close=uint8(val);
            else
                SOLUS_GSIPM_Parameters.printError(1);
            end
        end
        function obj = set.gate_open(obj,val)
            if isscalar(val)
                obj.gate_open=uint8(val);
            else
                SOLUS_GSIPM_Parameters.printError(1);
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
            error('SOLUS_GSIPM_Parameters:badSize',str);
        end
    end
end