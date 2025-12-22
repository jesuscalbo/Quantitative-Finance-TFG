%% Donsker: paseo aleatorio vs. browniano
rng(123)
N = 250;  M = 5;  T = 1;  dt = T/N;     % parámetros
t = linspace(0,T,N+1);

clf
fig = figure('Name','Donsker – paseo vs. browniano',...
             'Units','normalized','Position',[.1 .1 .8 .7]);

% (1) Paseo aleatorio reescalado
subplot(2,2,1); hold on; box on; grid on
for m = 1:M
    xi = 2*(rand(N,1)>0.5)-1;                % +-1 equiprobables
    S  = [0; cumsum(xi)]./sqrt(N);           % escalado sqrt(N)
    stairs(t,S,'LineWidth',1.1)
end
xlabel('t'); ylabel('Posición')
title('Paseo aleatorio reescalado')

% (2) Browniano simulado 
subplot(2,2,3); hold on; box on; grid on
for m = 1:M
    W = [0; cumsum(sqrt(dt)*randn(N,1))];
    plot(t,W,'LineWidth',1.1)
end
xlabel('t'); ylabel('W_t')
title('Movimiento browniano')

% (3) Comparación trayectoria a trayectoria
subplot(1,2,2); hold on; box on; grid on
xi = 2*(rand(N,1)>0.5)-1;  S = [0; cumsum(xi)]./sqrt(N);
W  = [0; cumsum(sqrt(dt)*randn(N,1))];
stairs(t,S,'r','LineWidth',2)
plot(t,W,'b','LineWidth',2)
legend('Paseo reescalado','Browniano','Location','southwest')
xlabel('t'); ylabel('Valor')
title('Convergencia de una trayectoria')

sgtitle('Convergencia funcional de Donsker: paseo \rightarrow browniano')

carpeta = fullfile('C:','Users','User', ...
                   'Documents','Jesús', 'UNI', '5º Carrera', 'TFG');

if ~exist(carpeta,'dir')         % crea la carpeta si no existe
    mkdir(carpeta)
end

   % mantiene líneas y texto vectoriales

fname = fullfile(carpeta,'paseo_vs_browniano.pdf');
% Guardar (300 dpi) y confirmar en pantalla
print(fig,fname,'-dpdf','-painters')
disp(['Figura guardada en: ', fname])
