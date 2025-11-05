%% Create example 1D 'images'

% Load a 2D MRI image
im=double(imread('noisyMRIbrain.jpeg'));

% Smooth the image with Gaussian filter
im=conv2(im, fspecial('gaussian',32,4));

% Take two lines through the image to simulate 1D images
sc1x = linspace(1,455,100);  sc1y = linspace(175,175,100);
sc2x = linspace(-10,495,100); sc2y = linspace(140,210,100);
I = interp2(im, sc1x, sc1y, 'linear', 0);
J = interp2(im, sc2x, sc2y, 'linear', 0);

% Plot the two images
clf;
subplot(1,2,1);
plot(I, 'r');
hold on;
plot(J, 'b');
legend('reference','moving');
subplot(1,2,2);
imagesc(im); colormap('gray'); axis image; hold on;
plot(sc1x,sc1y,'r');
plot(sc2x,sc2y,'b');

% Create a data object to pass in to the optimization function
data.I = I;
data.J = J;

%% Experiment with some basic 1D transformations

T=linspace(0,100);

T_shift = T+10;
J_shift = interp1(J, T_shift,'linear',0);

clf;
subplot(1,2,1);
plot(T, T_shift);
axis image; ylim([0 100]);
xlabel('T'); ylabel('T_{shift}');
subplot(1,2,2); 
plot(J,'r'); hold on;
plot(J_shift, 'b');
legend('J','J_{shift}');

%% Try a shift and flipping transformation

T_shift_flip = 100-T;
J_shift_flip = interp1(J, T_shift_flip,'linear',0);

clf;
subplot(1,2,1);
plot(T, T_shift_flip);
axis image; ylim([0 100]);
xlabel('T'); ylabel('T_{shift+flip}');
subplot(1,2,2); 
plot(J,'r'); hold on;
plot(J_shift_flip, 'b');
legend('J','J_{shift+flip}');


%% Try a scaling transformation

T_scale = 1.2 * T;
J_scale = interp1(J, T_scale,'linear',0);

clf;
subplot(1,2,1);
plot(T, T_scale);
axis image; ylim([0 100]); xlim([0 100]);
xlabel('T'); ylabel('T_{scale}');
subplot(1,2,2); 
plot(J,'r'); hold on;
plot(J_scale, 'b');
legend('J','J_{scale}');

%% Try an affine transformation (scale and shift)

% Notice we are composing two transformations
T_affine = 1.2 * T_shift;

J_affine = interp1(J, T_affine,'linear',0);

clf;
subplot(1,2,1);
plot(T, T_affine);
axis image; ylim([0 100]); xlim([0 100]);
xlabel('T'); ylabel('T_{affine}');
subplot(1,2,2); 
plot(J,'r'); hold on;
plot(J_affine, 'b');
legend('J','J_{affine}');

%% Try a polynomial transformation (non-linear)

% "Good" coefficients
%coeff = [0.0002, -0.01, 0.5, +10];

% "Bad" coefficients
coeff = [0.001, -0.06, 0.5, +20];

% Notice we are composing two transformations
T_poly = coeff(1) * T.^3 + coeff(2) * T.^2 + coeff(3) * T + coeff(4);

J_poly = interp1(J, T_poly,'linear',0);

clf;
subplot(1,2,1);
plot(T, T_poly);
axis image; ylim([0 100]); xlim([0 100]);
xlabel('T'); ylabel('T_{poly}');
subplot(1,2,2); 
plot(J,'r'); hold on;
plot(J_poly, 'b');
legend('J','J_{poly}');


%% Perform registration between the two images

% Print initial solution
fprintf('Initial cost: %f\n', reg1D_affine_objective([1 0], I, J));

% Set options for optimization
options = optimoptions('fminunc',...
    'Display','iter',...
    'SpecifyObjectiveGradient',true);

% Run optimization
[p,~] = fminunc(@(x)(reg1D_affine_objective(x, I, J)), [1 0], options);

% Plot final results
subplot(1,2,2);
hold off;
plot(I, 'r');
hold on;
plot(reg1D_affine_warp(p, I, J), 'b');
legend('reference','result');

%% Perform free-form deformable registration

% Apply the affine transform to J
Jaff = reg1D_affine_warp(p, I, J);

% Initial solution is a vector of zeros
v = zeros(size(I));

alpha = 200;

% Print initial solution
fprintf('Initial cost: %f\n', reg1D_freeform_objective(v, I, Jaff, alpha));

% Run optimization

[v,fval] = fminunc(@(x)(reg1D_freeform_objective(x, I, Jaff, alpha)), v, options);

% Plot final results
x = 1:length(I);

clf;
subplot(1,2,1);
plot(I, 'r');
hold on;
plot(Jaff, 'b');
plot(interp1(Jaff, x + v, '*linear', 0), 'g');
legend('reference','moving','registered');
hold off;

subplot(1,2,2);
plot(x, x+v);
