
%  Simulación exhaustiva del GBM bajo Black–Scholes
%  Ilustra media, varianza creciente, martingala descontada
%  y log-normalidad del precio en el vencimiento.


%% 1. Parámetros del modelo
S0    = 100;   % Precio inicial
r     = 0.05;  % Tipo libre de riesgo
sigma = 0.20;  % Volatilidad
T     = 1;     % Horizonte temporal (años)
N     = 252;   % Pasos (días de negociación en un año)
M     = 5e3;   % Nº de trayectorias (grande para histograma)

dt = T/N;                  % Tamaño de paso
t  = linspace(0,T,N+1);    % Vector de tiempos

rng(42)                % Semilla fija para reproducibilidad

%% 2. Browniano y trayectorias (vectorizado)
dW = sqrt(dt) * randn(M,N);          % Incrementos que siguen N(0,dt)
W  = [zeros(M,1)  cumsum(dW,2)];     % Caminos brownianos

drift = (r - 0.5*sigma^2) * t;       % Parte determinista
S     = S0 * exp( drift + sigma*W ); % Matriz M×(N+1) con todas las trayectorias

%% 3. Estadísticos teóricos y empíricos
mediaTheo  = S0 * exp(r*t);
varTheo    = (S0^2)*exp(2*r*t).*(exp(sigma^2*t)-1);
sigmaTheo  = sqrt(varTheo);

% Media empírica y varianza por instante
mediaEmp   = mean(S,1);
varEmp     = var(S,0,1);

fprintf('--- Comprobación numérica frente a teoría ---\n');
fprintf('  E[S(T)] teórico      = %.4f\n', mediaTheo(end));
fprintf('  E[S(T)] empírico     = %.4f\n', mediaEmp(end));
fprintf('  Var[S(T)] teórica    = %.4f\n', varTheo(end));
fprintf('  Var[S(T)] empírica   = %.4f\n\n', varEmp(end));

%% 4. Preparamos figura compuesta

% (modificamos parámetros para que no salga cortada la imagen en LaTeX)
cm   = 1/2.54;                        % factor pulgadas  a cm
wid  = 18*cm;  hei = 6*cm;            % 18×6 cm = página A4 a una columna
figure('Name','Black–Scholes: validación visual', ...
       'Units','centimeters', ...
       'Position',[2 2 wid hei], ...  % [x  y  ancho  alto]
       'PaperPositionMode','auto');   % garantiza que no se recorte

tiledlayout(1,3,'Padding','compact','TileSpacing','compact');

%% 4a. Subplot 1 - Trayectorias, media y banda  (+- 1 sigma)
nexttile
hold on
cols = [0.6 0.6 1];                     % Azul muy claro
plot(t, S(1:300,:)', 'Color', cols)     % Solo 300 para no saturar

% Banda sombreada (+- 1 sigma teórica)
fill([t fliplr(t)], ...
     [mediaTheo+sigmaTheo, fliplr(mediaTheo-sigmaTheo)], ...
     [0.85 0.85 0.85], 'EdgeColor','none', 'FaceAlpha',0.5);

plot(t, mediaTheo, 'k', 'LineWidth', 2) % Media teórica
xlabel('Tiempo'); ylabel('Precio S(t)')
title('Trayectorias, media y banda $\pm 1\sigma$','Interpreter','latex');
grid on; box on
hold off

%% 4b. Subplot 2 -- Proceso descontado: martingala bajo Q
nexttile
Sd = S .* exp(-r*t);                    
plot(t, Sd(1:300,:)', 'Color',[0.7 0.7 0.7]); hold on
plot(t, mean(Sd,1), 'r', 'LineWidth', 2)
xlabel('Tiempo'); ylabel('$e^{-rt}\,S(t)$', 'Interpreter','latex');
title('Proceso descontado: martingala')
legend({'Trayectorias desc.','Media empírica'},'Location','southwest')
grid on; box on
hold off

%% 4c. Subplot 3 -- Histograma de S(T) y densidad log-normal
nexttile
ST = S(:,end);
histogram(ST, 'Normalization','pdf','EdgeColor','none','FaceColor',[0.6 0.8 1])
hold on
xVals = linspace(min(ST), max(ST), 400);
pdfTheo = lognpdf(xVals, log(S0)+(r-0.5*sigma^2)*T, sigma*sqrt(T));
plot(xVals, pdfTheo, 'k', 'LineWidth', 2)
xlabel('S(T)'); ylabel('Densidad')
title('Log-normalidad en el vencimiento')
legend({'Histograma simulado','Densidad teórica'},'Location','northeast')
grid on; box on
hold off