%% Efficient Frontier (Analytical Solution)
% Calculation using Lagrange Multipliers method.

clear; clc; close all;

% --- 1. Inputs ---
mu  = [0.10  0.14  0.18]';         % Expected Returns
Sig = [0.015 0.010 0.008;          % Covariance Matrix
       0.010 0.040 0.018;
       0.008 0.018 0.035];

% --- 2. Lagrangian Constants ---
one = ones(3,1);
A = one'* (Sig\one);      B = one'*(Sig\mu);
C = mu'*(Sig\mu);         D = A*C - B^2;

% --- 3. Frontier Range ---
m_min = B/A;                       % Return at minimum variance
m_max = max(mu) - 1e-4;            
mvals = linspace(m_min, m_max, 150);

sigma = zeros(size(mvals));

% --- 4. Loop: Calculate Sigma for each Target Return ---
for k = 1:numel(mvals)
    m   = mvals(k);
    lam = (C - B*m)/D;
    nu  = (A*m - B)/D;
    w   = Sig\(lam*one + nu*mu);   % Optimal weights
    sigma(k) = sqrt(w'*Sig*w);     % Portfolio risk
end

% --- 5. Visualization ---
figure('Color','w'); 
plot(sigma, mvals, 'k-', 'LineWidth', 1.5); hold on; grid on; box on;

% Plot original assets (Added for context)
asset_vols = sqrt(diag(Sig));
plot(asset_vols, mu, 'ro', 'MarkerFaceColor', 'r'); 

xlabel('Risk (Sigma)', 'Interpreter', 'latex');
ylabel('Return (Mu)', 'Interpreter', 'latex');
title('Efficient Frontier');

% Save as PDF
print('-dpdf', 'efficient_frontier.pdf');
