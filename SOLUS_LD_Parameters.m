classdef SOLUS_LD_Parameters
    % SOLUS_LD_Parameters 
    %
    %   Author(s):  Alessandro RUGGERI
    %   Revision:   1.0 
    %   Date:       20/11/2019
    %
    %   Copyright 2019  Micro Photon Devices
    %   
    %   Usage:
    %   ldp = SOLUS_LD_Parameters(); initialize and fill all the parameters with 0
    %   ldp = SOLUS_LD_Parameters(ld_struct); initialize and fill with data from the struct. 
    %   ldp = SOLUS_LD_Parameters(d_f, d_c, w_f, w_c, i_f, i_c, c, s_f, s_c, c_l);
    %       initialize and fill data with given parameters.
    %
    %   Rev 1.0-20/11/2019: first issue
    
    properties
        delay_f = zeros(1,8,'uint16');
        delay_c = zeros(1,8,'uint8');
        width_f = zeros(1,8,'uint16');
        width_c = zeros(1,8,'uint8');
        current_f = zeros(1,8,'uint16');
        current_c = zeros(1,8,'uint8');
        citr = zeros(1,4,'uint8');
        sync_f = uint16(0);
        sync_c = uint8(0);
        current_limit = uint16(0);
    end
    
    methods
        % constructor / inizializator
        function obj = SOLUS_LD_Parameters(d_f__struct, d_c, w_f, w_c, i_f, i_c, c, s_f, s_c, c_l)
            if nargin ~= 0 && nargin ~= 1 && nargin ~= 9
                error('SOLUS_LD_Parameters:wrongArgs',...
                    'SOLUS_LD_Parameters must be called with 0, 1 or 9 arguments');
            end
            if nargin == 1
                obj=obj.fromStruct(d_f__struct);
            elseif nargin == 9
                obj.delay_f=d_f__struct;
                obj.delay_c=d_c;
                obj.width_f=w_f;
                obj.width_c=w_c;
                obj.current_f=i_f;
                obj.current_c=i_c;
                obj.citr=c;
                obj.sync_f=s_f;
                obj.sync_c=s_c;
                obj.current_limit=c_l;
            end
        end
        
        function ok=eq(obj1, obj2)
            ok=true;
            if size(obj1)==size(obj2)
                for k=1:numel(obj1)
                    ok=ok && all(obj1(k).delay_f==obj2(k).delay_f);
                    ok=ok && all(obj1(k).delay_c==obj2(k).delay_c);
                    ok=ok && all(obj1(k).width_f==obj2(k).width_f);
                    ok=ok && all(obj1(k).width_c==obj2(k).width_c);
                    ok=ok && all(obj1(k).current_f==obj2(k).current_f);
                    ok=ok && all(obj1(k).current_c==obj2(k).current_c);
                    ok=ok && all(obj1(k).citr==obj2(k).citr);
                    ok=ok && obj1(k).sync_f==obj2(k).sync_f;
                    ok=ok && obj1(k).sync_c==obj2(k).sync_c;
                    ok=ok && obj1(k).current_limit==obj2(k).current_limit;
                end
            else
                ok=false;
            end
        end
        
        % convert class to struct
        function LD_str = toStruct(obj)
            LD_str=struct('DELAY_F', obj.delay_f, 'DELAY_C', obj.delay_c,...
                'WIDTH_F', obj.width_f, 'WIDTH_C', obj.width_c,...
                'I_FINE', obj.current_f, 'I_COARSE', obj.current_c,...
                'CITR', obj.citr, 'SYNCD_F', obj.sync_f, 'SYNCD_C', obj.sync_c, 'CURRENT_LIMIT', obj.current_limit);
        end
        
        % convert from struct
        function obj=fromStruct(obj, str)
            if isa(str,'struct')
                fields={'DELAY_F', 'DELAY_C', 'WIDTH_F', 'WIDTH_C', 'I_FINE', 'I_COARSE', 'CITR', 'SYNCD_F', 'SYNCD_C', 'CURRENT_LIMIT'};
                ok=true;
                for k=1:length(fields);
                    if ~isfield(str,fields{k})
                        ok=false;
                        break;
                    end
                end
                if ok
                    obj.delay_f=str.DELAY_F;
                    obj.delay_c=str.DELAY_C;
                    obj.width_f=str.WIDTH_F;
                    obj.width_c=str.WIDTH_C;
                    obj.current_f=str.I_FINE;
                    obj.current_c=str.I_COARSE;
                    obj.citr=str.CITR;
                    obj.sync_f=str.SYNCD_F;
                    obj.sync_c=str.SYNCD_C;
                    obj.current_limit=str.CURRENT_LIMIT;
                else
                    error('SOLUS_LD_Parameters:wrongArgs',...
                    'Input argument of SOLUS_LD_Parameters does not contains all the expected fields');
                end
                else
                error('SOLUS_LD_Parameters:wrongArgs',...
                    'Input argument of SOLUS_LD_Parameters must be a struct');
            end            
        end
        
        % below functions to validate input parameters size
        % and convert to the desired type
        function obj = set.delay_f(obj,val)
            if isvector(val) && length(val)==8
                obj.delay_f=uint16(val);
            else
                SOLUS_LD_Parameters.printError(8);
            end
        end
        function obj = set.width_f(obj,val)
            if isvector(val) && length(val)==8
                obj.width_f=uint16(val);
            else
                SOLUS_LD_Parameters.printError(8);
            end
        end
        function obj = set.current_f(obj,val)
            if isvector(val) && length(val)==8
                obj.current_f=uint16(val);
            else
                SOLUS_LD_Parameters.printError(8);
            end
        end
        
        function obj = set.delay_c(obj,val)
            if isvector(val) && length(val)==8
                obj.delay_c=uint8(val);
            else
                SOLUS_LD_Parameters.printError(8);
            end
        end
        function obj = set.width_c(obj,val)
            if isvector(val) && length(val)==8
                obj.width_c=uint8(val);
            else
                SOLUS_LD_Parameters.printError(8);
            end
        end
        function obj = set.current_c(obj,val)
            if isvector(val) && length(val)==8
                obj.current_c=uint8(val);
            else
                SOLUS_LD_Parameters.printError(8);
            end
        end
        
        function obj = set.citr(obj,val)
            if isvector(val) && length(val)==4
                obj.citr=uint8(val);
            else
                SOLUS_LD_Parameters.printError(4);
            end
        end
        
        function obj = set.sync_f(obj,val)
            if isscalar(val)
                obj.sync_f=uint16(val);
            else
                SOLUS_LD_Parameters.printError(1);
            end
        end
        function obj = set.sync_c(obj,val)
            if isscalar(val)
                obj.sync_c=uint8(val);
            else
                SOLUS_LD_Parameters.printError(1);
            end
        end
        function obj = set.current_limit(obj,val)
            if isscalar(val)
                obj.current_limit=uint16(val);
            else
                SOLUS_LD_Parameters.printError(1);
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
            error('SOLUS_LD_Parameters:badSize',str);
        end
    end
end