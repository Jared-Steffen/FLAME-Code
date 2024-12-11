function [var_dot, motor_forces_control] = QuadrotorControl(t, var, Parameters,OpMode,t0)%UNTITLED Summary of this function goes here
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
    Ix = Parameters.I(1);
    Iy = Parameters.I(2);
    Iz = Parameters.I(3);
    d = Parameters.d;
    km = Parameters.km;
    m = Parameters.m;
    g = Parameters.g;
    mu = Parameters.mu;
    nu = Parameters.nu;

    [Fc, Gc] = ControlFeedback(t,var,m,g,OpMode,t0);
    motor_forces_control = ComputeMotorForces(Fc,Gc,d,km);


    Va = norm([u v w]);
    aero_moments = -mu*norm([p q r]).*[ p; q; r];
    L = aero_moments(1);
    M = aero_moments(2);
    N = aero_moments(3);
    aero_forces = -nu*Va.*[u;v;w];
    Lc = Gc(1);
    Mc = Gc(2);
    Nc = Gc(3);
    Zc = Fc(3);

    posdot = RotationMatrix321([phi,theta,psi])'*[u;v;w];
    angledot = [1 sin(phi)*tan(theta) cos(phi)*tan(theta);0 cos(phi) -sin(phi);0 sin(phi)*sec(theta) cos(phi)*sec(theta)]*[p;q;r];
    veldot = [r*v-q*w;p*w-r*u;q*u-p*v]+g.*[-sin(theta);cos(theta)*sin(phi);cos(theta)*cos(phi)]+1/m.*aero_forces+1/m*[0;0;Zc];
    angularveldot = [(Iy-Ix)/Ix*q*r;(Iz-Ix)/Iy*p*r;(Ix-Iy)/Iz*p*q]+[1/Ix*L; 1/Iy*M; 1/Iz*N]+[1/Ix*Lc; 1/Iy*Mc; 1/Iz*Nc];
    var_dot = [posdot;angledot;veldot;angularveldot];
end