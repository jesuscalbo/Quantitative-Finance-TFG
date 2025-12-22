%% 0. Configuración común 
startDate = '2019-01-01';
endDate   = '2024-01-01';

groups = {["AAPL","MSFT","GOOGL","AMZN","META"], ...   % Tech
          ["SPY","IEFA","EEM","AGG","GLD"],          ...% Multi
          ["KO","PG","JNJ","MCD","XLP"]};              % Defensive
groupNames = ["Tecnológicas USA","Multi activo ETF","Defensivo"];
clr = lines(numel(groups));           % colores del gráfico


apiKey = "YL0LRJ2OOALBTJIG";

%% 1. Descarga de precios ajustados 
pricesAll   = cell(numel(groups),1);
datesCommon = cell(numel(groups),1);

for g = 1:numel(groups)
    tickers   = groups{g};
    n         = numel(tickers);
    tmpP      = [];
    datesKeep = [];
    
    for k = 1:n
        tbl = alphaDaily(tickers(k),apiKey,startDate,endDate);  % función abajo
        
        if k==1                      % primera serie del grupo
            datesKeep = tbl.Date;
            tmpP      = tbl.AdjClose;
        else                         % alinear con fechas ya recogidas
            [common, ia, ib] = intersect(datesKeep,tbl.Date,'stable');
            datesKeep = common;
            tmpP      = [tmpP(ia) tbl.AdjClose(ib)];  
        end
        
        pause(12);   % Alpha Vantage: máx. 5 llamadas/minuto (12 s es seguro)
    end
    
    pricesAll{g}   = tmpP;
    datesCommon{g} = datesKeep;
end

save datosPrecios.mat pricesAll datesCommon groupNames

%% 2. Cálculo de la frontera eficiente (igual que antes) 
frontierRisk = cell(1,numel(groups));
frontierRet  = cell(1,numel(groups));
riskMV       = zeros(1,numel(groups));
retMV        = zeros(1,numel(groups));

for g = 1:numel(groups)
    P    = pricesAll{g};
    rets = diff(log(P));               % rendimientos logarítmicos
    mu   = mean(rets)' * 252;          % media anualizada
    Sig  = cov(rets)  * 252;           % covarianza anualizada
    one  = ones(size(mu));
    
    invS = Sig\eye(size(Sig));
    A = one'*invS*one;  B = one'*invS*mu;  C = mu'*invS*mu;  D = A*C - B^2;
    m_mv  = B/A;
    mVals = linspace(m_mv+eps, max(mu)-eps, 120);
    
    rEff = zeros(size(mVals));
    REff = zeros(size(mVals));
    for i = 1:numel(mVals)
        m   = mVals(i);
        lam = (C - B*m)/D;
        gam = (A*m - B)/D;
        w   = invS*(lam*one + gam*mu);
        REff(i) = w'*mu;
        rEff(i) = sqrt(w'*Sig*w);
    end
    frontierRisk{g} = rEff;
    frontierRet{g}  = REff;
    
    w_mv      = invS*one/A;
    riskMV(g) = sqrt(w_mv'*Sig*w_mv);
    retMV(g)  = w_mv'*mu;
end
save resultadosFronteras.mat frontierRisk frontierRet riskMV retMV groupNames

%% 3. Gráfico
figure; hold on;
for g = 1:numel(groups)
    plot(frontierRisk{g},frontierRet{g},'LineWidth',2,'Color',clr(g,:));
    scatter(riskMV(g),retMV(g),60,'filled','MarkerEdgeColor','k', ...
            'MarkerFaceColor',clr(g,:));
end
xlabel('$\sigma$ anual','Interpreter','latex');
ylabel('Rendimiento anual esperado','Interpreter','latex');

title('Fronteras eficientes comparadas (2019-2024)');
% --- leyenda más clara: dos columnas, curvas a la izda. y puntos MV a la dcha. ---
h = get(gca,'Children');     % recupera los handles en el orden en que se pintaron
h = flipud(h);               % los invierte para que primero salgan las curvas
legend(h, [groupNames+" (frontera)", "MV "+groupNames], ...
       'Location','southeast', ...
       'NumColumns', 2, ...
       'Box', 'on');
grid on; box on; hold off;


