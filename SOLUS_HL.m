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
        AutocalParams;
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
        analogOptodeUnits;
    end
    
    properties (Access = private)
        s;
    end

    methods
        function obj = SOLUS_HL(nodata)
            if nargin < 1
                nodata=false;
            end
            obj.s=SOLUS(nodata);
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
        
        function set.sequence(obj, seq__filename)
            if ischar(seq__filename) % load sequence from file
                seq__filename=SOLUS_HL.sequence_fromFile(seq__filename);
            end
            obj.s.SetSequence(seq__filename);
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
        
        function set.gsipm_params(obj, val)
            obj.OptodeParams_set(obj.LD_params,val);
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
        
        function set.LD_params(obj, val)
            obj.OptodeParams_set(val,obj.gsipm_params);
        end
        
        function OptodeParams_set(obj, LD_params__filename, GSIPM_params__filename)
            if ischar(LD_params__filename) % load from TRS file
                LD_params__filename=SOLUS_HL.LD_params_fromFile(LD_params__filename);
            end
            if ischar(GSIPM_params__filename) % load from TRS file
                GSIPM_params__filename=SOLUS_HL.GSIPM_params_fromFile(GSIPM_params__filename);
            end
            for k=8:-1:1
                if obj.s.optConnected(k)
                    obj.s.SetOptodeParams(LD_params__filename(k), GSIPM_params__filename(k), k-1);
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
        
        function calibMap_set(obj, map__filename, max_area)
            if ischar(map__filename) % load map from file (TRS format)
                map__filename=SOLUS_HL.calibMap_fromFile(map__filename);
            end
            % remember to set max_area before!
            for k=8:-1:1
                if obj.s.optConnected(k)
                    obj.s.SetCalibrationMap(k-1, map__filename(:,k), max_area(k));
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
        
        function set.AutocalParams(obj, AutocalParams)
            obj.s.SetAutocalParams(AutocalParams);
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
        
        function value = get.analogOptodeUnits(obj)
            aO=obj.analogOptode;
            for k=8:-1:1
                value(k).gsipmSPADvoltage=aO(k).gsipmSPADvoltage/1000;
                value(k).gsipmCoreVoltage=aO(k).gsipmCoreVoltage/1000;
                value(k).laserVoltage=aO(k).laserVoltage/1000;
                value(k).gsipmSPADcurrent=aO(k).gsipmSPADcurrent/1000*10;
                value(k).gsipmCoreCurrent=aO(k).gsipmCoreCurrent/1000*100;
                value(k).laserCurrent=aO(k).laserCurrent/1000*10;
                value(k).bandgap=aO(k).bandgap;
                value(k).gsipmTemperature=aO(k).gsipmTemperature/100;
                value(k).picTemperature=aO(k).picTemperature/100;
            end
        end
        
        function value = get.analogControl(obj)
            if ~obj.avoid_read_HW
                obj.s.ReadDiagControl();
            end
            value = obj.s.GetDiagControl();
        end
        
        function [data, control_status]=getMeas(obj, nLines, progress_on)
            if nargin < 3
                progress_on = false;
            end
            obj.s.StartSequence();
            data=[];
            tot_nl=0;
            if progress_on
                consoleProgress(0,'Sequence dnwl');
            end
            control_status(1:nLines)=SOLUS_Control_Status();
            while tot_nl<nLines
                nl=obj.s.QueryNLinesAvailable();
                if nl~=0
                    [data_t, status_t]=obj.s.GetMeasurement(nl);
                    data=[data; data_t]; %#ok<AGROW>
                    control_status(tot_nl+1:tot_nl+nl)=status_t;
                    tot_nl=tot_nl+nl;
                    if progress_on
                        consoleProgress(double(tot_nl)/nLines);
                    end
                end
            end
            if progress_on
                consoleProgress(1)
            end
            obj.s.StopSequence();
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
            t=zeros(N,6);
            for k=1:N
                acq=obj.analogOptode;
                t(k,:)=clock;
                for j=1:8
                    if obj.s.optConnected(j)
                        T(k,j)=acq(j).gsipmTemperature/100;
                    else
                        T(k,j)=NaN;
                    end
                end
                plot(etime(t(1:k,:),repmat(t(1,:),k,1)) ,T(1:k,:))
                drawnow;
                pause(0.1)
                if etime(t(k,:),t(1,:)) > Tm
                    break
                end
            end
            T=T(1:k,:);
            t=t(1:k);
        end
        
    end
    
    methods (Static)
        function LD_params=LD_params_fromFile(filename)
            r=2;
            P=zeros(7,8);
            for j=1:8
                for k=1:8
                    P(:,k)=dlmread(filename,'\t',[r,1,r+6,1]); % 1+(r:r+6);
                    r=r+8;
                end
                r=r+3;
                LD_params(j)=SOLUS_LD_Parameters(P(1,:), P(2,:), P(3,:), P(4,:), P(5,:), P(6,:), P(7,2:2:end), 0, 0, 300*100); %#ok<AGROW>
            end
        end
        
        function GSIPM_params=GSIPM_params_fromFile(filename)
            r=1;
            for k=1:8
                P=dlmread(filename,'\t',[r,1,r+6,1]); % 1+(r:r+6);
                GSIPM_params(k)=SOLUS_GSIPM_Parameters(P(1), P(2), P(3), P(4), P(5), P(6), P(7)); %#ok<AGROW>
                r=r+8;
            end
        end
        
        function calibMap=calibMap_fromFile(filename)
            calibMap=zeros(1728,8);
            r=1;
            for k=1:8
                calibMap(:,k)=dlmread(filename,'\t',[r,1,r+1727,1]);
                r=r+1729;
            end 
        end
        
        function sequence=sequence_fromFile(filename)
            A=dlmread(filename,'\t',1,0);
            if size(A,1)==384
                if size(A,2)==28 % new TRS file format
                    for k=384:-1:1
                        sequence(k)=SOLUS_SequenceLine(A(k,1),A(k,2:3:23), A(k,3:3:24), A(k,4:3:25), A(k,26));
                    end
                elseif size(A,2)==5 % old TRS file format
                    for k=384:-1:1
                        sequence(k)=SOLUS_SequenceLine(A(k,1),repmat(A(k,2),1,8), repmat(A(k,3),1,8), repmat(A(k,4),1,8), A(k,5));
                    end
                else
                    error('SOLUS_HL.sequence_fromFile, unexpected file size: wrong number of columns.');
                end 
            else
                error('SOLUS_HL.sequence_fromFile, unexpected file size: wrong number of lines.');
            end
        end
        
        function bootloader(hex_path, address)
            sol=SOLUS(true);
            fprintf('=== SOLUS Bootloader ===\n');
            if nargin < 2
                address = 0:7;
            end
            for k=1:length(address)
                switch address(k)
                    case SOLUS.CONTROL
                        id = 'control';
                    otherwise
                        id = ['optode ' num2str(address(k))];
                end
                sol.BootLoaderStart(address(k), hex_path);
                pct=0;
                t1=clock;
                while pct~=1
                    try
                        pct50=round(pct*50);
                        str=[repmat('#',1,pct50) repmat(' ',1,50-pct50)];
                        len=fprintf('Programming %s... [%s]\n', id, str);
                        pct=sol.BootLoaderAct();
                        fprintf(repmat(char(8),1,len));
                    catch err
                        try %#ok<TRYNC>
                            sol.BootLoaderStop();
                            sol.delete();
                        end
                        rethrow(err);
                    end
                end
                fprintf('Programming %s done, elapsed time: %.2f\n\n', id, etime(clock, t1));
                sol.BootLoaderStop();
                pause(0.5)
            end
            sol.ResetMCU(SOLUS.CONTROL);
            sol.delete();
        end
    end
end
