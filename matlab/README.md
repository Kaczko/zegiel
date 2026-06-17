# Projekt radiowy — MATLAB (zadanie nr 3, f = 1500 MHz)

Zestaw skryptów MATLAB realizujących projekt bilansu mocy łącza radiowego dla
wybranego zadania **nr 3 (częstotliwość 1500 MHz)**.

## Zawartość

| Plik | Problem | Opis |
|------|---------|------|
| `bilans_radiowy.m` | **Problem 2** | Radiowy bilans mocy: moc odbierana Rx oraz margines mocy w funkcji odległości (0,5–5 km). |
| `itu_r_p341.m` | **Problem 1** | Natężenie pola **E** i gęstość mocy **S** wg normy **ITU‑R P.341 (Annex 2)** oraz parametr **Q**. |
| `generuj_plik_mat.m` | **Problem 3** | Generator pliku **`.mat`** otwieralnego w aplikacji **RF Budget Analyzer**. |
| `rf_budget_analyzer.m` | **Problem 3** | Model toru w **RF Budget Analyzer** (RF Toolbox), schemat 7‑elementowy wg obrazka (wersja skryptowa z wykresami). |
| `przeszkody_radiowe.m` | **Przeszkody radiowe** | Orientacyjne tłumienie materiałów budowlanych i jego wpływ na moc odbieraną. |

Uruchomienie — w katalogu `matlab/` wpisać nazwę skryptu (bez rozszerzenia), np.:

```matlab
bilans_radiowy
itu_r_p341
rf_budget_analyzer        % wymaga RF Toolbox
przeszkody_radiowe
```

---

## Wspólne założenia

- Częstotliwość pracy: **f = 1500 MHz** (zadanie nr 3).
- Odcinek nadawczy (nadajnik → antena): **2 m**.
- Odcinek odbiorczy (antena → odbiornik): **4 m**.
- Tłumienie jednostkowe kabla: **0,5 dB/m** ⇒ strata toru nadawczego 1 dB, odbiorczego 2 dB.
- Moc nadawcza: **10–20 dBm**; czułość odbiornika: **−90 dBm**.
- Antena nadawcza: **2–16 dBi**; antena odbiorcza: **10–18 dBi**.
- (Problem 1 / ITU-R P.341 używa osobnego zakresu `GiT` = **2–18 dBi**.)

Tłumienie wolnej przestrzeni (FSPL):

```
FSPL[dB] = 20·log10(d) + 20·log10(f) + 20·log10(4·π/c)
```

---

## Problem 2 — `bilans_radiowy.m`

Moc odbierana:

```
Prx = Ptx + Gtx + Grx − L_tx − L_rx − FSPL(d)
```

Margines mocy: `M = Prx − Pmin`, gdzie `Pmin` to czułość odbiornika (domyślnie −90 dBm).

Analizowane **3 punkty pomiarowe** (wg skrajnych/średnich wartości mocy nadawczej
i wzmocnienia anten — Tx 2–16 dBi, Rx 10–18 dBi):

- **strata MINIMALNA** (najlepszy przypadek): `Ptx_max`, `Gtx_max`, `Grx_max`,
- **strata MAKSYMALNA** (najgorszy przypadek): `Ptx_min`, `Gtx_min`, `Grx_min`,
- **strata ŚREDNIA** (typowy przypadek): wartości średnie.

Wynik: tabela w konsoli oraz wykresy `Prx(d)` i `M(d)` dla odległości 500 m … 5 km
(krok 500 m), z zaznaczoną czułością odbiornika / granicą odbioru.

## Problem 1 — `itu_r_p341.m`

Wzory wg ITU‑R P.341 (Annex 2):

```
Q = GiT − 20·log10(d) − Lm + 10·log10(p) − Ltc      (9)
E = 14.77 + Q      [dB(V/m)]                          (7)
S = −11.02 + Q     [dB(W/m^2)]                        (8)
```

gdzie: `GiT` — wzmocnienie anteny (2–18 dBi), `d` — odległość (0–1000 m),
`Lm` — strata względem wolnej przestrzeni, `p` — moc nadajnika [W],
`Ltc` — strata obwodu anteny nadawczej [dB].

Wynik: tabela wartości oraz wykresy `Q(d)`, `E(d)`, `S(d)` (rodzina krzywych dla
GiT = 2/10/18 dBi), `E,S(GiT)` oraz powierzchnia `E(GiT, d)`.

## Problem 3 — `rf_budget_analyzer.m`

Schemat toru (7 elementów) wzorowany na podanym obrazku:

```
[Filtr]-[Tłumik]-[Wzmacniacz]-[Antena/łącze]-[Wzmacniacz]-[Tłumik]-[Filtr]
   1        2          3             4              5           6        7
 <-------- tor nadawczy --------->  |  <--------- tor odbiorczy --------->
```

Element 4 („Antena/łącze”) reprezentuje parę anten oraz tłumienie wolnej
przestrzeni: `G4 = Gtx + Grx − FSPL(d)`. Budżet liczony jest obiektem `rfbudget`
(solver Friisa). Skrypt wypisuje tabelę wyników kaskadowych (Friis‑Pout,
Friis‑GainT, Friis‑NF, Friis‑SNR) i rysuje je w funkcji stopnia oraz odległości.

> **Wymaga RF Toolbox.** Aplikację interaktywną otwiera `rfBudgetAnalyzer(b)`,
> raport HTML — `show(b)`, a skrypt odtwarzający budżet — `exportScript(b)`.

### Plik `.mat` do aplikacji RF Budget Analyzer

Aplikacja RF Budget Analyzer otwiera plik `.mat` zawierający obiekt `rfbudget`.
Obiektu tego **nie da się utworzyć poza MATLAB-em** (to klasa z RF Toolbox),
dlatego plik generuje się jednym uruchomieniem skryptu:

```matlab
generuj_plik_mat            % tworzy rfbudget_uklad.mat
```

Otwarcie gotowego pliku w aplikacji (dowolny sposób):

```matlab
rfBudgetAnalyzer('rfbudget_uklad.mat')   % bezposrednio z pliku
% albo
load('rfbudget_uklad.mat','rfb');  show(rfb)
% albo: APPS -> RF Budget Analyzer -> Open -> wybierz plik
```

Układ odwzorowuje **1:1 schemat z obrazka** (f = 1500 MHz, Pin = −20 dBm, BW = 20 MHz):

| # | Element | GainT [dB] | NF [dB] | OIP3 [dBm] |
|---|---------|-----------:|--------:|-----------:|
| 1 | Filter | −6.005 | 0 | Inf |
| 2 | Attenuator | −3 | 3 | Inf |
| 3 | Amplifier | 0 | 0 | Inf |
| 4 | Antenna | 6 | 0 | Inf |
| 5 | Amplifier | 0 | 0 | Inf |
| 6 | Attenuator | −3 | 3 | Inf |
| 7 | Filter | −6.005 | 0 | Inf |

## Przeszkody radiowe — `przeszkody_radiowe.m`

Tabela orientacyjnego tłumienia typowych materiałów (2,4 GHz / 5 GHz),
sumowanie tłumienia wybranego zestawu przeszkód oraz pokazanie wpływu na moc
odbieraną z bilansu.

---

## Uwagi techniczne

- Skrypty `bilans_radiowy.m`, `itu_r_p341.m`, `przeszkody_radiowe.m` zostały
  zweryfikowane numerycznie w GNU Octave 8.4 (część obliczeniowa i generowanie
  wykresów).
- `rf_budget_analyzer.m` korzysta z RF Toolbox (funkcje `rfbudget`, `rfelement`,
  `amplifier`) dostępnego wyłącznie w MATLAB — należy uruchomić w MATLAB.
- Każdy skrypt zapisuje wygenerowane wykresy do plików PNG (przydatne w
  sprawozdaniu).
