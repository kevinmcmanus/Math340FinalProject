time_t = [0:0.001:10];
IP = InvertedPendulum();
%V0 = [0;0; -0.175;0]; % initial bar tilt 10 degrees
V0 = [0;0; -0.175;0];
Force = 2.0;
figure(Name='With lqr')
sr = IP.euler_method(V0, Force, time=time_t, lqr=true);
sr.animate()