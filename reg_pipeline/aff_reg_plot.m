function [x,y,u,v] = aff_reg_plot(I, J, theta, a, b)

% Generate the coordinate grid. In MATLAB the first dimension
% is 'rows' or 'y' and the second dimension is 'columns', or 'x'
[y,x] = ndgrid(1:size(I,1), 1:size(I,2));

% Find the center of rotation, i.e., the center of the image
cx = size(I,2) * 0.5 + 0.5;
cy = size(I,1) * 0.5 + 0.5;

% Before applying a rotation, shift so the origin is at image center
x_ctr = x - cx; y_ctr = y - cy;

% Apply rotation and translation with origin at image center
x_aff_ctr = cos(theta) * x_ctr - sin(theta) * y_ctr + a;
y_aff_ctr = sin(theta) * x_ctr + cos(theta) * y_ctr + b;

% Shift again so that origin is where it was
x_aff = x_aff_ctr + cx; y_aff = y_aff_ctr + cy;

% Compute the displacements (arrows)
u = x_aff - x; v = y_aff - y;

% Interpolate the image at the new locations
Jhat = interpn(J, y_aff, x_aff, 'linear', 0);

% Compute the difference image
D = I - Jhat;

% Compute the mask - pixels that map inside of the moving image
M = interpn(ones(size(J)), y_aff, x_aff, 'nearest', 0);

% Compute the metric - sum of squared differences over the mask
metric = sum(sum(D.^2 .* M));

% Plot everything
clf;

subplot(2,2,1);
imagesc(I);
axis image;
colormap gray;
title('Fixed Image');
hold on;
scatter(x(:),y(:),'ro');
quiver(x,y,u,v,0,'b');
xlim([0.5,size(I,2)+0.5]);
ylim([0.5,size(I,1)+0.5]);

subplot(2,2,2);
imagesc(J);
axis image;
colormap gray;
hold on;
scatter(x(:)+u(:),y(:)+v(:),'ro');
xlim([0.5,size(I,2)+0.5]);
ylim([0.5,size(I,1)+0.5]);
title('Moving Image')

subplot(2,2,3);
imagesc(Jhat);
axis image;
colormap gray;
xlim([0.5,size(I,2)+0.5]);
ylim([0.5,size(I,1)+0.5]);
title('Resampled moving image')

% Set the places where mask is zero to NaN (not a number) 
% for clearer visualization
D(M == 0) = NaN;

subplot(2,2,4);
imagesc(D);
axis image;
colormap(gca,'jet');
title(sprintf('Difference image. Metric = %5.2f', metric));
caxis([-255, 255]);
colorbar(gca);

set(findobj(gcf,'type','axes'),'fontsize', 16);








