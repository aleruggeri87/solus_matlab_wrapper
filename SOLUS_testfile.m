%% SOLUS Class testfile
% Demonstrate basic usage of SOLUS & related classes

%%
color8=[0.9 0 0
        0 0.6 0
        0 0 0.9
        1 0.6 0
        0 0.8 1
        0.6 0.6 0.6
        0.8 0 1
        0 0 0];
set(groot,'DefaultAxesColorOrder',color8)
set(groot,'defaultLineLineWidth',1.2)

%% settings
clear all

T_MEAS=10e-3;               % [s] - set to Nan to use value in file
MAX_AREA=1000;              % [spad]
CR_TARGET=0.5e6;%500e3;            % [cps]
T_AUTOCAL=1e-3;            % [s]
SPAD_VOLT=28.25;             % [V]
PAUSE_T=1e-3;                  % [s]
LD_CURRENT_LIMIT=0.3*4;     % [A]
LD_CURRENT_AVERAGE_LEN=10;  % [steps]

flags=SOLUS_Flags();
flags.AUTOCAL=true;
flags.DISABLE_INTERLOCK=true;
flags.FORCE_LASER_OFF=false;
flags.GSIPM_GATE_OFF_AFTER_MEAS=true;
flags.LASER_OFF_AFTER_MEAS=true;
flags.OVERRIDE_MAP=true;
flags.TRIM_METHOD=2;
flags.TURNOFF_UNUSED_LD=false;
flags.ENABLE_SYNCOUT=true;

% load other data from file
path='C:\workMPD\Projects\Accettati\solus\sw\TRS\SOLUS\';
cal_map=SOLUS_HL.calibMap_fromFile([path 'calib5,7_fromM.ini']);%calib3,5_may2021.ini']);
gsipm_par=SOLUS_HL.GSIPM_params_fromFile([path 'GSiPM_par.ini']);
%ld_par=SOLUS_HL.LD_params_fromFile([path 'LDs_par_redLow.ini']);
%[ld_par(:).current_c]=deal(repmat(3, 1,8)); % reduce current;

o=loadMathieuFile();
for k=8:-1:1
    ld_par(k)=SOLUS_LD_Parameters(o.m_optodes(k).m_laser);
end

acParams=SOLUS_Autocal_Parameters(CR_TARGET*T_AUTOCAL, T_AUTOCAL, 9, 1);
controlParams=SOLUS_Control_Parameters(2, SPAD_VOLT*1000, 0, ...
    PAUSE_T/0.125e-3, LD_CURRENT_LIMIT/100e-6, LD_CURRENT_AVERAGE_LEN);

% Class Constructor
HL=SOLUS_HL();
HL.solus.log.open('log.txt');
HL.solus.log.level=logger.LOG_DEBUG;

% set loaded settings
HL.calibMap_set(cal_map,repmat(MAX_AREA,8,1));
HL.OptodeParams_set(ld_par,gsipm_par);
HL.AutocalParams=acParams;
HL.flags=flags;
HL.solus.SetControlParams(controlParams)
HL.solus.GetStatusControl
HL

%%

o=loadMathieuFile();
for k=8:-1:1
    ld_par(k)=SOLUS_LD_Parameters(o.m_optodes(k).m_laser);
end
HL.OptodeParams_set(ld_par,gsipm_par);

try
    HL.solus.StopSequence();
end

NSTEP_SEQ=8; % reduce sequence length
for therep=1:5
for ooo=1:8;
OFS=(ooo-1)*8;
seq=SOLUS_HL.sequence_fromFile([path 'SOLs40x.ini']);
%T_MEAS=nan;
if ~isnan(T_MEAS) % override measurement time
    [seq(:).meas_time]=deal(T_MEAS);
end
%[seq(:).laser_num]=deal(41); % change laser
%[seq(:).laser_num]=deal(SOLUS_SequenceLine.LASER_OFF);
seq=seq(1+OFS:NSTEP_SEQ+OFS);


% for k=1:NSTEP_SEQ % load intensity from trimming
%     seq(k).attenuation=AP(k,:);
% end
% seq(9).laser_num=255;
HL.sequence=seq;

% override laser/GSIPM settings
% HL.sequence(1).gate_delay_c(3)=5;

[HL.gsipm_params(1:8).stop]=deal(21);%20);
[HL.gsipm_params(1:8).gate_close]=deal(10);%8);
[HL.gsipm_params(1:8).gate_open]=deal(0);%1);
HL.gsipm_params(2).stop=7;
HL.gsipm_params(2).gate_close=6;
HL.gsipm_params(2).gate_open=23;

%[HL.sequence(1:NSTEP_SEQ).laser_num]=deal(61);


for j=1:10
fprintf('%03d - ',int32(j));
txx=tic;
[M,ctrStat]=HL.getMeas(NSTEP_SEQ,true,true);
fprintf('\b- %.3f\n',toc(txx));
%pause(rand()*100e-6);

% plot gates
figure(1)
O=find(HL.optodeID~=0);
% for k=1:8
%     subplot(2,4,k)
%     semilogy(cat(1,M(:,k).histogram_data)')
%     xlim([0 120])
%     ylim([1 1e4])
% end
i=1;
for k=[1 4 6]
    %subplot(2,3,i)
    subplot(3,10,j+10*(i-1))
    semilogy(flipud(cat(1,M(:,k).histogram_data)'))
    xlim([0 120])
    ylim([1 1e4])
%     subplot(2,3,i+3)
%     plot(sum(cat(1,M(:,k).histogram_data),2));
    if j==1
        ylabel(['Optode #' num2str(k)])
    end
    if i==1
        StatOpt=cat(1,M(:,ooo).Status_optode);
        StatOpt_SOL=arrayfun(@SOLUS_Optode_Status,uint16(StatOpt));
        title(strrep(char(cat(1,StatOpt_SOL.LD_pll_lock_error)'+'W'),'W','-'))
    end
    i=i+1;
end
xlabel(['rep #' num2str(j)])
drawnow;

% plot telemetry
figure(2)
subplot(2,2,1)
plot(reshape(cat(1,M(:,:).LD_current),[],8)/100)
ylabel('Laser current (mA)')
subplot(2,2,2)
semilogy(reshape(cat(1,M(:,:).Area_ON),[],8))
ylabel('SPAD ON')
subplot(2,2,3)
plot(reshape(cat(1,M(:,:).GSIPM_temperature),[],8))
ylabel('Temperature (°C)')
subplot(2,2,4)
plot(reshape(cat(1,M(:,:).intensity_data),[],8))
ylabel('Counts in integration window')
subplot(2,2,3)
legend()
drawnow;
%pause(3)
end

figure(1)
suptitle(['Lasers on Optode #' num2str(ooo)])
hlgd=legend('LasPos#1','LasPos#2','LasPos#3','LasPos#4',...
    'LasPos#5','LasPos#6','LasPos#7','LasPos#8',...
    'location','bestoutside');
drawnow;
legend('location','none')
hlgd.Position(1)=0.92;
save_pdf(['out' num2str(therep) '/Lop#' num2str(ooo) '.pdf'], 1, 3)
AP=reshape([M.Area_ON],[],8);
end
end