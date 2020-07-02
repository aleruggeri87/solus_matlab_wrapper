%% SOLUS BOOTLOADER UTILITIES EXAMPLE SCRIPT
% Basic scripts for reprogramming the probe & related utilities
%
% NOTE: EXECUTE SINGLE CELLS, DO NOT RUN THE WHOLE SCRIPT AT ONCE


%% Display fw versions
% Displays application and bootloader firmware versions on each MCU of the Probe
HL=SOLUS_HL();
fprintf('\nList of firmwares on SOLUS probe:\n');
[fw_app{9},fw_bl{9}]=HL.solus.ReadIDstrings(SOLUS.CONTROL);
fprintf('Control  : %s; %s\n', fw_app{9}, fw_bl{9});
O=find(HL.optodeID~=0);
for k=O
    [fw_app{k},fw_bl{k}]=HL.solus.ReadIDstrings(k-1);
    fprintf('Optode #%d: %s; %s\n', int16(k), fw_app{k}, fw_bl{k});
end
fprintf('\n');
clear HL

%% Program firmware on Control Board
% Make sure there are no SOLUS or SOLUS_HL instances active.
% Set control_hex variable to point the right file.
% Reboot the probe before launching this script.
control_hex='C:\workMPD\Projects\Accettati\solus\sw\controlFW.X\dist\snap\production\controlFW.X.production.hex';

SOLUS_HL.bootloader(control_hex,SOLUS.CONTROL);

%% Program firmware on Optode Boards
% Make sure there are no SOLUS or SOLUS_HL instances active.
% Set control_hex variable to point the right file; Set opt variable to the
% number of the optodes to be reprogrammed (1:8 will reprogram all of them).
% Reboot the probe before launching this script.
optode_hex='C:\workMPD\Projects\Accettati\solus\sw\optodeFW.X\dist\icd3\production\optodeFW.X.production.hex';
opt=1:8; % list of optodes to be programmed

SOLUS_HL.bootloader(optode_hex,opt-1);

%% Compensate Optode temperature
% After reprogramming the optode firmware it is mandatory to find the new
% compensation value for temperature sensors. Leave the probe OFF for a
% while, in order to allow the temperature to reach a stable value, i.e. approx 
% the room temperature. Set a proper START_TEMPERATURE value and launch
% this script.
START_TEMPERATURE=25; % [°C]

HL=SOLUS_HL();
HL.solus.CompensateTemperature(START_TEMPERATURE);
for k=0:7
    HL.solus.SaveEEPROM(k)
    pause(0.5)
end
clear HL
