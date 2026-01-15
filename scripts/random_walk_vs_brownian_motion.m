%% Donsker's Invariance Principle Simulation
% Context: Bachelor Thesis (TFG) - Math
% Purpose: Visualizing the convergence of a Scaled Random Walk to Brownian Motion.

clear; clc; clf;
rng(123); % Fixed seed for reproducibility

% --- Parameters ---
N = 250;        % Number of time steps
M = 5;          % Number of sample paths to plot
T = 1;          % Time horizon
dt = T/N;       % Time increment
t = linspace(0, T, N+1);

% Setup figure
fig = figure('Name', 'Donsker Convergence Analysis', ...
             'Units', 'normalized', 'Position', [.1 .1 .8 .7]);

% --- 1. Scaled Random Walk (The Discrete Process) ---
% X_i = +/- 1 with p=0.5. Scaled by 1/sqrt(N)
subplot(2,2,1); hold on; box on; grid on
for m = 1:M
    xi = 2*(rand(N,1)>0.5) - 1;      
    S  = [0; cumsum(xi)] ./ sqrt(N); 
    stairs(t, S, 'LineWidth', 1.1)
end
xlabel('t'); ylabel('S_n (Scaled)');
title('Scaled Random Walk');

% --- 2. Brownian Motion (The Limit Process) ---
% W_t ~ N(0, t). Increments are N(0, dt)
subplot(2,2,3); hold on; box on; grid on
for m = 1:M
    dW = sqrt(dt) * randn(N,1);
    W  = [0; cumsum(dW)];
    plot(t, W, 'LineWidth', 1.1)
end
xlabel('t'); ylabel('W_t');
title('Brownian Motion Simulation');

% --- 3. Functional Convergence Comparison ---
subplot(1,2,2); hold on; box on; grid on

% Generating a single realization for direct comparison
xi_sample = 2*(rand(N,1)>0.5) - 1; 
S_sample  = [0; cumsum(xi_sample)] ./ sqrt(N);
% Note: Mathematically, we compare distribution, but visually we overlay an independent BM to show scale similarity.
W_sample  = [0; cumsum(sqrt(dt)*randn(N,1))];

stairs(t, S_sample, 'r', 'LineWidth', 1.5, 'DisplayName', 'Random Walk (n=250)')
plot(t, W_sample, 'b', 'LineWidth', 1.5, 'DisplayName', 'Brownian Motion')

legend('Location','southwest');
xlabel('t'); ylabel('Value');
title('Trajectory Comparison');
sgtitle('Donsker''s Theorem: Weak Convergence');

% --- Save Output ---
% Using relative path to ensure portability across systems
if ~exist('output', 'dir')
    mkdir('output');
end
fname = fullfile('output', 'donsker_simulation.pdf');
print(fig, fname, '-dpdf', '-painters');
fprintf('Figure saved successfully to: %s\n', fname);

