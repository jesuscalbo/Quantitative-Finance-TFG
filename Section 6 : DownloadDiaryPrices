ffunction tbl = alphaDaily(ticker, ~, startDate, endDate)
% ALPHADAILY Descarga precios diarios de STOOQ.

    % Construimos URL
    url = sprintf("https://stooq.com/q/d/l/?s=%s.us&i=d", lower(ticker));

    try
        % Opción A: Intentamos leer directamente (funciona en el 99% de los casos)
        raw = readtable(url, 'FileType', 'text');
    catch
        % Opción B: Si falla, forzamos formato CSV clásico
        opts = detectImportOptions(url); % Nombre corregido
        opts.VariableTypes{'Date'} = 'datetime';
        raw = readtable(url, opts);
    end

    % Comprobación de datos
    if width(raw) < 2
        error('STOOQ no devolvió datos para %s.', ticker);
    end

    % Limpieza y Orden
    % Convertimos fecha si no se ha detectado automáticamente
    if ~isdatetime(raw.Date)
        raw.Date = datetime(raw.Date, 'InputFormat', 'yyyy-MM-dd');
    end
    
    raw = sortrows(raw, "Date");
    
    % Filtramos por fechas
    sel = raw.Date >= datetime(startDate) & raw.Date <= datetime(endDate);
    % Devolvemos solo Fecha y Cierre
    % Usamos indexación numérica para asegurar (Col 1=Date, Col 5=Close normalmente)
    % Pero por seguridad usamos nombres si existen:
    if ismember('Close', raw.Properties.VariableNames)
        prec = raw.Close(sel);
    elseif ismember('AdjClose', raw.Properties.VariableNames)
        prec = raw.AdjClose(sel);
    else
        % Fallback: la última columna es el cierre en Stooq simplificado
        prec = raw{sel, end}; 
    end

    tbl = table(raw.Date(sel), prec, 'VariableNames', {'Date', 'AdjClose'});
end
