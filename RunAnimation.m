time_t = [0:0.0001:20];
IP = InvertedPendulum();
V0 = [0;0; 0.175;0]; % initial bar tilt 10 degrees
%V0 = [0;0; 0;0];
Force =5;
Q = [1 0 0 0;
     0 0 0 0;
     0 0 1 0;
     0 0 0 0];
R=1;
N = [1;0;0;0];

sr = IP.euler_method(V0, 25, time=time_t, lqr=false, ...
    Q=Q,N=N,R=R, description='Force=5 N');
sr.animate()