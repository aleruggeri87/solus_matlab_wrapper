classdef SOLUS_HL% < handle
    % SOLUS_HL 
    %  SOLUS High-Level library.
    %
    %   Author(s):  Alessandro RUGGERI
    %   Revision:   1.0 
    %   Date:       20/11/2019
    %
    %   Copyright 2019  Micro Photon Devices
    %
    %   Rev 1.0-20/11/2019: first issue
    
    properties
        solus;
    end
    
    properties (Dependent)
        laserFrequency;
        gsipm_params;
    end
    
    properties (Access = private)
        s;
    end

    methods
        function obj = SOLUS_HL()
            obj.s=SOLUS();
        end
        
        function delete(obj)
            obj.s.delete();
        end
        
        function value = get.solus(obj)
            value = obj.s;
        end
        
        function obj = set.solus()
            error('Cannot set solus property');
        end
        
        function obj = set.laserFrequency(obj,value)
            obj.s.SetLaserFrequency(value);
        end
        
        function value = get.laserFrequency(obj)
            obj.s.ReadLaserFrequency();
            value = obj.s.GetLaserFrequency();
        end
        
        function value = get.gsipm_params(obj)
            for k=1:8
                try
                    value(k)=obj.s.GetOptodeParams(k);
                end
            end
        end
        
    end
end
