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

        FLAG_FORCE_LASER_OFF = 1;
        FLAG_AUTOCAL = 2;
        FLAG_OVERRIDE_MAP = 4;
        FLAG_GSIPM_GATE_OFF_AFTER_MEAS = 8;
        FLAG_LASER_OFF_AFTER_MEAS = 16;
        FLAG_TURNOFF_UNUSED_LD = 32;
        FLAG_TRIM_METHOD_BITL = 64;
        FLAG_TRIM_METHOD_BITh = 128;
        FLAG_DISABLE_INTERLOCK = 256;
    end
    
    properties (Constant, Access = private)
        LIBALIAS = 'SOLUS_SDK';
        N_ROWS=384;
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
        
        function ctrl_an_acq_ret = GetDiagControl(obj)
            % SOLUS_Return SOLUS_GetDiagControl(SOLUS_H solus, Control_analog_acq* Control_Analog);
            [err,~,ctrl_an_acq_ret]=calllib(obj.LIBALIAS, 'SOLUS_GetDiagControl', obj.s, []);
            SOLUS.checkError(err);
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
            
        function SetFlags(obj, flags, mask)
            if nargin < 3
                mask = flags;
            end
            
            % SOLUS_Return SOLUS_SetFlags(SOLUS_H solus, UINT16 flags, UINT16 mask)
            err=calllib(obj.LIBALIAS, 'SOLUS_SetFlags', obj.s, flags, mask);
            SOLUS.checkError(err);
        end
        
        function ctrl_param = GetControlParams(obj)
            % SOLUS_Return SOLUS_GetControlParams(SOLUS_H solus, Control_params* Params)
            [err, ~, cp]=calllib(obj.LIBALIAS, 'GetControlParams', obj.s, flags, mask);
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

        function ReadMCU_ID(obj, address)
            % SOLUS_Return SOLUS_ReadMCU_ID(SOLUS_H solus, ADDRESS address) 
            err=calllib(obj.LIBALIAS, 'SOLUS_ReadMCU_ID', obj.s, address);
            SOLUS.checkError(err);
        end        
        
        function id = GetMCU_ID(obj, address)
            % SOLUS_Return SOLUS_GetMCU_ID(SOLUS_H solus, ADDRESS address, UINT16 *id) 
            [err, ~, id ]=calllib(obj.LIBALIAS, 'SOLUS_GetMCU_ID', obj.s, address, 0);
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
                            [notfound, warnings] = loadlibrary(dll64fname, @SOLUS_header, 'alias', SOLUS.LIBALIAS);
                        else
                            [notfound, warnings] = loadlibrary(dll64fname, headerfname, ...
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