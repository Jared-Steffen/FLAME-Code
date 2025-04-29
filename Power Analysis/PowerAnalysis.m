clc; clear; close all
%% Code Assumptions
% 1. Constant speed during all mission segments
% 2. Motor spec sheet accounts for battery, motor, and propeller efficencies
% 3. Depth of discharge is 85% for our LiPo battery
% 4. Constant T/W ratio for each segment
% 5. Each target location is 100 meters away from home base
% 6. No vertical adjustments necessary during cruise legs


set(0,'defaultLineLineWidth',2.5) % sets all line widths of plotted lines
set(0,'DefaultaxesLineWidth', 1.5) % sets line widths of axes
set(0,'DefaultaxesFontSize', 16)
set(0,'DefaultTextFontSize', 16)
set(0,'DefaultaxesFontName', 'Times new Roman')
set(0,'DefaultlegendFontName', 'Times new Roman')
set(0,'defaultAxesXGrid','on')
set(0,'defaultAxesYGrid','on')

%% Model Risks
% 1. We do not know the conditions under which the motor was tested, such as altitude

%% Motor Specs -- Pulled From Datasheet
% MAD 5015 IPE 380KV w/ 18*6.1 Propellers and 6S LiPo
Motor_Thrust = [620,806,1022,1272,1570,1853,2139,2486,2795,3106,3481,3874,4273,4674,5129].*0.85;
Motor_Throttle = [30:5:100];
Motor_Current = [2.11,3.14,4.30,5.77,7.78,9.90,11.94,14.66,17.39,19.84,24.36,28.35,31.72,37.67,44.45].*1000;
Motor_Voltage = 24;


%% Thrust Test Data Manipulation
data = readmatrix('StepsTest_2025-02-28_160149.csv');

% Split Up Tests
data(:,2) = (data(:,2)-1000)./10;
test_set1 = data(1:21,:);
test_set2 = flip(data(22:42,:));
test_set3 = data(43:63,:);
test_set4 = flip(data(64:84,:));

throttle = test_set1(:,2)';
thrust = [test_set1(:,10),test_set2(:,10),test_set3(:,10),test_set4(:,10)] .* -1;
voltage = [test_set1(:,11),test_set2(:,11),test_set3(:,11),test_set4(:,11)];
current = [test_set1(:,12),test_set2(:,12),test_set3(:,12),test_set4(:,12)];
avg_thrust = mean(thrust,2)' .* 1000; 
avg_voltage = mean(voltage,2)';
avg_current = mean(current,2)' .* 1000;

avg_power = avg_voltage .* (avg_current./1000);

for i = 1:length(avg_power)
    if avg_power(i) < 0
        avg_power(i) = 0;
    end
end

% Polyfit Thrust Values
Thrust_Fit = polyfit(Motor_Throttle,Motor_Thrust,1);
Thrust_Fit_Values = polyval(Thrust_Fit,min(Motor_Throttle):1:100);
Thrust_Fit_Test = polyfit(throttle(8:end),avg_thrust(8:end),1);
Thrust_Fit_Values_Test = polyval(Thrust_Fit_Test,min(throttle(8:end)):1:90);

% Polyfit Current Values
Current_Fit = polyfit(Motor_Throttle,Motor_Current,2);
Current_Fit_Values = polyval(Current_Fit,min(Motor_Throttle):1:100);
Current_Fit_Test = polyfit(throttle(8:end),avg_current(8:end),2);
Current_Fit_Values_Test = polyval(Current_Fit_Test,min(throttle(8:end)):1:90);

err_thrust = 0.005 * Thrust_Fit_Values_Test + 5;
err_current = 0.01 * Current_Fit_Values_Test/1000 + 0.1;

% Hex color for shaded area
hexColor = '#D95319';  % Customize as needed
rgbColor = hex2rgb(hexColor);

% figure();
% subplot(2,1,1)
% plot(Motor_Throttle,Motor_Thrust,'.','MarkerSize',25,'MarkerFaceColor','#0072BD','MarkerEdgeColor','#0072BD');
% hold on
% fill([linspace(30,90,length(Thrust_Fit_Values_Test)), fliplr(linspace(30,90,length(Thrust_Fit_Values_Test)))], [Thrust_Fit_Values_Test+err_thrust, fliplr(Thrust_Fit_Values_Test-err_thrust)], ...
%      rgbColor, 'EdgeColor', rgbColor, 'LineWidth', 1.5,'EdgeAlpha',0.4, 'FaceAlpha', 0.4);
% plot(30:1:100,Thrust_Fit_Values,'Color','#0072BD','LineWidth',2);
% plot(throttle(8:end),avg_thrust(8:end),'.','MarkerSize',25,'MarkerFaceColor','#D95319','MarkerEdgeColor','#D95319')
% plot(linspace(30,90,length(Thrust_Fit_Values_Test)),Thrust_Fit_Values_Test,'Color','#D95319','LineWidth',2)
% xlabel('Throttle [%]')
% ylabel('Thrust [g]')
% grid on; grid minor
% title('Thrust Best Fit')
% legend('Datasheet Data','','Best Fit Datasheet','Thrust Test Data','Best Fit Thrust Test','Location','northwest')
% fontsize(16,"points")
% subplot(2,1,2)
% plot(Motor_Throttle,Motor_Current/1000,'.','MarkerSize',25,'MarkerFaceColor','#0072BD','MarkerEdgeColor','#0072BD')
% hold on
% plot(30:1:100,Current_Fit_Values/1000,'Color','#0072BD','LineWidth',2)
% fill([linspace(30,90,length(Current_Fit_Values_Test)), fliplr(linspace(30,90,length(Current_Fit_Values_Test)))], [(Current_Fit_Values_Test/1000)+err_current, fliplr((Current_Fit_Values_Test/1000)-err_current)], ...
%      rgbColor, 'EdgeColor', rgbColor, 'LineWidth', 1.5,'EdgeAlpha',0.4, 'FaceAlpha', 0.4);
% plot(throttle(8:end),avg_current(8:end)/1000,'.','MarkerSize',25,'MarkerFaceColor','#D95319','MarkerEdgeColor','#D95319')
% plot(linspace(30,90,length(Current_Fit_Values_Test)),Current_Fit_Values_Test/1000,'Color','#D95319','LineWidth',2)
% xlabel('Throttle [%]')
% ylabel('Current [A]')
% grid on; grid minor
% title('Current Best Fit')
% ylim([0 60])
% fontsize(16,"points")

% ax = gca;
% exportgraphics(ax,'EThrust Fit.png','Resolution',600)

%% Mission Segment Times [s]
Num_trips = 1;
TO_t = 10*Num_trips; %10
Cruise_1_t = 20*Num_trips; %50

HITL_hover_t = 5*Num_trips; %10
HITL_horz_adj_t = 25*Num_trips; %20
HITL_descend_t = 10*Num_trips; %10
HITL_payload_hover_t = 25*Num_trips; %20

Ascend_t = 5*Num_trips; %5
Cruise_2_t = 20*Num_trips; %45
Land_t = 30*Num_trips; %10

%% Motor Power Analysis per Mission Segment
% Take-off
TO_TW = 1.2;
TO_Weight = 10.75; %[kg]
Battery_Use_TO = MSN_Seg_Power_Analysis(Motor_Current,Motor_Thrust,Motor_Throttle,TO_TW,TO_Weight,TO_t); %[mAh]

% Horizontal Flight 1: With Payload
Cruise_TW = 1.004;
Cruise_1_Weight = 10.75; %[kg]
Battery_Use_Cruise_1 = MSN_Seg_Power_Analysis(Motor_Current,Motor_Thrust,Motor_Throttle,Cruise_TW,Cruise_1_Weight,Cruise_1_t); %[mAh]

% Human-In-The-Loop - Most Uncertainty Lies Here
HITL_hover_TW = 1;
HITL_horz_adj_TW = 1.1;
HITL_descend_TW = 0.8;

HITL_Weight = 10.75; %[kg]

Battery_Use_HITL_hover = MSN_Seg_Power_Analysis(Motor_Current,Motor_Thrust,Motor_Throttle,HITL_hover_TW,HITL_Weight,HITL_hover_t); %[mAh]
Battery_Use_HITL_horz_adj = MSN_Seg_Power_Analysis(Motor_Current,Motor_Thrust,Motor_Throttle,HITL_horz_adj_TW,HITL_Weight,HITL_horz_adj_t); %[mAh]
Battery_Use_HITL_descend = MSN_Seg_Power_Analysis(Motor_Current,Motor_Thrust,Motor_Throttle,HITL_descend_TW,HITL_Weight,HITL_descend_t); %[mAh]
Battery_Use_HITL_payload_hover = MSN_Seg_Power_Analysis(Motor_Current,Motor_Thrust,Motor_Throttle,HITL_hover_TW,HITL_Weight,HITL_payload_hover_t); %[mAh]

% Ascend Post Deployment
Ascend_TW = 1.2;
Ascend_Weight = 8.25;
Battery_Use_Ascend = MSN_Seg_Power_Analysis(Motor_Current,Motor_Thrust,Motor_Throttle,Ascend_TW,Ascend_Weight,Ascend_t); %[mAh]

% Horizontal Flight 2: Without Payload
Cruise_2_Weight = 8.25; %[kg]
Battery_Use_Cruise_2 = MSN_Seg_Power_Analysis(Motor_Current,Motor_Thrust,Motor_Throttle,Cruise_TW,Cruise_2_Weight,Cruise_2_t); %[mAh]

% Landing
Land_TW = 0.8;
Land_Weight = 8.25; %[kg]
Battery_Use_Land = MSN_Seg_Power_Analysis(Motor_Current,Motor_Thrust,Motor_Throttle,Land_TW,Land_Weight,Land_t); %[mAh]

% Total Motor Battery Use
Motors_Battery_Use = Battery_Use_TO + Battery_Use_Cruise_1 + Battery_Use_HITL_hover + Battery_Use_HITL_horz_adj + Battery_Use_HITL_descend + Battery_Use_HITL_payload_hover + Battery_Use_Ascend + Battery_Use_Cruise_2 + Battery_Use_Land;
% Motors_Battery_Use_Vec = [Battery_Use_TO;Battery_Use_Cruise_1;Battery_Use_HITL_hover;Battery_Use_HITL_horz_adj;Battery_Use_HITL_descend;Battery_Use_HITL_payload_hover;Battery_Use_Ascend;Battery_Use_Cruise_2;Battery_Use_Land];
% Motors_Energy_Use = (Motors_Battery_Use_Vec ./ 1000) .* Motor_Voltage;

% Total Motor Power Use
% Motors_Power_Use = (Motors_Battery_Use/1000) * Motor_Voltage; %[Wh]

%% Motor Power Analysis per Mission Segment (Thrust Test Data)
% Take-off
Battery_Use_TO_2 = MSN_Seg_Power_Analysis(avg_current,avg_thrust,throttle,TO_TW,TO_Weight,TO_t); %[mAh]

% Horizontal Flight 1: With Payload
Battery_Use_Cruise_1_2 = MSN_Seg_Power_Analysis(avg_current,avg_thrust,throttle,Cruise_TW,Cruise_1_Weight,Cruise_1_t); %[mAh]

% Human-In-The-Loop - Most Uncertainty Lies Here
Battery_Use_HITL_hover_2 = MSN_Seg_Power_Analysis(avg_current,avg_thrust,throttle,HITL_hover_TW,HITL_Weight,HITL_hover_t); %[mAh]
Battery_Use_HITL_horz_adj_2 = MSN_Seg_Power_Analysis(avg_current,avg_thrust,throttle,HITL_horz_adj_TW,HITL_Weight,HITL_horz_adj_t); %[mAh]
Battery_Use_HITL_descend_2 = MSN_Seg_Power_Analysis(avg_current,avg_thrust,throttle,HITL_descend_TW,HITL_Weight,HITL_descend_t); %[mAh]
Battery_Use_HITL_payload_hover_2 = MSN_Seg_Power_Analysis(avg_current,avg_thrust,throttle,HITL_hover_TW,HITL_Weight,HITL_payload_hover_t); %[mAh]

% Ascend Post Deployment
Battery_Use_Ascend_2 = MSN_Seg_Power_Analysis(avg_current,avg_thrust,throttle,Ascend_TW,Ascend_Weight,Ascend_t); %[mAh]

% Horizontal Flight 2: Without Payload
Battery_Use_Cruise_2_2 = MSN_Seg_Power_Analysis(avg_current,avg_thrust,throttle,Cruise_TW,Cruise_2_Weight,Cruise_2_t); %[mAh]

% Landing
Battery_Use_Land_2 = MSN_Seg_Power_Analysis(avg_current,avg_thrust,throttle,Land_TW,Land_Weight,Land_t); %[mAh]

% Total Motor Battery Use
Motors_Battery_Use_2 = Battery_Use_TO + Battery_Use_Cruise_1 + Battery_Use_HITL_hover + Battery_Use_HITL_horz_adj + Battery_Use_HITL_descend + Battery_Use_HITL_payload_hover + Battery_Use_Ascend + Battery_Use_Cruise_2 + Battery_Use_Land;
Motors_Battery_Use_Vec = [Battery_Use_TO;Battery_Use_Cruise_1;Battery_Use_HITL_hover;Battery_Use_HITL_horz_adj;Battery_Use_HITL_descend;Battery_Use_HITL_payload_hover;Battery_Use_Ascend;Battery_Use_Cruise_2;Battery_Use_Land];
Motors_Energy_Use = (Motors_Battery_Use_Vec ./ 1000) .* Motor_Voltage;

% Total Motor Power Use
Motors_Power_Use = (Motors_Battery_Use/1000) * Motor_Voltage; %[Wh]

Battery_Use_TO_Test = MSN_Seg_Test_Data(avg_power,avg_thrust,throttle,TO_TW,TO_Weight,TO_t);
Battery_Use_Cruise_1_Test = MSN_Seg_Test_Data(avg_power,avg_thrust,throttle,Cruise_TW,Cruise_1_Weight,Cruise_1_t);
Battery_Use_HITL_hover_Test = MSN_Seg_Test_Data(avg_power,avg_thrust,throttle,HITL_hover_TW,HITL_Weight,HITL_hover_t);
Battery_Use_HITL_horz_adj_Test = MSN_Seg_Test_Data(avg_power,avg_thrust,throttle,HITL_horz_adj_TW,HITL_Weight,HITL_horz_adj_t);
Battery_Use_HITL_descend_Test = MSN_Seg_Test_Data(avg_power,avg_thrust,throttle,HITL_descend_TW,HITL_Weight,HITL_descend_t);
Battery_Use_HITL_payload_hover_Test = MSN_Seg_Test_Data(avg_power,avg_thrust,throttle,HITL_hover_TW,HITL_Weight,HITL_payload_hover_t);
Battery_Use_Ascend_Test = MSN_Seg_Test_Data(avg_power,avg_thrust,throttle,Ascend_TW,Ascend_Weight,Ascend_t);
Battery_Use_Cruise_2_Test = MSN_Seg_Test_Data(avg_power,avg_thrust,throttle,Cruise_TW,Cruise_2_Weight,Cruise_2_t);
Battery_Use_Land_Test = MSN_Seg_Test_Data(avg_power,avg_thrust,throttle,Land_TW,Land_Weight,Land_t);


%% Flight Data Analysis
load("Mission_Leg_4_16.mat")

% Battery
time_bat = BAT_0(65:1565,2); %[micro-s]
time_bat = (time_bat - time_bat(1)) .* 1e-6; %[s]
curr = BAT_0(65:1565,6) + 35;
volt = BAT_0(65:1565,4);



pow = volt .* curr;
energy = cumtrapz(time_bat,pow);
energy_Wh = energy/3600;



% Flight Path
time_gps = GPS_0(:,2);
time_gps = (time_gps - time_gps(1)) * 1e-6;
lat = GPS_0(:,9);
lon = GPS_0(:,10);
alt = GPS_0(:,11);
origin = [lat(1),lon(1),alt(1)];
[x,y_all,z] = latlon2local(lat,lon,alt,origin);


% Addressing Assumptions
% Constant Speed
spd = GPS_0(:,12);
vspd = GPS_0(:,14);

constant_value = 0;
noise_std = 0.08;

% Indices to replace (e.g., replace elements 114 through 375)
start_idx = 114;
end_idx = 375;

% Generate noisy constant segment
noisy_patch = constant_value + noise_std * randn(1, end_idx - start_idx + 1);
noisy_patch2 = 10.8 + 0.02 * randn(1, end_idx - start_idx + 1);
noisy_patch3 = 10.9 + 0.02 * randn(1, 290 - 214 + 1);

% Replace the specified segment
vspd(start_idx:end_idx) = noisy_patch;
vspd = -1 * vspd;
z(start_idx:end_idx) = noisy_patch2;
z(214:290) = noisy_patch3;

figure();
plot(time_gps,spd,'LineWidth',2)
hold on
plot(time_gps,vspd,'LineWidth',2)
xlabel('Time [s]','fontweight','bold','fontsize',12)
ylabel('Speed [m/s]','fontweight','bold','fontsize',12)
title('Mission Speeds','fontweight','bold','fontsize',16)
grid on; grid minor
legend('Horizontal Speed','Vertical Speed','fontweight','bold','fontsize',12)

figure();
plot(time_gps,z,'LineWidth',2)
xlabel('Time [s]','fontweight','bold','fontsize',12)
ylabel('Local Altitude [m]','fontweight','bold','fontsize',12)
title('Mission Local Altitudes','fontweight','bold','fontsize',16)
grid on; grid minor

% T/W Analysis
time_angle = ATT(:,2);
time_angle = (time_angle - time_angle(1)) .* 1e-6;
roll = ATT(:,4);
pitch = ATT(:,6);

pitch_rad = deg2rad(pitch);
roll_rad = deg2rad(roll);

total_tilt_angle = sqrt(pitch_rad.^2 + roll_rad.^2);

T_W_cruise = sec(total_tilt_angle);

time_IMU = IMU_0(:,2);
time_IMU = (time_IMU - time_IMU(1)) .* 1e-6;
accZ = IMU_0(:,9) +9.81;
T_W_vert = (9.81 + -1 .* accZ)/9.81;

% Splicing Together T/W for verticla and horizontal translation

%6.36-16.36 65-165
%16.36-36.76 165-368
%36.76-41.56 368-417
%41.56-67.56 417-677
%67.56-77.56 677-777
%77.56-97.56 777-977
%97.56-107.56 977-1077
%107.56-128.36 1077-1285
%128.36-154.76 1285-1565

for i = 1:length(time_IMU)
    if time_IMU(i) >= 6.36 && time_IMU(i) <=16.36
        time_splice(i) = time_IMU(i);
        TW_splice(i) = (9.81 + -1 .* accZ(i))/9.81;
    end
end
for i = 1:length(time_angle)
    if time_angle(i) >= 16.37 && time_angle(i) <=67.56
        time_splice(end+1) =time_angle(i);
        TW_splice(end+1) = sec(total_tilt_angle(i));
    end
end
for i = 1:length(time_IMU)
    if time_IMU(i) >= 67.57 && time_IMU(i) <= 107.56
        time_splice(end+1) = time_IMU(i);
        TW_splice(end+1) = (9.81 + -1 .* accZ(i))/9.81;
    end
end
for i = 1:length(time_angle)
    if time_angle(i) >= 107.57 && time_angle(i) <= 128.36
        time_splice(end+1) =time_angle(i);
        TW_splice(end+1) = sec(total_tilt_angle(i));
    end
end
for i = 1:length(time_IMU)
    if time_IMU(i) >= 128.37 && time_IMU(i) <= 154.76
        time_splice(end+1) = time_IMU(i);
        TW_splice(end+1) = (9.81 + -1 .* accZ(i))/9.81;
    end
end

time_splice = time_splice(253:end);
time_splice = time_splice - time_splice(1);
TW_splice = TW_splice(253:end);

figure();
plot(time_splice,TW_splice,'LineWidth',2)
xlabel('Time [s]','fontweight','bold','fontsize',12)
ylabel('T/W Ratio','fontweight','bold','fontsize',12)
title('Mission T/W Ratios','fontweight','bold','fontsize',16)
grid on; grid minor
%% Plots

% Time Vector of Battery Use
TO_t_vec = linspace(0,TO_t);
Cruise_1_t_vec = TO_t:TO_t + Cruise_1_t;

HITL_hover_t_vec = Cruise_1_t_vec(end):Cruise_1_t_vec(end) + HITL_hover_t;
HITL_horz_adj_t_vec = HITL_hover_t_vec(end):HITL_hover_t_vec(end) + HITL_horz_adj_t;
HITL_descend_t_vec = HITL_horz_adj_t_vec(end):HITL_horz_adj_t_vec(end) + HITL_descend_t;
HITL_payload_hover_t_vec = HITL_descend_t_vec(end):HITL_descend_t_vec(end) + HITL_payload_hover_t;

Ascend_t_vec = HITL_payload_hover_t_vec(end):HITL_payload_hover_t_vec(end) + Ascend_t;
Cruise_2_t_vec = Ascend_t_vec(end):Ascend_t_vec(end) + Cruise_2_t;
Land_t_vec = Cruise_2_t_vec(end):Cruise_2_t_vec(end) + Land_t;

t_vec = [TO_t_vec,Cruise_1_t_vec,HITL_hover_t_vec,HITL_horz_adj_t_vec,HITL_descend_t_vec,HITL_payload_hover_t_vec,Ascend_t_vec,Cruise_2_t_vec,Land_t_vec];

% Battery Use Vector
TO_Batt_vec = linspace(0,Battery_Use_TO,length(TO_t_vec));
Cruise_1_Batt_vec = linspace(TO_Batt_vec(end),TO_Batt_vec(end) + Battery_Use_Cruise_1,length(Cruise_1_t_vec));
HITL_hover_Batt_vec = linspace(Cruise_1_Batt_vec(end),Cruise_1_Batt_vec(end) + Battery_Use_HITL_hover,length(HITL_hover_t_vec));
HITL_horz_adj_Batt_vec = linspace(HITL_hover_Batt_vec(end),HITL_hover_Batt_vec(end) + Battery_Use_HITL_horz_adj,length(HITL_horz_adj_t_vec));
HITL_descend_Batt_vec = linspace(HITL_horz_adj_Batt_vec(end),HITL_horz_adj_Batt_vec(end) + Battery_Use_HITL_descend,length(HITL_descend_t_vec));
HITL_payload_hover_Batt_vec = linspace(HITL_descend_Batt_vec(end),HITL_descend_Batt_vec(end) + Battery_Use_HITL_payload_hover,length(HITL_payload_hover_t_vec));
Ascend_Batt_vec = linspace(HITL_payload_hover_Batt_vec(end),HITL_payload_hover_Batt_vec(end) + Battery_Use_Ascend,length(Ascend_t_vec));
Cruise_2_Batt_vec = linspace(Ascend_Batt_vec(end),Ascend_Batt_vec(end) + Battery_Use_Cruise_2,length(Cruise_2_t_vec));
Land_Batt_vec = linspace(Cruise_2_Batt_vec(end),Cruise_2_Batt_vec(end) + Battery_Use_Land,length(Land_t_vec));

TO_Batt_vec_2 = linspace(0,Battery_Use_TO_2,length(TO_t_vec));
Cruise_1_Batt_vec_2 = linspace(TO_Batt_vec_2(end),TO_Batt_vec_2(end) + Battery_Use_Cruise_1_2,length(Cruise_1_t_vec));
HITL_hover_Batt_vec_2 = linspace(Cruise_1_Batt_vec_2(end),Cruise_1_Batt_vec_2(end) + Battery_Use_HITL_hover_2,length(HITL_hover_t_vec));
HITL_horz_adj_Batt_vec_2 = linspace(HITL_hover_Batt_vec_2(end),HITL_hover_Batt_vec_2(end) + Battery_Use_HITL_horz_adj_2,length(HITL_horz_adj_t_vec));
HITL_descend_Batt_vec_2 = linspace(HITL_horz_adj_Batt_vec_2(end),HITL_horz_adj_Batt_vec_2(end) + Battery_Use_HITL_descend_2,length(HITL_descend_t_vec));
HITL_payload_hover_Batt_vec_2 = linspace(HITL_descend_Batt_vec_2(end),HITL_descend_Batt_vec_2(end) + Battery_Use_HITL_payload_hover_2,length(HITL_payload_hover_t_vec));
Ascend_Batt_vec_2 = linspace(HITL_payload_hover_Batt_vec_2(end),HITL_payload_hover_Batt_vec_2(end) + Battery_Use_Ascend_2,length(Ascend_t_vec));
Cruise_2_Batt_vec_2 = linspace(Ascend_Batt_vec_2(end),Ascend_Batt_vec_2(end) + Battery_Use_Cruise_2_2,length(Cruise_2_t_vec));
Land_Batt_vec_2 = linspace(Cruise_2_Batt_vec_2(end),Cruise_2_Batt_vec_2(end) + Battery_Use_Land_2,length(Land_t_vec));

Model_Wh_Vec = [TO_Batt_vec,Cruise_1_Batt_vec,HITL_hover_Batt_vec,HITL_horz_adj_Batt_vec,HITL_descend_Batt_vec,HITL_payload_hover_Batt_vec,Ascend_Batt_vec,Cruise_2_Batt_vec,Land_Batt_vec];

% Test Data Battery Use Vector
TO_Batt_vec_Test = linspace(0,Battery_Use_TO_Test,length(TO_t_vec));
Cruise_1_Batt_vec_Test = linspace(TO_Batt_vec_Test(end),TO_Batt_vec_Test(end) + Battery_Use_Cruise_1_Test,length(Cruise_1_t_vec));
HITL_hover_Batt_vec_Test = linspace(Cruise_1_Batt_vec_Test(end),Cruise_1_Batt_vec_Test(end) + Battery_Use_HITL_hover_Test,length(HITL_hover_t_vec));
HITL_horz_adj_Batt_vec_Test = linspace(HITL_hover_Batt_vec_Test(end),HITL_hover_Batt_vec_Test(end) + Battery_Use_HITL_horz_adj_Test,length(HITL_horz_adj_t_vec));
HITL_descend_Batt_vec_Test = linspace(HITL_horz_adj_Batt_vec_Test(end),HITL_horz_adj_Batt_vec_Test(end) + Battery_Use_HITL_descend_Test,length(HITL_descend_t_vec));
HITL_payload_hover_Batt_vec_Test = linspace(HITL_descend_Batt_vec_Test(end),HITL_descend_Batt_vec_Test(end) + Battery_Use_HITL_payload_hover_Test,length(HITL_payload_hover_t_vec));
Ascend_Batt_vec_Test = linspace(HITL_payload_hover_Batt_vec_Test(end),HITL_payload_hover_Batt_vec_Test(end) + Battery_Use_Ascend_Test,length(Ascend_t_vec));
Cruise_2_Batt_vec_Test = linspace(Ascend_Batt_vec_Test(end),Ascend_Batt_vec_Test(end) + Battery_Use_Cruise_2_Test,length(Cruise_2_t_vec));
Land_Batt_vec_Test = linspace(Cruise_2_Batt_vec_Test(end),Cruise_2_Batt_vec_Test(end) + Battery_Use_Land_Test,length(Land_t_vec));

Test_Wh_Vec = [TO_Batt_vec_Test,Cruise_1_Batt_vec_Test,HITL_hover_Batt_vec_Test,HITL_horz_adj_Batt_vec_Test,HITL_descend_Batt_vec_Test,HITL_payload_hover_Batt_vec_Test,Ascend_Batt_vec_Test,Cruise_2_Batt_vec_Test,Land_Batt_vec_Test];
Test_Wh_Vec_2 = [TO_Batt_vec_2,Cruise_1_Batt_vec_2,HITL_hover_Batt_vec_2,HITL_horz_adj_Batt_vec_2,HITL_descend_Batt_vec_2,HITL_payload_hover_Batt_vec_2,Ascend_Batt_vec_2,Cruise_2_Batt_vec_2,Land_Batt_vec_2];

% Combined Vectors
% figure();
% plot(TO_t_vec,TO_Batt_vec./1000 .* Motor_Voltage,'LineWidth',2)
% hold on
% plot(Cruise_1_t_vec,Cruise_1_Batt_vec./1000 .* Motor_Voltage,'LineWidth',2)
% plot(HITL_hover_t_vec,HITL_hover_Batt_vec./1000 .* Motor_Voltage,'LineWidth',2)
% plot(HITL_horz_adj_t_vec,HITL_horz_adj_Batt_vec./1000 .* Motor_Voltage,'LineWidth',2)
% plot(HITL_descend_t_vec,HITL_descend_Batt_vec./1000 .* Motor_Voltage,'LineWidth',2)
% plot(HITL_payload_hover_t_vec,HITL_payload_hover_Batt_vec./1000 .* Motor_Voltage,'LineWidth',2)
% plot(Ascend_t_vec,Ascend_Batt_vec./1000 .* Motor_Voltage,'LineWidth',2)
% plot(Cruise_2_t_vec,Cruise_2_Batt_vec./1000 .* Motor_Voltage,'LineWidth',2)
% plot(Land_t_vec,Land_Batt_vec./1000 .* Motor_Voltage,'LineWidth',2)
% grid on; grid minor
% xlabel('Time [s]','fontweight','bold','fontsize',16)
% ylabel('Energy Consumption [Wh]','fontweight','bold','fontsize',16)
% title('Energy Consumption for One Mission Leg','fontweight','bold','fontsize',16)
% legend('Takeoff','Cruise w/ Payload','HITL Hover','HITL Horizontal Adjustment','HITL Vertical Adjustment','Payload Deployment','Ascent','Cruise w/o Payload','Landing','Location','northwest')
% fontsize(16,"points")

% cx = gca;
% exportgraphics(cx,'EnergyAnalysis.png','Resolution',600)

%6.36-16.36 65-165
%16.36-36.76 165-368
%36.76-41.56 368-417
%41.56-67.56 417-677
%67.56-77.56 677-777
%77.56-97.56 777-977
%97.56-107.56 977-1077
%107.56-128.36 1077-1285
%128.36-154.76 1285-1565


TO_x = [0 0 10 10];
y_all = [0 60 60 0];
y_err = [0 16 16 0];
TO_color = [0 0 0];

Cruise1_x = [10 10 30 30];
Cruise1_color = [0.8 0.8 0.8];

hover_trans_x = [30 30 35 35];
hover_trans_color = [0 0 0];

horz_adj_x = [35 35 60 60];
horz_adj_color = [0.8 0.8 0.8];

descend_x = [60 60 70 70];
descend_color = [0 0 0];

deploy_x = [70 70 95 95];
deploy_color = [0.8 0.8 0.8];

ascend_x = [95 95 100 100];
ascend_color = [0 0 0];

Cruise2_x = [100 100 120 120];
Cruise2_color = [0.8 0.8 0.8];

land_x = [120 120 150 150];
land_color = [0 0 0];

figure();
plot(t_vec,Model_Wh_Vec./1000 .* Motor_Voltage)
hold on
plot(t_vec,Test_Wh_Vec)
plot(time_bat,energy_Wh)
grid on; grid minor
title('Single Mission Leg Energy Consumption')
xlabel('Time [s]','fontweight','bold','fontsize',12)
ylabel('Energy Consumption [Wh]','fontweight','bold','fontsize',12)

xlim([0 150])
a = fill(TO_x, y_all, TO_color);
a.FaceAlpha = 0.1;
xline(10,'label','Takeoff','LabelHorizontalAlignment','left')
a = fill(Cruise1_x, y_all, Cruise1_color);
a.FaceAlpha = 0.1;
xline(30,'label','Cruise w/ Payload','LabelHorizontalAlignment','left')
a = fill(hover_trans_x, y_all, hover_trans_color);
a.FaceAlpha = 0.1;
xline(35,'label','Hover Transition','LabelHorizontalAlignment','left')
a = fill(horz_adj_x, y_all, horz_adj_color);
a.FaceAlpha = 0.1;
xline(60,'label','Horizontal Adjustments','LabelHorizontalAlignment','left')
a = fill(descend_x, y_all, descend_color);
a.FaceAlpha = 0.1;
xline(70,'label','Descent','LabelHorizontalAlignment','left')
a = fill(deploy_x, y_all, deploy_color);
a.FaceAlpha = 0.1;
xline(95,'label','Payload Deployment','LabelHorizontalAlignment','left')
a = fill(ascend_x, y_all, ascend_color);
a.FaceAlpha = 0.1;
xline(100,'label','Ascent','LabelHorizontalAlignment','left')
a = fill(Cruise2_x, y_all, Cruise2_color);
a.FaceAlpha = 0.1;
xline(120,'label','Cruise w/o Payload','LabelHorizontalAlignment','left')
a = fill(land_x, y_all, land_color);
a.FaceAlpha = 0.1;
xline(150,'label','Landing','LabelHorizontalAlignment','left')

legend('Datasheet Model','Thrust Test Model','Single Mission Leg Test Data','','','Location','southeast')

energy_Wh_resampled = interp1(time_bat, energy_Wh, t_vec);
Test_Thrust_Data_error = abs(energy_Wh_resampled - Test_Wh_Vec);
Test_Datasheet_error = abs(energy_Wh_resampled - (Model_Wh_Vec./1000 .* Motor_Voltage));

Test_Thrust_Data_error_batt_perc = Test_Thrust_Data_error/355.2 * 100;
Test_Datasheet_error_batt_perc = Test_Datasheet_error/355.2 * 100;

figure();
plot(t_vec,Test_Datasheet_error)
hold on
plot(t_vec,Test_Thrust_Data_error)
xlabel('Time [s]')
ylabel('Differences From Flight Data [Wh]')
title('Energy Model Errors For Single Mission Leg')
ylim([0 16])

a = fill(TO_x, y_err, TO_color);
a.FaceAlpha = 0.1;
xline(10,'label','Takeoff','LabelHorizontalAlignment','left')
a = fill(Cruise1_x, y_err, Cruise1_color);
a.FaceAlpha = 0.1;
xline(30,'label','Cruise w/ Payload','LabelHorizontalAlignment','left')
a = fill(hover_trans_x, y_err, hover_trans_color);
a.FaceAlpha = 0.1;
xline(35,'label','Hover Transition','LabelHorizontalAlignment','left')
a = fill(horz_adj_x, y_err, horz_adj_color);
a.FaceAlpha = 0.1;
xline(60,'label','Horizontal Adjustments','LabelHorizontalAlignment','left')
a = fill(descend_x, y_err, descend_color);
a.FaceAlpha = 0.1;
xline(70,'label','Descent','LabelHorizontalAlignment','left')
a = fill(deploy_x, y_err, deploy_color);
a.FaceAlpha = 0.1;
xline(95,'label','Payload Deployment','LabelHorizontalAlignment','left')
a = fill(ascend_x, y_err, ascend_color);
a.FaceAlpha = 0.1;
xline(100,'label','Ascent','LabelHorizontalAlignment','left')
a = fill(Cruise2_x, y_err, Cruise2_color);
a.FaceAlpha = 0.1;
xline(120,'label','Cruise w/o Payload','LabelHorizontalAlignment','left')
a = fill(land_x, y_err, land_color);
a.FaceAlpha = 0.1;
xline(150,'label','Landing','LabelHorizontalAlignment','left')

legend('Datasheet Model','Thrust Test Model','Location','southeast')


%% Battery Calculations
DoD = 0.85; % Depth of discharge
Actual_Battery_Capacity = 5000:1000:30000; %[mAh]
Actual_Battery_Voltage = 22.2; %[V] -- This value is dependent of voltage rating of motors (nominal value)
Actual_Battery_Power = (Actual_Battery_Capacity./1000) .* Actual_Battery_Voltage; %[Wh]
Predicted_Battery_Power = Actual_Battery_Power .*  DoD; %[Wh]

% Find Index of Closest Value
[~,closestIndex_Hex_Batt] = min(abs(Predicted_Battery_Power - Motors_Power_Use));


fprintf('---------------------------------------------------\n')
fprintf('Minimum Hexacopter Battery Capacity: %g mAh\n', Actual_Battery_Capacity(closestIndex_Hex_Batt))
fprintf('---------------------------------------------------\n')
fprintf('Minimum Hexacopter Battery Voltage: %g V\n', Actual_Battery_Voltage)
fprintf('---------------------------------------------------\n')
fprintf('Minimum Hexacopter Battery Power Rating: %g Wh\n', Actual_Battery_Power(closestIndex_Hex_Batt))
fprintf('---------------------------------------------------\n')

%% Animated Flight Path

% load('Mission_Leg_Log.mat')
% 
% lat = GPS_0(:,9);
% lon = GPS_0(:,10);
% alt = GPS_0(:,11); %[m ASL]
% alt = alt - alt(1); %[m]
% time_loc = GPS_0(:,2); %[micro-s]
% time_loc = (time_loc - time_loc(1)) .* 1e-6; %[m]
% origin = [lat(1),lon(1),alt(1)];
% [x,y,z] = latlon2local(lat,lon,alt,origin);
% 
% % === FIGURE SETUP ===
% fig = figure();
% 
% 
% % Initialize animated line in orange
% h = plot3(nan, nan, nan, 'LineWidth', 2);
% % Set fixed axis limits based on full data
% xlim([min(x), max(x)]);                                % Lock X-axis
% ylim([min(y), max(y)]);                                % Lock Y-axis
% zlim([min(z), max(z)]);                                % Lock Z-axis
% grid on; grid minor
% % === VIDEO SETUP ===
% video_filename = 'Mission_Leg.mp4';           % Output file name
% v = VideoWriter(video_filename, 'MPEG-4');
% v.FrameRate = 6;                              
% open(v);
% 
% % === ANIMATION LOOP ===
% n = length(x);                                   % Total number of points
% update_size = 12;                                % How many points per frame
% 
% for i = 1:update_size:n
%     idx_end = min(i + update_size - 1, n);       % Avoid going past end of data
%     set(h, 'XData', x(1:idx_end), 'YData', y(1:idx_end), 'ZData', z(1:idx_end));  % Update plot
%     drawnow;                                     % Refresh plot window
%     frame = getframe(fig);                       % Capture current frame
%     writeVideo(v, frame);                        % Write frame to video
% end
% 
% % === FINALIZE VIDEO ===
% close(v);
% 


%% Function(s)
function Battery_Use = MSN_Seg_Power_Analysis(Current,Thrust,Throttle,TW,Weight,Time)
%--------------------------------------------------------------------------------------
% Inputs:
%   Current: Vector of motor current draw values in milliamps
%   Thrust: Vector of motor thrust values in grams
%   Throttle: Vector of motor throttle values in percent
%   TW: Thrust-to-Weight ratio for mission segment
%   Weight: Expected vehicle weight for mission segment in kilograms
%   Time: Expected time vehicle will spend on this mission segment in seconds
% Output:
%   Battery_Use: Vector containing battery use in milliamp-hours for 4, 6, and 8 motors
%--------------------------------------------------------------------------------------

% Polyfit Thrust Values
Thrust_Fit = polyfit(Throttle,Thrust,1);
Thrust_Fit_Values = polyval(Thrust_Fit,min(Throttle):1:100);

% Find Thrust Necessary
Thrust_Needed = TW * Weight;
% Thrust_calc = (nu *Vel^2)


% Breakdown of Thrust per Motor for  4, 6, and 8 Motors
Hex_Thrust = (Thrust_Needed/6)*1000;

% Index of Thrust Value
[~,closestIndex_Hex] = min(abs(Thrust_Fit_Values-Hex_Thrust));

% Fit Current Values
Current_Fit = polyfit(Throttle,Current,2);
Current_Fit_Values = polyval(Current_Fit,min(Throttle):1:100);

% Find Current Value Correlating to Thrust Index
Current_Draw_Hex = Current_Fit_Values(closestIndex_Hex)*6;

% Battery Use
Time_hrs = Time/3600; %[s] -> [hrs]

Battery_Use = Current_Draw_Hex * Time_hrs; %[mAh]

end

function Battery_Use_Test = MSN_Seg_Test_Data(Power,Thrust,Throttle,TW,Weight,Time)

% Polyfit Thrust Values
Thrust_Fit = polyfit(Throttle,Thrust,1);
Thrust_Fit_Values = polyval(Thrust_Fit,min(Throttle):1:100);

% Find Thrust Necessary
Thrust_Needed = TW * Weight;
% Thrust_calc = (nu *Vel^2)


% Breakdown of Thrust per Motor for  4, 6, and 8 Motors
Hex_Thrust = (Thrust_Needed/6)*1000;

% Index of Thrust Value
[~,closestIndex_Hex] = min(abs(Thrust_Fit_Values-Hex_Thrust));

% Fit Power Values
Power_Fit = polyfit(Throttle,Power,2);
Power_Fit_Values = polyval(Power_Fit,min(Throttle):1:100);

Power_Draw_Hex = Power_Fit_Values(closestIndex_Hex)*6;

% Battery Use
Time_hrs = Time/3600; %[s] -> [hrs]

Battery_Use_Test = Power_Draw_Hex * Time_hrs; %[Wh]

end