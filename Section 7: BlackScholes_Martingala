%% Black-Scholes GBM Simulation & Validation
% Exhaustive simulation of GBM under Black-Scholes
% Illustrates mean, increasing variance, discounted martingale property,
% and log-normality of the price at maturity.

%% 1. Model Parameters
S0    = 100;   % Initial Price
r     = 0.05;  % Risk-free rate
sigma = 0.20;  % Volatility
T     = 1;     % Time horizon (years)
N     = 252;   % Steps (trading days in a year)
M     = 5e3;   % Number of paths (large for histogram accuracy)

dt = T/N;              % Step size
t  = linspace(0,T,N+1);% Time vector

rng(42)                % Fixed seed for reproducibility

%% 2. Brownian Motion and Paths (Vectorized)
dW = sqrt(dt) * randn(M,N);      % Increments following N(0,dt)
W  = [zeros(M,1)  cumsum(dW,2)]; % Brownian paths

drift = (r - 0.5*sigma^2) * t;       % Deterministic part
S     = S0 * exp( drift + sigma*W ); % Mx(N+1) Matrix with all trajectories

%% 3. Theoretical and Empirical Statistics
mediaTheo  = S0 * exp(r*t);
varTheo    = (S0^2)*exp(2*r*t).*(exp(sigma^2*t)-1);
sigmaTheo  = sqrt(varTheo);

% Empirical mean and variance per time step
mediaEmp   = mean(S,1);
varEmp     = var(S,0,1);

fprintf('--- Numerical check vs Theory ---\n');
fprintf('  E[S(T)] Theoretical  = %.4f\n', mediaTheo(end));
fprintf('  E[S(T)] Empirical    = %.4f\n', mediaEmp(end));
fprintf('  Var[S(T)] Theoretical= %.4f\n', varTheo(end));
fprintf('  Var[S(T)] Empirical  = %.4f\n\n', varEmp(end));

%% 4. Figure Setup
% (Modified parameters to avoid cropping)
cm  = 1/2.54;                         % factor inches to cm
wid = 18*cm;  hei = 6*cm;             % 18x6 cm = A4 page single column format
figure('Name','Black-Scholes: Visual Validation', ...
       'Units','centimeters', ...
       'Position',[2 2 wid hei], ...  % [x  y  width  height]
       'PaperPositionMode','auto');   % Ensures no cropping on print

tiledlayout(1,3,'Padding','compact','TileSpacing','compact');

%% 4a. Subplot 1 - Paths, Mean, and Band (+- 1 sigma)
nexttile
hold on
cols = [0.6 0.6 1];                     % Light blue
plot(t, S(1:300,:)', 'Color', cols)     % Plot only 300 to avoid saturation

% Shaded band (+- 1 theoretical sigma)
fill([t fliplr(t)], ...
     [mediaTheo+sigmaTheo, fliplr(mediaTheo-sigmaTheo)], ...
     [0.85 0.85 0.85], 'EdgeColor','none', 'FaceAlpha',0.5);

plot(t, mediaTheo, 'k', 'LineWidth', 2) % Theoretical Mean
xlabel('Time'); ylabel('Price S(t)')
title('Paths, Mean & \pm 1\sigma Band','Interpreter','tex');
grid on; box on
hold off

%% 4b. Subplot 2 -- Discounted Process: Martingale under Q
nexttile
Sd = S .* exp(-r*t);                    
plot(t, Sd(1:300,:)', 'Color',[0.7 0.7 0.7]); hold on
plot(t, mean(Sd,1), 'r', 'LineWidth', 2)
xlabel('Time'); ylabel('e^{-rt} S(t)');
title('Discounted Process: Martingale')
legend({'Disc. Paths','Empirical Mean'},'Location','southwest')
grid on; box on
hold off

%% 4c. Subplot 3 -- S(T) Histogram and Log-Normal Density
nexttile
ST = S(:,end);
histogram(ST, 'Normalization','pdf','EdgeColor','none','FaceColor',[0.6 0.8 1])
hold on
xVals = linspace(min(ST), max(ST), 400);
pdfTheo = lognpdf(xVals, log(S0)+(r-0.5*sigma^2)*T, sigma*sqrt(T));
plot(xVals, pdfTheo, 'k', 'LineWidth', 2)
xlabel('S(T)'); ylabel('Density')
title('Log-Normality at Maturity')
legend({'Simulated Hist','Theoretical PDF'},'Location','northeast')
grid on; box on
hold off

