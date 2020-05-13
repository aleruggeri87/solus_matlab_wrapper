classdef SOLUS_Control_Status
    % SOLUS_Control_Status 
    %
    %   Author(s):  Alessandro RUGGERI
    %   Revision:   1.0 
    %   Date:       21/11/2019
    %
    %   Copyright 2019  Micro Photon Devices
    %   
    %   Usage:
    %   Cstatus = SOLUS_Control_Status(); initialize and fill all the parameters with 0
    %   Cstatus = SOLUS_Control_Status(int16); initialize and fill with data from the int16. 
    %
    %   Rev 1.0-21/11/2019: first issue
    
    properties(SetAccess = private)
        q_fromPC_is_full=false;
        q_fromPC_data_is_full=false;
        Vpol_error_run=false;
        Ispad_limit=false;
        Pinput_limit=false;
        Vinput_limit=false;
        P5V_error=false;
        Vpol_error_oth=false;
        Error_optode=false;
        LD_I_limit=false;
        stusb_bad_cfg=false;
        usbC_pow=0; % 0: error, 1: contracted 2.5W, 2: >15W, 3: >20W
        interlock_active=false;
    end
    
    methods
        % constructor / inizializator
        function obj = SOLUS_Control_Status(num)
            if nargin ~= 0 && nargin ~= 1
                error('SOLUS_Control_Status:wrongArgs',...
                    'SOLUS_Control_Status must be called with 0 or 1 argument');
            end
            if nargin == 1
                obj=obj.fromInt(num);
            end
        end
        
        % convert class to int
        function int = toInt(obj)
            int=uint16(obj.q_fromPC_is_full+obj.q_fromPC_data_is_full*2+obj.Vpol_error_run*4+obj.Ispad_limit*8+...
                obj.Pinput_limit*16+obj.Vinput_limit*32+obj.P5V_error*64+obj.Vpol_error_oth*128+...
                obj.Error_optode*256+obj.LD_I_limit*512+obj.stusb_bad_cfg*4096+obj.usbC_pow*8192+obj.interlock_active*32768);
        end
        %% convert from int
        function obj = fromInt(obj, num)
            if isa(num,'uint16')
                obj.q_fromPC_is_full=bitget(num,1);
                obj.q_fromPC_data_is_full=bitget(num,2);
                obj.Vpol_error_run=bitget(num,3);
                obj.Ispad_limit=bitget(num,4);
                obj.Pinput_limit=bitget(num,5);
                obj.Vinput_limit=bitget(num,6);
                obj.P5V_error=bitget(num,7);
                obj.Vpol_error_oth=bitget(num,8);
                obj.Error_optode=bitget(num,9);
                obj.LD_I_limit=bitget(num,10);
                obj.stusb_bad_cfg=bitget(num,13);
                obj.usbC_pow=uint16(sum(bitget(num,14:15).*uint16([1 2])));
                obj.interlock_active=bitget(num,16);
            else
                error('SOLUS_Control_Status:wrongArgs',...
                    'Input argument of SOLUS_Control_Status must be a uint16');
            end
        end
    end
end