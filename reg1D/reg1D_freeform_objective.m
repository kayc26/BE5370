function [f, g] = reg1D_freeform_objective(v, I, J, alpha)
% Objective function for 1D registration example

% Compute the transformation given parameters
x = 1:length(I);
phi = x + v;

% Compute the difference between reference image and resliced moving image
idiff = I - interp1(J, phi, '*linear', 0);

% Compute the derivative of v
vt = gradient(v);

% Compute the metric
f = sum(idiff .^ 2) + alpha * sum(vt .^ 2);

% Compute gradient if requested
if nargout > 1
    
    % Apply phi to the gradient image
    dJdt_phi = interp1(gradient(J), phi, '*linear', 0);
    
    % Compute partial derivative w.r.t. s
    vtt = gradient(vt);
    g = - 2 * idiff .* dJdt_phi - 2 * alpha * vtt;
   
end
