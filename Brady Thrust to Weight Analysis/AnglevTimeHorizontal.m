clc;
close all;
clear all;

m = 10; %kg
d = 100; %m
g = 9.8; %m/s^2
t = 6:0.1:30; %s

theta = rad2deg(atan(2*d./(g.*t.^2)));

figure(1)
plot(t, theta)
title('Theta vs. Time to Complete 100m Horizontal Trip')
xlabel('Time to complete horizontal translation (s)')
ylabel('Theta (degrees)')

thetamax = max(theta); %max theta
Fxmax = g*tand(thetamax); %max x force

vmax = sqrt(2*d*(2*d/(min(t))^2)); %max velocity for max tilt angle
wind = 15 * 0.447; %mph -> m/s
vax_effective = vmax - wind;
nu = Fxmax/vmax^2; %drag coeff

vterminal = sqrt(tand(theta).*g/nu); %maximum velocity
wind = 15 * 0.447; %mph -> m/s
vterminal_effective = vterminal - wind;
T = (m*g - nu.*vterminal)./cosd(theta); %N

figure(2)
TtW = T./(m*g);
plot(t, TtW)
title('Thrust to Weight Ratio vs. Time to Complete 100m Horizontal Trip')
ylabel('T/W')
xlabel('Time to Translate Horizontally [s]')

