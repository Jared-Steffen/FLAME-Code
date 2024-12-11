function [Fc, Gc] = ControlFeedback(t,var, m, g,Op_Mode,t0)
<<<<<<< HEAD
<<<<<<< HEAD

=======
%% Init parameters
>>>>>>> b0728ae1d54e5adb4bf8c50131c6769e49353d6b
=======
%% Init parameters
>>>>>>> bnels
x = var(1);
y = var(2);
z = var(3);
phi = var(4);
theta = var(5);
psi = var(6);
u = var(7);
v = var(8);
w = var(9);
p = var(10);
q = var(11);
r = var(12);
Ix = 0.14862;   % [kg*m^2]
Iy = 0.17616;   % [kg*m^2]
Iz = 0.18792;   % [kg*m^2]

k1 =0.004;
<<<<<<< HEAD
<<<<<<< HEAD
k_up_outer = 0.01;    % Random k_up gain chosen
=======
k_up_outer = 0.1;    % Random k_up gain chosen
>>>>>>> b0728ae1d54e5adb4bf8c50131c6769e49353d6b
=======
k_up_outer = 0.1;    % Random k_up gain chosen
>>>>>>> bnels
%k_up_inner = 0.001;
k1_lon = 22*Iy;
k2_lon = 40*Iy;
%k3_lon = -1.001*10^-5;
k3_lon = -0.0135;
<<<<<<< HEAD
%k4_lon = 0.1751;

<<<<<<< HEAD
k3_lon = -1.001*10^-5;
=======
>>>>>>> bnels
%k4_lon = 0.1751;

% k1_lat = 22*Ix;
% k2_lat = 40*Ix;
k1_lat = 3.2696;
k2_lat = 5.9448;
k3_lat = 1.001*10^-5;
%k4_lat = 0.1751;

%% Mode statements

% Phase 1 Vertical
if Op_Mode == "Up"
<<<<<<< HEAD
    if t <= (t0 + 6)
        w_ref = 3; % Setting commanded speed to -2 meters (EVENT STOPS IT AT 10.5 m)
        Fc = [0;0;-m*g - m*k_up_outer*(w_ref - w)];  
=======
% k1_lat = 22*Ix;
% k2_lat = 40*Ix;
k1_lat = 3.2696;
k2_lat = 5.9448;
k3_lat = 1.001*10^-5;
%k4_lat = 0.1751;

%% Mode statements

% Phase 1 Vertical
if Op_Mode == "Up"
=======
>>>>>>> bnels
    if t <= (t0 + 4)
        w_ref = -9.5; % Setting commanded speed to -9.5 m/s (EVENT STOPS IT AT 10.5 m)
        Fc = [0;0;-m*g + m*k_up_outer*(w_ref - w)];  
        Lc = -k1_lat*p-k2_lat*phi;              
        Mc = -k1_lon*q-k2_lon*theta;            % Include rotational feedback
        Nc = -k1*r;
    elseif (t< (t0 + 6)) && (t> t0+4)

        w_ref = 10; % Setting commanded speed to 10 m/s (EVENT STOPS IT AT 10.5 m)
        Fc = [0;0;-m*g + m*k_up_outer*(w_ref - w)];  
<<<<<<< HEAD
>>>>>>> b0728ae1d54e5adb4bf8c50131c6769e49353d6b
=======
>>>>>>> bnels
        Lc = -k1_lat*p-k2_lat*phi;              
        Mc = -k1_lon*q-k2_lon*theta;            % Include rotational feedback
        Nc = -k1*r;

    else
<<<<<<< HEAD
<<<<<<< HEAD
        w_ref = 0; % Setting commanded height to 11 meters (EVENT STOPS IT AT 10.5 m)
        Fc = [0;0;-m*g - m*k_up_outer*(w_ref - w)];    % Steady hover weight + Control of where we want to be
=======
        w_ref = 0; % Setting commanded speed to 0 m/s (EVENT STOPS IT AT 10.5 m)
        Fc = [0;0;-m*g + m*(w_ref - w)];    % Steady hover weight + Control of where we want to be
>>>>>>> b0728ae1d54e5adb4bf8c50131c6769e49353d6b
=======
        w_ref = 0; % Setting commanded speed to 0 m/s (EVENT STOPS IT AT 10.5 m)
        Fc = [0;0;-m*g + m*(w_ref - w)];    % Steady hover weight + Control of where we want to be
>>>>>>> bnels
        Lc = -k1_lat*p-k2_lat*phi;              
        Mc = -k1_lon*q-k2_lon*theta;            % Include rotational feedback
        Nc = -k1*r;

    end
end

if Op_Mode == "Across"
    
<<<<<<< HEAD
<<<<<<< HEAD
    if t <= (t0 + 40)           % Set reference speed to 5 m/s for 20 seconds
=======
    if t <= (t0 + 50)   % Set reference speed to 5 m/s for 50 seconds
>>>>>>> bnels

        uref = 5;       % Setting reference speed [m/s]
        Fc = [0;0;-m*g];
        Lc = -k1_lat*p-k2_lat*phi;    
        Mc = -k1_lon*q-k2_lon*theta+k3_lon*(uref - u); % Longitudinal reference command
        Nc = -k1*r;

    elseif (t < (t0 + 64)) && (t > (t0 + 50))   % 14 seconds of decreasing currently velocity
        
        uref = -10;       % Setting reference speed [m/s]
        Fc = [0;0;-m*g];
        Lc = -k1_lat*p-k2_lat*phi;    
        Mc = -k1_lon*q-k2_lon*theta+k3_lon*(uref - u); % Longitudinal reference command
        Nc = -k1*r;

    else             % Set reference speed to 0 (assume movement has been achieved)
<<<<<<< HEAD
        uref = -1;
=======
    if t <= (t0 + 50)   % Set reference speed to 5 m/s for 50 seconds

        uref = 5;       % Setting reference speed [m/s]
        Fc = [0;0;-m*g];
        Lc = -k1_lat*p-k2_lat*phi;    
        Mc = -k1_lon*q-k2_lon*theta+k3_lon*(uref - u); % Longitudinal reference command
        Nc = -k1*r;

    elseif (t < (t0 + 64)) && (t > (t0 + 50))   % 14 seconds of decreasing currently velocity
        
        uref = -10;       % Setting reference speed [m/s]
        Fc = [0;0;-m*g];
        Lc = -k1_lat*p-k2_lat*phi;    
        Mc = -k1_lon*q-k2_lon*theta+k3_lon*(uref - u); % Longitudinal reference command
        Nc = -k1*r;

    else             % Set reference speed to 0 (assume movement has been achieved)
        uref = 0;
>>>>>>> b0728ae1d54e5adb4bf8c50131c6769e49353d6b
=======
        uref = 0;
>>>>>>> bnels
        Fc = [0;0;-m*g];
        Lc = -k1_lat*p-k2_lat*phi;    % Longitudinal reference command ends (revert to regular controls)
        Mc = -k1_lon*q-k2_lon*theta+k3_lon*(uref - u);
        Nc = -k1*r;
    
    end

    % y_ref = 55;     % Setting reference location [m] -- Event stops at 60 m
    % Fc = [0;0;-m*g];
    % Lc = -k1_lat*p-k2_lat*phi+k3_lat*(k4_lat*(y_ref - y) - v);    % Lateral reference command
    % Mc = -k1_lon*q-k2_lon*theta;
    % Nc = -k1*r;
    % Gc = [Lc;Mc;Nc];

end
if Op_Mode == "Down"
    
<<<<<<< HEAD
<<<<<<< HEAD
    if t <= (t0 + 2)
=======
 if t <= (t0 + 4)
        w_ref = 6; % Setting commanded speed to -9.5 m/s (EVENT STOPS IT AT 10.5 m)
        Fc = [0;0;-m*g + m*k_up_outer*(w_ref - w)];  
        Lc = -k1_lat*p-k2_lat*phi;              
        Mc = -k1_lon*q-k2_lon*theta;            % Include rotational feedback
        Nc = -k1*r;
    elseif (t< (t0 + 6)) && (t> t0+4)
>>>>>>> bnels

        w_ref = -2; % Setting commanded speed to 10 m/s (EVENT STOPS IT AT 10.5 m)
        Fc = [0;0;-m*g + m*k_up_outer*(w_ref - w)];  
        Lc = -k1_lat*p-k2_lat*phi;              
        Mc = -k1_lon*q-k2_lon*theta;            % Include rotational feedback
        Nc = -k1*r;

    else
        w_ref = 0; % Setting commanded speed to 0 m/s (EVENT STOPS IT AT 10.5 m)
        Fc = [0;0;-m*g + m*(w_ref - w)];    % Steady hover weight + Control of where we want to be
        Lc = -k1_lat*p-k2_lat*phi;              
        Mc = -k1_lon*q-k2_lon*theta;            % Include rotational feedback
        Nc = -k1*r;

    end

end

<<<<<<< HEAD
=======
 if t <= (t0 + 4)
        w_ref = 6; % Setting commanded speed to -9.5 m/s (EVENT STOPS IT AT 10.5 m)
        Fc = [0;0;-m*g + m*k_up_outer*(w_ref - w)];  
        Lc = -k1_lat*p-k2_lat*phi;              
        Mc = -k1_lon*q-k2_lon*theta;            % Include rotational feedback
        Nc = -k1*r;
    elseif (t< (t0 + 6)) && (t> t0+4)

        w_ref = -2; % Setting commanded speed to 10 m/s (EVENT STOPS IT AT 10.5 m)
        Fc = [0;0;-m*g + m*k_up_outer*(w_ref - w)];  
        Lc = -k1_lat*p-k2_lat*phi;              
        Mc = -k1_lon*q-k2_lon*theta;            % Include rotational feedback
        Nc = -k1*r;

    else
        w_ref = 0; % Setting commanded speed to 0 m/s (EVENT STOPS IT AT 10.5 m)
        Fc = [0;0;-m*g + m*(w_ref - w)];    % Steady hover weight + Control of where we want to be
        Lc = -k1_lat*p-k2_lat*phi;              
        Mc = -k1_lon*q-k2_lon*theta;            % Include rotational feedback
        Nc = -k1*r;

    end

end

=======
>>>>>>> bnels
if Op_Mode == "Back_Up"
    if t <= (t0 + 3.5)
        w_ref = -9.5; % Setting commanded speed to -9.5 m/s (EVENT STOPS IT AT 10.5 m)
        Fc = [0;0;-m*g + m*k_up_outer*(w_ref - w)];  
        Lc = -k1_lat*p-k2_lat*phi;              
        Mc = -k1_lon*q-k2_lon*theta;            % Include rotational feedback
        Nc = -k1*r;
    elseif (t< (t0 + 5)) && (t> t0+3.5)

        w_ref = 8; % Setting commanded speed to 10 m/s (EVENT STOPS IT AT 10.5 m)
        Fc = [0;0;-m*g + m*k_up_outer*(w_ref - w)];  
        Lc = -k1_lat*p-k2_lat*phi;              
        Mc = -k1_lon*q-k2_lon*theta;            % Include rotational feedback
        Nc = -k1*r;

    else
        w_ref = 0; % Setting commanded speed to 0 m/s (EVENT STOPS IT AT 10.5 m)
        Fc = [0;0;-m*g + m*(w_ref - w)];    % Steady hover weight + Control of where we want to be
        Lc = -k1_lat*p-k2_lat*phi;              
        Mc = -k1_lon*q-k2_lon*theta;            % Include rotational feedback
        Nc = -k1*r;

    end
end

if Op_Mode == "Back_Across"
    
    if t <= (t0 + 48.5)   % Set reference speed to 5 m/s for 48 seconds

        uref = -5;       % Setting reference speed [m/s]
        Fc = [0;0;-m*g];
        Lc = -k1_lat*p-k2_lat*phi;    
        Mc = -k1_lon*q-k2_lon*theta+k3_lon*(uref - u); % Longitudinal reference command
        Nc = -k1*r;

    elseif (t < (t0 + 62)) && (t > (t0 + 48.5))   % 14 seconds of decreasing currently velocity
        
        uref = 10;       % Setting reference speed [m/s]
        Fc = [0;0;-m*g];
        Lc = -k1_lat*p-k2_lat*phi;    
        Mc = -k1_lon*q-k2_lon*theta+k3_lon*(uref - u); % Longitudinal reference command
        Nc = -k1*r;

    else             % Set reference speed to 0 (assume movement has been achieved)
        uref = 0;
        Fc = [0;0;-m*g];
        Lc = -k1_lat*p-k2_lat*phi;    % Longitudinal reference command ends (revert to regular controls)
        Mc = -k1_lon*q-k2_lon*theta+k3_lon*(uref - u);
        Nc = -k1*r;
    
    end
end

if Op_Mode == "Back_Down"
    
 if t <= (t0 + 4.75)
        w_ref = 6; % Setting commanded speed to -9.5 m/s (EVENT STOPS IT AT 10.5 m)
        Fc = [0;0;-m*g + m*k_up_outer*(w_ref - w)];  
        Lc = -k1_lat*p-k2_lat*phi;              
        Mc = -k1_lon*q-k2_lon*theta;            % Include rotational feedback
        Nc = -k1*r;
    elseif (t< (t0 + 6.5)) && (t> t0+4.75)

        w_ref = -2.5; % Setting commanded speed to 10 m/s (EVENT STOPS IT AT 10.5 m)
        Fc = [0;0;-m*g + m*k_up_outer*(w_ref - w)];  
        Lc = -k1_lat*p-k2_lat*phi;              
        Mc = -k1_lon*q-k2_lon*theta;            % Include rotational feedback
        Nc = -k1*r;

    else
        w_ref = 0; % Setting commanded speed to 0 m/s (EVENT STOPS IT AT 10.5 m)
        Fc = [0;0;-m*g + m*(w_ref - w)];    % Steady hover weight + Control of where we want to be
        Lc = -k1_lat*p-k2_lat*phi;              
        Mc = -k1_lon*q-k2_lon*theta;            % Include rotational feedback
        Nc = -k1*r;

    end
<<<<<<< HEAD
>>>>>>> b0728ae1d54e5adb4bf8c50131c6769e49353d6b
=======
>>>>>>> bnels

end

%fprintf("\n Mode is currently: %s", Op_Mode)

Gc = [Lc;Mc;Nc];
end