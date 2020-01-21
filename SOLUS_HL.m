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
        avoid_read_HW=false;
    end
    
    properties (Dependent)
        laserFrequency;
        gsipm_params;
        LD_params;
        sequence;
        calibMap;
        flags;
    end
    
    properties(SetAccess = private)
        solus;
        statusControl;
        optodeID;
        statusLD=SOLUS_LD_Status();
        statusOptode;
        analogLD;
        analogOptode;
        analogControl;
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
            if ~obj.avoid_read_HW
                obj.s.ReadLaserFrequency();
            end
            value = obj.s.GetLaserFrequency();
        end
        
        function value = get.statusControl(obj)
            if ~obj.avoid_read_HW
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
                    [~,value(k)]=obj.s.GetOptodeParams(k-1);
                else
                    value(k)=SOLUS_GSIPM_Parameters();
                end
            end
        end
        
        function value = get.LD_params(obj)
            for k=8:-1:1
                if obj.s.optConnected(k)
                    value(k)=obj.s.GetOptodeParams(k-1);
                else
                    value(k)=SOLUS_LD_Parameters();
                end
            end
        end
        
        function value = get.optodeID(obj)
            for k=8:-1:1
                if obj.s.optConnected(k)
                    % No need to call ReadMCU_ID!
                    value(k)=obj.s.GetMCU_ID(k-1);
                else
                    value(k)=0;
                end
            end
        end
        
        function value = get.calibMap(obj)
            for k=8:-1:1
                if obj.s.optConnected(k)
                    if ~obj.avoid_read_HW
                        obj.s.ReadCalibrationMap(k-1);
                    end
                    [value(:,k) obj.max_area(k)]=obj.s.GetCalibrationMap(k-1);
                else
                    value(:,k)=zeros(1,1728,'uint16');
                    obj.max_area(k)=0;
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
                    if ~obj.avoid_read_HW
                        obj.s.ReadStatusOptode(k-1);
                    end
                    [status, LD_status]=obj.s.GetStatusOptode(k-1);
                    value(k)=status;
                    obj.statusLD(:,k)=LD_status;
                else
                    value(k)=SOLUS_Optode_Status();
                    obj.statusLD(:,k)=repmat(SOLUS_LD_Status,4,1);
                end
            end
        end
        
        function value = get.flags(obj)
            value=obj.s.GetFlags();
        end
        
        function set.flags(obj,flags)
            obj.s.SetFlags(flags);
        end
        
        function value = get.analogLD(obj)
            for k=8:-1:1
                if obj.s.optConnected(k)
                    if ~obj.avoid_read_HW
                        obj.s.ReadDiagOptode(k-1);
                    end
                    value(:,k) = obj.s.GetDiagOptode(k-1);
                else
                    value(:,k) = repmat(SOLUS_LD_analog(),1,4);
                end
            end
        end
        
        function value = get.analogOptode(obj)
            for k=8:-1:1
                if obj.s.optConnected(k)
                    if ~obj.avoid_read_HW
                        obj.s.ReadDiagOptode(k-1);
                    end
                    [~,value(k)] = obj.s.GetDiagOptode(k-1);
                else
                    value(k) = SOLUS_Optode_analog();
                end
            end
        end
        
        function value = get.analogControl(obj)
            if ~obj.avoid_read_HW
                obj.s.ReadDiagControl();
            end
            value = obj.s.GetDiagControl();
        end
        
        %% print
        function print_analogOptodes(obj)
            title='Optode analog acquisitions';
            label={'Opd', 'SPAD (V)', 'GSIPM (V)', 'LASER (V)', 'SPAD (uA)',...
                'GSIPM (mA)', 'LASER (mA)', 'Bandg', ' GSIPM (°C)', 'PIC (°C)'};

            acq=obj.analogOptode();
            K=find(obj.s.optConnected);
            L=length(K);
            data=zeros(L,9);
            col1=cell(L,1);
            j=1;
            for k=1:L
                data(j,1)=acq(K(k)).gsipmSPADvoltage/1000;
                data(j,2)=acq(K(k)).gsipmCoreVoltage/1000;
                data(j,3)=acq(K(k)).laserVoltage/1000;
                data(j,4)=acq(K(k)).gsipmSPADcurrent/1000*10;
                data(j,5)=acq(K(k)).gsipmCoreCurrent/1000*100;
                data(j,6)=acq(K(k)).laserCurrent/1000*10;
                data(j,7)=acq(K(k)).bandgap;
                data(j,8)=acq(K(k)).gsipmTemperature/100;
                data(j,9)=acq(K(k)).picTemperature/100;
                col1{j}=['  #' num2str(K(k)) ' '];
                j=j+1;
            end

            table_ale(data,label,title,3,col1)
        end
        
        function print_analogControl(obj)
            title='Control analog acquisitions';
            label={'IN (V)', 'SPAD (V)', 'IN (mA)', 'SPAD (uA)', '5V (V)', ' IN (W)'};

            acq=obj.analogControl();
            data=zeros(1,6);
            data(1)=acq.inputVoltage/1000;
            data(2)=acq.spadVoltage/1000;
            data(3)=acq.inputCurrent/1000*100;
            data(4)=acq.spadCurrent/1000*10;
            data(5)=acq.p5Volt/1000;
            data(6)=data(1)*data(3)/1000;

            table_ale(data,label,title,3)
        end
        
        %% plot
        function [T,t]=plot_temperature_vs_time(obj, Tm)
            N=Tm*10;
            T=zeros(N,8);
            t=zeros(N,1);
            for k=1:1000
                acq=obj.analogOptode;
                t(k)=now;
                for j=1:8
                    if obj.s.optConnected(j)
                        T(k,j)=acq(j).gsipmTemperature/100;
                    else
                        T(k,j)=Nan;
                    end
                end
                plot(t(1:k)-t(1),T(1:k,:))
                drawnow;
                pause(0.1)
                if t(k)-t(1) > Tm
                    break
                end
            end
            T=T(1:k,:);
            t=t(1:k);
        end
    end
end
