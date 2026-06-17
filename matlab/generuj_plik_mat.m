% =========================================================================
%  GENERATOR PLIKU .MAT DLA RF BUDGET ANALYZER  (zadanie nr 3)
%
%  Skrypt buduje obiekt rfbudget odwzorowujacy UKLAD Z OBRAZKA (1:1) i
%  zapisuje go do pliku  rfbudget_uklad.mat , ktory mozna OTWORZYC w
%  aplikacji RF Budget Analyzer.
%
%  >>> URUCHOM RAZ W MATLAB-ie (wymaga RF Toolbox):  generuj_plik_mat
%
%  Otwarcie gotowego pliku w aplikacji (dowolny sposob):
%     rfBudgetAnalyzer('rfbudget_uklad.mat')
%   albo:
%     load('rfbudget_uklad.mat','rfb');  show(rfb)
%   albo w aplikacji: zakladka APPS -> RF Budget Analyzer -> Open -> wybierz plik.
%
%  UKLAD (7 elementow) - wartosci dokladnie jak na obrazku:
%   #  element       GainT[dB]  NF[dB]  OIP3[dBm]
%   1  Filter         -6.005      0       Inf
%   2  Attenuator     -3          3       Inf
%   3  Amplifier       0          0       Inf
%   4  Antenna         6          0       Inf
%   5  Amplifier       0          0       Inf
%   6  Attenuator     -3          3       Inf
%   7  Filter         -6.005      0       Inf
% =========================================================================

clear; clc;

%% ------------------------- PARAMETRY GLOWNE -----------------------------
f    = 1500e6;           % [Hz]  czestotliwosc (zadanie nr 3 = 1500 MHz)
Pin  = -20;              % [dBm] dostepna moc wejsciowa (jak w przykladzie)
BW   = 20e6;             % [Hz]  pasmo sygnalu

%% ----------------- ELEMENTY TORU (wartosci 1:1 z obrazka) ---------------
% Uwaga: 'Name' musi byc poprawna nazwa zmiennej (bez spacji/znakow).
% Filtry i tlumiki -> rfelement; wzmacniacze -> amplifier; antena -> rfelement.
filtr1  = rfelement('Name','Filter1',    'Gain',-6.005, 'NF',0, 'OIP3',Inf);
tlumik1 = rfelement('Name','Attenuator1','Gain',-3,     'NF',3, 'OIP3',Inf);
wzm1    = amplifier('Name','Amplifier1', 'Gain',0,      'NF',0, 'OIP3',Inf);
antena  = rfelement('Name','Antenna',    'Gain',6,      'NF',0, 'OIP3',Inf);
wzm2    = amplifier('Name','Amplifier2', 'Gain',0,      'NF',0, 'OIP3',Inf);
tlumik2 = rfelement('Name','Attenuator2','Gain',-3,     'NF',3, 'OIP3',Inf);
filtr2  = rfelement('Name','Filter2',    'Gain',-6.005, 'NF',0, 'OIP3',Inf);

elementy = [filtr1, tlumik1, wzm1, antena, wzm2, tlumik2, filtr2];

% --- Alternatywa: element "Antenna" jako rfantenna (ikona anteny w aplikacji)
%     antena = rfantenna('Name','Antenna','Gain',6);
%   (domyslnie PathLoss = 0, wiec wzmocnienie wnosi +6 dB jak na obrazku)

%% ----------------------- BUDOWA I ZAPIS OBIEKTU -------------------------
rfb = rfbudget(elementy, f, Pin, BW);     %#ok<NASGU>

nazwaPliku = 'rfbudget_uklad.mat';
save(nazwaPliku, 'rfb');

fprintf('\nPlik "%s" zostal zapisany.\n', nazwaPliku);
fprintf('Otworz w aplikacji poleceniem:\n');
fprintf('   rfBudgetAnalyzer(''%s'')\n', nazwaPliku);
fprintf('lub:\n');
fprintf('   load(''%s'',''rfb''); show(rfb)\n\n', nazwaPliku);

% Mozna od razu otworzyc aplikacje z gotowym ukladem:
%   show(rfb)
