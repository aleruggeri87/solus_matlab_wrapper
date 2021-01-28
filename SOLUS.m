classdef SOLUS < handle
    % SOLUS 
    %  probe control library.
    %
    %   Author(s):  Alessandro RUGGERI
    %   Revision:   1.0 
    %   Date:       20/11/2019
    %
    %   Copyright 2019  Micro Photon Devices
    %
    %   Rev 1.0-20/11/2019: first issue
    
    properties
        s;
        optConnected;
        log;
    end
    
    properties (Constant)
        OPTODE1 = 0;
        OPTODE2 = 1;
        OPTODE3 = 2;
        OPTODE4 = 3;
        OPTODE5 = 4;
        OPTODE6 = 5;
        OPTODE7 = 6;
        OPTODE8 = 7;
        CONTROL = 8;
        N_ROWS=384;
    end
    
    properties (Constant, Access = private)
        LIBALIAS = 'SOLUS_SDK';
        N_LD=4;
        N_OPT=8;
    end
        
    methods
        function obj = SOLUS(nodata)
            SOLUS.loadLib();
            
            obj.s = libpointer('s_SOLUS_HPtr');
            obj.optConnected=zeros(8,1);
            
            if nargin < 1
                nodata = false;
            end
            if ~nodata
                [err,~,obj.optConnected]=calllib(obj.LIBALIAS, 'SOLUS_Constr', obj.s, obj.optConnected);
            else
                [err,~,obj.optConnected]=calllib(obj.LIBALIAS, 'SOLUS_Constr_nodata', obj.s, obj.optConnected);
            end
            SOLUS.checkError(err);
            obj.log=logger([],[],'SOLUS LOGGER', @SOLUS.log_data_formatter);
            obj.getOrIncrementInstCount(1);
        end
        
        function SetLaserFrequency(obj, laser_frequency)
            % SOLUS_Return SOLUS_SetLaserFrequency(SOLUS_H solus, UINT32 Frequency);
            err=calllib(obj.LIBALIAS, 'SOLUS_SetLaserFrequency', obj.s, laser_frequency);
            obj.log.log(err, laser_frequency);
            SOLUS.checkError(err);
        end
        
        function ReadLaserFrequency(obj)
            % SOLUS_Return SOLUS_ReadLaserFrequency(SOLUS_H solus);
            err=calllib(obj.LIBALIAS, 'SOLUS_ReadLaserFrequency', obj.s);
            obj.log.log(err);
            SOLUS.checkError(err);
        end
        
        function lf_ret = GetLaserFrequency(obj)
            % SOLUS_Return SOLUS_GetLaserFrequency(SOLUS_H solus, UINT32* Frequency);
            [err, ~, lf_ret]=calllib(obj.LIBALIAS, 'SOLUS_GetLaserFrequency', obj.s, 0);
            obj.log.log(err);
            SOLUS.checkError(err);
        end

        function ReadDiagControl(obj)
            % SOLUS_Return SOLUS_ReadDiagControl(SOLUS_H solus);
            err=calllib(obj.LIBALIAS, 'SOLUS_ReadDiagControl', obj.s);
            obj.log.log(err);
            SOLUS.checkError(err);
        end
        
        function ctrl_an_acq = GetDiagControl(obj)
            % SOLUS_Return SOLUS_GetDiagControl(SOLUS_H solus, Control_analog_acq* Control_Analog);
            [err,~,ctrl_an_a]=calllib(obj.LIBALIAS, 'SOLUS_GetDiagControl', obj.s, []);
            SOLUS.checkError(err);
            obj.log.log(err);
            ctrl_an_acq=SOLUS_Control_analog(ctrl_an_a);
        end
        
        
        function SetSequence(obj, seq)
            if ~isa(seq,'SOLUS_SequenceLine')
                SOLUS.printError('badType','Input sequence must be type SOLUS_SequenceLine');
            end
            if length(seq) > obj.N_ROWS
                SOLUS.printError('badLength',...
                    ['Input sequence must be shorter than ' num2str(obj.N_ROWS+1) ' elements']);
            end

            seq_byte=zeros(1,obj.N_ROWS*45,'uint8');
            i=1;
            for k=1:length(seq)
                seq_byte(i:i+45-1)=uint8([typecast(seq(k).meas_time,'uint8')...
                    typecast(seq(k).attenuation,'uint8') typecast(seq(k).gate_delay_c,'uint8')...
                    typecast(seq(k).gate_delay_f,'uint8') typecast(seq(k).laser_num,'uint8')]);
                i=i+45;
            end
            seqPtr = libpointer('voidPtr',seq_byte);

            % SOLUS_Return SOLUS_SetSequence(SOLUS_H solus, Sequence* sequence)
            err=calllib(obj.LIBALIAS, 'SOLUS_SetSequence', obj.s, seqPtr);
            obj.log.log(err, seq);
            SOLUS.checkError(err);
        end

        function seq_str_rd = GetSequence(obj)
            seq_b_rd=zeros(1,obj.N_ROWS*45,'uint8');
            seqPtr_rd = libpointer('uint8Ptr',seq_b_rd);

            % SOLUS_Return SOLUS_GetSequence(SOLUS_H solus, Sequence* sequence)
            err=calllib(obj.LIBALIAS, 'SOLUS_GetSequence', obj.s, seqPtr_rd);
            obj.log.log(err);
            SOLUS.checkError(err);
            seq_str_rd(obj.N_ROWS)=SOLUS_SequenceLine();
            i=0;
            for k=1:obj.N_ROWS
                seq_str_rd(k).meas_time=typecast(seqPtr_rd.Value((1:4)+i),'single');
                seq_str_rd(k).attenuation=typecast(seqPtr_rd.Value((5:20)+i),'uint16');
                seq_str_rd(k).gate_delay_c=typecast(seqPtr_rd.Value((21:28)+i),'uint8');
                seq_str_rd(k).gate_delay_f=typecast(seqPtr_rd.Value((29:44)+i),'uint16');
                seq_str_rd(k).laser_num=typecast(seqPtr_rd.Value((45)+i),'uint8');
                i=i+45;
            end
        end

        function SetOptodeParams(obj, LD_params, GSIPM_params, optode_addr)
            if ~isa(LD_params, 'SOLUS_LD_Parameters')
                SOLUS.printError('badType','LD_params must be type SOLUS_LD_Parameters');
            end
            if ~isa(GSIPM_params, 'SOLUS_GSIPM_Parameters')
                SOLUS.printError('badType','GSIPM_params must be type SOLUS_GSIPM_Parameters');
            end
            
            LD_str=LD_params.toStruct();
            GSIPM_str=GSIPM_params.toStruct();
            if ~strcmp(version('-release'),'2012a')
                % SOLUS_Return SOLUS_SetOptodeParams(SOLUS_H solus, ADDRESS optode, LD_parameters LD_parameters, GSIPM_parameters GSIPM_parameters)
                err=calllib(obj.LIBALIAS, 'SOLUS_SetOptodeParams', obj.s, optode_addr, LD_str, GSIPM_str);
            else
                pLD_str=libpointer('LD_parametersPtr',LD_str);
                pGSIPM_str=libpointer('GSIPM_parametersPtr',GSIPM_str);
                % SOLUS_Return SOLUS_SetOptodeParams_byRef(SOLUS_H solus, ADDRESS optode, LD_parameters *LD_parameters, GSIPM_parameters *GSIPM_parameters)
                err=calllib(obj.LIBALIAS, 'SOLUS_SetOptodeParams_byRef', obj.s, optode_addr, pLD_str, pGSIPM_str);
            end
            obj.log.log(err, optode_addr, LD_params, GSIPM_params);
            SOLUS.checkError(err);
        end

        function [LD_str,GSIPM_str] = GetOptodeParams(obj, optode_addr)
            % SOLUS_Return SOLUS_GetOptodeParams(SOLUS_H solus, ADDRESS optode, LD_parameters* LD_Parameters, GSIPM_parameters* GSIPM_parameters)
            [err,~,LD_str_ret,GSIPM_str_ret]=calllib(obj.LIBALIAS, 'SOLUS_GetOptodeParams', obj.s, optode_addr, [], []);
            obj.log.log(err, optode_addr);
            SOLUS.checkError(err);
            
            LD_str=SOLUS_LD_Parameters(LD_str_ret);
            GSIPM_str=SOLUS_GSIPM_Parameters(GSIPM_str_ret);
        end
        
        function ReadStatusControl(obj)
            % SOLUS_Return SOLUS_ReadStatusControl(SOLUS_H solus)
            err=calllib(obj.LIBALIAS, 'SOLUS_ReadStatusControl', obj.s);
            obj.log.log(err);
            SOLUS.checkError(err);
        end
        
        function status = GetStatusControl(obj)
            % SOLUS_Return SOLUS_GetStatusControl(SOLUS_H solus, UINT16* status)
            [err, ~, stat]=calllib(obj.LIBALIAS, 'SOLUS_GetStatusControl', obj.s, 0);
            obj.log.log(err);
            SOLUS.checkError(err);
            status = SOLUS_Control_Status(stat);
        end
        
        function ReadDiagOptode(obj, optode)
            % SOLUS_Return SOLUS_ReadDiagOptode(SOLUS_H solus, ADDRESS Optode)
            err=calllib(obj.LIBALIAS, 'SOLUS_ReadDiagOptode', obj.s, optode);
            obj.log.log(err, optode);
            SOLUS.checkError(err);           
        end
            
        function [LD_analog, Optode_analog]=GetDiagOptode(obj, optode)
            % SOLUS_Return SOLUS_GetDiagOptode(SOLUS_H solus, ADDRESS Optode, LDs_analog* LD_Analog, Optode_analog_acq* Optode_Analog)
            [err, ~, LD_an_arry, Opt_an]=calllib(obj.LIBALIAS, 'SOLUS_GetDiagOptode', obj.s, optode, zeros(1,4*5,'uint16'), []);
            obj.log.log(err, optode);
            SOLUS.checkError(err);
            for k=4:-1:1
                LD_analog(k)=SOLUS_LD_analog(LD_an_arry((1:5)+(k-1)*5));
            end
            Optode_analog=SOLUS_Optode_analog(Opt_an);
        end
        
        function LaserON(obj, optode, laser)
            % SOLUS_Return SOLUS_LaserON(SOLUS_H solus, ADDRESS address, UINT8 laser)
            err=calllib(obj.LIBALIAS, 'SOLUS_LaserON', obj.s, optode, laser);
            obj.log.log(err, optode, laser);
            SOLUS.checkError(err);           
        end
        
        function LaserOFF(obj)
            % SOLUS_Return SOLUS_LaserOFF(SOLUS_H solus)
            err=calllib(obj.LIBALIAS, 'SOLUS_LaserOFF', obj.s);
            obj.log.log(err);
            SOLUS.checkError(err);
        end
            
        function SetFlags(obj, flags, mask)
            if nargin < 3
                mask = SOLUS_Flags(65535);
            end
            
            if ~isa(flags, 'SOLUS_Flags')
                SOLUS.printError('badType','flags must be type SOLUS_Flags');
            end
            if ~isa(mask, 'SOLUS_Flags')
                SOLUS.printError('badType','mask must be type SOLUS_Flags');
            end
            
            flg=flags.toInt();
            msk=mask.toInt();
            
            % SOLUS_Return SOLUS_SetFlags(SOLUS_H solus, UINT16 flags, UINT16 mask)
            err=calllib(obj.LIBALIAS, 'SOLUS_SetFlags', obj.s, flg, msk);
            obj.log.log(err, flags, mask)
            SOLUS.checkError(err);
        end
        
        function flags = GetFlags(obj)
            % SOLUS_Return SOLUS_GetFlags(SOLUS_H solus, UINT16* flags)
            [err,~,flg] =calllib(obj.LIBALIAS, 'SOLUS_GetFlags', obj.s, 0);
            obj.log.log(err);
            SOLUS.checkError(err);
            flags = SOLUS_Flags(flg);
        end
        
        function ctrl_param = GetControlParams(obj)
            % SOLUS_Return SOLUS_GetControlParams(SOLUS_H solus, Control_params* Params)
            [err, ~, cp]=calllib(obj.LIBALIAS, 'SOLUS_GetControlParams', obj.s, []);
            ctrl_param = SOLUS_Control_Parameters(cp);
            obj.log.log(err);
            SOLUS.checkError(err);
        end
        
        function SetControlParams(obj, ctrl_param)
            if ~isa(ctrl_param, 'SOLUS_Control_Parameters')
                SOLUS.printError('badType','ctrl_param must be type SOLUS_Control_Parameters');
            end
            
            cp=ctrl_param.toStruct();
            % SOLUS_Return SOLUS_SetControlParams(SOLUS_H solus, Control_params Params)
            err=calllib(obj.LIBALIAS, 'SOLUS_SetControlParams', obj.s, cp);
            obj.log.log(err, ctrl_param)
            SOLUS.checkError(err);
        end
        
        function ReadStatusOptode(obj, optode)
            % SOLUS_Return SOLUS_ReadStatusOptode(SOLUS_H solus, ADDRESS optode)
            err=calllib(obj.LIBALIAS, 'SOLUS_ReadStatusOptode', obj.s, optode);
            obj.log.log(err, optode);
            SOLUS.checkError(err);
        end
        
        function [status, LD_status]=GetStatusOptode(obj, optode)
            % SOLUS_Return SOLUS_GetStatusOptode(SOLUS_H solus, ADDRESS optode, UINT16* status, LDs_status* LD_Status)
            [err, ~, stat, LD_stat]=calllib(obj.LIBALIAS, 'SOLUS_GetStatusOptode',...
                obj.s, optode, 0, zeros(1,obj.N_LD,'uint32'));
            obj.log.log(err, optode, stat);
            SOLUS.checkError(err);
            status=SOLUS_Optode_Status(stat);
            for k=obj.N_LD:-1:1
                LD_status(k)=SOLUS_LD_Status(LD_stat(k));
            end
        end
        
        function SetCalibrationMap(obj, optode, map, max_area)
            if ~isvector(map)
                SOLUS.printError('badType','map must be a vector');
            end
            if length(map)~=1728
                SOLUS.printError('badLength','length of map must be 1728');
            end
            % SOLUS_Return SOLUS_SetCalibrationMap(SOLUS_H solus, ADDRESS optode, CalMap* data, UINT16 MaxArea)
            err=calllib(obj.LIBALIAS, 'SOLUS_SetCalibrationMap', obj.s, optode, map, max_area);
            obj.log.log(err, optode, max_area, map);
            SOLUS.checkError(err);
        end
        
        function ReadCalibrationMap(obj, optode)
            % SOLUS_Return SOLUS_ReadCalibrationMap(SOLUS_H solus, ADDRESS optode)
            err=calllib(obj.LIBALIAS, 'SOLUS_ReadCalibrationMap', obj.s, optode);
            obj.log.log(err, optode);
            SOLUS.checkError(err);
        end
        
        function [map, max_area]=GetCalibrationMap(obj, optode)
            % SOLUS_Return SOLUS_GetCalibrationMap(SOLUS_H solus, ADDRESS optode, CalMap* data, UINT16* MaxArea)
            [err, ~, map, max_area]=calllib(obj.LIBALIAS, 'SOLUS_GetCalibrationMap', obj.s, optode, zeros(1,1728), 0);
            obj.log.log(err, optode);
            SOLUS.checkError(err);
        end

        function ReadMCU_ID(obj, address)
            % SOLUS_Return SOLUS_ReadMCU_ID(SOLUS_H solus, ADDRESS address) 
            err=calllib(obj.LIBALIAS, 'SOLUS_ReadMCU_ID', obj.s, address);
            obj.log.log(err);
            SOLUS.checkError(err);
        end        
        
        function id = GetMCU_ID(obj, address)
            % SOLUS_Return SOLUS_GetMCU_ID(SOLUS_H solus, ADDRESS address, UINT16 *id) 
            [err, ~, id]=calllib(obj.LIBALIAS, 'SOLUS_GetMCU_ID', obj.s, address, 0);
            obj.log.log(err);
            SOLUS.checkError(err);
        end

        function StartSequence(obj)
            % SOLUS_Return SOLUS_StartSequence(SOLUS_H solus, DataType type)
            err=calllib(obj.LIBALIAS, 'SOLUS_StartSequence', obj.s, 1);
            obj.log.log(err);
            SOLUS.checkError(err);
        end
        
        function [nLines, err] = QueryNLinesAvailable(obj)
            % SOLUS_Return SOLUS_QueryNLinesAvailable(SOLUS_H solus, UINT16 *NLines)
            [err, ~, nLines]=calllib(obj.LIBALIAS, 'SOLUS_QueryNLinesAvailable', obj.s, 0);
            obj.log.log(err);
            if nargout<2
                SOLUS.checkError(err);
            end
        end

        function [H, control_status, err] = GetMeasurement(obj,NLines)
            dataPtr = libpointer('FramePtrPtr');
            % SOLUS_Return SOLUS_GetMeasurement(SOLUS_H solus, Data_H* data, UINT16 NLines, Status_array status);
            [err, ~, ~, status_u16a]=calllib(obj.LIBALIAS, 'SOLUS_GetMeasurement', obj.s, dataPtr, NLines, zeros(1,384));
            obj.log.log(err, NLines);
            if nargout<3
                SOLUS.checkError(err);
            end

            dataPtr.setdatatype('FramePtr');
            
            p=libpointer('FramePtr',libstruct('Frame'));
            H(1:NLines,1:8)=p.Value; % preallocation
            K=find(obj.optConnected);
            L=length(K);
            for j=1:NLines
                for k=1:L
                    H(j,K(k))=dataPtr.Value;
                    dataPtr=dataPtr+1;
                end
            end
            control_status = SOLUS_Control_Status(status_u16a(1:NLines));            
        end

        function StopSequence(obj, enable_dump)
            if nargin < 2
                enable_dump=false;
            end
            
            if enable_dump
                en_dmp=1;
            else
                en_dmp=0;
            end
            
            % SOLUS_Return SOLUS_StopSequence(SOLUS_H solus, BOOLEAN enable_dump)
            err=calllib(obj.LIBALIAS, 'SOLUS_StopSequence', obj.s, en_dmp);
            obj.log.log(err);
            SOLUS.checkError(err);
        end
        
        function SetAutocalParams(obj, Autocal_params)
            if ~isa(Autocal_params, 'SOLUS_Autocal_Parameters')
                SOLUS.printError('badType','Autocal_params must be type SOLUS_Autocal_params');
            end
            strAutocal_params=Autocal_params.toStruct();
            if ~strcmp(version('-release'),'2012a')
                % SOLUS_Return SOLUS_SetAutocalParams(SOLUS_H solus, Autocal_params Params)
                err=calllib(obj.LIBALIAS, 'SOLUS_SetAutocalParams', obj.s, strAutocal_params);
            else
                strAutocal_params_ptr=libpointer('Autocal_paramsPtr', strAutocal_params);
                % SOLUS_Return SOLUS_SetAutocalParams_byRef(SOLUS_H solus, Autocal_params Params)
                err=calllib(obj.LIBALIAS, 'SOLUS_SetAutocalParams_byRef', obj.s, strAutocal_params_ptr);
            end
            obj.log.log(err, Autocal_params);
            SOLUS.checkError(err);
        end
        
        function SaveEEPROM(obj, optode)
            % SOLUS_Return SOLUS_SaveEEPROM(SOLUS_H solus, ADDRESS address)
            err=calllib(obj.LIBALIAS, 'SOLUS_SaveEEPROM', obj.s, optode);
            obj.log.log(err);
            SOLUS.checkError(err);
        end
        
        function eeprom=ReadEEPROM(obj, optode)
            % SOLUS_Return SOLUS_ReadEEPROM(SOLUS_H solus, ADDRESS address, UINT8* data)
            [err,~,eeprom]=calllib(obj.LIBALIAS, 'SOLUS_ReadEEPROM', obj.s, optode, zeros(1,4096,'uint8'));
            obj.log.log(err);
            SOLUS.checkError(err);
        end
        
        function CompensateTemperature(obj, temperature)
            % SOLUS_Return SOLUS_CompensateTemperature(SOLUS_H solus, float temperature)
            err=calllib(obj.LIBALIAS, 'SOLUS_CompensateTemperature', obj.s, temperature);
            obj.log.log(err);
            SOLUS.checkError(err);
        end
        
        function TrimCTMU(obj, optode, ctmu_en, ctmu_trim)
            % SOLUS_Return SOLUS_TrimCTMU(SOLUS_H solus, ADDRESS address, BOOLEAN ctmu_en, INT16 ctmu_trim)
            err=calllib(obj.LIBALIAS, 'SOLUS_TrimCTMU', obj.s, optode, ctmu_en, ctmu_trim);
            obj.log.log(err);
            SOLUS.checkError(err);
        end
        
        function ProgramSTUSB4500(obj)
            % SOLUS_Return SOLUS_ProgramSTUSB4500(SOLUS_H solus)
            err=calllib(obj.LIBALIAS, 'SOLUS_ProgramSTUSB4500', obj.s);
            obj.log.log(err);
            SOLUS.checkError(err);
        end
        
        function BootLoaderStart(obj, optode, path)
            % SOLUS_Return SOLUS_BootLoaderStart(SOLUS_H solus, ADDRESS address, char* path)
            err=calllib(obj.LIBALIAS, 'SOLUS_BootLoaderStart', obj.s, optode, path);
            SOLUS.checkError(err);
        end
        
        function progress=BootLoaderAct(obj)
            % SOLUS_Return SOLUS_BootLoaderAct(SOLUS_H solus, float *programming_pct)
            [err,~,progress]=calllib(obj.LIBALIAS, 'SOLUS_BootLoaderAct', obj.s, 0);
            SOLUS.checkError(err);
        end
        
        function BootLoaderStop(obj)
            % SOLUS_Return SOLUS_BootLoaderStop(SOLUS_H solus)
            err=calllib(obj.LIBALIAS, 'SOLUS_BootLoaderStop', obj.s);
            SOLUS.checkError(err);
        end

        function ResetMCU(obj, optode)
            % SOLUS_Return SOLUS_ResetMCU(SOLUS_H solus, ADDRESS address)
            err=calllib(obj.LIBALIAS, 'SOLUS_ResetMCU', obj.s, optode);
            obj.log.log(err, optode);
            SOLUS.checkError(err);
        end

        function ReadAnalogLogs(obj)
            % SOLUS_Return SOLUS_ReadAnalogLogs(SOLUS_H solus)
            err=calllib(obj.LIBALIAS, 'SOLUS_ReadAnalogLogs', obj.s);
            obj.log.log(err);
            SOLUS.checkError(err);
        end
        
        function [idStr, bl_idStr]=ReadIDstrings(obj, optode)
            voidStr=libpointer('cstring', repmat('0',64,1));
            % SOLUS_Return SOLUS_ReadIDstrings(SOLUS_H solus, ADDRESS address, char * id_string, char * id_string_bl)
            [err, ~, idStr, bl_idStr]=calllib(obj.LIBALIAS, 'SOLUS_ReadIDstrings', obj.s, optode, voidStr, voidStr);
            obj.log.log(err);
            SOLUS.checkError(err);
        end
        
        function PowerSupply(obj, optode, config)
            warning('SOLUS.PowerSupply() is a debug function. Type YES if you want to proceed, anything else to quit.')
            answer=input('','s');
            if strcmp(answer, 'YES')
                % SOLUS_Return SOLUS_PowerSupplyON(SOLUS_H solus, ADDRESS address, UINT16 config)
                err=calllib(obj.LIBALIAS, 'SOLUS_PowerSupplyON', obj.s, optode, config);
                obj.log.log(err, optode, config);
                SOLUS.checkError(err);
            end
        end
        
        function delete(obj)
            obj.getOrIncrementInstCount(-1);
            % SOLUS_Return SOLUS_Destr(SOLUS_H SOLUS);
            err=calllib(obj.LIBALIAS, 'SOLUS_Destr', obj.s);
            obj.log.log(err);
            SOLUS.checkError(err);
            clear obj.log
            clear obj.s
        end
        
    end
    
    methods (Static, Access =  {?logger})
        function log_data_formatter(log, varargin)
            va=varargin{1};
            fun_name=log.getCallerName(4);
            thedata='';
            skip=false;
            switch fun_name
                case 'SetLaserFrequency'
                    thedata=num2str(va{2});
                case 'SetSequence'
                    thedata=['L:' num2str(length(va{2}))];
                    if log.level >= logger.LOG_TRACE
                        thedata=[thedata ', M:{'...
                            log.u8toBase64(cell2mat(arrayfun(@(x) ...
                            x.toUint8A(), va{2}, 'UniformOutput', false))) '}'];
                    end
                case 'SetOptodeParams'
                    thedata=['O:' num2str(va{2})];
                    if log.level >= logger.LOG_DEBUG
                        thedata=[thedata ', L:{'...
                            log.u8toBase64(va{3}.toUint8A) '}, G:{' ...
                            log.u8toBase64(va{4}.toUint8A) '}'];
                    end
                case 'LaserON'
                    thedata=['O:' num2str(va{2}) ', L:' num2str(va{3})];
                case 'SetFlags'
                    thedata=['F:' num2str(va{2}.toInt()) ', M:' num2str(va{3}.toInt())];
                case 'SetControlParams'
                    thedata=['P:{' log.u8toBase64(va{2}.toUint8A) '}'];
                case 'SetCalibrationMap'
                    thedata=['O:' num2str(va{2}) ', X:' num2str(va{3})];
                    if log.level >= logger.LOG_DEBUG
                        thedata=[thedata ', M:{' log.u8toBase64(typecast(uint16(va{4}),'uint8')) '}'];
                    end
                case 'StartSequence'
                case 'StopSequence'
                case 'QueryNLinesAvailable'
                    if log.level < logger.LOG_TRACE
                        skip = true;
                    end
                case 'GetMeasurement'
                    if log.level < logger.LOG_DEBUG
                        skip = true;
                    else
                        thedata=['N:' num2str(va{2})];
                    end
                case 'SetAutocalParams'
                    if log.level >= logger.LOG_INFO
                        thedata=[thedata 'P:{' log.u8toBase64(va{2}.toUint8A) '}'];
                    end
                case {'ResetMCU', 'GetOptodeParams', 'ReadDiagOptode', ...
                        'GetDiagOptode', 'ReadStatusOptode', ...
                        'ReadCalibrationMap', 'GetCalibrationMap'}
                    thedata=['O:' num2str(va{2})];
                case 'GetStatusOptode'
                    thedata=['O:' num2str(va{2}) ', S:' num2str(va{3}.toInt())];
                case 'PowerSupply'
                    thedata=['O:' num2str(va{2}), ', C:' num2str(va{2}), ];
                otherwise
                    if log.level < logger.LOG_TRACE
                        skip = true;
                    end
            end
            if ~strcmp(va{1},'OK')
                log.report(['(' fun_name ') ' va{1}]);
            end
            if ~skip
                log.report(['(' fun_name ') ' thedata]);
            end
        end
    end

    methods (Static)
        function yes = isLibLoad()
            yes = libisloaded(SOLUS.LIBALIAS);
        end
        function n = numInstances()
            n = SOLUS.getOrIncrementInstCount();
        end
        
        function mex=loadLib()
            errid = 'SOLUS_SDK_loadlib:';
            headerfname = 'SOLUS_SDK.h';
            dll64fname = 'SOLUS_SDK.dll';

            if ~SOLUS.isLibLoad()
                switch(computer('arch'))
                    %case 'win32'
                    %    loadlibrary(dll32fname, headerfname, 'alias', LIBALIAS);
                    case 'win64'
                        if exist('SOLUS_header.m', 'file')
                            loadlibrary(dll64fname, @SOLUS_header, 'alias', SOLUS.LIBALIAS);
                        else
                            [~,mex]=loadlibrary(dll64fname, headerfname, ...
                                'alias', SOLUS.LIBALIAS, ...
                                'mfilename', 'SOLUS_header.m');
                            SOLUS.unloadLib();
                            SOLUS.adjustProtofile('SOLUS_header.m');
                            SOLUS.loadLib();
                        end
                    otherwise
                        error([errid 'wrongOS'],'Not supported operating system');
                end        
                if ~SOLUS.isLibLoad()
                   error([errid 'loadfailed'],'Unable to load the SOLUS_SDK');
                end
            end
        end
        
        function unloadLib()
           errid = 'SOULS_unloadLib:';
            if SOLUS.isLibLoad()
                unloadlibrary(SOLUS.LIBALIAS);
                if libisloaded(SOLUS.LIBALIAS)
                    error([errid 'unloadfailed'],'Unable to unload the SOLUS_SDK library');
                end
            end 
        end
    end
    
    methods (Static, Access = private)
        function checkError(err)
            if ~strcmp(err,'OK')
                ME = MException(['SOLUS:' err], err);
                throw(ME);
            end
        end
        function printError(type, msg)
            ME = MException(['SOLUS:' type], msg);
            throw(ME);
        end
        function adjustProtofile(filename)
            repl{7}={'structs.Frame.members', 'error', 'uint16'};
            repl{6}={'fcns.name{fcnNum}=''SOLUS_GetMeasurement'';', 'errorPtr', 'uint16Ptr'};
            repl{5}={'fcns.name{fcnNum}=''SOLUS_GetStatusOptode'';', 'voidPtr', 'uint16Ptr'};
            repl{4}={'fcns.name{fcnNum}=''SOLUS_GetStatusControl'';', 'voidPtr', 'uint16Ptr'};
            repl{3}={'fcns.name{fcnNum}=''SOLUS_GetDiagOptode'';', 's_LD_AnalogPtr', 'uint16Ptr'};
            repl{2}={'fcns.name{fcnNum}=''SOLUS_SetSequence'';', 's_Sequence_LinePtr', 'voidPtr'};
            repl{1}={'fcns.name{fcnNum}=''SOLUS_GetSequence'';', 's_Sequence_LinePtr', 'uint8Ptr'};
            fid=fopen(filename);
            str=fread(fid,inf,'*char')';
            fclose(fid);
            movefile(filename, [filename '_original']);
            for k=1:length(repl)
                idx=strfind(str,repl{k}{1});
                idx2=strfind(str(idx:end),repl{k}{2});
                str=[str(1:idx+idx2-2) repl{k}{3} str(idx+idx2-1+length(repl{k}{2}):end)];
            end
            fid=fopen(filename,'w');
            fwrite(fid,str,'char');
            fclose(fid);
        end
        function n_inst = getOrIncrementInstCount(increment)
            persistent N_INSTANCES
            if isempty(N_INSTANCES)
                N_INSTANCES = 0;
            end
            n_inst = N_INSTANCES;
            if nargin > 0
                N_INSTANCES = N_INSTANCES + increment;
            end
        end
    end
end
