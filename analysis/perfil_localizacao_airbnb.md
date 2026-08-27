# Perfil e Localização — Análise Airbnb

**Data:** 2026-08-26
**Base:** `outputs/base_airbnb_consolidada.csv` (999 listings)
**Amostra principal:** 847 listings (datas_estadia >= 30, diaria_mediana entre R$ 150 e R$ 2.500)

---

## 1. Tabela por bairro

### Bairros com pelo menos 30 listings (comparação principal)

| Bairro | Qtd | DM mediana | DM média | DM P25 | DM P75 | Qrt med | Hósp med | Datas med |
|--------|-----|-----------|----------|--------|--------|---------|----------|-----------|
| Meia Praia | 524 | R$ 595 | R$ 669 | R$ 450 | R$ 800 | 3 | 7 | 64 |
| Centro | 189 | R$ 509 | R$ 599 | R$ 385 | R$ 715 | 2 | 5 | 73 |
| Morretes | 69 | R$ 471 | R$ 522 | R$ 350 | R$ 600 | 2 | 6 | 65 |

### Bairros com menos de 30 listings (amostra pequena, sem ranking)

| Bairro | Qtd | DM mediana | DM média | DM P25 | DM P75 | Qrt med | Hósp med |
|--------|-----|-----------|----------|--------|--------|---------|----------|
| Tabuleiro dos Oliveiras | 17 | R$ 560 | R$ 676 | R$ 400 | R$ 670 | 2 | 6 |
| Casa Branca | 14 | R$ 350 | R$ 363 | R$ 300 | R$ 400 | 2 | 5 |
| Ilhota | 9 | R$ 500 | R$ 540 | R$ 350 | R$ 590 | 2 | 8 |
| Canto da Praia | 6 | R$ 600 | R$ 632 | R$ 518 | R$ 793 | 2 | 6 |
| Alto Sao Bento | 5 | R$ 280 | R$ 712 | R$ 199 | R$ 400 | 1 | 4 |
| Sertaozinho | 5 | R$ 500 | R$ 640 | R$ 369 | R$ 500 | 2 | 5 |
| Varzea | 2 | R$ 1.500 | R$ 845 | R$ 190 | R$ 1.500 | 5 | 15 |
| Outros (4 bairros) | 1-3 | — | — | — | — | — | — |

**Nota:** Tabuleiro dos Oliveiras (R$ 560) e Canto da Praia (R$ 600) têm medianas competitivas, mas com amostra pequena (17 e 6 listings). Casa Branca (R$ 350) e Alto Sao Bento (R$ 280) têm medianas baixas, também com amostra pequena.

---

## 2. Tabela por número de quartos

| Quartos | Qtd | DM mediana | DM média | DM P25 | DM P75 | Hósp med | Distribuição tipo |
|---------|-----|-----------|----------|--------|--------|----------|-------------------|
| 0 | 8 | R$ 490 | R$ 431 | R$ 331 | R$ 550 | 5 | apartamento=8 |
| 1 | 129 | R$ 400 | R$ 425 | R$ 330 | R$ 516 | 3 | apt=99; casa=17; outros=12; hotel=1 |
| 2 | 302 | R$ 464 | R$ 499 | R$ 350 | R$ 600 | 6 | apt=287; casa=15 |
| 3 | 337 | R$ 693 | R$ 710 | R$ 500 | R$ 850 | 8 | apt=327; casa=10 |
| 4 | 64 | R$ 1.000 | R$ 1.175 | R$ 850 | R$ 1.574 | 10 | apt=54; casa=10 |
| 5+ | 9 | R$ 1.500 | R$ 1.532 | R$ 1.450 | R$ 1.897 | 15 | apt=4; casa=5 |

**Observação:** A diária mediana sobe monotonicamente com quartos. Saltos relevantes: de 2 para 3 quartos (+50%) e de 3 para 4 quartos (+44%).

---

## 3. Tabela por listing_type

| Tipo | Qtd | DM mediana | DM média | DM P25 | DM P75 | Qrt med | Hósp med |
|------|-----|-----------|----------|--------|--------|---------|----------|
| apartamento | 779 | R$ 562 | R$ 637 | R$ 415 | R$ 770 | 2 | 6 |
| casa | 57 | R$ 500 | R$ 689 | R$ 350 | R$ 946 | 2 | 8 |
| outros | 12 | R$ 179 | R$ 197 | R$ 150 | R$ 250 | 1 | 2 |
| hotel | 1 | R$ 330 | R$ 330 | R$ 330 | R$ 330 | 1 | 4 |

**Observação:** Apartamentos dominam a amostra (91,8%). Casas têm mediana levemente menor (R$ 500 vs R$ 562) mas média maior (R$ 689 vs R$ 637), indicando maior variabilidade.

---

## 4. Tabela combinada (suburb + tipo + quartos) — grupos com pelo menos 10 listings

| Bairro | Tipo | Quartos | Qtd | DM mediana | DM média | DM P25 | DM P75 | Hósp med |
|--------|------|---------|-----|-----------|----------|--------|--------|----------|
| Meia Praia | apt | 3 | 273 | R$ 697 | R$ 708 | R$ 520 | R$ 842 | 8 |
| Meia Praia | apt | 2 | 156 | R$ 450 | R$ 483 | R$ 380 | R$ 585 | 6 |
| Centro | apt | 1 | 76 | R$ 450 | R$ 468 | R$ 378 | R$ 537 | 4 |
| Centro | apt | 2 | 61 | R$ 583 | R$ 601 | R$ 399 | R$ 715 | 6 |
| Meia Praia | apt | 4 | 47 | R$ 900 | R$ 1.216 | R$ 850 | R$ 1.604 | 10 |
| Morretes | apt | 2 | 43 | R$ 464 | R$ 471 | R$ 350 | R$ 550 | 5 |
| Centro | apt | 3 | 39 | R$ 750 | R$ 785 | R$ 518 | R$ 897 | 8 |
| Meia Praia | apt | 1 | 17 | R$ 490 | R$ 466 | R$ 400 | R$ 545 | 4 |
| Casa Branca | apt | 2 | 11 | R$ 350 | R$ 361 | R$ 280 | R$ 400 | 5 |
| Tab. Oliveiras | apt | 2 | 10 | R$ 550 | R$ 509 | R$ 399 | R$ 644 | 6 |

---

## 5. Grupos específicos

| Grupo | Qtd | DM mediana | DM média | DM P25 | DM P75 | Hósp med | Datas med |
|-------|-----|-----------|----------|--------|--------|----------|-----------|
| Apt 0-1q Centro | 76 | R$ 450 | R$ 468 | R$ 378 | R$ 537 | 4 | 77 |
| Apt 0-1q Fora Centro | 31 | R$ 400 | R$ 425 | R$ 330 | R$ 540 | 4 | 67 |
| Apt 2q Centro | 61 | R$ 583 | R$ 601 | R$ 399 | R$ 715 | 6 | 71 |
| Apt 2q Meia Praia | 156 | R$ 450 | R$ 483 | R$ 380 | R$ 585 | 6 | 60 |
| Apt 2q Morretes | 43 | R$ 464 | R$ 471 | R$ 350 | R$ 550 | 5 | 68 |
| Apt 3q Centro | 39 | R$ 750 | R$ 785 | R$ 518 | R$ 897 | 8 | 69 |
| Apt 3q Meia Praia | 273 | R$ 697 | R$ 708 | R$ 520 | R$ 842 | 8 | 67 |
| Apt 3q Morretes | 8 | R$ 650 | R$ 739 | R$ 600 | R$ 1.022 | 8 | 66 |

### Destaques:
- **Apt 2q Centro (R$ 583)** é ~29% mais caro que **Apt 2q Meia Praia (R$ 450)** e ~26% mais caro que **Apt 2q Morretes (R$ 464)** — mesma quantidade de quartos.
- **Apt 1q Centro (R$ 450)** é ~12% mais caro que **Apt 1q Fora Centro (R$ 400)**.
- **Apt 3q Centro (R$ 750)** é ~8% mais caro que **Apt 3q Meia Praia (R$ 697)**.

---

## 6. Diária por hóspede (diaria_mediana / number_of_guests)

### Por grupo específico

| Grupo | Qtd | DM/hósp mediana | DM/hósp média |
|-------|-----|-----------------|---------------|
| Apt 0-1q Centro | 76 | R$ 143 | R$ 157 |
| Apt 0-1q Fora Centro | 31 | R$ 100 | R$ 120 |
| Apt 2q Centro | 61 | R$ 100 | R$ 112 |
| Apt 2q Meia Praia | 156 | R$ 78 | R$ 86 |
| Apt 2q Morretes | 43 | R$ 92 | R$ 96 |
| Apt 3q Centro | 39 | R$ 107 | R$ 111 |
| Apt 3q Meia Praia | 273 | R$ 91 | R$ 95 |
| Apt 3q Morretes | 8 | R$ 83 | R$ 88 |

### Por bairro (todos os tamanhos)

| Bairro | Qtd | DM/hósp mediana | DM/hósp média |
|--------|-----|-----------------|---------------|
| Centro | 189 | R$ 123 | R$ 129 |
| Tabuleiro dos Oliveiras | 17 | R$ 104 | R$ 100 |
| Canto da Praia | 6 | R$ 104 | R$ 114 |
| Sertaozinho | 5 | R$ 100 | R$ 108 |
| Meia Praia | 524 | R$ 89 | R$ 96 |
| Ilhota | 9 | R$ 88 | R$ 87 |
| Morretes | 69 | R$ 85 | R$ 92 |
| Casa Branca | 14 | R$ 79 | R$ 86 |

**Observação:** Centro tem a maior diária por hóspede entre os bairros principais (R$ 123 vs R$ 89 de Meia Praia — 38% maior). Entre os grupos específicos, Apt 0-1q Centro (R$ 143/hósp) é o mais eficiente em termos de diária por hóspede.

---

## 7. Análise de sensibilidade

### Comparação: amostra principal (847) vs. todos os 999 listings

#### Ranking dos bairros (>=30 listings)

| Pos | Amostra principal | DM mediana | Todos 999 | DM mediana |
|-----|-------------------|-----------|-----------|-----------|
| 1° | Meia Praia (524) | R$ 595 | Meia Praia (626) | R$ 594 |
| 2° | Centro (189) | R$ 509 | Centro (204) | R$ 509 |
| 3° | Morretes (69) | R$ 471 | Morretes (81) | R$ 471 |

**Conclusão estável:** A ordem Meia Praia > Centro > Morretes é idêntica nas duas amostras. As medianas praticamente não mudam.

#### Ranking dos grupos combinados (>=10 listings)

| Pos | Amostra principal | DM mediana | Todos 999 | DM mediana |
|-----|-------------------|-----------|-----------|-----------|
| 1° | Meia Praia apt 4q (47) | R$ 900 | Meia Praia apt 4q (58) | R$ 975 |
| 2° | Centro apt 3q (39) | R$ 750 | Centro apt 3q (44) | R$ 790 |
| 3° | Meia Praia apt 3q (273) | R$ 697 | Meia Praia apt 3q (327) | R$ 680 |
| 4° | Centro apt 2q (61) | R$ 583 | Morretes apt 3q (10) | R$ 623 |
| 5° | Tab. Oliveiras apt 2q (10) | R$ 550 | Centro apt 2q (65) | R$ 580 |

**Conclusão estável:** Os 3 primeiros são idênticos. A posição 4-5 muda levemente (Morretes apt 3q sobe na amostra completa por ter 10 listings vs. 8 na principal).

### Resumo da sensibilidade

| Aspecto | Estável? | Detalhe |
|---------|----------|---------|
| Ranking bairros (top 3) | **Sim** | Ordem idêntica |
| Medianas por bairro | **Sim** | Diferença < R$ 1 |
| Ranking grupos combinados (top 3) | **Sim** | Ordem idêntica |
| Ranking grupos combinados (top 4-5) | **Não** | Morretes apt 3q aparece apenas na amostra completa |
| Diária por hóspede por bairro | **Sim** | Centro sempre lidera |
| Proporção Centro vs Meia Praia | **Sim** | Centro sempre ~30% mais caro por hóspede |

---

## 8. Sobre a tese dos compactos no Centro

### Lado da receita anunciada

A análise preliminar indica que o lado da **receita anunciada favorece parcialmente** a tese:

- **Diária total:** Apt 1q Centro (R$ 450) é ~12% mais caro que Apt 1q Fora Centro (R$ 400), mas ~29% mais barato que Apt 2q Centro (R$ 583). Em termos de diária absoluta, compactos no Centro não são os mais caros.

- **Diária por hóspede:** Apt 0-1q Centro (R$ 143/hósp) é o grupo mais eficiente em termos de diária por hóspede — 18% mais alto que Apt 2q Centro (R$ 100/hósp) e 83% mais alto que Apt 2q Meia Praia (R$ 78/hósp). Isso indica que o mercado cobra um **prêmio por pessoa** em imóveis pequenos no Centro.

- **Tamanho da amostra:** Apt 0-1q Centro tem 76 listings (amostra razoável). Apt 0-1q Fora Centro tem apenas 31 (amostra pequena). A diferença pode ser parcialmente explicada por composição.

- **Eficiência de investimento:** A diária anunciada por hóspede é apenas um lado da equação. O retorno real depende também do **preço de compra** (disponível no VivaReal), taxa de ocupação, custos operacionais e sazonalidade. Esses dados ainda não foram integrados.

### Ressalvas
- Diária anunciada ≠ receita realizada
- Amostra de compactos no Centro (76 listings) é razoável, mas menor que a de Meia Praia
- Falta o custo de aquisição (VivaReal) para calcular yield
- Apartamentos compactos no Centro lideram em **diária anunciada por hóspede** (R$ 143), mas **não necessariamente em diária total, margem ou retorno**

---

*Tabelas auxiliares: `outputs/airbnb_por_bairro.csv`, `outputs/airbnb_por_quartos.csv`, `outputs/airbnb_por_tipo.csv`, `outputs/airbnb_grupos_comparaveis.csv`*
*Script: `src/analise_perfil_localizacao.ps1`*
