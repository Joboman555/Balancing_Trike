%animateTrike.m
clear all;
initial_angle = pi/4; % radians
xDotDot = 20; % m/s^2
D = 0.5; % meters
[time, stocks] = simulateTrike(D, initial_angle, xDotDot);

thetas = stocks(:,1);
x = time.^2 / 2 * xDotDot;

x_pivot = x;
y_pivot = zeros(size(x));
x_com = x + D.*cos(thetas);
y_com = D.*sin(thetas);
figure;
min_x = min([x_pivot; x_com]);
max_x = max([x_pivot; x_com]);
min_y = min([y_pivot; y_com]);
max_y = max([y_pivot; y_com]);

loops = numel(thetas);
F(loops) = struct('cdata',[],'colormap',[]);
for j = 1:loops

    Xs = [x_pivot(j); x_com(j)];
    Ys = [y_pivot(j); y_com(j)];
    plot(Xs, Ys, 'o', Xs, Ys);
    axis equal
    xlim([min_x, max_x])
    ylim([min_y, max_y])
    drawnow
    F(j) = getframe;
end

% movie(F,1,15)