clc; clear; close all

% Read in data
data_cell = load('2025-04-07 13-08-18.bin-182870.mat','VIBE_label');
imu0_data_nopl = load("2025-04-07 13-08-18.bin-182870.mat",'VIBE_0');
imu1_data_nopl = load('2025-04-07 13-08-18.bin-182870.mat','VIBE_1');
imu2_data_nopl = load('2025-04-07 13-08-18.bin-182870.mat','VIBE_2');
imu0_data_pl = load('log_13_2025-4-8-15-03-06.bin-1630594.mat','VIBE_0');
imu1_data_pl = load('log_13_2025-4-8-15-03-06.bin-1630594.mat','VIBE_1');
imu2_data_pl = load('log_13_2025-4-8-15-03-06.bin-1630594.mat','VIBE_2');
post_vibe_changes = load('Mission_Leg_Log.mat','VIBE_0');


% IMU Data Breakup
[time0_nopl,Xvibe0_nopl,Yvibe0_nopl,Zvibe0_nopl,clip_nopl] = imu_data_breakup(imu0_data_nopl.VIBE_0);
[time0_pl,Xvibe0_pl,Yvibe0_pl,Zvibe0_pl,clip_pl] = imu_data_breakup(imu0_data_pl.VIBE_0);
[time0_chngs,Xvibe0_chngs,Yvibe0_chngs,Zvibe0_chngs,clip_chngs] = imu_data_breakup(post_vibe_changes.VIBE_0);

figure();
plot(time0_pl,Zvibe0_pl,'LineWidth',2)
hold on
plot(time0_chngs,Zvibe0_chngs,'LineWidth',2)
xlim([100 200])
xlabel('Time [s]','fontweight','bold','fontsize',12)
ylabel('Vibrational Accelerations [m/s^2]','fontweight','bold','fontsize',12)
grid on; grid minor
legend('Pre-Mounting','Post Mounting')
title('Vibrational Readings','fontweight','bold','fontsize',16)


function [time,Xvibe,Yvibe,Zvibe,clip] = imu_data_breakup(data)

time = data(:,2);
time = (time - time(1)) .* 1e-6;

Xvibe = data(:,4);
Yvibe = data(:,5);
Zvibe = data(:,6);
clip = data(:,7);

end