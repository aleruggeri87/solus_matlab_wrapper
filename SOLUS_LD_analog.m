classdef SOLUS_LD_analog
    % SOLUS_LD_analog
    %
    %   Author(s):  Alessandro RUGGERI
    %   Revision:   1.0 
    %   Date:       26/11/2019
    %
    %   Copyright 2019  Micro Photon Devices
    %   
    %   Usage:
    %   lda = SOLUS_LD_analog(); initialize and fill all the parameters with 0
    %   lda = SOLUS_LD_analog(ld_struct); initialize and fill with data from the struct. 
    %   lda = SOLUS_LD_analog();
    %       initialize and fill data with given parameters.
    %
    %   Rev 1.0-26/11/2019: first issue
    
    properties(SetAccess = private)
        ILDK=uint16(0);
        VCI=uint16(0);
        V18=uint16(0);
        VDD=uint16(0);
        Temp=uint16(0);
    end
    
    properties(Constant, Access = private)
        fields={'ILDK', 'VCI', 'V18', 'VDD', 'Temp'};
    end
    
    methods
        % constructor / inizializator
        function obj = SOLUS_LD_analog(struct__array)
            if nargin ~= 0 && nargin ~= 1
                error('SOLUS_LD_analog:wrongArgs',...
                    'SOLUS_LD_analog must be called with 0 or 1 argument');
            end
            if nargin == 1
                obj=obj.fromStruct(struct__array);
            end
        end
        
        % convert class to struct
        function str = toStruct(obj)
            f=SOLUS_LD_analog.fields;
            str=repmat(cell2struct({[],[],[],[],[]}',f),size(obj));
            for j=1:numel(obj)
                for k=1:length(f)
                    str(j).(f{k})=obj(j).(f{k});
                end
            end
        end
        %% convert from struct/array
        function obj = fromStruct(obj, str_arr)
            % convert struct to class
            if isa(str_arr,'struct')
                ok=true;
                for k=1:length(obj.fields)
                    if ~isfield(str_arr,obj.fields{k})
                        ok=false;
                        break;
                    end
                end
                if ok
                    for k=1:length(obj.fields)
                        obj.(obj.fields{k})=str_arr.(obj.fields{k});
                    end
                else
                    error('SOLUS_LD_analog:wrongArgs',...
                    'Input argument of SOLUS_LD_analog does not contains all the expected fields');
                end
            elseif isvector(str_arr) && length(str_arr)==5 && isa(str_arr, 'uint16')
                for k=1:length(obj.fields)
                    obj.(obj.fields{k})=str_arr(k);
                end
            else
                error('SOLUS_LD_analog:wrongArgs',...
                    'Input argument of SOLUS_LD_analog must be a struct or an array of uint16 with length==5');
            end
        end
    end
end