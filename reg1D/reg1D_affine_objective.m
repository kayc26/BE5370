function [f,g] = reg1D_affine_objective(p, I, J)
% Objective function for 1D registration example

% Compute the transformation given parameters
s = p(1);
tau = p(2);
x = 1:length(I);
phi = s * x + tau;

% Compute the difference between reference image and resliced moving image
idiff = I - interp1(J, phi, '*linear', 0);

% Compute the metric
f = sum(idiff .^ 2);

% Compute gradient if requested
if nargout > 1
    
    % Apply phi to the gradient image
    dJdt_phi = interp1(gradient(J), phi, '*linear', 0);
    
    % Compute partial derivative w.r.t. s
    g(1) = -2 * sum(idiff .* dJdt_phi .* x);
    
    % Compute partial derivative w.r.t. tau
    g(2) = -2 * sum(idiff .* dJdt_phi);
   
end