% =========================================================================
%  GENERATOR PLIKU .MAT DLA RF BUDGET ANALYZER  (zadanie nr 3, 1500 MHz)
%
%  Skrypt buduje obiekt rfbudget zgodny z parametrami projektu i zapisuje go
%  do pliku  rfbudget_1500MHz.mat , ktory mozna OTWORZYC w aplikacji
%  RF Budget Analyzer.
%
%  >>> URUCHOM RAZ W MATLAB-ie (wymaga RF Toolbox):  generuj_plik_mat
%
%  Otwarcie gotowego pliku w aplikacji (dowolny z ponizszych sposobow):
%     rfBudgetAnalyzer('rfbudget_1500MHz.mat')
%   albo:
%     load('rfbudget_1500MHz.mat','rfb');  show(rfb)
%   albo w aplikacji: zakladka APPS -> RF Budget Analyzer -> Open -> wybierz plik.
%
%  Schemat (7 elementow, wzorowany na obrazku):
%   [Filtr]-[Tlumik]-[Wzmacniacz]-[Antena/lacze]-[Wzmacniacz]-[Tlumik]-[Filtr]
% =========================================================================

clear; clc;

%% ------------------------- PARAMETRY (zgodne z bilansem) ----------------
c    = 299792458;        % [m/s]
f    = 1500e6;           % [Hz]  czestotliwosc (zadanie nr 3)
Pin  = 20;               % [dBm] moc nadawcza Ptx (zakres 10..20 dBm)
BW   = 20e6;             % [Hz]  pasmo sygnalu

Gtx  = (2  + 16)/2;      % [dBi] antena nadawcza  (2..16 dBi)  -> 9 dBi
Grx  = (10 + 18)/2;      % [dBi] antena odbiorcza (10..18 dBi) -> 14 dBi
d0   = 1000;             % [m]   odleglosc lacza

FSPL0 = 20*log10(d0) + 20*log10(f) + 20*log10(4*pi/c);   % [dB]
Gpath = Gtx + Grx - FSPL0;                               % [dB] netto elementu "antena/lacze"

%% ----------------- ELEMENTY TORU (Name = poprawna nazwa zmiennej) -------
filtTX = rfelement('Name','FiltrTX',      'Gain',-6.005,'NF',6.005, 'OIP3',Inf);
attTX  = rfelement('Name','TlumikTX',     'Gain',-3,    'NF',3,     'OIP3',Inf);
ampTX  = amplifier('Name','WzmacniaczTX', 'Gain',30,    'NF',4,     'OIP3',40);
antena = rfelement('Name','AntenaLacze',  'Gain',Gpath, 'NF',-Gpath,'OIP3',Inf);
ampRX  = amplifier('Name','WzmacniaczRX', 'Gain',20,    'NF',2,     'OIP3',25);
attRX  = rfelement('Name','TlumikRX',     'Gain',-3,    'NF',3,     'OIP3',Inf);
filtRX = rfelement('Name','FiltrRX',      'Gain',-6.005,'NF',6.005, 'OIP3',Inf);

elementy = [filtTX, attTX, ampTX, antena, ampRX, attRX, filtRX];

%% ----------------------- BUDOWA I ZAPIS OBIEKTU -------------------------
rfb = rfbudget(elementy, f, Pin, BW);     %#ok<NASGU>  obiekt do zapisu

nazwaPliku = 'rfbudget_1500MHz.mat';
save(nazwaPliku, 'rfb');

fprintf('\nPlik "%s" zostal zapisany.\n', nazwaPliku);
fprintf('FSPL(%.0f m) = %.2f dB  ->  G_lacza = %.2f dB\n', d0, FSPL0, Gpath);
fprintf('Otworz w aplikacji poleceniem:\n');
fprintf('   rfBudgetAnalyzer(''%s'')\n', nazwaPliku);
fprintf('lub:\n');
fprintf('   load(''%s'',''rfb''); show(rfb)\n\n', nazwaPliku);

% Mozna od razu otworzyc aplikacje z gotowym ukladem:
%   show(rfb)
