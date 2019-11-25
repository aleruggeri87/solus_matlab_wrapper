classdef SOLUS_HL < handle
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
        max_area=zeros(1,8);
        avoid_read=false;
    end
    
    properties (Dependent)
        laserFrequency;
        gsipm_params;
        sequence;
        calibMap;
    end
    
    properties(SetAccess = private)
        solus;
        statusControl;
        optodeID;
        statusLD=SOLUS_LD_Status();
        statusOptode;
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
        
        function set.laserFrequency(obj,value)
            obj.s.SetLaserFrequency(value);
        end
        
        function value = get.laserFrequency(obj)
            if ~obj.avoid_read
                obj.s.ReadLaserFrequency();
            end
            value = obj.s.GetLaserFrequency();
        end
        
        function value = get.statusControl(obj)
            if ~obj.avoid_read
                obj.s.ReadStatusControl();
            end
            value = obj.s.GetStatusControl();
        end
        
        function value = get.sequence(obj)
            value = obj.s.GetSequence();
        end
        
        function set.sequence(obj, value)
            obj.s.SetSequence(value);
        end
        
        function value = get.gsipm_params(obj)
            for k=8:-1:1
                if obj.s.optConnected(k)
                    value(k)=obj.s.GetOptodeParams(k-1);
                end
            end
        end
        
        function value = get.optodeID(obj)
            for k=8:-1:1
                if obj.s.optConnected(k)
                    % No need to call ReadMCU_ID!
                    value(k)=obj.s.GetMCU_ID(k-1);
                end
            end
        end
        
        function value = get.calibMap(obj)
            for k=8:-1:1
                if obj.s.optConnected(k)
                    if ~obj.avoid_read
                        obj.s.ReadCalibrationMap(k-1);
                    end
                    [value(:,k) obj.max_area(k)]=obj.s.GetCalibrationMap(k-1);
                end
            end
        end
        
        function set.calibMap(obj, value)
            % remember to set max_area before!
            for k=8:-1:1
                if obj.s.optConnected(k)
                    obj.s.SetCalibrationMap(k-1, value(:,k), obj.max_area(k));
                end
            end
        end
        
        function value = get.statusOptode(obj)
            obj.statusLD(4,8)=SOLUS_LD_Status();
            for k=8:-1:1
                if obj.s.optConnected(k)
                    if ~obj.avoid_read
                        obj.s.ReadStatusOptode(k-1);
                    end
                    [status, LD_status]=obj.s.GetStatusOptode(k-1);
                    value(k)=status;
                    obj.statusLD(:,k)=LD_status;
                end
            end
        end
        
    end
end
