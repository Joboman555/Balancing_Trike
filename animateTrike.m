%animateTrike.m
function animateTrike()
    clear all;
    initial_angle = (pi/4); % radians
    D = 0.5; % meters
    [time, stocks] = simulateTrike(D, initial_angle, @inputFunction);

    new_timesteps = linspace(time(1), time(end), 100);
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
    
    plot(new_timesteps, xDotDot);

    loops = numel(thetas);
    panningView(loops, x_pivot, x_com, y_pivot, y_com, min_y, max_y, D)
%     stationaryView(loops, x_pivot, x_com, y_pivot, y_com, min_y, max_y, min_x, max_x, D)
end

function xDotDot = inputFunction(t, theta, thetaDot)
    a = 350;
    %b = 100000;
    b = 100000;
    xDotDot = t.^0 .* a .* ((pi/2 - 0.1) - theta) - b.*thetaDot;
end

function panningView(loops, x_pivot, x_com, y_pivot, y_com, min_y, max_y, D)
    F(loops) = struct('cdata',[],'colormap',[]);
    for j = 1:loops

        Xs = [x_pivot(j); x_com(j)];
        Ys = [y_pivot(j); y_com(j)];
        plot(Xs, Ys, 'o', Xs, Ys);
        axis equal
        xlim([x_com(j) - D * 2, x_com(j) + D * 2])
        ylim([min_y, max_y])
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