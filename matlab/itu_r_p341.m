% =========================================================================
%  PROBLEM 1 - NATEZENIE POLA (E) I GESTOSC MOCY (S) WG ITU-R P.341 (Annex 2)
%
%  Wzory z normy ITU-R P.341 (Aneks 2):
%     Q = GiT - 20*log10(d) - Lm + 10*log10(p) - Ltc          (9)
%     E = 14.77 + Q     [dB(V/m)]   ->  E = 20*log10(e)        (7)
%     S = -11.02 + Q    [dB(W/m^2)] ->  S = 10*log10(s)        (8)
%  gdzie:
%     GiT - wzmocnienie anteny nadawczej wzgl. izotropowej [dBi]  (2..18 dBi)
%     d   - odleglosc od anteny [m]                               (0..1000 m)
%     Lm  - strata wzgl. wolnej przestrzeni ("loss relative to free space") [dB]
%     p   - moc nadajnika [W]
%     Ltc - strata obwodu anteny nadawczej [dB]
%
%  Uruchomienie: itu_r_p341
% =========================================================================

clear; clc; close all;

%% ------------------------- DANE WEJSCIOWE -------------------------------
GiT_zakres = [2 18];     % [dBi] zakres wzmocnienia anteny (skrajne wartosci)
GiT_rep    = [2 10 18];  % [dBi] reprezentatywne wartosci do rodziny krzywych

p   = 0.1;               % [W]  moc nadajnika (= 20 dBm, jak w bilansie)
Ltc = 1;                 % [dB] strata obwodu anteny nad. (kabel 2 m * 0.5 dB/m)
Lm  = 0;                 % [dB] strata wzgl. wolnej przestrzeni (0 = wolna przestrzen)

% Odleglosc 0..1000 m (od 1 m, aby uniknac log10(0))
d = 1:1:1000;            % [m]

% Stale konwersji
E_const = 14.77;         % [dB] stala dla natezenia pola E (eq.7)
S_const = -11.02;        % [dB] stala dla gestosci mocy S (eq.8)

%% ----------------- FUNKCJE WG NORMY (eq. 7, 8, 9) -----------------------
Qfun = @(GiT,d,Lm) GiT - 20*log10(d) - Lm + 10*log10(p) - Ltc;  % (9)
Efun = @(Q) E_const + Q;     % [dB(V/m)]    (7)
Sfun = @(Q) S_const + Q;     % [dB(W/m^2)]  (8)

%% --------------- OBLICZENIA DLA RODZINY KRZYWYCH GiT --------------------
nG = numel(GiT_rep);
Q = zeros(nG, numel(d));
E = zeros(nG, numel(d));
S = zeros(nG, numel(d));
for i = 1:nG
    Q(i,:) = Qfun(GiT_rep(i), d, Lm);
    E(i,:) = Efun(Q(i,:));
    S(i,:) = Sfun(Q(i,:));
end

% Wartosci liniowe (dla informacji)
e_lin = 10.^(E/20);      % [V/m]
s_lin = 10.^(S/10);      % [W/m^2]
E_uV  = E + 120;         % [dB(uV/m)] - czesto stosowana jednostka

%% --------------------------- WYDRUK TABELI ------------------------------
d_pick = [10 50 100 500 1000];     % [m] punkty kontrolne
fprintf('\n==============================================================\n');
fprintf(' ITU-R P.341 (Annex 2)  |  p=%g W  Ltc=%g dB  Lm=%g dB\n', p, Ltc, Lm);
fprintf('==============================================================\n');
for i = 1:nG
    fprintf('\n GiT = %g dBi\n', GiT_rep(i));
    fprintf('%8s %10s %12s %14s %14s\n','d[m]','Q[dB]','E[dB(V/m)]','S[dB(W/m^2)]','e[mV/m]');
    for dp = d_pick
        qv = Qfun(GiT_rep(i), dp, Lm);
        ev = Efun(qv); sv = Sfun(qv);
        fprintf('%8d %10.2f %12.2f %14.2f %14.4f\n',...
                dp, qv, ev, sv, 1e3*10^(ev/20));
    end
end
fprintf('==============================================================\n\n');

%% ------------------------------ WYKRESY ---------------------------------
leg = arrayfun(@(g) sprintf('GiT = %g dBi', g), GiT_rep, 'UniformOutput', false);

% Wykres 1: Q w funkcji odleglosci
figure('Name','Q wg ITU-R P.341');
plot(d, Q, 'LineWidth',1.6); grid on;
xlabel('Odleglosc d [m]'); ylabel('Q [dB]');
title('Parametr Q wg ITU-R P.341 (Annex 2)');
legend(leg,'Location','northeast');

% Wykres 2: natezenie pola E w funkcji odleglosci
figure('Name','Natezenie pola E');
plot(d, E, 'LineWidth',1.6); grid on;
xlabel('Odleglosc d [m]'); ylabel('E [dB(V/m)]');
title('Natezenie pola E w funkcji odleglosci');
legend(leg,'Location','northeast');

% Wykres 3: gestosc mocy S w funkcji odleglosci
figure('Name','Gestosc mocy S');
plot(d, S, 'LineWidth',1.6); grid on;
xlabel('Odleglosc d [m]'); ylabel('S [dB(W/m^2)]');
title('Gestosc mocy promieniowania S w funkcji odleglosci');
legend(leg,'Location','northeast');

% Wykres 4: E oraz S w funkcji wzmocnienia GiT (dla wybranej odleglosci)
d_fix = 100;             % [m]
GiT_vec = GiT_zakres(1):0.5:GiT_zakres(2);
Q_g = Qfun(GiT_vec, d_fix, Lm);
figure('Name','E i S vs GiT');
plot(GiT_vec, Efun(Q_g), '-o', 'LineWidth',1.6, 'Color',[0 0.45 0.74]); hold on;
plot(GiT_vec, Sfun(Q_g), '-s', 'LineWidth',1.6, 'Color',[0.85 0.33 0.10]);
grid on; hold off;
xlabel('Wzmocnienie anteny GiT [dBi]');
ylabel('E [dB(V/m)]  oraz  S [dB(W/m^2)]');
title(sprintf('E oraz S w funkcji GiT (d = %d m)', d_fix));
legend('E [dB(V/m)]','S [dB(W/m^2)]','Location','northwest');

% Wykres 5: powierzchnia E(GiT, d)
[Dg, Gg] = meshgrid(d, GiT_zakres(1):1:GiT_zakres(2));
Es = Efun(Qfun(Gg, Dg, Lm));
figure('Name','Powierzchnia E(GiT,d)');
surf(Dg, Gg, Es, 'EdgeColor','none'); 
xlabel('d [m]'); ylabel('GiT [dBi]'); zlabel('E [dB(V/m)]');
title('Natezenie pola E w funkcji odleglosci i wzmocnienia anteny');
colorbar; view(135,30);

% Zapis wykresow
try
    saveas(figure(1),'itu_Q.png');
    saveas(figure(2),'itu_E.png');
    saveas(figure(3),'itu_S.png');
    saveas(figure(4),'itu_E_S_vs_GiT.png');
    saveas(figure(5),'itu_E_surf.png');
catch
end
