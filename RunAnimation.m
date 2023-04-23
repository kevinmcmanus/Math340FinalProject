time_t = [0:0.005:10];
IP = InvertedPendulum();
%V0 = [0;0; 0.175;0]; % initial bar tilt 10 degrees
V0 = [0;0; 0;0];
Force =5;
Q = [1 0 0 0;
     0 0 0 0;
     0 0 1 0;
     0 0 0 0];
R=1;
N = [1;0;0;0];

sr = IP.euler_method(V0, 350, time=time_t, lqr=true, Q=Q,N=N,R=R);

sr.plotX;

sr2 = IP.euler_method(V0, 0.0, time=time_t, lqr=true, Q=Q,N=N,R=R);
hold on
sr2.plotX
hold off
legend()
% figure(Name='With lqr')
% sr.animate()