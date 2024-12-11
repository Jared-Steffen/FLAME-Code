function PlotAircraftSim(time, aircraft_state_array, control_input_array, fig, col)
figure(fig(1))
subplot(311)
plot(time,aircraft_state_array(1,:),col); hold on;
title("X position")
subplot(312);
plot(time,aircraft_state_array(2,:),col); hold on;
title("Y position")
subplot(313)
plot(time,aircraft_state_array(3,:),col); hold on;
title("Z position")
sgtitle("Positions")
legend('Uncontrolled','Controlled')

figure(fig(2))
subplot(311)
plot(time,aircraft_state_array(4,:),col); hold on;
subplot(312);
plot(time,aircraft_state_array(5,:),col); hold on;
subplot(313)
plot(time,aircraft_state_array(6,:),col); hold on;
sgtitle("Euler Angles")
legend('Uncontrolled','Controlled')

figure(fig(3))
subplot(311)
plot(time,aircraft_state_array(7,:),col); hold on;
subplot(312);
plot(time,aircraft_state_array(8,:),col); hold on;
subplot(313)
plot(time,aircraft_state_array(9,:),col); hold on;
sgtitle("Velocities")
legend('Uncontrolled','Controlled')

figure(fig(4))
subplot(311)
plot(time,aircraft_state_array(10,:),col); hold on;
subplot(312);
plot(time,aircraft_state_array(11,:),col); hold on;
subplot(313)
plot(time,aircraft_state_array(12,:),col); hold on;
sgtitle("Angular Velocities")
legend('Uncontrolled','Controlled')

figure(fig(5))
subplot(411)
plot(time,control_input_array(1,:),col); hold on;
title("f 1")
subplot(412);
plot(time,control_input_array(2,:),col); hold on;
title("f 2")
subplot(413)
plot(time,control_input_array(3,:),col); hold on;
title("f 3")
subplot(414)
plot(time,control_input_array(4,:),col); hold on;
title("f 4")
sgtitle("Motor Forces")
legend('Uncontrolled','Controlled')

figure(fig(6))
plot3(aircraft_state_array(1,:),aircraft_state_array(2,:),-(aircraft_state_array(3,:)));hold on;
plot3(aircraft_state_array(1,1),aircraft_state_array(2,1),-(aircraft_state_array(3,1)),"og");
plot3(aircraft_state_array(1,end),aircraft_state_array(2,end),-(aircraft_state_array(3,end)),"or");
legend('Path','Start','Stop')
%zlim([0 10])
sgtitle("Path")
xlabel('Xpos')
ylabel('Ypos')
zlabel('Zpos')
legend('Uncontrolled','start','end','Controlled','Start','End')

end