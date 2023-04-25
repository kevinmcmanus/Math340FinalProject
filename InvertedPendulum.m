classdef InvertedPendulum
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here

    properties
        M % Cart Mass
        m % bar mass
        b % cart friction
        l % bar half-length
        I % bar mass moment of inertia
        g % grav acceleration, don't change this
        A % coefficient matrix
        B % constant matrix
    end

    methods
        function obj = InvertedPendulum(params)
            arguments
                % default parameters
                params.M = 0.5; % kg
                params.m = 0.2 % kg
                params.b = 0.1 % N per m/s ??
                params.I = 0.006 % shouldn't this be calculated?
                params.l = 0.3 % m
            end
            %UNTITLED Construct an instance of this class
            %   Detailed explanation goes here
            obj.M = params.M;
            obj.m = params.m;
            obj.b = params.b;
            obj.I = params.I;
            obj.l = params.l;
            obj.g = 9.8; % m/s^2

            %calculate the coef matrix:
            d = obj.I*(obj.M + obj.m) + obj.M*obj.m*obj.l^2;
            obj.A = [0, 1, 0,  0;
                0, -(obj.I+obj.m*obj.l^2)*obj.b/d, -(obj.m^2*obj.g*obj.l^2)/d, 0;
                0, 0, 0, 1;
                0, -obj.m*obj.l*obj.b/d, obj.m*obj.g*obj.l*(obj.M+obj.m)/d, 0
                ];
            % constant (col) vector
            obj.B = [0; (obj.I+obj.m*obj.l^2)/d; 0; obj.m*obj.l/d];
        end

        function simres = euler_method(obj, V0, F, options)
            % computes V(t), given initial conditions and force
            % using Euler's method.

            arguments
                obj InvertedPendulum
                V0(4,1) double {mustBeNumeric}% initial conditions
                F double % force
                options.time = [0:0.01:3]
                options.lqr = false;
                %lqr parameters
                options.R =  1
                options.Q = eye(4)
                options.N = [1; 0; 0; 0]
                options.description = 'Simulation'
                options.negatePhiPrime = false
            end
            nsteps = size(options.time,2);
            time_t = options.time;

            %constant vector:
            u = F;

            %initialize output arrays
            Vt = zeros(size(V0,1), nsteps);
            Vt(:,1) = V0;
            % incremental cost
            dC = zeros(1, nsteps);
            ut = zeros(1, nsteps);
            ut(1) = u;

            if options.lqr
                Q = options.Q; R=options.R; N=options.N;
                [K, s, p] = lqr(obj.A, obj.B, Q, R, N);
            end

            A = obj.A;
            if options.negatePhiPrime
                A(3,:) = -1*A(3,:);
            end

            %update the output for each time step
            thisV = Vt(:,1); %state vec for current time step
            for i = 2:nsteps
                % previous state vector
                lastV = thisV;
                ut(i) = u;

                % calc the derivative col vector and the new state
                Bu = obj.B*u;
                dV = A*lastV + Bu;
                dt = time_t(i) - time_t(i-1);
                thisV = lastV + dV*dt;

                % update the output for the current time step
                Vt(:,i) = thisV;

                %update the cost and control vectors
                if options.lqr
                    dC(i) = thisV'*Q*thisV + u*u*R + 2.*(thisV'*N*u);
                    u = -K*thisV;
                end
            end
            simres = SimResult(Vt, dC, time_t,F,ut, options.description);
        end
        function cf = critical_force(obj,V0)
            cf = [ obj.A(1,:)*V0/obj.B(1,1);
                   obj.A(2,:)*V0/obj.B(2,1);
                   obj.A(3,:)*V0/obj.B(3,1);
                   obj.A(4,:)*V0/obj.B(4,1)];
        end

        function simres = nonlinear_method(obj, V0, F, options)
            arguments
                obj InvertedPendulum
                V0(4,1) double {mustBeNumeric}% initial conditions
                F double % force
                options.time = [0:0.01:3]

                options.description = 'Simulation'
                options.negatePhiPrime = false
            end

            nsteps = size(options.time,2);
            time_t = options.time;

            % get model properties into local variables
            M = obj.M; m = obj.m; l = obj.l; g=obj.g; I = obj.I;b=obj.b;

            Vt = zeros(size(V0,1), nsteps);
            thisV = V0;
            thisV(3) = pi+thisV(3); % convert to theta from phi
            Vt(:,1) = thisV;
            dC = zeros(size(V0,1),nsteps);
            ut = zeros(size(V0,1),nsteps);

            for i = 2:nsteps
                % state variables from last time step
                lastV = thisV;
                x = lastV(1,1); xprime = lastV(2,1);
                theta = lastV(3,1); thetaprime = lastV(4,1);

                dt = time_t(i) - time_t(i-1);

                %compute derivative:

                A = M + m;
                B = m*l*cos(theta);
                C = m*l*cos(theta);
                D = I + m*l^2;
                S = m*l*thetaprime^2*sin(theta)-b*xprime+F;
                T = -m*g*l*sin(theta);

                dV = [xprime;             ...
                     (S*D-B*T)/(A*D-B*C); ...
                     thetaprime;          ...
                     (A*T-C*S)/(A*D-B*C)];

                %update the state
                thisV = lastV +dV*dt;
                Vt(:,i) = thisV;
            end

            %convert theta back to phi
            Vt(3,:) = Vt(3,:) - pi;

            simres = SimResult(Vt, dC, time_t,F,ut, options.description);
        end

                
    end
end