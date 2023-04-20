function plotsim(Vt, time_t)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

    subplot(2,2,1)
    plot(time_t, Vt(1,:), linewidth=2)
    title('Displacement v. Time')
    xlabel('Time (s)')
    ylabel('Displacement (m)')
    
    subplot(2,2,3)
    plot(time_t, Vt(2,:), linewidth=2)
    title('velocity v. time')
    xlabel('Time (s)')
    ylabel('Velocity (m/s)')

    subplot(2,2,2)
    %polarscatter( Vt(3,:), time_t,[], time_t)
    polarscatter( Vt(3,:), Vt(1,:),[], time_t)
    set(gca,'ThetaZeroLocation', 'top')
    title('Angular Displacement v. Time')
    colorbar();

    
    subplot(2,2,4)
    plot(time_t, Vt(4,:), linewidth=2)
    title('Angular Velocity v. Time')
    xlabel('Time (s)')
    ylabel('Radians/second')
end