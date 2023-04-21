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
            obj.A = [0 1 0 0;
                0 -(obj.I+obj.m*obj.l^2)*obj.b/d -(obj.m^2*obj.g*obj.l^2)/d 0;
                0 0 0 1;
                0 -obj.m*obj.l*obj.b/d obj.m*obj.g*obj.l*(obj.M+obj.m)/d 0
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
                options.R = 1; % eye(4)
                options.Q = [1 0 0 0; 0 0 0 0; 0 0 1 0; 0 0 0 0]
                options.N = 0.0 %zeros(4,1)
            end
            nsteps = size(options.time,2);
            time_t = options.time;

            %constant vector:
            Bu = obj.B * F;

            %initialize output arrays
            Vt = zeros(size(V0,1), nsteps);
            Vt(:,1) = V0;
            % incremental cost
            dC = zeros(1, nsteps);

            if options.lqr
                Q = options.Q; R=options.R; N=options.N;
                [K, s, p] = lqr(obj.A, Bu, Q, R, N);
            end

            %update the output for each time step
            thisV = Vt(:,1); %state vec for current time step
            for i = 2:nsteps
                % previous state vector
                lastV = thisV;

                % calc the derivative col vector and the new state
                dV = obj.A*lastV + Bu;
                dt = time_t(i) - time_t(i-1);
                thisV = lastV + dV*dt;

                % update the output for the current time step
                Vt(:,i) = thisV;

                %update the cost and control vectors
                if options.lqr
                    dC(i) = thisV'*Q*thisV + Bu'*R*Bu + 2.*(thisV'*N*Bu);
                    u = -K*thisV;
                    Bu = obj.B*u;
                end
            end
            simres = SimResult(Vt, dC, time_t);
        end
    end
end