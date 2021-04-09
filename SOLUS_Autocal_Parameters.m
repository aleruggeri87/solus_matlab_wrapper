classdef SOLUS_Autocal_Parameters
    % SOLUS_Autocal_Parameters 
    %
    %   Author(s):  Alessandro RUGGERI
    %   Revision:   1.0 
    %   Date:       20/11/2019
    %
    %   Copyright 2019  Micro Photon Devices
    %   
    %   Usage:
    %   ap = SOLUS_Autocal_Parameters(); initialize and fill all the  parameters with 0
    %   ap = SOLUS_Autocal_Parameters(ld_struct); initialize and fill with data from the struct. 
    %   ap = SOLUS_Autocal_Parameters(goal, meas_time, steps, start_pos);
    %       initialize and fill data with given parameters.
    %
    %   Rev 1.0-20/11/2019: first issue
    
    properties
        goal=uint32(0);
        meas_time=uint16(0);
        steps=uint16(0);
        start_pos=uint16(0);
    end
    
    methods
        % constructor / inizializator
        function obj = SOLUS_Autocal_Parameters(goal__struct, meas_time, steps, start_pos)
            if nargin ~= 0 && nargin ~= 1 && nargin ~= 4
                error('SOLUS_Autocal_Parameters must be called with 0, 1 or 4 arguments');
            end
            if nargin == 1
                obj=obj.fromStruct(en1__struct);
            elseif nargin == 4
                obj.goal=goal__struct;
                obj.meas_time=meas_time;
                obj.steps=steps;
                obj.start_pos=start_pos;
            end
        end
        
        function ok=eq(obj1, obj2)
            ok=true;
            if size(obj1)==size(obj2)
                for k=1:numel(obj1)
                    ok=ok && obj1(k).goal==obj2(k).goal;
                    ok=ok && obj1(k).meas_time==obj2(k).meas_time;
                    ok=ok && obj1(k).steps==obj2(k).steps;
                    ok=ok && obj1(k).start_pos==obj2(k).start_pos;
                end
            else
                ok=false;
            end
        end
        
        % convert class to struct
        function LD_str = toStruct(obj)
            LD_str=struct('goal', obj.goal, ...
                'meas_time', uint16(obj.meas_time/100e-6),...
                'steps', obj.steps, 'start_pos', obj.start_pos);
        end
        % convert from struct
        function obj = fromStruct(obj, str)
            % convert struct to class
            if isa(str,'struct')
                fields={'goal', 'meas_time', 'steps', 'start_pos'};
                ok=true;
                for k=1:length(fields)
                    if ~isfield(str,fields{k})
                        ok=false;
                        break;
                    end
                end
                if ok
                    obj.goal=str.goal;
                    obj.meas_time=str.meas_time;
                    obj.steps=str.steps;
                    obj.start_pos=str.start_pos;
                else
                    error('Input argument of SOLUS_Autocal_Parameters does not contains all the expected fields');
                end
            else
                error('Input argument of SOLUS_Autocal_Parameters must be a struct');
            end
        end
        % convert to uint8 array
        function u8a=toUint8A(obj)
            u8a=[typecast(obj.goal,'uint8'), ...
                 typecast(obj.meas_time,'uint8'), ...
                 typecast(obj.steps,'uint8'), ...
                 typecast(obj.start_pos,'uint8')];
        end
        
        % convert from uint8 array
        function obj=fromUint8A(obj, u8a)
            obj.goal=u8a(1);
            obj.meas_time=u8a(2);
            obj.steps=u8a(3);
            obj.start_pos=u8a(4);
        end
        
        % below functions to validate input parameters size
        % and convert to the desired type
        function obj = set.goal(obj,val)
            if isscalar(val)
                obj.goal=uint32(val);
            else
                SOLUS_Autocal_Parameters.printError(1);
            end
        end
        function obj = set.meas_time(obj,val)
            if isscalar(val)
                obj.meas_time=uint16(val/100e-6);
            else
                SOLUS_Autocal_Parameters.printError(1);
            end
        end
        function val = get.meas_time(obj)
            val=double(obj.meas_time)*100e-6;
        end
        function obj = set.steps(obj,val)
            if isscalar(val)
                obj.steps=uint16(val);
            else
                SOLUS_Autocal_Parameters.printError(1);
            end
        end
        function obj = set.start_pos(obj,val)
            if isscalar(val)
                obj.start_pos=uint16(val);
            else
                SOLUS_Autocal_Parameters.printError(1);
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
            error('SOLUS_Autocal_Parameters:badSize',str);
        end
    end
end