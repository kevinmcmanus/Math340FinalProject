classdef SimResult
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here

    properties
        Vt
        dC
        time_t
        force
        ut
        description
    end

    methods
        function obj = SimResult(Vt,dC, time_t,force,ut,description)
            %UNTITLED3 Construct an instance of this class
            %   Detailed explanation goes here
            obj.Vt = Vt;
            obj.time_t = time_t;
            obj.dC = dC;
            obj.force=force;
            obj.ut = ut;
            obj.description = description;
        end

        function plotX(obj)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            plot(obj.time_t, obj.Vt(1,:), LineWidth=2, ...
                DisplayName=obj.description)
            yline(0,HandleVisibility="off");
            title('Displacement v. Time')
            xlabel('Time (s)')
            ylabel('Displacement (m)')
        end

        function plotF(obj)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            plot(obj.time_t, obj.ut, LineWidth=2, ...
                DisplayName=obj.description)
            title('Effective Force v. Time')
            yline(0,HandleVisibility="off");
            xlabel('Time (s)')
            ylabel('Force (N)')
        end

        function plotdC(obj, options)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            arguments
                obj SimResult
                options.cumulative=false;
            end
            if options.cumulative
                c = cumsum(obj.dC);
                titlestr = 'Cumulative Cost v. Time';
                plot(obj.time_t, c, LineWidth=2, ...
                    DisplayName=obj.description)
            else
                titlestr = 'Incremental Cost v. Time';
                c = obj.dC;
                semilogy(obj.time_t, c, LineWidth=2, ...
                    DisplayName=obj.description)
            end

            title(titlestr)
            xlabel('Time (s)')
            ylabel('Cost')
        end

        function plotXdX(obj, options)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            arguments
                obj SimResult;
                options.colorbar=true
            end

            scatter( obj.Vt(1,:), obj.Vt(2,:),[], obj.time_t, "filled", ...
                SizeData = 5);
            if options.colorbar
                cb=colorbar();
                cb.Label.String = 'Parameter t';
                cb.Label.FontSize = 12;
                %cb.Label.FontWeight="bold";
                cb.Label.Rotation = -90;
                cb.Label.VerticalAlignment="bottom";
            end
            title('Velocity v. Displacement');
            subtitle(obj.description);
            xlabel('Displacement (m)')
            ylabel('Velocity (m/s)')
        end

        function animate(obj, options)
            arguments
                obj SimResult
                options.xlim = [-8 8];
            end
            Vt = obj.Vt;

            cartl = 3;     % length of the cart
            carth = 1;     % height of the cart

            barl = 6.0;    % length of the bar
            ballr = 0.5;   % radius of the ball at the end of the bar

            % initial cart and pendulum
            % 
            x = Vt(1,1);
            cart  = rectangle('Position',[x-0.5*cartl -0.5*carth cartl carth],'Curvature',0.2,'FaceColor','k','EdgeColor','k');
            axis equal;
            xlim([options.xlim]);
            ylim([-8 8]);
         
            hold on;
            %get the x, y positons of the bar end
            barends = [obj.Vt(1,:)+barl*sin(Vt(3,:)); barl*cos(Vt(3,:)) ];

            bar  = plot([Vt(1,1) barends(1,1)], [0, barends(2,1)], ...
                'Linewidth',4,'Color','b');
            angle = 0.1;
            avar  = 0.5*pi-angle;

            ball  = rectangle('Position', ...
                [x+barl*cos(avar)-ballr barl*sin(avar)-ballr 2*ballr 2*ballr], ...
                'Curvature',[1 1],'FaceColor','b','EdgeColor','b');

            N = size(obj.time_t,2);
            for n=1:N
                delete(cart); delete(bar); delete(ball);

                % update position of the cart and the angle of the pendulum
                x = Vt(1,n);
                %angle = mangle*sin(n*dt);
                angle = Vt(3,n);
                avar  = 0.5*pi-angle;

                
                % redraw cart and pendulum
                cart  = rectangle('Position',[x-0.5*cartl -0.5*carth cartl carth],'Curvature',0.2,'FaceColor','k','EdgeColor','k');
                bar  = plot([x barends(1,n)],[0 barends(2,n)],'Linewidth',4,'Color','b');
                ball  = rectangle('Position',[x+barl*cos(avar)-ballr barl*sin(avar)-ballr 2*ballr 2*ballr],'Curvature',[1 1],'FaceColor','b','EdgeColor','b');

                if mod(n, 10)==0
                    pause(0.01);
                    title(sprintf('Time: %f', obj.time_t(n)));
                end
            end
        end

    end
end