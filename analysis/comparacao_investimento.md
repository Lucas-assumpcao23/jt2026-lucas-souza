# Comparação de Investimento — Airbnb vs VivaReal

**Data:** 2026-08-26
**Fontes:** `outputs/base_airbnb_consolidada.csv`, `outputs/vivareal_base_tratada.csv`

---

## Metodologia

- **Airbnb:** Filtro datas_estadia >= 30, diaria_mediana entre R$ 150 e R$ 2.500, listing_type = apartamento
- **VivaReal:** Base tratada (8.293 registros). Morretes 1q usa amostra validada (área 20-100m², P1-P99)
- **Retorno bruto simplificado:** diaria_mediana × 365 × ocupacao / preco_compra_mediano
- **Ocupacao para 7%:** 0.07 × preco / (diaria × 365)

---

## 1. Tabela comparativa

| Segmento | Qtd Airbnb | DM mediana | DM P25 | DM P75 | Hósp | Qtd VR | SP mediana | Área med | Pm² med |
|----------|-----------|-----------|--------|--------|------|--------|-----------|----------|---------|
| Centro 1q | 76 | R$ 450 | R$ 378 | R$ 537 | 4 | 25 | R$ 890.000 | 54 m² | R$ 19.905 |
| Centro 2q | 61 | R$ 583 | R$ 399 | R$ 715 | 6 | 92 | R$ 1.140.000 | 86 m² | R$ 13.029 |
| Centro 3q | 39 | R$ 750 | R$ 518 | R$ 897 | 8 | 442 | R$ 2.100.000 | 131 m² | R$ 15.789 |
| Meia Praia 1q | 17 | R$ 490 | R$ 400 | R$ 545 | 4 | 62 | R$ 880.000 | 47 m² | R$ 21.250 |
| Meia Praia 2q | 156 | R$ 450 | R$ 380 | R$ 585 | 6 | 243 | R$ 1.080.000 | 85 m² | R$ 13.033 |
| Meia Praia 3q | 273 | R$ 697 | R$ 520 | R$ 842 | 8 | 1.708 | R$ 1.884.860 | 129 m² | R$ 14.957 |
| Meia Praia 4q | 47 | R$ 900 | R$ 850 | R$ 1.604 | 10 | 1.329 | R$ 3.549.790 | 188 m² | R$ 18.428 |
| Morretes 1q | 2 | R$ 480 | — | — | 5 | 49 | R$ 600.000 | 44 m² | R$ 12.889 |
| Morretes 2q | 43 | R$ 464 | R$ 350 | R$ 550 | 5 | 1.243 | R$ 750.000 | 69 m² | R$ 11.086 |
| Morretes 3q | 8 | R$ 650 | R$ 600 | R$ 1.022 | 8 | 306 | R$ 790.000 | 100 m² | R$ 8.333 |

**Morretes 1q:** Amostra validada com área 20-100m² e controle P1-P99. SP mediana conferida: R$ 600.000.

---

## 2. Retorno bruto simplificado (3 cenários)

| Segmento | Ret 40% | Ret 55% | Ret 70% | Oc7% |
|----------|---------|---------|---------|------|
| Centro 1q | 7,4% | 10,2% | 12,9% | 37,9% |
| Centro 2q | 7,5% | 10,3% | 13,1% | 37,5% |
| Centro 3q | 5,2% | 7,2% | 9,1% | 53,7% |
| Meia Praia 1q | 8,1% | 11,2% | 14,2% | 34,4% |
| Meia Praia 2q | 6,1% | 8,4% | 10,7% | 46,0% |
| Meia Praia 3q | 5,4% | 7,4% | 9,5% | 51,9% |
| Meia Praia 4q | 3,7% | 5,1% | 6,5% | 75,6% |
| Morretes 1q | 11,7% | 16,1% | 20,4% | 24,0% |
| Morretes 2q | 9,0% | 12,4% | 15,8% | 31,0% |
| Morretes 3q | 12,0% | 16,5% | 21,0% | 23,3% |

**Observação:** Nenhum retorno exige ocupação acima de 100% no cenário de 7%. Meia Praia 4q (75,6%) é o mais desafiador.

---

## 3. Ranking por retorno bruto (cenário 55%)

| Pos | Segmento | Retorno 55% | Oc7% |
|-----|----------|------------|------|
| 1° | Morretes 3q | 16,5% | 23,3% |
| 2° | Morretes 1q | 16,1% | 24,0% |
| 3° | Morretes 2q | 12,4% | 31,0% |
| 4° | Meia Praia 1q | 11,2% | 34,4% |
| 5° | Centro 2q | 10,3% | 37,5% |
| 6° | Centro 1q | 10,2% | 37,9% |
| 7° | Meia Praia 2q | 8,4% | 46,0% |
| 8° | Meia Praia 3q | 7,4% | 51,9% |
| 9° | Centro 3q | 7,2% | 53,7% |
| 10° | Meia Praia 4q | 5,1% | 75,6% |

---

## 4. Sensibilidade: diária P25 vs mediana

| Segmento | Ret 55% (DM) | Ret 55% (P25) | Diferença |
|----------|-------------|--------------|-----------|
| Centro 1q | 10,2% | 9,6% | -0,6pp |
| Centro 2q | 10,3% | 8,8% | -1,5pp |
| Centro 3q | 7,2% | 6,6% | -0,6pp |
| Meia Praia 1q | 11,2% | 10,7% | -0,5pp |
| Meia Praia 2q | 8,4% | 7,4% | -1,0pp |
| Meia Praia 3q | 7,4% | 6,2% | -1,2pp |
| Meia Praia 4q | 5,1% | 5,1% | 0pp |
| Morretes 1q | 16,1% | 16,1% | 0pp |
| Morretes 2q | 12,4% | 10,7% | -1,7pp |
| Morretes 3q | 16,5% | 15,3% | -1,2pp |

**Observação:** A maioria dos rankings se mantém com P25. Morretes 2q tem maior sensibilidade (-1,7pp). Morretes 3q e 1q permanecem como os dois primeiros.

---

## 5. Segmentos com menor preço de entrada

| Pos | Segmento | SP mediana |
|-----|----------|-----------|
| 1° | Morretes 1q | R$ 600.000 |
| 2° | Morretes 2q | R$ 750.000 |
| 3° | Meia Praia 1q | R$ 880.000 |
| 4° | Centro 1q | R$ 890.000 |
| 5° | Meia Praia 2q | R$ 1.080.000 |

---

## 6. Amostras insuficientes ou incompatíveis

| Segmento | Issue |
|----------|-------|
| Morretes 1q | **2 listings no Airbnb** — amostra insuficiente para qualquer conclusão |
| Morretes 3q | **8 listings no Airbnb** — amostra pequena, resultado orientativo |
| Centro 1q | **25 registros VR** — amostra razoável mas menor que outros |
| Meia Praia 1q | **17 listings Airbnb** — amostra pequena |

---

## 7. Notas metodológicas

- Preço de venda é preço anunciado, não preço efetivamente negociado
- Diária anunciada não é receita realizada
- Retorno bruto simplificado não é ROI líquido (não inclui custos operacionais, impostos, manutenção, vacância implícita)
- Ocupação é premissa de cenário, não dado da base
- Não inclui valorização do imóvel
- Morretes 1q validado com filtros de área (20-100m²) e extremos (P1-P99)

---

*Tabelas auxiliares: `outputs/comparacao_investimento.csv`*
*Script: `src/comparacao_investimento.ps1`*
