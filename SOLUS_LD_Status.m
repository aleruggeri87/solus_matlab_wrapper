classdef SOLUS_LD_Status < objArr
    % SOLUS_LD_Status 
    %
    %   Author(s):  Alessandro RUGGERI
    %   Revision:   1.0 
    %   Date:       25/11/2019
    %
    %   Copyright 2019  Micro Photon Devices
    %   
    %   Usage:
    %   LDstatus = SOLUS_LD_Status(); initialize and fill all the parameters with 0
    %   LDstatus = SOLUS_LD_Status(int16); initialize and fill with data from the int32. 
    %
    %   Rev 1.0-25/11/2019: first issue
    
    properties(SetAccess = private)
        ERR_VDD5=false;     % 5V supply voltage error
		ERR_VBG=false;		% Bandgap reference error
		ERR_STUP=false;     % Error during startup procedure
		ERR_ID=false;		% Wrong ID (serial comm)
		ERR_IDRED=false;	% ID redundancy error (RAM)
		ERR_OP=false;		% Wrong opcode (serial comm)
		ERR_ADR=false;		% Wrong address (serial comm)
		ERR_CRC=false;		% CRC checksum error (RAM)
		ERR_LCKL=false;     % Error PLL low not locked
		ERR_LCKH=false;     % Error PLL high not locked
		ERR_OVC=false;		% Over current error
		ERR_OVT=false;		% Over temperature error
		ERR_PULSE=false;	% Pulse width error
		ERR_CLKI=false;     % Internal 10M clock error
		ERR_FFBIH=false;	% Internal PLL timing error hi
		ERR_FFBIL=false;	% Internal PLL timing error low
		ERR_CI=false;		% Output current error
		ERR_CHANN=false;	% No channel selected
    end
    
    methods
        % constructor / inizializator
        function obj = SOLUS_LD_Status(num)
            if nargin ~= 0 && nargin ~= 1
                error('SOLUS_LD_Status:wrongArgs',...
                    'SOLUS_LD_Status must be called with 0 or 1 argument');
            end
            if nargin == 1
                obj=obj.fromInt(num);
            end
        end
        
        % convert class to int
        function int = toInt(obj)
            int=obj.ERR_VDD5+obj.ERR_VBG*2+obj.ERR_STUP*4+obj.ERR_ID*8+...
                obj.ERR_IDRED*16+obj.ERR_OP*32+obj.ERR_ADR*64+obj.ERR_CRC*128+...
                obj.ERR_LCKL*256+obj.ERR_LCKH*512+obj.ERR_OVC*1024+...
                obj.ERR_OVT*2048+obj.ERR_PULSE*4096+obj.ERR_CLKI*8192+...
                obj.ERR_FFBIH*2^14+obj.ERR_FFBIL*2^15+obj.ERR_CI*2^16+obj.ERR_CHANN*2^17;
        end
        %% convert from int
        function obj = fromInt(obj, num)
            if isa(num,'uint32')
                obj.ERR_VDD5=bitget(num,1);
                obj.ERR_VBG=bitget(num,2);
                obj.ERR_STUP=bitget(num,3);
                obj.ERR_ID=bitget(num,4);
                obj.ERR_IDRED=bitget(num,5);
                obj.ERR_OP=bitget(num,6);
                obj.ERR_ADR=bitget(num,7);
                obj.ERR_CRC=bitget(num,8);
                obj.ERR_LCKL=bitget(num,9);
                obj.ERR_LCKH=bitget(num,10);
                obj.ERR_OVC=bitget(num,11);
                obj.ERR_OVT=bitget(num,12);
                obj.ERR_PULSE=bitget(num,13);
                obj.ERR_CLKI=bitget(num,14);
                obj.ERR_FFBIH=bitget(num,15);
                obj.ERR_FFBIL=bitget(num,16);
                obj.ERR_CI=bitget(num,17);
                obj.ERR_CHANN=bitget(num,18);
            else
                error('SOLUS_LD_Status:wrongArgs',...
                    'Input argument of SOLUS_LD_Status must be a uint32');
            end
        end
    end
end