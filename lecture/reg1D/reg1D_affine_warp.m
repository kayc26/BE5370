function J_phi = reg1D_affine_warp(p, I, J)
% Apply affine transformation to a 1D image

% Get the affine parameters
s = p(1);
tau = p(2);

% Create deformation field
x = 1:length(I);
phi = s * x + tau;

% Compute the difference between reference image and resliced moving image
J_phi = interp1(J, phi, '*linear', 0);

