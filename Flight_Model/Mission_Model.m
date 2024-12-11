%% Driver function for FLAME Dynamics model
% Goals:
% 1. Model time of flight
% 2. Validate that it is possible to accomplish mission (weight isn't too
% much)
% 3. Use to model wind/mass?
%

%% Housekeeping
close all;
clear;
clc;

%% Setup
<<<<<<< HEAD

% Initial value setup
Parameters = Get_Paramters();
var0 = [0;0;0;0;0;0;0;0;0;0;0;0];  % On the ground initial conditions

%% ODE45 Calls

OpMode1 = "Up";  % Initial Op Mode sent to ode45
[t,stateVec] = ode45(@(t,var)QuadrotorControl(t, var, Parameters, OpMode1,0),[0 10],var0);

t_end = t(end)+1;
New_var0 = stateVec(end,:);

OpMode2 = "Across"; % Second Op Mode sent to ode45
[t2,stateVec2] = ode45(@(t,var)QuadrotorControl(t, var, Parameters, OpMode2,t_end),[t_end, t_end + 70],New_var0);

t_end_2 = t2(end)+1;
New_var0_2 = stateVec2(end,:);

OpMode3 = "Down"; % Third Op Mode sent to ode45
[t3,stateVec3] = ode45(@(t,var)QuadrotorControl(t, var, Parameters, OpMode3,t_end_2),[t_end_2, t_end_2 + 10],New_var0_2);

t_end_3 = t3(end)+1;
New_var0_3 = stateVec3(end,:);

OpMode4 = "Back_Up";
[t4,stateVec4] = ode45(@(t,var)QuadrotorControl(t, var, Parameters, OpMode4,t_end_3),[t_end_3, t_end_3 + 10],New_var0_3);

t_end_4 = t4(end)+1;
New_var0_4 = stateVec4(end,:);

OpMode5 = "Back_Across";
[t5,stateVec5] = ode45(@(t,var)QuadrotorControl(t, var, Parameters, OpMode5,t_end_4),[t_end_4, t_end_4 + 70],New_var0_4);

t_end_5 = t5(end)+1;
New_var0_5 = stateVec5(end,:);

OpMode6 = "Back_Down";
[t6,stateVec6] = ode45(@(t,var)QuadrotorControl(t, var, Parameters, OpMode6,t_end_5),[t_end_5, t_end_5 + 10],New_var0_5);

% Extracting motor forces from each flight
for i=1:numel(t)
    [~,motor_forces_1(:,i)] = QuadrotorControl(t(i), stateVec(i,:), Parameters, OpMode1,0);
end
for i=1:numel(t2)
    [~,motor_forces_2(:,i)] = QuadrotorControl(t2(i), stateVec2(i,:), Parameters, OpMode2,t_end);
end
for i=1:numel(t3)
    [~,motor_forces_3(:,i)] = QuadrotorControl(t3(i), stateVec3(i,:), Parameters, OpMode3,t_end_2);
end
<<<<<<< HEAD
=======
>>>>>>> b0728ae1d54e5adb4bf8c50131c6769e49353d6b

% Initial value setup
Parameters = Get_Paramters();
var0 = [0;0;0;0;0;0;0;0;0;0;0;0];  % On the ground initial conditions

<<<<<<< HEAD
%% Combining values and Plotting
=======
%% ODE45 Calls

OpMode1 = "Up";  % Initial Op Mode sent to ode45
[t,stateVec] = ode45(@(t,var)QuadrotorControl(t, var, Parameters, OpMode1,0),[0 10],var0);

t_end = t(end)+1;
New_var0 = stateVec(end,:);

OpMode2 = "Across"; % Second Op Mode sent to ode45
[t2,stateVec2] = ode45(@(t,var)QuadrotorControl(t, var, Parameters, OpMode2,t_end),[t_end, t_end + 70],New_var0);

t_end_2 = t2(end)+1;
New_var0_2 = stateVec2(end,:);

OpMode3 = "Down"; % Third Op Mode sent to ode45
[t3,stateVec3] = ode45(@(t,var)QuadrotorControl(t, var, Parameters, OpMode3,t_end_2),[t_end_2, t_end_2 + 10],New_var0_2);

t_end_3 = t3(end)+1;
New_var0_3 = stateVec3(end,:);

OpMode4 = "Back_Up";
[t4,stateVec4] = ode45(@(t,var)QuadrotorControl(t, var, Parameters, OpMode4,t_end_3),[t_end_3, t_end_3 + 10],New_var0_3);

t_end_4 = t4(end)+1;
New_var0_4 = stateVec4(end,:);

OpMode5 = "Back_Across";
[t5,stateVec5] = ode45(@(t,var)QuadrotorControl(t, var, Parameters, OpMode5,t_end_4),[t_end_4, t_end_4 + 70],New_var0_4);

t_end_5 = t5(end)+1;
New_var0_5 = stateVec5(end,:);

OpMode6 = "Back_Down";
[t6,stateVec6] = ode45(@(t,var)QuadrotorControl(t, var, Parameters, OpMode6,t_end_5),[t_end_5, t_end_5 + 10],New_var0_5);

% Extracting motor forces from each flight
for i=1:numel(t)
    [~,motor_forces_1(:,i)] = QuadrotorControl(t(i), stateVec(i,:), Parameters, OpMode1,0);
end
for i=1:numel(t2)
    [~,motor_forces_2(:,i)] = QuadrotorControl(t2(i), stateVec2(i,:), Parameters, OpMode2,t_end);
end
for i=1:numel(t3)
    [~,motor_forces_3(:,i)] = QuadrotorControl(t3(i), stateVec3(i,:), Parameters, OpMode3,t_end_2);
end
for i=1:numel(t4)
    [~,motor_forces_4(:,i)] = QuadrotorControl(t4(i), stateVec4(i,:), Parameters, OpMode4,t_end_3);
end
for i=1:numel(t5)
    [~,motor_forces_5(:,i)] = QuadrotorControl(t5(i), stateVec5(i,:), Parameters, OpMode5,t_end_4);
end
for i=1:numel(t6)
    [~,motor_forces_6(:,i)] = QuadrotorControl(t6(i), stateVec6(i,:), Parameters, OpMode6,t_end_5);
end

%% Combining values and rgbPlotting

% Combining flight values
t_total = [t;t2;t3;t4;t5;t6];
stateVec_total = [stateVec;stateVec2;stateVec3;stateVec4;stateVec5;stateVec6];
motor_forces_control = [motor_forces_1,motor_forces_2,motor_forces_3,motor_forces_4,motor_forces_5,motor_forces_6];

% Plots
PlotAircraftSim(t_total', stateVec_total', motor_forces_control, Parameters.fig, Parameters.col)
% PlotAircraftSim(t2', stateVec2', motor_forces_2, Parameters.fig, Parameters.col)
>>>>>>> b0728ae1d54e5adb4bf8c50131c6769e49353d6b
=======
for i=1:numel(t4)
    [~,motor_forces_4(:,i)] = QuadrotorControl(t4(i), stateVec4(i,:), Parameters, OpMode4,t_end_3);
end
for i=1:numel(t5)
    [~,motor_forces_5(:,i)] = QuadrotorControl(t5(i), stateVec5(i,:), Parameters, OpMode5,t_end_4);
end
for i=1:numel(t6)
    [~,motor_forces_6(:,i)] = QuadrotorControl(t6(i), stateVec6(i,:), Parameters, OpMode6,t_end_5);
end

%% Combining values and rgbPlotting
>>>>>>> bnels

% Combining flight values
t_total = [t;t2;t3;t4;t5;t6];
stateVec_total = [stateVec;stateVec2;stateVec3;stateVec4;stateVec5;stateVec6];
motor_forces_control = [motor_forces_1,motor_forces_2,motor_forces_3,motor_forces_4,motor_forces_5,motor_forces_6];

% Plots
PlotAircraftSim(t_total', stateVec_total', motor_forces_control, Parameters.fig, Parameters.col)
% PlotAircraftSim(t2', stateVec2', motor_forces_2, Parameters.fig, Parameters.col)

