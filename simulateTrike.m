
function [time, stocks] = simulateTrike(D, initial_angle, xDotDot)
    close all;
    mass = 100; % kg
    time_limit = 10; % seconds
    g = 9.8; % m/s^2
    I = (1/12) * mass * (2*D)^2;
    beta = 0.05;

    options = odeset('Events', @events);
    
    [time, stocks] = ode45(@netFlow, [0, time_limit], [initial_angle; 0], options);
    
    
    function flows = netFlow(t, stocks)
        theta = stocks(1);
        thetaDot = stocks(2);
        theta_flow = thetaDot;
        thetaDot_flow = (xDotDot(t,theta,thetaDot)*sin(theta) - g * cos(theta) - beta * thetaDot)/((I/mass*D) + D);
        flows = [theta_flow; thetaDot_flow];
    end

    function [value,isterminal,direction] = events(~,stocks)
        value = sin(stocks(1));
        isterminal = 1;
        direction = 0;
    end
end
