%% --- SCRIPT PRINCIPAL: PORTFOLIO LONG-ONLY (REAL) ---
clear; clc; close all;

%% 0. Configuración
startDate = '2019-01-01';
endDate   = '2024-01-01';

groups = {["AAPL","MSFT","GOOGL","AMZN","META"], ...   % Tech
          ["SPY","IEFA","EEM","AGG","GLD"], ...        % Multi
          ["KO","PG","JNJ","MCD","XLP"]};              % Defensive
groupNames = ["Tecnológicas USA","Multi activo ETF","Defensivo"];
clr = lines(numel(groups)); 

%% 1. Descarga de precios (Igual que antes)
pricesAll   = cell(numel(groups),1);
datesCommon = cell(numel(groups),1);

fprintf('Descargando datos...\n');
for g = 1:numel(groups)
    tickers   = groups{g};
    tmpP      = [];
    datesKeep = [];
    
    for k = 1:numel(tickers)
        % Llamamos a tu función alphaDaily (debe estar en la misma carpeta)
        tbl = alphaDaily(tickers(k), [], startDate, endDate);  
        
        if k == 1
            datesKeep = tbl.Date;
            tmpP      = tbl.AdjClose;
        else
            [common, ia, ib] = intersect(datesKeep, tbl.Date, 'stable');
            datesKeep = common;
            tmpP = [tmpP(ia, :) tbl.AdjClose(ib)]; % Alineación correcta
        end
    end
    pricesAll{g} = tmpP;
    fprintf('  Grupo %d descargado.\n', g);
end

%% 2. CÁLCULO FRONTERA EFICIENTE (LONG-ONLY / QUADPROG)
% Aquí está la magia. Usamos optimización numérica, no fórmulas analíticas.

frontierRisk = cell(1,numel(groups));
frontierRet  = cell(1,numel(groups));
riskMV       = zeros(1,numel(groups));
retMV        = zeros(1,numel(groups));

% Opciones para que el optimizador no saque texto en la pantalla
opt = optimoptions('quadprog','Display','off');

for g = 1:numel(groups)
    P    = pricesAll{g};
    rets = diff(log(P));        
    mu   = mean(rets)' * 252;   % Retorno esperado anual
    Sig  = cov(rets)  * 252;    % Matriz Covarianza anual
    
    nAssets = length(mu);
    
    % --- A. Calcular el punto de Mínima Varianza Global (Long-Only) ---
    % Min 0.5*w'*Sig*w  sujeto a: sum(w)=1, w>=0
    f = zeros(nAssets, 1);
    Aeq = ones(1, nAssets);     % Restricción de igualdad: suma(w) = ...
    beq = 1;                    % ... = 1
    lb  = zeros(nAssets, 1);    % Restricción: w >= 0 (LONG ONLY)
    ub  = ones(nAssets, 1);     % Restricción: w <= 1
    
    w_mv = quadprog(Sig, f, [], [], Aeq, beq, lb, ub, [], opt);
    
    riskMV(g) = sqrt(w_mv' * Sig * w_mv);
    retMV(g)  = w_mv' * mu;
    
    % --- B. Calcular la Frontera ---
    % En Long-Only, la frontera va desde el retorno de MinVar hasta el MaxRetorno
    targetRets = linspace(retMV(g), max(mu), 50); 
    
    rEff = zeros(size(targetRets));
    
    for i = 1:length(targetRets)
        rtarget = targetRets(i);
        
        % Min 0.5*w'*Sig*w sujeto a:
        % 1. sum(w) = 1
        % 2. w'*mu  = rtarget
        
        Aeq_grid = [ones(1, nAssets); mu']; % Dos igualdades
        beq_grid = [1; rtarget];
        
        w_opt = quadprog(Sig, f, [], [], Aeq_grid, beq_grid, lb, ub, [], opt);
        
        rEff(i) = sqrt(w_opt' * Sig * w_opt);
    end
    
    frontierRisk{g} = rEff;
    frontierRet{g}  = targetRets;
end

%% 3. Visualization
% Define dimensions for correct PDF export (prevent cropping)
W = 28; H = 12; % Width and Height in cm

figure('Color','w', ...
       'Units','centimeters', 'Position',[2 2 W H], ...
       'PaperUnits','centimeters', 'PaperPosition',[0 0 W H], ...
       'PaperSize',[W H]); 

hold on;
for g = 1:numel(groups)
    % Efficient Frontier
    plot(frontierRisk{g}, frontierRet{g}, 'LineWidth', 2, 'Color', clr(g,:));
    % MinVar Point
    scatter(riskMV(g), retMV(g), 80, 'filled', 'MarkerEdgeColor', 'k', ...
            'MarkerFaceColor', clr(g,:));
end

% Labels
xlabel('Riesgo Anual ($\sigma$)', 'Interpreter', 'latex', 'FontSize', 12);
ylabel('Rendimiento Esperado ($E[r]$)', 'Interpreter', 'latex', 'FontSize', 12);
title('Fronteras Eficientes LONG-ONLY (Restringidas)', 'FontSize', 14);

% Legend layout
legend([groupNames+" (Frontera)", "MinVar "+groupNames], ...
       'Location', 'bestoutside', ...
       'NumColumns', 1);

grid on; box on; hold off;

% Export final PDF
print('Fronteras_LongOnly.pdf', '-dpdf', '-painters');
