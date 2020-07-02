%% SOLUS Class testfile
% Demonstrate basic usage of SOLUS & related classes

%% settings
clear all

T_MEAS=10e-3;               % [s] - set to Nan to use value in file
MAX_AREA=900;               % [spad]
CR_TARGET=500e3;            % [cps]
T_AUTOCAL=10e-3;            % [s]
SPAD_VOLT=28.5;             % [V]
PAUSE_T=0;                  % [s]
LD_CURRENT_LIMIT=0.3*4;     % [A]
LD_CURRENT_AVERAGE_LEN=10;  % [steps]

flags=SOLUS_Flags();
flags.AUTOCAL=true;
flags.DISABLE_INTERLOCK=true;
flags.FORCE_LASER_OFF=false;
flags.GSIPM_GATE_OFF_AFTER_MEAS=true;
flags.LASER_OFF_AFTER_MEAS=true;
flags.OVERRIDE_MAP=true;
flags.TRIM_METHOD=1;
flags.TURNOFF_UNUSED_LD=true;
flags.ENABLE_SYNCOUT=true;

% load other data from file
path='C:\workMPD\Projects\Accettati\solus\sw\TRS\SOLUS\';
cal_map=SOLUS_HL.calibMap_fromFile([path 'calib3,5.ini']);
gsipm_par=SOLUS_HL.GSIPM_params_fromFile([path 'GSiPM_par.ini']);
ld_par=SOLUS_HL.LD_params_fromFile([path 'LDs_par_redLow.ini']);
[ld_par(:).current_c]=deal(repmat(3, 1,8)); % reduce current;
acParams=SOLUS_Autocal_Parameters(CR_TARGET*T_AUTOCAL, T_AUTOCAL, 9, 1);
controlParams=SOLUS_Control_Parameters(2, SPAD_VOLT*1000, 0, ...
    PAUSE_T/0.125e-3, LD_CURRENT_LIMIT/100e-6, LD_CURRENT_AVERAGE_LEN);

% Class Constructor
HL=SOLUS_HL();

% set loaded settings
HL.calibMap_set(cal_map,repmat(MAX_AREA,8,1));
HL.OptodeParams_set(ld_par,gsipm_par);
HL.AutocalParams=acParams;
HL.flags=flags;
HL.solus.SetControlParams(controlParams)

%%
NSTEP_SEQ=100; % reduce sequence length

seq=SOLUS_HL.sequence_fromFile([path 'SOLs40x.ini']);
if ~isnan(T_MEAS) % override measurement time
    [seq(:).meas_time]=deal(T_MEAS);
end
%[seq(:).laser_num]=deal(41); % change laser
%[seq(:).laser_num]=deal(SOLUS_SequenceLine.LASER_OFF);
seq=seq(1:NSTEP_SEQ);
HL.sequence=seq;

% override laser/GSIPM settings
% HL.sequence(1).gate_delay_c(3)=5;
% HL.sequence(1).laser_num=16;
[HL.gsipm_params(1:8).stop]=deal(21);
[HL.gsipm_params(1:8).gate_close]=deal(10);
[HL.gsipm_params(1:8).gate_open]=deal(1);
% HL.gsipm_params(3).stop=21;
% HL.gsipm_params(3).gate_close=10;
% HL.gsipm_params(3).gate_open=1;

[M,ctrStat]=HL.getMeas(NSTEP_SEQ,true);

% plot gates
figure(1)
O=find(HL.optodeID~=0);
for k=1:8
    subplot(2,4,k)
    semilogy(cat(1,M(:,k).histogram_data)')
    xlim([0 120])
    ylim([1 1e4])
end

% plot telemetry
figure(2)
subplot(2,2,1)
plot(reshape(cat(1,M(:,:).LD_current),[],8)/100)
ylabel('Laser current (mA)')
subplot(2,2,2)
plot(reshape(cat(1,M(:,:).Area_ON),[],8))
ylabel('SPAD ON')
subplot(2,2,3)
plot(reshape(cat(1,M(:,:).GSIPM_temperature),[],8))
ylabel('Temperature (°C)')
subplot(2,2,4)
plot(reshape(cat(1,M(:,:).intensity_data),[],8))
ylabel('Counts in integration window')
