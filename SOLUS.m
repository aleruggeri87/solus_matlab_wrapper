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
    end
    
    properties (Constant, Access = private)
        LIBALIAS = 'SOLUS_SDK';
        N_ROWS=384;
        N_LD=4;
        N_OPT=8;
    end
    
    methods
        function obj = SOLUS()
            SOLUS.loadLib();
            
            obj.s = libpointer('s_SOLUS_HPtr');
            obj.optConnected=zeros(8,1);

            [err,~,obj.optConnected]=calllib(obj.LIBALIAS, 'SOLUS_Constr', obj.s, obj.optConnected);
            SOLUS.checkError(err);
        end
        
        function SetLaserFrequency(obj, laser_frequency)
            % SOLUS_Return SOLUS_SetLaserFrequency(SOLUS_H solus, UINT32 Frequency);
            err=calllib(obj.LIBALIAS, 'SOLUS_SetLaserFrequency', obj.s, laser_frequency);
            SOLUS.checkError(err);
        end

        function ReadLaserFrequency(obj)
            % SOLUS_Return SOLUS_ReadLaserFrequency(SOLUS_H solus);
            err=calllib(obj.LIBALIAS, 'SOLUS_ReadLaserFrequency', obj.s);
            SOLUS.checkError(err);
        end
        
        function lf_ret = GetLaserFrequency(obj)
            % SOLUS_Return SOLUS_GetLaserFrequency(SOLUS_H solus, UINT32* Frequency);
            [err, ~, lf_ret]=calllib(obj.LIBALIAS, 'SOLUS_GetLaserFrequency', obj.s, 0);
            SOLUS.checkError(err);
        end

        function ReadDiagControl(obj)
            % SOLUS_Return SOLUS_ReadDiagControl(SOLUS_H solus);
            err=calllib(obj.LIBALIAS, 'SOLUS_ReadDiagControl', obj.s);
            SOLUS.checkError(err);
        end
        
        function ctrl_an_acq = GetDiagControl(obj)
            % SOLUS_Return SOLUS_GetDiagControl(SOLUS_H solus, Control_analog_acq* Control_Analog);
            [err,~,ctrl_an_a]=calllib(obj.LIBALIAS, 'SOLUS_GetDiagControl', obj.s, []);
            SOLUS.checkError(err);
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
            SOLUS.checkError(err);
        end

        function seq_str_rd = GetSequence(obj)
            seq_b_rd=zeros(1,obj.N_ROWS*45,'uint8');
            seqPtr_rd = libpointer('voidPtr',seq_b_rd);

            % SOLUS_Return SOLUS_GetSequence(SOLUS_H solus, Sequence* sequence)
            err=calllib(obj.LIBALIAS, 'SOLUS_GetSequence', obj.s, seqPtr_rd);
            SOLUS.checkError(err);
            tic
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
            toc
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

            % SOLUS_Return SOLUS_SetOptodeParams(SOLUS_H solus, ADDRESS optode, LD_parameters LD_parameters, GSIPM_parameters GSIPM_parameters)
            err=calllib(obj.LIBALIAS, 'SOLUS_SetOptodeParams', obj.s, optode_addr, LD_str, GSIPM_str);
            SOLUS.checkError(err);
        end

        function [LD_str,GSIPM_str] = GetOptodeParams(obj, optode_addr)
            % SOLUS_Return SOLUS_GetOptodeParams(SOLUS_H solus, ADDRESS optode, LD_parameters* LD_Parameters, GSIPM_parameters* GSIPM_parameters)
            [err,~,LD_str_ret,GSIPM_str_ret]=calllib(obj.LIBALIAS, 'SOLUS_GetOptodeParams', obj.s, optode_addr, [], []);
            SOLUS.checkError(err);
            
            LD_str=SOLUS_LD_Parameters(LD_str_ret);
            GSIPM_str=SOLUS_GSIPM_Parameters(GSIPM_str_ret);
        end
        
        function ReadStatusControl(obj)
            % SOLUS_Return SOLUS_ReadStatusControl(SOLUS_H solus)
            err=calllib(obj.LIBALIAS, 'SOLUS_ReadStatusControl', obj.s);
            SOLUS.checkError(err);
        end
        
        function status = GetStatusControl(obj)
            % SOLUS_Return SOLUS_GetStatusControl(SOLUS_H solus, UINT16* status)
            [err, ~, stat]=calllib(obj.LIBALIAS, 'SOLUS_GetStatusControl', obj.s, 0);
            SOLUS.checkError(err);
            status = SOLUS_Control_Status(stat);
        end
        
        function ReadDiagOptode(obj, optode)
            % SOLUS_Return SOLUS_ReadDiagOptode(SOLUS_H solus, ADDRESS Optode)
            err=calllib(obj.LIBALIAS, 'SOLUS_ReadDiagOptode', obj.s, optode);
            SOLUS.checkError(err);           
        end
        
        function [LD_analog, Optode_analog]=GetDiagOptode(obj, optode)
            % SOLUS_Return SOLUS_GetDiagOptode(SOLUS_H solus, ADDRESS Optode, LDs_analog* LD_Analog, Optode_analog_acq* Optode_Analog)
            [err, ~, LD_an_arry, Opt_an]=calllib(obj.LIBALIAS, 'SOLUS_GetDiagOptode', obj.s, optode, zeros(1,4*5,'uint16'), []);
            SOLUS.checkError(err);
            for k=4:-1:1
                LD_analog(k)=SOLUS_LD_analog(LD_an_arry((1:5)+(k-1)*5));
            end
            Optode_analog=SOLUS_Optode_analog(Opt_an);
        end
            
        function SetFlags(obj, flags, mask)
            if nargin < 3
                mask = flags;
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
            SOLUS.checkError(err);
        end
        
        function flags = GetFlags(obj)
            % SOLUS_Return SOLUS_GetFlags(SOLUS_H solus, UINT16* flags)
            [err,~,flg] =calllib(obj.LIBALIAS, 'SOLUS_GetFlags', obj.s, 0);
            SOLUS.checkError(err);
            flags = SOLUS_Flags(flg);
        end
        
        function ctrl_param = GetControlParams(obj)
            % SOLUS_Return SOLUS_GetControlParams(SOLUS_H solus, Control_params* Params)
            [err, ~, cp]=calllib(obj.LIBALIAS, 'SOLUS_GetControlParams', obj.s, flags, mask);
            ctrl_param = SOLUS_Control_Parameters(cp);
            SOLUS.checkError(err);
        end
        
        function SOLUS_SetControlParams(obj, ctrl_param)
            if ~isa(ctrl_param, 'SOLUS_Control_Parameters')
                SOLUS.printError('badType','ctrl_param must be type SOLUS_Control_Parameters');
            end
            
            cp=ctrl_param.toStruct();
            % SOLUS_Return SOLUS_SetControlParams(SOLUS_H solus, Control_params Params)
            err=calllib(obj.LIBALIAS, 'SOLUS_SetControlParams', obj.s, cp);
            SOLUS.checkError(err);
        end
        
        function ReadStatusOptode(obj, optode)
            % SOLUS_Return SOLUS_ReadStatusOptode(SOLUS_H solus, ADDRESS optode)
            err=calllib(obj.LIBALIAS, 'SOLUS_ReadStatusOptode', obj.s, optode);
            SOLUS.checkError(err);
        end
        
        function [status, LD_status]=GetStatusOptode(obj, optode)
            % SOLUS_Return SOLUS_GetStatusOptode(SOLUS_H solus, ADDRESS optode, UINT16* status, LDs_status* LD_Status)
            [err, ~, stat, LD_stat]=calllib(obj.LIBALIAS, 'SOLUS_GetStatusOptode',...
                obj.s, optode, 0, zeros(1,obj.N_LD,'uint32'));
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
            SOLUS.checkError(err);
        end
        
        function ReadCalibrationMap(obj, optode)
            % SOLUS_Return SOLUS_ReadCalibrationMap(SOLUS_H solus, ADDRESS optode)
            err=calllib(obj.LIBALIAS, 'SOLUS_ReadCalibrationMap', obj.s, optode);
            SOLUS.checkError(err);
        end
        
        function [map, max_area]=GetCalibrationMap(obj, optode)
            % SOLUS_Return SOLUS_GetCalibrationMap(SOLUS_H solus, ADDRESS optode, CalMap* data, UINT16* MaxArea)
            [err, ~, map, max_area]=calllib(obj.LIBALIAS, 'SOLUS_GetCalibrationMap', obj.s, optode, zeros(1,1728), 0);
            SOLUS.checkError(err);
        end

        function ReadMCU_ID(obj, address)
            % SOLUS_Return SOLUS_ReadMCU_ID(SOLUS_H solus, ADDRESS address) 
            err=calllib(obj.LIBALIAS, 'SOLUS_ReadMCU_ID', obj.s, address);
            SOLUS.checkError(err);
        end        
        
        function id = GetMCU_ID(obj, address)
            % SOLUS_Return SOLUS_GetMCU_ID(SOLUS_H solus, ADDRESS address, UINT16 *id) 
            [err, ~, id]=calllib(obj.LIBALIAS, 'SOLUS_GetMCU_ID', obj.s, address, 0);
            SOLUS.checkError(err);
        end

        function StartSequence(obj)
            % SOLUS_Return SOLUS_StartSequence(SOLUS_H solus, DataType type)
            err=calllib(obj.LIBALIAS, 'SOLUS_StartSequence', obj.s, 1);
            SOLUS.checkError(err);
        end

        function H = GetMeasurement(obj,NLines)
            dataPtr = libpointer('FramePtrPtr');
            
            % SOLUS_Return SOLUS_GetMeasurement(SOLUS_H solus, Data_H* data, UINT16 NLines)
            err=calllib(obj.LIBALIAS, 'SOLUS_GetMeasurement', obj.s, dataPtr, NLines);
            SOLUS.checkError(err);

            dataPtr.setdatatype('FramePtr');

            H(NLines,8)=dataPtr.Value; % preallocation (remember to overwrite/clear this)
            K=find(obj.optConnected);
            for j=1:NLines
                for k=K
                    H(j,k)=dataPtr.Value;
                    dataPtr=dataPtr+1;
                end
            end
            toc
        end

        function StopSequence(obj)
            % SOLUS_Return SOLUS_StopSequence(SOLUS_H solus)
            err=calllib(obj.LIBALIAS, 'SOLUS_StopSequence', obj.s);
            SOLUS.checkError(err);
        end

        function delete(obj)
            % SOLUS_Return SOLUS_Destr(SOLUS_H SOLUS);
            err=calllib(obj.LIBALIAS, 'SOLUS_Destr', obj.s);
            SOLUS.checkError(err);
            clear obj.s
        end
        
    end
    methods (Static)
        function yes = isLibLoad()
            yes = libisloaded(SOLUS.LIBALIAS);
        end
        
        function loadLib()
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
                            loadlibrary(dll64fname, headerfname, ...
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
            repl{3}={'fcns.name{fcnNum}=''SOLUS_GetDiagOptode'';', 's_LD_AnalogPtr', 'uint16Ptr'};
            repl{2}={'fcns.name{fcnNum}=''SOLUS_SetSequence'';', 's_Sequence_LinePtr', 'voidPtr'};
            repl{1}={'fcns.name{fcnNum}=''SOLUS_GetSequence'';', 's_Sequence_LinePtr', 'voidPtr'};
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
    end
end