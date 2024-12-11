function Parameters = Get_Paramters()

Ix = 0.14862;   % [kg*m^2]
Iy = 0.17616;   % [kg*m^2]
Iz = 0.18792;   % [kg*m^2]

Parameters.m = 10;      % mass [kg]
Parameters.g = 9.81;    % [m/s^2]
Parameters.d = 0.060;   % distance of arm
Parameters.km = 0.0024;            % Yaw rotation constant
Parameters.nu = 1*10^-3;
Parameters.mu = 2*10^-6;
Parameters.d = 0.48;    % distance of arm [m]
Parameters.km = 0.0024; % Yaw rotation constant (CURRENTLY DO NOT KNOW)
Parameters.nu = 5*10^-3;
Parameters.mu = 2*10^-6;    % CURRENTLY DO NOT KNOW
Parameters.I = [Ix; Iy; Iz];    % Inertia matrix
Parameters.fig = 1:6;   % Fig vec for PlotAircraftSim function
Parameters.col = "b-";  % color def for PlotAircraftSim function
Parameters.col2 = "r-";

end