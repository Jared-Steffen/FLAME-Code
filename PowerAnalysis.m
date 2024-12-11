clc; clear; close all
%% Code Assumptions
% 1. Constant speed during all mission segments
% 2. Motor spec sheet accounts for battery, motor, and propeller efficencies
% 3. Depth of discharge is 80% for our LiPo battery
% 4. Constant T/W ratio for each segment
% 5. Each target location is 100 meters away from home base
% 6. No vertical adjustments necessary during cruise legs
% 7. MTOW is 10 kg w/ payload
% 8. Vehicle is tiltled 5 degrees during cruise

%% Model Risks
% 1. We do not know the conditions under which the motor was tested, such as altitude

%% Motor Specs -- Pulled From Datasheet
% T-Motor MN505-S IP45 KV320 Navigator Type w/ T-Motor P18*6.1 Propellers and 6S LiPo
% Motor_Thrust = [1071,1160,1287,1414,1545,1676,1843,1985,2084,2216,2347,2486,2645,2806,2936,3091,3456,3818,4606,5444]; %[g]
% Motor_Throttle = [40:2:70,75,80:10:100]; %[%]
% Motor_Current = [5.3,5.9,6.6,7.4,8.2,9.0,10.1,11.2,12.2,13.3,14.5,15.6,16.9,18.3,19.6,21.0,24.5,28.6,37.7,48.8]*1000; %[mA]
% Motor_Voltage = 24; %[V]

% T-Motor MN501-S IP45 KV360 Navigator Type w/ T-Motor P18*6.1 Propellers and 6S LiPo
Motor_Thrust = [917,989,1080,1160,1310,1450,1540,1657,1708,1881,2003,2138,2269,2400,2519,2671,2974,3276,3959,4644]; %[g]
Motor_Throttle = [40:2:70,75,80:10:100]; %[%]
Motor_Current = [3.93,4.35,4.82,5.32,6.14,7.09,7.76,8.48,9.31,10.36,11.26,12.10,13.13,14.24,15.29,16.46,19.34,22.39,29.83,38.43]*1000; %[mA]
Motor_Voltage = 24; %[V]
Motor_Resistance = 0.045; %[Ohms]

Wire_Resistance = 4.016/1000;
Current_Range = linspace(Motor_Current(1),Motor_Current(end));

P_ideal = Motor_Voltage * Current_Range;
P_loss_wire = Current_Range.^2*Wire_Resistance;
P_loss_motor = Current_Range.^2*Motor_Resistance;
P_loss_total = P_loss_motor+P_loss_wire;
P_actual = P_ideal - (Current_Range.^2*(Motor_Resistance + Wire_Resistance));

figure();
plot(Current_Range,P_ideal)
hold on
plot(Current_Range,P_loss_wire),
plot(Current_Range,P_loss_motor)
plot(Current_Range,P_loss_total)
plot(Current_Range,P_actual)
legend('Ideal','Wire Losses (1 foot)','Motor Losses','Total Losses','Actual')


%% Mission Segment Times [s]
TO_t = 30;
Cruise_1_t = 180;

HITL_hover_t = 15;
HITL_horz_adj_t = 180;
HITL_descend_t = 180;
HITL_payload_hover_t = 30;

Ascend_t = 10;
Cruise_2_t = 180;
Land_t = 30;

%% Motor Power Analysis per Mission Segment
% Take-off
TO_TW = 1.5;
TO_Weight = 10; %[kg]
Battery_Use_TO = MSN_Seg_Power_Analysis(Motor_Current,Motor_Thrust,Motor_Throttle,TO_TW,TO_Weight,TO_t); %[mAh]

% Horizontal Flight 1: With Payload
Cruise_TW = 1.004; % https://www.halfchrome.com/drone-thrust-testing/
Cruise_1_Weight = 10; %[kg]
Battery_Use_Cruise_1 = MSN_Seg_Power_Analysis(Motor_Current,Motor_Thrust,Motor_Throttle,Cruise_TW,Cruise_1_Weight,Cruise_1_t); %[mAh]

% Human-In-The-Loop - Most Uncertainty Lies Here
HITL_hover_TW = 1;
HITL_horz_adj_TW = 1.004;
HITL_descend_TW = 0.8;

HITL_Weight = 10; %[kg]

Battery_Use_HITL_hover = MSN_Seg_Power_Analysis(Motor_Current,Motor_Thrust,Motor_Throttle,HITL_hover_TW,HITL_Weight,HITL_hover_t); %[mAh]
Battery_Use_HITL_horz_adj = MSN_Seg_Power_Analysis(Motor_Current,Motor_Thrust,Motor_Throttle,HITL_horz_adj_TW,HITL_Weight,HITL_horz_adj_t); %[mAh]
Battery_Use_HITL_descend = MSN_Seg_Power_Analysis(Motor_Current,Motor_Thrust,Motor_Throttle,HITL_descend_TW,HITL_Weight,HITL_descend_t); %[mAh]
Battery_Use_HITL_payload_hover = MSN_Seg_Power_Analysis(Motor_Current,Motor_Thrust,Motor_Throttle,HITL_hover_TW,HITL_Weight,HITL_payload_hover_t); %[mAh]

% Ascend Post Deployment
Ascend_TW = 1.5;
Ascend_Weight = 7.73;
Battery_Use_Ascend = MSN_Seg_Power_Analysis(Motor_Current,Motor_Thrust,Motor_Throttle,Ascend_TW,Ascend_Weight,Ascend_t); %[mAh]

% Horizontal Flight 2: Without Payload
Cruise_2_Weight = 7.7; %[kg]
Battery_Use_Cruise_2 = MSN_Seg_Power_Analysis(Motor_Current,Motor_Thrust,Motor_Throttle,Cruise_TW,Cruise_2_Weight,Cruise_2_t); %[mAh]

% Landing
Land_TW = 0.8;
Land_Weight = 7.73; %[kg]
Battery_Use_Land = MSN_Seg_Power_Analysis(Motor_Current,Motor_Thrust,Motor_Throttle,Land_TW,Land_Weight,Land_t); %[mAh]

% Total Motor Battery Use
Motors_Battery_Use = Battery_Use_TO + Battery_Use_Cruise_1 + Battery_Use_HITL_hover + Battery_Use_HITL_horz_adj + Battery_Use_HITL_descend + HITL_descend_t + Battery_Use_HITL_payload_hover + Battery_Use_Ascend + Battery_Use_Cruise_2 + Battery_Use_Land;

% Total Motor Power Use
Motors_Power_Use = (Motors_Battery_Use/1000) * Motor_Voltage; %[Wh]

%% Plots
% % Bar Plot of Battery Use
% Battery_Use_Data = [Battery_Use_TO;Battery_Use_Cruise_1;Battery_Use_HITL_hover;Battery_Use_Cruise_2;Battery_Use_Land];
% Power_Use_Data = (Battery_Use_Data./1000) .* Motor_Voltage;
% Mission_Segments = ({'Take-off','Horizontal Flight w/ Payload','HITL Control','Horizontal Flight w/o Payload','Landing'});
% 
% figure();
% bar(Mission_Segments,Battery_Use_Data)
% legend('Quadcopter','Hexacopter','Octocopter')
% ylabel('Battery Capacity Usage [mAh]')
% title('Battery Capacity Usage for Mission Segments for Each Rotor Count')
% 
% ax = gca;
% exportgraphics(ax,'Capacity Comparison.png','Resolution',300)
% 
% figure();
% bar(Mission_Segments,Power_Use_Data)
% legend('Quadcopter','Hexacopter','Octocopter')
% ylabel('Battery Power Usage [Wh]')
% title('Battery Power Usage for Mission Segments for Each Rotor Count')
% 
% bx = gca;
% exportgraphics(bx,'Energy Comparison.png','Resolution',300)

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

% % Battery Use Vector
% TO_Batt_vec = linspace(0,Battery_Use_TO(2),length(TO_t_vec));
% Cruise_1_Batt_vec = linspace(TO_Batt_vec(end),TO_Batt_vec(end) + Battery_Use_Cruise_1(2),length(Cruise_1_t_vec));
% HITL_Batt_vec = linspace(Cruise_1_Batt_vec(end),Cruise_1_Batt_vec(end) + Battery_Use_HITL_hover(2),length(HITL_t_vec));
% Cruise_2_Batt_vec = linspace(HITL_Batt_vec(end),HITL_Batt_vec(end) + Battery_Use_Cruise_2(2),length(Cruise_2_t_vec));
% Land_Batt_vec = linspace(Cruise_2_Batt_vec(end),Cruise_2_Batt_vec(end) + Battery_Use_Land(2),length(Land_t_vec));
% MSN_Batt_vec = [TO_Batt_vec,Cruise_1_Batt_vec,HITL_Batt_vec,Cruise_2_Batt_vec,Land_Batt_vec];
% 
% % plot(MSN_t_vec,MSN_Batt_vec)
% % Plot Time vs Battery Use
% figure();
% plot(TO_t_vec,TO_Batt_vec,'LineWidth',3)
% hold on
% plot(Cruise_1_t_vec,Cruise_1_Batt_vec,'LineWidth',3)
% plot(HITL_t_vec,HITL_Batt_vec,'LineWidth',3)
% plot(Cruise_2_t_vec,Cruise_2_Batt_vec,'LineWidth',3)
% plot(Land_t_vec,Land_Batt_vec,'LineWidth',3)
% legend('Takeoff','Cruise with Payload','Human-In-The-Loop','Cruise without Payload','Land','Location','northwest')
% grid on; grid minor
% title('Battery Capacity Usage')
% xlabel('Time [s]')
% ylabel('Battery Use [mAh]')
% hold off

cx = gca;
exportgraphics(cx,'CapacityAnalysis.png','Resolution',300)

%% Additional Components Power Analysis
% Camera
% RunCam Nano2 FPV Camera
Camera_Current = 120; %[mA]
Camera_Time_of_Operation = 20; %[min]
Camera_Battery_Use = Camera_Current * (Camera_Time_of_Operation/60); %[mAh]

% Video Transmitter
% WT832 5.8 Ghz 40CH FPV Transmitter
VTx_Current = 220; %[mA]
VTx_Time_of_Operation = 20; %[min]
VTx_Battery_Use = VTx_Current*(VTx_Time_of_Operation/60); %[mAh]

% Radio Transmitter
% Holybro SiK Telemetry Radio V3
RadioTx_Current = 100; %[mA]
RadioRx_Current = 25; %[mA]
Radio_Current = RadioTx_Current + RadioRx_Current;
Radio_Time_of_Operation = 20; %[min]
Radio_Battery_Use = Radio_Current * (Radio_Time_of_Operation/60); %[mAh]

% RC Reciever
% Holybro R86V RC Reciever
% NOTE: Datasheet doesn't state current, so most likely negligible
RCRx_Current = 100; %[mA]
RCRx_Time_of_Operation = 20; %[min]
RCRx_Battery_Use = RCRx_Current * (RCRx_Time_of_Operation/60); %[mAh]

% Switch
% DSTFuy 12VDC Long Range Remote Control Switch
% NOTE: Datsheet doesn't state current draw, so most likely negligible
Switch_Standby_Current = 50; %[mA]
Switch_Active_Current = 200; %[mA]
Switch_Standby_Time_of_Operation = 20; %[min]
Switch_Active_Time_of_Operation = 1; %[min]
Switch_Standby_Battery_Use = Switch_Standby_Current * (Switch_Standby_Time_of_Operation/60); %[mAh]
Switch_Active_Battery_Use = Switch_Active_Current * (Switch_Active_Time_of_Operation/60); %[mAh]
Switch_Battery_Use = Switch_Standby_Battery_Use + Switch_Active_Battery_Use;

% Solenoid Valve
% PSL-25 1" Solenoid Valve
Valve_V = 12; %[V]
Valve_Power = 32; %[W]
Valve_Current = (Valve_Power/Valve_V)*1000; %[mA]
Valve_Time_of_Operation = 30; %[s]
Valve_Battery_Use = Valve_Current * (Valve_Time_of_Operation/3600); %[mAh]

% Flight Controller
% Pixhawk 4 https://diydrones.com/profiles/blogs/pixhawk-and-apm-power-consumption
FC_Current = 200; %[mA]
FC_Time_of_Operation = 20; %[min]
FC_Battery_Use = FC_Current * (FC_Time_of_Operation/60); %[mAh]

% Lidar Sensor
% MakerFocus TFmini-s Micro Lidar Module
Lidar_Current = 200; %[mA]
Lidar_Time_of_Operation = 20; %[min]
Lidar_Battery_Use = Lidar_Current * (Lidar_Time_of_Operation/60); %[mAh]

% GPS
% Holybro M10 and M9N GPS
GPS_Current = 200; %[mA]
GPS_Time_of_Operation = 20; %[min]
GPS_Battery_Use = GPS_Current * (GPS_Time_of_Operation/60); %[mAh]

% Total Additional Components Battery Use
Components_Battery_Use = Camera_Battery_Use + VTx_Battery_Use + Radio_Battery_Use + RCRx_Battery_Use + ...
Switch_Battery_Use + Valve_Battery_Use + FC_Battery_Use + Lidar_Battery_Use + GPS_Battery_Use;

%% Total Power Analysis
Total_Battery_Use = [Motors_Battery_Use(2),Components_Battery_Use];

% % Bar plot comparison
% Batt_Use_Cats = ({'Motors','Additional Components'});
% bar(Batt_Use_Cats,Total_Battery_Use)
% ylabel('Battery Capacity Usage [mAh]')
% title('Battery Usage Comparison')
% 
% dx = gca;
% exportgraphics(dx,'Comparison.png','Resolution',300)

%% Battery Calculations
DoD = 0.8; % Depth of discharge
% n_Battery = 0.84; % Battery Efficiency https://www.mdpi.com/2076-3417/10/3/895
Actual_Battery_Capacity = 5000:1000:30000; %[mAh]
Actual_Battery_Voltage = 22.2; %[V] -- This value is dependent of voltage rating of motors (nominal value)
Actual_Battery_Power = (Actual_Battery_Capacity./1000) .* Actual_Battery_Voltage; %[Wh]
Predicted_Battery_Power = Actual_Battery_Power .*  DoD; %[Wh]

% Find Index of Closest Value
[~,closestIndex_Quad_Batt] = min(abs(Predicted_Battery_Power - Motors_Power_Use(1)));
[~,closestIndex_Hex_Batt] = min(abs(Predicted_Battery_Power - Motors_Power_Use(2)));
[~,closestIndex_Oct_Batt] = min(abs(Predicted_Battery_Power - Motors_Power_Use(3)));

fprintf('---------------------------------------------------\n')
fprintf('Minimum Quadcopter Battery Capacity: %g mAh\n', Actual_Battery_Capacity(closestIndex_Quad_Batt))
fprintf('Minimum Hexacopter Battery Capacity: %g mAh\n', Actual_Battery_Capacity(closestIndex_Hex_Batt))
fprintf('Minimum Octocopter Battery Capacity: %g mAh\n', Actual_Battery_Capacity(closestIndex_Oct_Batt))
fprintf('---------------------------------------------------\n')
fprintf('Minimum Quadcopter Battery Voltage: %g V\n', Actual_Battery_Voltage)
fprintf('Minimum Hexacopter Battery Voltage: %g V\n', Actual_Battery_Voltage)
fprintf('Minimum Octocopter Battery Voltage: %g V\n', Actual_Battery_Voltage)
fprintf('---------------------------------------------------\n')
fprintf('Minimum Quadcopter Battery Power Rating: %g Wh\n', Actual_Battery_Power(closestIndex_Quad_Batt))
fprintf('Minimum Hexacopter Battery Power Rating: %g Wh\n', Actual_Battery_Power(closestIndex_Hex_Batt))
fprintf('Minimum Octocopter Battery Power Rating: %g Wh\n', Actual_Battery_Power(closestIndex_Oct_Batt))
fprintf('---------------------------------------------------\n')


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

% Breakdown of Thrust per Motor for  4, 6, and 8 Motors
Quad_Thrust = (Thrust_Needed/4)*1000;
Hex_Thrust = (Thrust_Needed/6)*1000;
Oct_Thrust = (Thrust_Needed/8)*1000;

% Index of Thrust Value
[~,closestIndex_Quad] = min(abs(Thrust_Fit_Values-Quad_Thrust));
[~,closestIndex_Hex] = min(abs(Thrust_Fit_Values-Hex_Thrust));
[~,closestIndex_Oct] = min(abs(Thrust_Fit_Values-Oct_Thrust));

% Fit Current Values
Current_Fit = polyfit(Throttle,Current,2);
Current_Fit_Values = polyval(Current_Fit,min(Throttle):1:100);

% Find Current Value Correlating to Thrust Index
Current_Draw_Quad = Current_Fit_Values(closestIndex_Quad)*4;
Current_Draw_Hex = Current_Fit_Values(closestIndex_Hex)*6;
Current_Draw_Oct = Current_Fit_Values(closestIndex_Oct)*8;

% Battery Use
Time_hrs = Time/3600; %[s] -> [hrs]

Battery_Use_Quad = Current_Draw_Quad * Time_hrs; %[mAh]
Battery_Use_Hex = Current_Draw_Hex * Time_hrs; %[mAh]
Battery_Use_Oct = Current_Draw_Oct * Time_hrs; %[mAh]

Battery_Use = [Battery_Use_Quad,Battery_Use_Hex,Battery_Use_Oct];

end