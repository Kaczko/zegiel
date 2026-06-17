% =========================================================================
%  PRZESZKODY RADIOWE - orientacyjne tlumienie materialow budowlanych
%
%  Tabela tlumienia (orientacyjnego) sygnalu radiowego przez typowe
%  przeszkody dla pasm 2.4 GHz i 5 GHz. Dla zadania (1500 MHz) jako
%  odniesienie przyjmuje sie wartosci dla 2.4 GHz - przy nizszej
%  czestotliwosci tlumienie jest zwykle nieco mniejsze (wartosc
%  bezpieczna/gorna oszacowania).
%
%  Skrypt:
%   - wyswietla tabele tlumien,
%   - liczy laczne tlumienie dla przykladowego zestawu przeszkod,
%   - pokazuje wplyw przeszkod na moc odbierana (powiazanie z bilansem).
%
%  Uruchomienie: przeszkody_radiowe
% =========================================================================

clear; clc; close all;

%% --------------------------- DANE (tabela) ------------------------------
% kolumny: nazwa | min@2.4 | max@2.4 | min@5 | max@5   [dB]
mat = {
 'Drewno / plyta gipsowo-kartonowa',      2,  5,   5, 10
 'Szklo zwykle (pojedyncze)',             2,  3,   4,  6
 'Cegla (zwykla sciana dzialowa)',        5, 10,  15, 20
 'Pustak / beton komorkowy',              5, 15,  15, 25
 'Szklo niskoemisyjne (powloka metal.)', 10, 30,  20, 40
 'Beton (niezbrojony)',                  15, 20,  30, 40
 'Strop zelbetonowy',                    15, 25,  30, 45
 'Beton zbrojony (sciana nosna)',        20, 30,  40, 55
 'Metalowe drzwi / folia / lustro',      30, 40,  60, 80   % ~calkowity brak sygnalu
};

%% --------------------------- WYDRUK TABELI ------------------------------
fprintf('\n===========================================================================\n');
fprintf(' ORIENTACYJNE TLUMIENIE PRZESZKOD RADIOWYCH\n');
fprintf('===========================================================================\n');
fprintf('%-40s | %-12s | %-12s\n','Material','2.4 GHz [dB]','5 GHz [dB]');
fprintf('---------------------------------------------------------------------------\n');
for i = 1:size(mat,1)
    fprintf('%-40s | %4g - %-5g | %4g - %-5g\n', ...
        mat{i,1}, mat{i,2}, mat{i,3}, mat{i,4}, mat{i,5});
end
fprintf('===========================================================================\n');

%% ---------------- PRZYKLAD: laczne tlumienie przeszkod ------------------
% Przyklad: sygnal pokonuje 2 sciany dzialowe z cegly + 1 strop zelbetonowy.
wybor = {'Cegla (zwykla sciana dzialowa)', 'Cegla (zwykla sciana dzialowa)', ...
         'Strop zelbetonowy'};

% Sumowanie tlumien wybranych przeszkod dla pasma 2.4 GHz (kolumny 2 i 3)
kmin = 2; kmax = 3;
Lmin = 0; Lmax = 0;
for i = 1:numel(wybor)
    idx = find(strcmp(mat(:,1), wybor{i}), 1);
    if isempty(idx)
        warning('Nie znaleziono materialu: %s', wybor{i});
    else
        Lmin = Lmin + mat{idx,kmin};
        Lmax = Lmax + mat{idx,kmax};
    end
end
fprintf('\nPrzyklad (2 x cegla + strop zelbetonowy) @2.4 GHz:\n');
fprintf('  Laczne tlumienie przeszkod: %g - %g dB (srednio %.1f dB)\n', ...
        Lmin, Lmax, (Lmin+Lmax)/2);

%% ------------- WPLYW NA MOC ODBIERANA (powiazanie z bilansem) -----------
% Bazowa moc odbierana (przyklad z bilansu, przypadek sredni @1 km):
Prx_baza = -58;          % [dBm] przykladowa wartosc z problemu 2
Lsr = (Lmin+Lmax)/2;
fprintf('\n  Moc odbierana bez przeszkod: %g dBm\n', Prx_baza);
fprintf('  Moc odbierana z przeszkodami: %.1f dBm (spadek o %.1f dB)\n', ...
        Prx_baza - Lsr, Lsr);

%% ------------------------------ WYKRES ----------------------------------
figure('Name','Tlumienie przeszkod');
v24 = (cell2mat(mat(:,2)) + cell2mat(mat(:,3)))/2;   % srednia @2.4 GHz
v5  = (cell2mat(mat(:,4)) + cell2mat(mat(:,5)))/2;   % srednia @5 GHz
barh([v24 v5]); grid on;
set(gca,'YTick',1:size(mat,1),'YTickLabel',mat(:,1));
xlabel('Srednie tlumienie [dB]');
title('Orientacyjne tlumienie przeszkod radiowych');
legend('2.4 GHz','5 GHz','Location','southeast');
try, saveas(gcf,'przeszkody.png'); catch, end
