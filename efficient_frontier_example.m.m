%% -Frontera Eficiente- %%
mu  = [0.10  0.14  0.18]';                      % rendimientos medios
Sig = [0.015 0.010 0.008;                       % matriz de covarianzas
       0.010 0.040 0.018;
       0.008 0.018 0.035];

one = ones(3,1);
A = one'* (Sig\one);          B = one'*(Sig\mu);
C = mu'*(Sig\mu);             D = A*C - B^2;

m_min = B/A;                                  % retorno mínima varianza
m_max = max(mu) - 1e-4;                       % evita división por cero
mvals = linspace(m_min, m_max, 150);

sigma = zeros(size(mvals));
for k = 1:numel(mvals)
    m   = mvals(k);
    lam = (C - B*m)/D;
    nu  = (A*m - B)/D;
    w   = Sig\(lam*one + nu*mu);
    sigma(k) = sqrt(w'*Sig*w);
end

plot(sigma, mvals,'k-','LineWidth',1.2), grid on, box on
xlabel('$\sigma$','Interpreter','latex');
ylabel('$\mu$','Interpreter','latex'); title('Frontera eficiente ')
print -dpdf frontera_sintetica.pdf
