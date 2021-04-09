classdef SOLUS_Optode_Status < objArr
    % SOLUS_Optode_Status 
    %
    %   Author(s):  Alessandro RUGGERI
    %   Revision:   1.1 
    %   Date:       09/04/2021
    %
    %   Copyright 2019-2021  Micro Photon Devices
    %   
    %   Usage:
    %   Ostatus = SOLUS_Optode_Status(); initialize and fill all the parameters with 0
    %   Ostatus = SOLUS_Optode_Status(int16); initialize and fill with data from the int16. 
    %
    %   Rev 1.0-25/11/2019: first issue
    %   Rev 1.1-09/04/2021: update flags:
    %                                    remove measurement_in_progress,
    %                                    add    measurement_ready_to_program
    
    properties(SetAccess = private)
        measurement_ready_to_start=false;
        measurement_ready_to_read=false;
        measurement_ready_to_program=false;
        gspim_core_current_range=0;
        LD_conf_bad=false;
        cmd_queue_full=false;
        gsipm_passthrough_err=false;
        i2c_error=false;
        LD_pll_lock_error=false;
        LD_overcurrent=false;
        LD_overtemp=false;
        LD_others=false;
        pic_temperature_range=0;
        interlock=false;
    end
    
    methods
        % constructor / inizializator
        function obj = SOLUS_Optode_Status(num)
            if nargin ~= 0 && nargin ~= 1
                error('SOLUS_Optode_Status:wrongArgs',...
                    'SOLUS_Optode_Status must be called with 0 or 1 argument');
            end
            if nargin == 1
                obj=obj.fromInt(num);
            end
        end
        
        % convert class to int
        function int = toInt(obj)
            int=obj.measurement_ready_to_start+obj.measurement_ready_to_read*2+...
                obj.measurement_ready_to_program*4+obj.gspim_core_current_range*8+...
                obj.LD_conf_bad*32+obj.cmd_queue_full*64+obj.gsipm_passthrough_err*128+...
                obj.i2c_error*256+obj.LD_pll_lock_error*512+obj.LD_overcurrent*1024+...
                obj.LD_overtemp*2048+obj.LD_others*4096+obj.pic_temperature_range*8192+...
                obj.interlock*32768;
        end
        % convert from int
        function obj = fromInt(obj, num)
            if isa(num,'uint16')
                obj.measurement_ready_to_start=bitget(num,1);
                obj.measurement_ready_to_read=bitget(num,2);
                obj.measurement_ready_to_program=bitget(num,3);
                obj.gspim_core_current_range=uint16(sum(bitget(num,4:5).*uint16([1 2])));
                obj.LD_conf_bad=bitget(num,6);
                obj.cmd_queue_full=bitget(num,7);
                obj.gsipm_passthrough_err=bitget(num,8);
                obj.i2c_error=bitget(num,9);
                obj.LD_pll_lock_error=bitget(num,10);
                obj.LD_overcurrent=bitget(num,11);
                obj.LD_overtemp=bitget(num,12);
                obj.LD_others=bitget(num,13);
                obj.pic_temperature_range=uint16(sum(bitget(num,14:15).*uint16([1 2])));
                obj.interlock=bitget(num,16);
            else
                error('SOLUS_Optode_Status:wrongArgs',...
                    'Input argument of SOLUS_Optode_Status must be a uint16');
            end
        end
    end
end