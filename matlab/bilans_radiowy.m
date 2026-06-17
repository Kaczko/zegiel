% =========================================================================
%  PROBLEM 2 - RADIOWY BILANS MOCY (LINK BUDGET)
%  Zadanie nr 3:  f = 1500 MHz
%
%  Program oblicza moc odbieran  (Rx) oraz margines mocy (Rx - czulosc
%  odbiornika) w funkcji odleglosci od 500 m do 5 km (krok 500 m).
%
%  Analizowane sa 3 punkty pomiarowe wyznaczone skrajnymi/srednimi
%  wartosciami mocy nadawczej oraz wzmocnienia anten:
%     - strata MINIMALNA  (najlepszy przypadek): Ptx_max, G_max
%     - strata MAKSYMALNA (najgorszy przypadek): Ptx_min, G_min
%     - strata SREDNIA    (przypadek typowy)    : Ptx_sr , G_sr
%
%  Odcinek nadawczy (nadajnik -> antena)  = 2 m
%  Odcinek odbiorczy (antena -> odbiornik)= 4 m
%
%  Uruchomienie: bilans_radiowy
% =========================================================================

clear; clc; close all;

%% ------------------------- DANE WEJSCIOWE -------------------------------
c   = 299792458;        % [m/s]  predkosc swiatla
f   = 1500e6;           % [Hz]   czestotliwosc pracy (zadanie nr 3)

% Moc nadawcza - wartosci skrajne [dBm]
Ptx_min = 10;           % [dBm]  (= 10 mW)
Ptx_max = 20;           % [dBm]  (= 100 mW)
Ptx_sr  = (Ptx_min + Ptx_max)/2;

% Wzmocnienie pojedynczej anteny - wartosci skrajne [dBi]
% (zakres zgodny z norma ITU-R P.341 uzyta w problemie 1: 2 - 18 dBi)
G_min = 2;              % [dBi]
G_max = 18;             % [dBi]
G_sr  = (G_min + G_max)/2;

% Tlumienie kabli zasilajacych anteny
alpha_kabel = 0.5;      % [dB/m] tlumienie jednostkowe kabla @1500 MHz
len_tx = 2;             % [m]   odcinek nadawczy
len_rx = 4;             % [m]   odcinek odbiorczy
L_tx = alpha_kabel * len_tx;    % [dB] strata toru nadawczego  = 1 dB
L_rx = alpha_kabel * len_rx;    % [dB] strata toru odbiorczego = 2 dB
L_tor = L_tx + L_rx;            % [dB] laczna strata torow

% Dodatkowe straty stale (zlacza, dopasowanie, zapas)
L_misc = 0;             % [dB]

% Czulosc odbiornika - minimalna moc mozliwa do odebrania
Pmin = -90;             % [dBm]

% Odleglosci analizy: 500 m ... 5 km, krok 500 m
d = 500:500:5000;       % [m]

%% --------------------- TLUMIENIE WOLNEJ PRZESTRZENI ---------------------
% FSPL = 20*log10(d) + 20*log10(f) + 20*log10(4*pi/c)   [dB]
FSPL = 20*log10(d) + 20*log10(f) + 20*log10(4*pi/c);    % wektor wzgledem d

%% ------------------------ MOC ODBIERANA (Rx) ----------------------------
% Prx = Ptx + Gtx + Grx - L_tx - L_rx - L_misc - FSPL
% (Gtx oraz Grx przyjmuja te same wartosci skrajne -> 2*G)

Prx_best  = (Ptx_max + 2*G_max) - L_tor - L_misc - FSPL;   % strata MIN
Prx_worst = (Ptx_min + 2*G_min) - L_tor - L_misc - FSPL;   % strata MAX
Prx_avg   = (Ptx_sr  + 2*G_sr ) - L_tor - L_misc - FSPL;   % strata SR

%% --------------------------- MARGINES MOCY ------------------------------
M_best  = Prx_best  - Pmin;
M_worst = Prx_worst - Pmin;
M_avg   = Prx_avg   - Pmin;

%% --------------------------- WYDRUK TABELI ------------------------------
fprintf('\n=========================================================\n');
fprintf(' RADIOWY BILANS MOCY  -  f = %.0f MHz\n', f/1e6);
fprintf('=========================================================\n');
fprintf(' Ptx: %g..%g dBm | G ant: %g..%g dBi | L_tor=%.1f dB | Pmin=%g dBm\n',...
        Ptx_min,Ptx_max,G_min,G_max,L_tor,Pmin);
fprintf('---------------------------------------------------------\n');
fprintf('%6s | %10s %10s %10s | %8s %8s %8s\n',...
        'd[m]','Prx_min','Prx_sr','Prx_max','M_min','M_sr','M_max');
fprintf('       | %10s %10s %10s | %8s %8s %8s\n',...
        '(L max)','(L sr)','(L min)','[dB]','[dB]','[dB]');
fprintf('---------------------------------------------------------\n');
for k = 1:numel(d)
    fprintf('%6d | %10.2f %10.2f %10.2f | %8.2f %8.2f %8.2f\n',...
        d(k), Prx_worst(k), Prx_avg(k), Prx_best(k), ...
        M_worst(k), M_avg(k), M_best(k));
end
fprintf('=========================================================\n');
fprintf(' Uwaga: margines < 0 dB  => brak poprawnego odbioru.\n\n');

%% ------------------------------ WYKRESY ---------------------------------
% Wykres 1: moc odbierana w funkcji odleglosci
figure('Name','Moc odbierana Rx');
plot(d/1000, Prx_best ,'-o','LineWidth',1.6); hold on;
plot(d/1000, Prx_avg  ,'-s','LineWidth',1.6);
plot(d/1000, Prx_worst,'-^','LineWidth',1.6);
xl = xlim; plot(xl,[Pmin Pmin],'--','Color',[0.4 0.4 0.4],'LineWidth',1.2);
grid on; hold off;
xlabel('Odleglosc d [km]');
ylabel('Moc odbierana P_{rx} [dBm]');
title(sprintf('Moc odbierana w funkcji odleglosci  (f = %.0f MHz)', f/1e6));
legend('strata MIN (Ptx_{max}, G_{max})',...
       'strata SR  (Ptx_{sr}, G_{sr})',...
       'strata MAX (Ptx_{min}, G_{min})',...
       'czulosc P_{min}','Location','northeast');

% Wykres 2: margines mocy w funkcji odleglosci
figure('Name','Margines mocy');
plot(d/1000, M_best ,'-o','LineWidth',1.6); hold on;
plot(d/1000, M_avg  ,'-s','LineWidth',1.6);
plot(d/1000, M_worst,'-^','LineWidth',1.6);
xl = xlim; plot(xl,[0 0],'--','Color',[0.4 0.4 0.4],'LineWidth',1.2);
grid on; hold off;
xlabel('Odleglosc d [km]');
ylabel('Margines mocy M [dB]');
title(sprintf('Margines mocy w funkcji odleglosci  (f = %.0f MHz)', f/1e6));
legend('strata MIN','strata SR','strata MAX',...
       'M = 0 dB','Location','northeast');

% Zapis wykresow do plikow PNG (przydatne w sprawozdaniu)
try
    saveas(figure(1),'bilans_moc_odbierana.png');
    saveas(figure(2),'bilans_margines.png');
catch
end
