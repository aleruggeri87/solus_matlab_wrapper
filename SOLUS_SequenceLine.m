classdef SOLUS_SequenceLine
    % SOLUS_SequenceLine 
    %
    %   Author(s):  Alessandro RUGGERI
    %   Revision:   1.0 
    %   Date:       20/11/2019
    %
    %   Copyright 2019  Micro Photon Devices
    %   
    %   Usage:
    %   ldp = SOLUS_SequenceLine(); initialize and fill all the  parameters with 0
    %   ldp = SOLUS_SequenceLine(ld_struct); initialize and fill with data from the struct. 
    %   ldp = SOLUS_SequenceLine(meas_time__struct, atten, gdc, gdf, las_num);
    %       initialize and fill data with given parameters.
    %
    %   Rev 1.0-20/11/2019: first issue
    
    properties
        meas_time = single(0);
        attenuation = zeros(1,8,'uint16');
        gate_delay_c = zeros(1,8,'uint8');
        gate_delay_f = zeros(1,8,'uint16');
        laser_num = uint8(0);
    end
    
    methods
        % constructor / inizializator
        function obj = SOLUS_SequenceLine(meas_time__struct, atten, gdc, gdf, las_num)
            if nargin ~= 0 && nargin ~= 1 && nargin ~= 5
                error('SOLUS_SequenceLine:wrongArgs',...
                    'SOLUS_SequenceLine must be called with 0, 1 or 5 arguments');
            end
            if nargin == 1
                obj.fromStruct(d_f__struct);                
            elseif nargin == 5
                obj.meas_time=meas_time__struct;
                obj.attenuation=atten;
                obj.gate_delay_c=gdc;
                obj.gate_delay_f=gdf;
                obj.laser_num=las_num;
            end
        end
        
        function ok=eq(obj1, obj2)
            ok=true;
            if size(obj1)==size(obj2)
                for k=1:numel(obj1)
                    ok=ok && obj1(k).meas_time==obj2(k).meas_time;
                    ok=ok && all(obj1(k).attenuation==obj2(k).attenuation);
                    ok=ok && all(obj1(k).gate_delay_c==obj2(k).gate_delay_c);
                    ok=ok && all(obj1(k).gate_delay_f==obj2(k).gate_delay_f);
                    ok=ok && obj1(k).laser_num==obj2(k).laser_num;
                end
            else
                ok=false;
            end
        end
        
        % convert class to struct
        function LD_str = toStruct(obj)
            LD_str=struct('meas_time', obj.meas_time, 'attenuation', obj.attenuation,...
                'gate_delay_coarse', obj.gate_delay_c, 'gate_delay_fine', obj.gate_delay_f,...
                'laser_num', obj.laser_num);
        end
        
        % convert from struct
        function obj = fromStruct(obj, str)
            if isa(str,'struct')
                fields={'meas_time', 'attenuation', 'gate_delay_coarse', 'gate_delay_fine', 'laser_num'};
                ok=true;
                for k=1:length(fields);
                    if ~isfield(str,fields{k})
                        ok=false;
                        break;
                    end
                end
                if ok
                    obj.meas_time=str.meas_time;
                    obj.attenuation=str.attenuation;
                    obj.gate_delay_c=str.gate_delay_coarse;
                    obj.gate_delay_f=str.gate_delay_fine;
                    obj.laser_num=str.laser_num;
                else
                    error('SOLUS_SequenceLine:wrongArgs',...
                    'Input argument of SOLUS_SequenceLine does not contains all the expected fields');
                end
                else
                error('SOLUS_SequenceLine:wrongArgs',...
                    'Input argument of SOLUS_SequenceLine must be a struct');
            end            
        end
        
        % below functions to validate input parameters size
        % and convert to the desired type
        function obj = set.meas_time(obj,val)
            if isscalar(val)
                obj.meas_time=single(val);
            else
                SOLUS_SequenceLine.printError(1);
            end
        end
        function obj = set.attenuation(obj,val)
            if isvector(val) && length(val)==8
                obj.attenuation=uint16(val);
            else
                SOLUS_SequenceLine.printError(8);
            end
        end
        function obj = set.gate_delay_c(obj,val)
            if isvector(val) && length(val)==8
                obj.gate_delay_c=uint8(val);
            else
                SOLUS_SequenceLine.printError(8);
            end
        end
        
        function obj = set.gate_delay_f(obj,val)
            if isvector(val) && length(val)==8
                obj.gate_delay_f=uint16(val);
            else
                SOLUS_SequenceLine.printError(8);
            end
        end
        function obj = set.laser_num(obj,val)
            if isscalar(val)
                obj.laser_num=uint8(val);
            else
                SOLUS_SequenceLine.printError(1);
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
            error('SOLUS_SequenceLine:badSize',str);
        end
    end
end