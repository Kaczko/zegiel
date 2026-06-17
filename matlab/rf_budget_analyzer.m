% =========================================================================
%  PROBLEM 3 - RF BUDGET ANALYZER (MATLAB RF Toolbox)
%
%  Model toru radiowego zbudowany wg schematu z obrazka (7 elementow):
%
%     [Filtr]-[Tlumik]-[Wzmacniacz]-[Antena/lacze]-[Wzmacniacz]-[Tlumik]-[Filtr]
%        1        2          3            4              5           6        7
%      <----------- TOR NADAWCZY ------->  | <--------- TOR ODBIORCZY ------->
%
%  Element 4 ("Antena/lacze") reprezentuje pare anten nadawcza+odbiorcza
%  oraz tlumienie wolnej przestrzeni (FSPL): G4 = Gtx + Grx - FSPL.
%
%  Parametry pochodza z obliczen z problemu 2 (bilans) oraz problemu 1 (ITU):
%     f   = 1500 MHz,  G_anteny = 10 dBi (sr.),  kable 0.5 dB/m (2 m + 4 m).
%
%  WYMAGA: RF Toolbox (funkcje rfbudget, rfelement, amplifier).
%  Uruchomienie: rf_budget_analyzer
% =========================================================================

clear; clc; close all;

%% ------------------------- DANE WEJSCIOWE -------------------------------
c    = 299792458;        % [m/s]
f    = 1500e6;           % [Hz]  czestotliwosc (zadanie nr 3)
Pin  = 20;               % [dBm] dostepna moc wejsciowa (moc nadawcza Ptx)
BW   = 20e6;             % [Hz]  pasmo sygnalu

Gtx  = 10;               % [dBi] wzmocnienie anteny nadawczej (srednie)
Grx  = 10;               % [dBi] wzmocnienie anteny odbiorczej (srednie)
d0   = 1000;             % [m]   odleglosc lacza dla modelu glownego

% Tlumienie wolnej przestrzeni dla d0
FSPL0 = 20*log10(d0) + 20*log10(f) + 20*log10(4*pi/c);   % [dB]
Gpath = Gtx + Grx - FSPL0;                               % [dB] netto elementu 4

fprintf('FSPL(%.0f m) = %.2f dB  ->  G_lacza (el.4) = %.2f dB\n', d0, FSPL0, Gpath);

%% ----------------- DEFINICJA ELEMENTOW TORU (7 stopni) ------------------
% Elementy bierne (filtry, tlumiki, lacze): NF = strata wtraceniowa = -Gain.
filtTX = rfelement('Name','Filtr TX',     'Gain',-6.005,'NF',6.005, 'OIP3',Inf);
attTX  = rfelement('Name','Tlumik TX',    'Gain',-3,    'NF',3,     'OIP3',Inf);
ampTX  = amplifier('Name','Wzmacniacz TX','Gain',30,    'NF',4,     'OIP3',40);
antena = rfelement('Name','Antena/lacze', 'Gain',Gpath, 'NF',-Gpath,'OIP3',Inf);
ampRX  = amplifier('Name','Wzmacniacz RX (LNA)','Gain',20,'NF',2,   'OIP3',25);
attRX  = rfelement('Name','Tlumik RX',    'Gain',-3,    'NF',3,     'OIP3',Inf);
filtRX = rfelement('Name','Filtr RX',     'Gain',-6.005,'NF',6.005, 'OIP3',Inf);

elementy = [filtTX, attTX, ampTX, antena, ampRX, attRX, filtRX];

%% --------------------- BUDOWA OBIEKTU RFBUDGET --------------------------
b = rfbudget(elementy, f, Pin, BW);
disp(b);                              % podsumowanie obiektu

%% --------------------- WYNIKI KASKADOWE (Friis) -------------------------
nazwy = {'Filtr TX','Tlumik TX','Wzm. TX','Antena/lacze',...
         'Wzm. RX','Tlumik RX','Filtr RX'};

GainT = b.TransducerGain(:);     % [dB]   skumulowane wzmocnienie
Pout  = b.OutputPower(:);        % [dBm]  moc wyjsciowa
NFc   = b.NF(:);                 % [dB]   skumulowany wsp. szumow
SNRc  = b.SNR(:);                % [dB]   skumulowany SNR
Fout  = b.OutputFrequency(:);    % [Hz]

T = table(nazwy(:), Fout/1e9, GainT, Pout, NFc, SNRc, ...
    'VariableNames', {'Stopien','Fout_GHz','GainT_dB','Pout_dBm','NF_dB','SNR_dB'});
disp(T);

fprintf('\n--- WYNIK KONCOWY (na wyjsciu toru) ---\n');
fprintf(' Moc odbierana Pout   = %8.2f dBm\n', Pout(end));
fprintf(' Wzmocnienie GainT    = %8.2f dB\n',  GainT(end));
fprintf(' Wsp. szumow NF       = %8.2f dB\n',  NFc(end));
fprintf(' SNR                  = %8.2f dB\n',  SNRc(end));

%% ------------------------------ WYKRESY ---------------------------------
x = 1:numel(nazwy);

figure('Name','RF budget - moc i wzmocnienie');
subplot(2,1,1);
stairs(x, Pout, '-o','LineWidth',1.6); grid on;
set(gca,'XTick',x,'XTickLabel',nazwy); xtickangle(30);
ylabel('P_{out} [dBm]'); title('Moc kaskadowa (Friis-Pout)');
subplot(2,1,2);
stairs(x, GainT, '-s','LineWidth',1.6); grid on;
set(gca,'XTick',x,'XTickLabel',nazwy); xtickangle(30);
ylabel('GainT [dB]'); title('Wzmocnienie skumulowane (Friis-GainT)');

figure('Name','RF budget - NF i SNR');
subplot(2,1,1);
stairs(x, NFc, '-o','LineWidth',1.6); grid on;
set(gca,'XTick',x,'XTickLabel',nazwy); xtickangle(30);
ylabel('NF [dB]'); title('Wspolczynnik szumow (Friis-NF)');
subplot(2,1,2);
stairs(x, SNRc, '-s','LineWidth',1.6); grid on;
set(gca,'XTick',x,'XTickLabel',nazwy); xtickangle(30);
ylabel('SNR [dB]'); title('Stosunek sygnal/szum (Friis-SNR)');

%% ------------- ANALIZA W FUNKCJI ODLEGLOSCI (powiazanie z bilansem) -----
d = 500:500:5000;                     % [m]
Pout_d = zeros(size(d));
SNR_d  = zeros(size(d));
for k = 1:numel(d)
    FSPL = 20*log10(d(k)) + 20*log10(f) + 20*log10(4*pi/c);
    ant_k = rfelement('Name','Antena/lacze','Gain',Gtx+Grx-FSPL,...
                      'NF',FSPL-Gtx-Grx,'OIP3',Inf);
    bk = rfbudget([filtTX, attTX, ampTX, ant_k, ampRX, attRX, filtRX], f, Pin, BW);
    Pout_d(k) = bk.OutputPower(end);
    SNR_d(k)  = bk.SNR(end);
end

figure('Name','RF budget vs odleglosc');
yyaxis left;  plot(d/1000, Pout_d,'-o','LineWidth',1.6); ylabel('P_{out} [dBm]');
yyaxis right; plot(d/1000, SNR_d ,'-s','LineWidth',1.6); ylabel('SNR [dB]');
grid on; xlabel('Odleglosc d [km]');
title('Moc odbierana i SNR w funkcji odleglosci (RF budget)');

%% --------------------- EKSPORT / OTWARCIE APLIKACJI ---------------------
% Otwarcie interaktywnej aplikacji RF Budget Analyzer:
%   rfBudgetAnalyzer(b)
% Wygenerowanie raportu HTML:
%   show(b)
% Wygenerowanie skryptu MATLAB odtwarzajacego budzet:
%   exportScript(b)

try
    saveas(figure(1),'rfb_moc_gain.png');
    saveas(figure(2),'rfb_nf_snr.png');
    saveas(figure(3),'rfb_vs_dist.png');
catch
end
