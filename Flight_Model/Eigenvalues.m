clc; clear all; close all;

Ix = 5.8*10^-5;
Iy = 7.2*10^-5; % constants
Iz = 1*10^-4;
g = 9.81;
m = 0.068;

k1_x = 22*Ix; % previous gain values
k2_x = 40*Ix;

% Ix = 5.8*10^-5;
% Iy = 7.2*10^-5; % constants
% Iz = 1*10^-4;

Ix = 0.14862;   % [kg*m^2]
Iy = 0.17616;   % [kg*m^2]
Iz = 0.18792;   % [kg*m^2]

g = 9.81;
m = 0.068;

% Ix = 5.8*10^-5;
% Iy = 7.2*10^-5; % constants
% Iz = 1*10^-4;

Ix = 0.14862;   % [kg*m^2]
Iy = 0.17616;   % [kg*m^2]
Iz = 0.18792;   % [kg*m^2]

g = 9.81;
m = 0.068;

>>>>>>> bnels
% k1_x = 22*Ix; % previous gain values
% k2_x = 40*Ix;

k1_x = 3.26964; % New gain values
k2_x = 5.9448;

k1_y = 22*Iy; % previous gain values
k2_y = 40*Iy;

natural_freq_x = sqrt(k2_x/Ix);
damping_ratio_x = k1_x/(2*sqrt(k2_x*Ix));

natural_freq_y = sqrt(k2_y/Iy);
damping_ratio_y = k1_y/(2*sqrt(k2_y*Iy));

% outer loop design Lateral (k4)
Time_constant_minimum_x = 10*2*pi/(natural_freq_x*damping_ratio_x);
k4_x = 1/Time_constant_minimum_x;

% outer loop design Longitudianl (k4)
Time_constant_minimum_y = 10*2*pi/(natural_freq_y*damping_ratio_y);
k4_y = 1/Time_constant_minimum_y;

% K4 - Vertical
k4_up = 0.001;

% Design for k3 velocity gains
<<<<<<< HEAD
<<<<<<< HEAD
k3 = linspace(-0.01,0.01,1000); % array of possible k3 values
=======
k3 = linspace(-1,1,6000); % array of possible k3 values
>>>>>>> b0728ae1d54e5adb4bf8c50131c6769e49353d6b
=======
k3 = linspace(-1,1,6000); % array of possible k3 values
>>>>>>> bnels


for i=1:length(k3)

 Amat = [
    0 1 0 0;
    0 0 g 0;            % Lateral Model
    0 0 0 1;        
    -k3(i)*k4_x/Ix -k3(i)/Ix -k2_x/Ix -k1_x/Ix
];

%  Amat = [
%     0 1 0 0;
%     0 0 g 0;            % Lateral Model
%     0 0 0 1;        
%     -k3(i)/Ix -k3(i)/Ix -k2_x/Ix -k1_x/Ix
% ];

%  Amat = [
%     0 1 0 0;
%     0 0 g 0;            % Lateral Model
%     0 0 0 1;        
%     -k3(i)/Ix -k3(i)/Ix -k2_x/Ix -k1_x/Ix
% ];

  Amat = [
    0 1 0 0;
    0 0 -g 0;            % Longitudinal Model
    0 0 0 1;        
    -k3(i)/Iy -k3(i)/Iy -k2_y/Iy -k1_y/Iy
];


    % Amat = [            % k3 is outer
    % 0 1;
    % -m*k3(i)*k4_up -m*k3(i) % k4 is inner
% ];

Evals(:,i) = eig(Amat);

end

figure(1)
subplot(4,1,1)
scatter(real(Evals(1,:)),imag(Evals(1,:)))
subplot(4,1,2)
scatter(real(Evals(2,:)),imag(Evals(2,:)))      % Plotting real and imaginary values
subplot(4,1,3)                                  % Need negative real eigenvalues with 0 imaginary component (hard damped)
scatter(real(Evals(3,:)),imag(Evals(3,:)))      % Can use imaginary component eigenvalues (oscillations)
subplot(4,1,4)
scatter(real(Evals(4,:)),imag(Evals(4,:)))

imaginary = imag(Evals);        % Helps to look at which index we should find our k3
realq = real(Evals);

% Note: Used k3 value at index 495 for Longitudinal Model and 506 for
% Lateral Model
