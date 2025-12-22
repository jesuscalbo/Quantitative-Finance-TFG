function tbl = alphaDaily(ticker, ~, startDate, endDate)
% ALPHADAILY  Descarga precios diarios de STOOQ .
%   tbl = alphaDaily("AAPL", ~, "2019-01-01", "2024-01-01")
%
%   Devuelve una tabla con:
%       Date      – datetime
%       AdjClose  – precio de cierre (STOOQ solo publica Close)
%
%   • Sin límites de peticiones.
%   • Sin esperas.
%   • Sin dependencias externas.

    % ---- Construir URL de descarga ----
    url = sprintf("https://stooq.com/q/d/l/?s=%s.us&i=d", lower(ticker));

    % ---- Leer CSV ----
    raw = readtable(url, 'Delimiter', ',', 'FileType', 'text');

    % Comprobación rápida de que haya datos (>= 2 columnas)
    if width(raw) < 2
        error('STOOQ no devolvió datos para %s.', ticker);
    end

    % ---- Formatear ----
    raw.Date = datetime(raw.Date, 'InputFormat', 'yyyy-MM-dd');
    raw      = sortrows(raw, "Date");

    sel = raw.Date >= datetime(startDate) & raw.Date <= datetime(endDate);

    tbl = table(raw.Date(sel), raw.Close(sel), ...
                'VariableNames', {'Date', 'AdjClose'});
end
