% =========================================================================
%  PROBLEM 2 (wariant) - RADIOWY BILANS MOCY Z PRZESZKODAMI
%  Zadanie nr 3:  f = 1500 MHz
%
%  Skrypt liczy bilans mocy tak jak bilans_radiowy.m, ale DODATKOWO
%  uwzglednia tlumienie wybranych przeszkod radiowych (tabela dla 1,5 GHz).
%
%  Zalozenia (jak w bilans_radiowy.m):
%     f   = 1500 MHz
%     Ptx = 10..20 dBm           (moc nadawcza)
%     Pmin= -90 dBm              (czulosc odbiornika)
%     Gtx = 2..16 dBi            (antena nadawcza)
%     Grx = 10..18 dBi           (antena odbiorcza)
%     kable: 2 m (nadawczy) + 4 m (odbiorczy), 0.5 dB/m
%
%  3 punkty pomiarowe (strata MIN / MAX / SR) - laczone skrajne wartosci
%  mocy, wzmocnienia anten ORAZ tlumienia przeszkod.
%
%  Uruchomienie: bilans_z_przeszkodami
% =========================================================================

clear; clc; close all;

%% ------------------------- DANE WEJSCIOWE -------------------------------
c   = 299792458;        % [m/s]
f   = 1500e6;           % [Hz]

Ptx_min = 10;  Ptx_max = 20;  Ptx_sr = (Ptx_min+Ptx_max)/2;     % [dBm]
Gtx_min = 2;   Gtx_max = 16;  Gtx_sr = (Gtx_min+Gtx_max)/2;     % [dBi] antena Tx
Grx_min = 10;  Grx_max = 18;  Grx_sr = (Grx_min+Grx_max)/2;     % [dBi] antena Rx

alpha_kabel = 0.5;      % [dB/m]
L_tx = alpha_kabel*2;   % [dB] tor nadawczy
L_rx = alpha_kabel*4;   % [dB] tor odbiorczy
L_tor = L_tx + L_rx;    % [dB]
L_misc = 0;             % [dB]

Pmin = -90;             % [dBm] czulosc odbiornika
d = 500:500:5000;       % [m]

%% --------- TABELA TLUMIENIA PRZESZKOD DLA 1,5 GHz [dB] ------------------
% kolumny: nazwa | L_min | L_max
przeszkody = {
 'Drewno / plyta gipsowo-kartonowa',      1,  4
 'Szklo zwykle (pojedyncze)',             1,  2
 'Cegla (zwykla sciana dzialowa)',        3,  8
 'Pustak / beton komorkowy',              4, 12
 'Szklo niskoemisyjne (powloka metal.)',  8, 25
 'Beton (niezbrojony)',                  10, 18
 'Strop zelbetonowy',                    12, 22
 'Beton zbrojony (sciana nosna)',        15, 28
 'Metalowe drzwi / folia / lustro',      20, 35
};

%% ------------------- WYBRANE PRZESZKODY (SCENARIUSZ) --------------------
% { nazwa przeszkody , liczba sztuk } - mozna dowolnie zmieniac.
% Przyklad: sygnal pokonuje 2 sciany z cegly, 1 strop zelbetonowy i 1 szybe.
scenariusz = {
 'Cegla (zwykla sciana dzialowa)',  2
 'Strop zelbetonowy',               1
 'Szklo zwykle (pojedyncze)',       1
};

% Sumowanie tlumienia wybranych przeszkod (min/max/sr)
Lp_min = 0; Lp_max = 0;
for i = 1:size(scenariusz,1)
    idx = find(strcmp(przeszkody(:,1), scenariusz{i,1}), 1);
    if isempty(idx)
        warning('Nie znaleziono przeszkody: %s', scenariusz{i,1});
        continue;
    end
    n = scenariusz{i,2};
    Lp_min = Lp_min + n*przeszkody{idx,2};
    Lp_max = Lp_max + n*przeszkody{idx,3};
end
Lp_sr = (Lp_min + Lp_max)/2;

%% --------------------- TLUMIENIE WOLNEJ PRZESTRZENI ---------------------
FSPL = 20*log10(d) + 20*log10(f) + 20*log10(4*pi/c);    % [dB]

%% ------------------------ MOC ODBIERANA (Rx) ----------------------------
% Prx = Ptx + Gtx + Grx - L_tor - L_misc - Lp - FSPL
% best  (strata MIN): max moc/wzm. + MIN tlumienie przeszkod
% worst (strata MAX): min moc/wzm. + MAX tlumienie przeszkod
% avg   (strata SR) : wartosci srednie
Prx_best  = (Ptx_max + Gtx_max + Grx_max) - L_tor - L_misc - Lp_min - FSPL;
Prx_worst = (Ptx_min + Gtx_min + Grx_min) - L_tor - L_misc - Lp_max - FSPL;
Prx_avg   = (Ptx_sr  + Gtx_sr  + Grx_sr ) - L_tor - L_misc - Lp_sr  - FSPL;

% Dla porownania: przypadek sredni BEZ przeszkod
Prx_avg_bez = (Ptx_sr + Gtx_sr + Grx_sr) - L_tor - L_misc - FSPL;

%% --------------------------- MARGINES MOCY ------------------------------
M_best  = Prx_best  - Pmin;
M_worst = Prx_worst - Pmin;
M_avg   = Prx_avg   - Pmin;

%% --------------------------- WYDRUK -------------------------------------
fprintf('\n==============================================================\n');
fprintf(' BILANS MOCY Z PRZESZKODAMI  -  f = %.0f MHz\n', f/1e6);
fprintf('==============================================================\n');
fprintf(' Scenariusz przeszkod:\n');
for i = 1:size(scenariusz,1)
    fprintf('   %2dx  %s\n', scenariusz{i,2}, scenariusz{i,1});
end
fprintf(' Laczne tlumienie przeszkod: %g .. %g dB (sr. %.1f dB)\n', ...
        Lp_min, Lp_max, Lp_sr);
fprintf('--------------------------------------------------------------\n');
fprintf('%6s | %10s %10s %10s | %8s %8s %8s\n',...
        'd[m]','Prx_min','Prx_sr','Prx_max','M_min','M_sr','M_max');
fprintf('--------------------------------------------------------------\n');
for k = 1:numel(d)
    fprintf('%6d | %10.2f %10.2f %10.2f | %8.2f %8.2f %8.2f\n',...
        d(k), Prx_worst(k), Prx_avg(k), Prx_best(k), ...
        M_worst(k), M_avg(k), M_best(k));
end
fprintf('==============================================================\n');
fprintf(' Margines < 0 dB => brak poprawnego odbioru.\n\n');

%% ------------------------------ WYKRESY ---------------------------------
% Wykres 1: moc odbierana z przeszkodami (3 przypadki) + odniesienie bez przeszkod
figure('Name','Moc odbierana Rx z przeszkodami');
plot(d/1000, Prx_best ,'-o','LineWidth',1.6); hold on;
plot(d/1000, Prx_avg  ,'-s','LineWidth',1.6);
plot(d/1000, Prx_worst,'-^','LineWidth',1.6);
plot(d/1000, Prx_avg_bez,':d','LineWidth',1.4,'Color',[0.2 0.6 0.2]);
xl = xlim; plot(xl,[Pmin Pmin],'--','Color',[0.4 0.4 0.4],'LineWidth',1.2);
grid on; hold off;
xlabel('Odleglosc d [km]'); ylabel('Moc odbierana P_{rx} [dBm]');
title(sprintf('Moc odbierana z przeszkodami (f = %.0f MHz, L_{przeszk}=%g..%g dB)',...
      f/1e6, Lp_min, Lp_max));
legend('strata MIN (najlepszy, L_{przeszk} min)',...
       'strata SR  (sredni)',...
       'strata MAX (najgorszy, L_{przeszk} max)',...
       'sredni BEZ przeszkod',...
       'czulosc P_{min}','Location','northeast');

% Wykres 2: margines mocy z przeszkodami
figure('Name','Margines mocy z przeszkodami');
plot(d/1000, M_best ,'-o','LineWidth',1.6); hold on;
plot(d/1000, M_avg  ,'-s','LineWidth',1.6);
plot(d/1000, M_worst,'-^','LineWidth',1.6);
xl = xlim; plot(xl,[0 0],'--','Color',[0.4 0.4 0.4],'LineWidth',1.2);
grid on; hold off;
xlabel('Odleglosc d [km]'); ylabel('Margines mocy M [dB]');
title('Margines mocy z uwzglednieniem przeszkod');
legend('strata MIN','strata SR','strata MAX','M = 0 dB','Location','northeast');

% Zapis wykresow
try
    saveas(figure(1),'bilans_przeszkody_moc.png');
    saveas(figure(2),'bilans_przeszkody_margines.png');
catch
end
