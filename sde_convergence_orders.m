clear;  clc;  close all;
rng(42);                          % semilla fija, reproducible

%% Parámetros modificables 
mu      = 0.5;
sigma   = 0.3;
X0      = 1;
T       = 1;

Nvec    = 100 * 2.^(0:4);         % [100 200 400 800 1600]
M       = 1e4;                    % nº de trayectorias Monte-Carlo


hvec   = T ./ Nvec;
errEM  = zeros(size(Nvec));
errMil = zeros(size(Nvec));


for k = 1:numel(Nvec)
    N = Nvec(k);    h = hvec(k);

    % Incrementos brownianos (M×N)
    dW = sqrt(h) * randn(M, N);
    W  = cumsum(dW, 2);           % posiciones W(t_n)  (no se usa dentro del bucle)

    % - Euler–Maruyama -
    X_EM = X0 * ones(M,1);
    for n = 1:N
        X_EM = X_EM + mu*X_EM*h + sigma*X_EM .* dW(:,n);
    end

    % - Milstein -
    X_Mil = X0 * ones(M,1);
    for n = 1:N
        dWn   = dW(:,n);
        X_Mil = X_Mil + mu*X_Mil*h + sigma*X_Mil .* dWn ...
                + 0.5*sigma^2 * X_Mil .* (dWn.^2 - h);
    end

    % - Solución exacta X(T) -
    X_exact = X0 * exp( (mu - 0.5*sigma^2)*T + sigma*W(:,end) );

    % ---------- Error RMS ----------
    errEM (k) = sqrt(mean( (X_exact - X_EM ).^2 ));
    errMil(k) = sqrt(mean( (X_exact - X_Mil).^2 ));

    fprintf('%5d   %8.5f   %11.3e   %11.3e\n',...
            N, h, errEM(k), errMil(k));
end
fprintf('------------------------------------------------------\n\n');

%% - Pendientes (orden numérico empírico) -
slopeEM  = polyfit(log(hvec), log(errEM ), 1);   % pendiente ≈ 0.5
slopeMil = polyfit(log(hvec), log(errMil), 1);   % pendiente ≈ 1.0
fprintf('Pendiente log-log   EM = %.3f   |  Milstein = %.3f\n',...
        slopeEM(1), slopeMil(1));

%% - Gráfica log-log -
figure('Color','w');
set(groot,'defaultAxesTickLabelInterpreter','latex',...
          'defaultLegendInterpreter','latex',...
          'defaultTextInterpreter','latex');

loglog(hvec, errEM , 'o-','LineWidth',1.1,'MarkerSize',6,...
       'DisplayName','Euler--Maruyama');
hold on;
loglog(hvec, errMil, 's-','LineWidth',1.1,'MarkerSize',6,...
       'DisplayName','Milstein');

% Líneas guía desplazadas (constantes tomadas al 1er punto / 2)
C_EM   = 0.5 * errEM(1)  / hvec(1)^0.5;
C_Mil  = 0.5 * errMil(1) / hvec(1)^1.0;
loglog(hvec, C_EM * hvec.^0.5 , '--','DisplayName','Pendiente $-1/2$');
loglog(hvec, C_Mil* hvec     , '--','DisplayName','Pendiente $-1$');

xlabel('$h$ (\textit{tama\~{n}o de paso})','Interpreter','latex');
ylabel('RMSE');
title('Convergencia fuerte en norma $L^{2}$');
grid on;  box on;  axis tight;
legend('Location','northwest');

if export
    print('-dpdf','convergencia_gbm.pdf');
    print('-dpng','convergencia_gbm.png','-r300');
end

