time_t = [0:0.001:20];
IP = InvertedPendulum();
%V0 = [0;0; -0.175;0]; % initial bar tilt 10 degrees
V0 = [0;0; -0.175;0];
Force = 2.5;

% figure(Name='No lqr')
% nc = IP.euler_method(V0, Force, time=time_t, lqr=false);
% 
% plotsim(nc.Vt, time_t)

figure(Name='With lqr')
sr = IP.euler_method(V0, Force, time=time_t, lqr=true);

plotsim(sr.Vt, time_t)