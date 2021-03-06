%animateTrike.m
function animateTrike()
    clear all;
    initial_angle = (pi/4); % radians
    D = 0.5; % meters
    [time, stocks] = simulateTrike(D, initial_angle, @inputFunction);

    new_timesteps = linspace(time(1), time(end), 200);
    % Linearly interpolate points so that our theta values are evenly spaced in
    % time
    thetas = interp1(time, stocks(:,1), new_timesteps);
    thetaDots = interp1(time, stocks(:,2), new_timesteps);

    xDotDot = inputFunction(new_timesteps, thetas, thetaDots);
    xDot = cumtrapz(new_timesteps, xDotDot);
    x = cumtrapz(new_timesteps, xDot);

    x_pivot = x;
    y_pivot = zeros(size(x));
    x_com = x + D.*cos(thetas);
    y_com = D.*sin(thetas);
    figure;
    min_x = min([x_pivot, x_com]);
    max_x = max([x_pivot, x_com]);
    min_y = min([y_pivot, y_com]);
    max_y = max([y_pivot, y_com]);
    
     plot(new_timesteps, xDot);

    loops = numel(thetas);
%     panningView(loops, x_pivot, x_com, y_pivot, y_com, min_y, max_y, D, thetas, initial_angle)
%     stationaryView(loops, x_pivot, x_com, y_pivot, y_com, min_y, max_y, min_x, max_x, D)

end

function xDotDot = inputFunction(t, theta, thetaDot)
    a = 17;
    b = 0;
    xDotDot = t.^0 .* a .* ((pi/2) - theta) - b.*thetaDot;
end

function panningView(loops, x_pivot, x_com, y_pivot, y_com, min_y, max_y, D, thetas, initial_angle)
    F(loops) = struct('cdata',[],'colormap',[]);
    for j = 1:loops
        clf
        Xs = [x_pivot(j); x_com(j)];
        Ys = [y_pivot(j); y_com(j)];
        drawRider(D, thetas(j) - initial_angle, x_pivot(j), 0);
        xlim([x_pivot(j) - D * 1, x_pivot(j) + D * 3])
        ylim([0, 2*D])
        drawnow
        F(j) = getframe;
        
    end
end

function stationaryView(loops, x_pivot, x_com, y_pivot, y_com, min_y, max_y, min_x, max_x, D)
    F(loops) = struct('cdata',[],'colormap',[]);
    for j = 1:loops

        Xs = [x_pivot(j); x_com(j)];
        Ys = [y_pivot(j); y_com(j)];
        plot(Xs, Ys, 'o', Xs, Ys);
        axis equal
        xlim([min_x - D * 2, max_x + D * 2])
        ylim([min_y, max_y])
        drawnow
        F(j) = getframe;
    end
end

function drawRider(D, angle, x, y)
    hold on;
    unitHeight = D * sin(pi/4);
    unitLength = D * cos(pi/4);
    
    % Draw line to COM
    COM_x = [0, 1];
    COM_y = [0, 1];

    % Points on Bike
    back_hub_x = 0;
    back_hub_y = 1/3;
    front_hub_x = 2;
    front_hub_y = 1/3;
    [back_wheel_xs, back_wheel_ys] = getCircle(back_hub_x, back_hub_y, (1/3));
    [front_wheel_xs, front_wheel_ys] = getCircle(front_hub_x, front_hub_y, (1/3));
    
    [new_back_wheel_xs, new_back_wheel_ys] = rotate(back_wheel_xs, back_wheel_ys, angle);
    
    %Find the point that is touching the ground;
    [pivot_y, pivot_index] = min(new_back_wheel_ys);
    pivot_x = new_back_wheel_xs(pivot_index);
    
    crank_x = 0.9;
    crank_y = (1/3)*1.5;
    seat_stay_x = 0.8;
    seat_stay_y = (2/3)*1.2;
    seat_tube_angle = (seat_stay_y - crank_y)/(seat_stay_x - crank_x);
    seat_tube_x = 0.725;
    seat_tube_y = (seat_tube_x - seat_stay_x)*seat_tube_angle + seat_stay_y;
    seat_start_x = 0.6;
    seat_start_y = seat_tube_y;
    seat_end_x = 0.85;
    seat_end_y = seat_tube_y;
    down_tube_x = 1.8;
    down_tube_y = 0.9;
    fork_angle = (front_hub_y - down_tube_y)/(front_hub_x - down_tube_x);
    fork_x = 1.7;
    fork_y = (fork_x - down_tube_x)*fork_angle + down_tube_y;
    top_tube_x = 1.775;
    top_tube_y = (top_tube_x - down_tube_x)*fork_angle + down_tube_y;
    handle_x = 1.4;
    handle_y = fork_y + 0.1;
    
    % Points on Human
    foot_x = 0.9;
    foot_y = 1/3;
    knee_x = 1;
    knee_y = 2/3;
    hip_x = 0.85;
    hip_y = 1.1;
    neck_x = 1.1;
    neck_y = 1.9;
    back_angle = (neck_y - hip_y)/(neck_x - hip_x);
    shoulder_x = 1;
    shoulder_y = (shoulder_x - hip_x)*back_angle + hip_y;
    
    
    % Draw line to COM
%     plotRotated(COM_x, COM_y, angle, x, y);

    % Plot Wheels
    plotRotated(back_wheel_xs, back_wheel_ys, angle, x, y);
    plotRotated(front_wheel_xs, front_wheel_ys, angle, x, y);

    % Chain Stay
    plotRotated([0, crank_x], [(1/3), crank_y], angle, x, y);
    
    % Seat Stay
    plotRotated([0, seat_stay_x], [(1/3), seat_stay_y], angle, x, y); 
    
    % Seat Tube
    plotRotated([seat_tube_x, crank_x], [seat_tube_y, crank_y], angle, x, y);
    
    % Seat
    plotRotated([seat_start_x, seat_end_x], [seat_start_y, seat_end_y], angle, x, y);
    
    % Down Tube
    plotRotated([crank_x, down_tube_x], [crank_y, down_tube_y], angle, x, y);
    
    % Fork
    plotRotated([front_hub_x, fork_x], [front_hub_y, fork_y], angle, x, y);
    
    % Handle
    plotRotated([fork_x, handle_x], [fork_y, handle_y], angle, x, y);
    
    % Top Tube
    plotRotated([seat_stay_x, top_tube_x], [seat_stay_y, top_tube_y], angle, x, y);
    
    % Calf
    plotRotated([foot_x, knee_x], [foot_y, knee_y], angle, x, y);
    
    % Thigh
    plotRotated([knee_x, hip_x], [knee_y, hip_y], angle, x, y);
    
    % Back
    plotRotated([hip_x, neck_x], [hip_y, neck_y], angle, x, y);
    
    % Arm
    plotRotated([shoulder_x, handle_x], [shoulder_y, handle_y], angle, x, y);
    
    % Head
    [head_xs, head_ys] = getCircle(neck_x, neck_y, (1/5));
    plotRotated(head_xs, head_ys, angle, x, y);
    
    axis equal;
    hold off;
    
    function plotRotated(xs, ys, angle, x, y)
        [new_xs, new_ys] = rotate(xs, ys, angle);
        plot((new_xs - pivot_x)*unitLength + x, (new_ys - pivot_y)*unitHeight + y, 'k');
    end
end

function [new_xs, new_ys] = rotate(x_points, y_points, angle)
    [thetas, rs] = cart2pol(x_points, y_points);
    thetas = thetas + angle;
    [new_xs, new_ys] = pol2cart(thetas, rs);
end

function [xs, ys] = getCircle(x,y,r)
    th = 0:pi/50:2*pi;
    xs = r * cos(th) + x;
    ys = r * sin(th) + y;
end