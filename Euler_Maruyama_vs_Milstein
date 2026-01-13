% Strong Convergence Analysis: Euler-Maruyama vs. Milstein
% Model: Geometric Brownian Motion (GBM)
% dX_t = mu*X_t*dt + sigma*X_t*dW_t
%
% Result: Demonstrates that Milstein scheme (Order 1.0) converges faster  in strong sense (L2 norm) than Euler-Maruyama (Order 0.5).

clear; clc; close all;
rng(42);                        % Fixed seed for reproducibility

%% --- Parameters ---
mu      = 0.5;                  % Drift
sigma   = 0.3;                  % Volatility
X0      = 1;                    % Initial condition
T       = 1;                    % Time horizon
M       = 1e4;                  % Monte-Carlo paths (Vectorized)

% Discrete time steps to analyze
N_vec   = 100 * 2.^(0:4);       % [100 200 400 800 1600]
h_vec   = T ./ N_vec;           % Step sizes (dt)

err_EM  = zeros(size(N_vec));
err_Mil = zeros(size(N_vec));

%% --- Simulation Loop ---
fprintf('------------------------------------------------------------\n');
fprintf('   N        dt (h)        Error EM       Error Milstein\n');
fprintf('------------------------------------------------------------\n');

for k = 1:numel(N_vec)
    N = N_vec(k);   
    h = h_vec(k);

    % Brownian Increments (M x N Matrix)
    dW = sqrt(h) * randn(M, N);
    
    % True Solution (using full path brownian for terminal value)
    W_T = sum(dW, 2); 
    X_exact = X0 * exp((mu - 0.5*sigma^2)*T + sigma*W_T);

    % --- 1. Euler-Maruyama Scheme ---
    X_EM = X0 * ones(M,1);
    for n = 1:N
        X_EM = X_EM + mu*X_EM*h + sigma*X_EM .* dW(:,n);
    end

    % --- 2. Milstein Scheme ---
    X_Mil = X0 * ones(M,1);
    for n = 1:N
        dWn = dW(:,n);
        % Milstein adds the correction term: 0.5 * sigma * sigma' * (dW^2 - h)
        X_Mil = X_Mil + mu*X_Mil*h + sigma*X_Mil .* dWn ...
                      + 0.5*sigma^2 * X_Mil .* (dWn.^2 - h);
    end

    % --- RMS Error (L2 Convergence) ---
    err_EM(k)  = sqrt(mean((X_exact - X_EM).^2));
    err_Mil(k) = sqrt(mean((X_exact - X_Mil).^2));

    fprintf('%5d    %8.5f    %11.3e    %11.3e\n',...
            N, h, err_EM(k), err_Mil(k));
end
fprintf('------------------------------------------------------------\n');

%% --- Empirical Slope Calculation ---
% We expect Slope ~ 0.5 for Euler and ~ 1.0 for Milstein
coeffs_EM  = polyfit(log(h_vec), log(err_EM), 1);
coeffs_Mil = polyfit(log(h_vec), log(err_Mil), 1);

fprintf('\nObserved Convergence Rates (Slope):\n');
fprintf('Euler-Maruyama : %.3f (Theory: 0.5)\n', coeffs_EM(1));
fprintf('Milstein       : %.3f (Theory: 1.0)\n', coeffs_Mil(1));

%% --- Visualization ---
fig = figure('Color','w', 'Name', 'SDE Convergence Analysis');

% Log-Log Plot
loglog(h_vec, err_EM,  'o-', 'LineWidth', 1.5, 'MarkerSize', 8, ...
       'DisplayName', 'Euler-Maruyama');
hold on;
loglog(h_vec, err_Mil, 's-', 'LineWidth', 1.5, 'MarkerSize', 8, ...
       'DisplayName', 'Milstein');

% Reference Slopes (shifted for visual comparison)
ref_EM  = 1.1 * err_EM(1)  / h_vec(1)^0.5;
ref_Mil = 0.8 * err_Mil(1) / h_vec(1)^1.0;

loglog(h_vec, ref_EM  * h_vec.^0.5, 'k--', 'LineWidth', 1.2, ...
       'DisplayName', 'Ref: Slope 0.5');
loglog(h_vec, ref_Mil * h_vec.^1.0, 'b-.', 'LineWidth', 1.2, ...
       'DisplayName', 'Ref: Slope 1.0');

% Formatting
grid on; axis tight;
xlabel('Time Step ($h$)', 'Interpreter', 'latex', 'FontSize', 12);
ylabel('Strong Error ($RMSE$)', 'Interpreter', 'latex', 'FontSize', 12);
title('Strong Convergence: $L^2$ Norm', 'Interpreter', 'latex', 'FontSize', 14);
legend('Location', 'northwest', 'Interpreter', 'latex', 'FontSize', 10);
set(gca, 'TickLabelInterpreter', 'latex', 'FontSize', 11);

% --- Save Output ---
save_plot = true; % Toggle this to false if you don't want to save
if save_plot
    if ~exist('output', 'dir'), mkdir('output'); end
    print('-dpdf', 'output/sde_convergence_gbm.pdf');
    print('-dpng', 'output/sde_convergence_gbm.png', '-r300');
    disp('Plots saved to /output directory.');
end
