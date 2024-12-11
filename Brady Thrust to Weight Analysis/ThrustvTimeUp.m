clc;
close all;
clear all;

m = 10; %kg
h = 9.144; %m
g = 9.81; %m/s^2

t = 1.5:0.1:100; %s
a = 2*h./(t.^2);

T = m*g + m.*a;
Fmax = max(T) - m*g;
vmax = sqrt(2*h*(2*h./t.^2)); %max velocity for max tilt angle
nu = Fmax / (max(vmax))^2;
Tnew = m*g + m.*a + nu.*vmax.^2;

TtW = Tnew./(m*g);

plot(t, TtW)
title('Thrust to Weight Ratio vs. Time to Complete Trip to 30 Foot Hard Deck')
ylabel('T/W')
xlabel('Time to complete vertical translation (s)')

