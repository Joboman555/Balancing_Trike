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
    
%     plot(new_timesteps, thetas);

    loops = numel(thetas);
    panningView(loops, x_pivot, x_com, y_pivot, y_com, min_y, max_y, D, thetas, initial_angle)
%     stationaryView(loops, x_pivot, x_com, y_pivot, y_com, min_y, max_y, min_x, max_x, D)

%      drawRider(D, x_pivot(1), thetas(1))
end

function xDotDot = inputFunction(t, theta, thetaDot)
    a = 13;
    b = 0;
    xDotDot = t.^0 .* a .* ((pi/2) - theta) - b.*thetaDot;
end

function panningView(loops, x_pivot, x_com, y_pivot, y_com, min_y, max_y, D, thetas, initial_angle)
    F(loops) = struct('cdata',[],'colormap',[]);
    for j = 1:loops
        clf
        Xs = [x_pivot(j); x_com(j)];
        Ys = [y_pivot(j); y_com(j)];
        drawRider(D, thetas(j) - initial_angle, x_pivot(j));
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

function drawRider(D, angle, x)
    hold on;
    unitHeight = D * sin(pi/4);
    unitLength = D * cos(pi/4);
    
    % Draw line to COM
    COM_x = [0, 1];
    COM_y = [0, 1];
%     plot(COM_x * unitLength + x, COM_y * unitHeight)
    
    [new_COM_x, new_COM_y] = rotate(COM_x, COM_y, angle);
    plot(new_COM_x * unitLength + x, new_COM_y * unitHeight)
    
    
    % Draw frame
    back_hub_x = 0;
    back_hub_y = 1/3;
    front_hub_x = 2;
    front_hub_y = 1/3;
    crank_x = 0.9;
    crank_y = (1/3)*1.5;
    seat_stay_x = 0.8;
    seat_stay_y = (2/3)*1.2;
    seat_tube_angle = (seat_stay_y - crank_y)/(seat_stay_x - crank_x);
    seat_tube_x = 0.725;
    seat_tube_y = (seat_tube_x - seat_stay_x)*seat_tube_angle + seat_stay_y;
    down_tube_x = 1.8;
    down_tube_y = 0.9;
    fork_angle = (front_hub_y - down_tube_y)/(front_hub_x - down_tube_x);
    fork_x = 1.7;
    fork_y = (fork_x - down_tube_x)*fork_angle + down_tube_y;
    top_tube_x = 1.775;
    top_tube_y = (top_tube_x - down_tube_x)*fork_angle + down_tube_y;
    
    
    % Draw the wheels
    [back_wheel_xs, back_wheel_ys] = getCircle(back_hub_x, back_hub_y * unitHeight, (1/3) * unitHeight);
    [front_wheel_xs, front_wheel_ys] = getCircle(front_hub_x*unitLength, front_hub_y * unitHeight, (1/3) * unitHeight);
    
%     plot(back_wheel_xs  + x, back_wheel_ys, 'k');
%     plot(front_wheel_xs + x, front_wheel_ys, 'k');
    
    %Plot the wheels rotated
    [new_back_xs , new_back_ys] = rotate(back_wheel_xs, back_wheel_ys, angle);
    [new_front_xs, new_front_ys] = rotate(front_wheel_xs, front_wheel_ys, angle);
    plot(new_back_xs  + x, new_back_ys, 'r');
    plot(new_front_xs + x, new_front_ys, 'r');
    
    % Chain Stay
%      plot([0, crank_x]*unitLength + x, [(1/3), crank_y]*unitHeight, 'k')
    plotRotated([0, crank_x], [(1/3), crank_y], angle, x);
    
    % Seat Stay
%      plot([0, seat_stay_x]*unitLength + x, [(1/3), seat_stay_y]*unitHeight, 'k')
    plotRotated([0, seat_stay_x], [(1/3), seat_stay_y], angle, x); 
    
    % Seat Tube
%     plot([seat_tube_x, crank_x]*unitLength + x, [seat_tube_y, crank_y]*unitHeight, 'k')
    plotRotated([seat_tube_x, crank_x], [seat_tube_y, crank_y], angle, x);
    
    % Down Tube
%     plot([crank_x, down_tube_x]*unitLength + x, [crank_y, down_tube_y]*unitHeight, 'k')
    plotRotated([crank_x, down_tube_x], [crank_y, down_tube_y], angle, x);
    
    % Fork
%     plot([front_hub_x, fork_x]*unitLength + x, [front_hub_y, fork_y]*unitHeight, 'k')
    plotRotated([front_hub_x, fork_x], [front_hub_y, fork_y], angle, x);
    
    % Top Tube
%     plot([seat_stay_x, top_tube_x]*unitLength + x, [seat_stay_y, top_tube_y]*unitHeight, 'k')
    plotRotated([seat_stay_x, top_tube_x], [seat_stay_y, top_tube_y], angle, x);
    axis equal;
    hold off;
    
    function plotRotated(xs, ys, angle, x)
        [new_xs, new_ys] = rotate(xs, ys, angle);
        plot(new_xs*unitLength + x, new_ys*unitHeight, 'r');
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