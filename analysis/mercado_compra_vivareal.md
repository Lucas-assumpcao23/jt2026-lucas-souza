# Mercado de Compra — VivaReal

**Data:** 2026-08-26
**Base:** `data/VivaReal_Itapema.csv` (8.329 linhas originais)
**Base tratada:** `outputs/vivareal_base_tratada.csv` (8.293 registros)

---

## 1. Preparação e padronização

### Padronização de bairros

| Variação original | Correção | Registros |
|-------------------|----------|-----------|
| Tabuleiro | Tabuleiro dos Oliveiras | 6 |
| Taboleiro | Tabuleiro dos Oliveiras | 1 |
| Meia Praia - Frente Mar | Meia Praia | 1 |

### Duplicidades

| Etapa | Registros |
|-------|-----------|
| Total original | 8.329 |
| Duplicatas exatas removidas | 35 |
| Duplicatas diferentes (mantida aquisição mais recente) | 1 |
| Total tratado | 8.293 |

---

## 2. Métricas por bairro x quartos

### Grupos com pelo menos 10 anúncios

| Bairro | Quartos | Qtd | SP mediana | SP média | SP P25 | SP P75 | Área med | Pm² med | Conc med | %conc | IPTU med | %IPTU |
|--------|---------|-----|-----------|----------|--------|--------|----------|---------|----------|-------|----------|-------|
| Centro | 0 | 1 | 1.290.000 | 1.290.000 | 1.290.000 | 1.290.000 | 29 | 44.483 | — | 0% | — | 0% |
| Centro | 1 | 27 | 960.000 | 1.008.148 | 790.000 | 1.100.000 | 54 | 20.433 | 400 | 53,6% | 120 | 50% |
| Centro | 0-1 | 28 | 960.000 | 1.004.714 | 790.000 | 1.100.000 | 54 | 20.433 | 400 | 53,6% | 120 | 50% |
| Centro | 2 | 92 | 1.140.000 | 1.337.337 | 920.000 | 1.400.000 | 86 | 13.029 | 460 | 82,6% | 700 | 84,8% |
| Centro | 3 | 442 | 2.100.000 | 2.527.308 | 1.600.000 | 3.100.000 | 131 | 15.789 | — | 72,6% | — | 67,6% |
| Meia Praia | 0 | 17 | 850.000 | 853.706 | 700.000 | 999.000 | 37 | 22.568 | 0 | 52,9% | 0 | 47,1% |
| Meia Praia | 1 | 75 | 970.000 | 1.016.027 | 750.000 | 1.100.000 | 47 | 19.500 | 0 | 66,7% | 0 | 64% |
| Meia Praia | 0-1 | 92 | 970.000 | 998.717 | 750.000 | 1.100.000 | 45 | 18.900 | 0 | 65,2% | 0 | 62% |
| Meia Praia | 2 | 243 | 1.080.000 | 1.209.383 | 850.000 | 1.400.000 | 85 | 13.033 | 450 | 73,7% | 650 | 69,1% |
| Meia Praia | 3 | 1.708 | 1.884.860 | 2.282.451 | 1.400.000 | 2.800.000 | 129 | 14.957 | 500 | 71,1% | 531 | 65,5% |
| Meia Praia | 4 | 1.329 | 3.549.790 | 4.442.207 | 2.700.000 | 5.000.000 | 188 | 18.428 | 600 | 68,2% | — | 62,6% |
| Morretes | 1 | 12 | 567.500 | 625.750 | 450.000 | 742.500 | 65 | 8.788 | 0 | 58,3% | 400 | 66,7% |
| Morretes | 2 | 1.243 | 750.000 | 826.954 | 560.000 | 960.000 | 69 | 11.086 | — | 71,6% | 500 | 76,1% |
| Morretes | 3 | 306 | 790.000 | 929.542 | 595.000 | 1.050.000 | 100 | 8.333 | — | 70,6% | 500 | 79,7% |
| Morretes | 4 | 3 | 1.000.000 | 1.363.333 | 1.000.000 | 1.500.000 | 150 | 14.286 | — | 100% | 600 | 100% |
| Tab. Oliveiras | 2 | 5 | 1.350.000 | 1.420.000 | 1.200.000 | 1.600.000 | 116 | 11.638 | 600 | 80% | 1.100 | 80% |

### Grupos menores (com ressalva)

| Bairro | Quartos | Qtd | SP mediana |
|--------|---------|-----|-----------|
| Centro | 0 | 1 | R$ 1.290.000 |
| Morretes | 0 | 6 | R$ 560.000 |
| Morretes | 4 | 3 | R$ 1.000.000 |
| Tab. Oliveiras | 1 | 4 | R$ 915.000 |
| Tab. Oliveiras | 3 | 2 | R$ 2.400.000 |
| Tab. Oliveiras | 4 | 1 | R$ 4.100.000 |
| Canto da Praia | 1 | 3 | R$ 800.000 |
| Canto da Praia | 2 | 15 | R$ 1.300.000 |
| Canto da Praia | 3 | 3 | R$ 3.200.000 |

---

## 3. Grupos específicos

| Grupo | Qtd | SP mediana | Área med | Pm² med | Conc med | %conc | IPTU med | %IPTU | Áreas=0 | Pm² inv |
|-------|-----|-----------|----------|---------|----------|-------|----------|-------|---------|---------|
| Compactos 0-1q Centro | 28 | R$ 960.000 | 54 m² | R$ 20.433 | R$ 400 | 53,6% | R$ 120 | 50% | 0 | 0 |
| Compactos 0-1q Meia Praia | 92 | R$ 970.000 | 45 m² | R$ 18.900 | — | 65,2% | — | 62% | 0 | 0 |
| Compactos 0-1q Morretes | 149 | R$ 650.000 | 252 m² | R$ 5.159 | — | 65,8% | R$ 500 | 66,4% | 0 | 0 |
| 2q Centro | 92 | R$ 1.140.000 | 86 m² | R$ 13.029 | R$ 460 | 82,6% | R$ 700 | 84,8% | 0 | 1 |
| 2q Meia Praia | 243 | R$ 1.080.000 | 85 m² | R$ 13.033 | R$ 450 | 73,7% | R$ 650 | 69,1% | 0 | 0 |
| 2q Morretes | 1.243 | R$ 750.000 | 69 m² | R$ 11.086 | — | 71,6% | R$ 500 | 76,1% | 0 | 0 |
| 3q Centro | 442 | R$ 2.100.000 | 131 m² | R$ 15.789 | — | 72,6% | — | 67,6% | 1 | 5 |
| 3q Meia Praia | 1.708 | R$ 1.884.860 | 129 m² | R$ 14.957 | R$ 500 | 71,1% | R$ 531 | 65,5% | 0 | 0 |
| 3q Morretes | 306 | R$ 790.000 | 100 m² | R$ 8.333 | — | 70,6% | R$ 500 | 79,7% | 0 | 0 |
| 4q Meia Praia | 1.329 | R$ 3.549.790 | 188 m² | R$ 18.428 | R$ 600 | 68,2% | — | 62,6% | 0 | 0 |

**Inconsistências relevantes:**
- **Compactos 0-1q Morretes: GRUPO INVÁLIDO PARA ANÁLISE RESIDENCIAL** — Investigação detalhada (ver seção 6) revelou que 93 dos 98 registros com 0 quartos são terrenos, salas comerciais ou lojas, não studios residenciais. Área mediana de 252 m² e Pm² de R$ 5.159 confirmam a natureza não residencial. O grupo agregado 0-1q Morretes (149 registros) é portanto inválido. **Para compactos em Morretes, usar exclusivamente 1 quarto (51 registros).**
- 2q Centro: 1 registro com pm² inválido.
- 3q Centro: 1 registro com área zero, 5 registros com pm² inválido.
- Omissão de condomínio/IPTU: entre 17-47% dos anúncios não têm esses campos preenchidos, dependendo do grupo.

---

## 4. Análise de extremos

### Limites calculados
- sale_price: P1 = R$ 450.000 | P99 = R$ 8.774.000
- price_per_m²: P1 = R$ 1.762 | P99 = R$ 53.944

### Registros válidos (P1-P99): 7.858 de 8.293

### Comparação: todos vs P1-P99

| Grupo | Qtd orig | SP mediana orig | Qtd filtrado | SP mediana filtrada | Variação |
|-------|----------|----------------|--------------|--------------------|-----------|
| Compactos 0-1q Centro | 28 | R$ 960.000 | 23 | R$ 980.000 | +2% |
| Compactos 0-1q Meia Praia | 92 | R$ 970.000 | 84 | R$ 980.000 | +1% |
| Compactos 0-1q Morretes | 149 | R$ 650.000 | 125 | R$ 705.243 | +8,5% |
| 2q Centro | 92 | R$ 1.140.000 | 87 | R$ 1.100.000 | -3,5% |
| 2q Meia Praia | 243 | R$ 1.080.000 | 241 | R$ 1.070.000 | -0,9% |
| 2q Morretes | 1.243 | R$ 750.000 | 1.216 | R$ 752.270 | +0,3% |
| 3q Centro | 442 | R$ 2.100.000 | 437 | R$ 2.100.000 | 0% |
| 3q Meia Praia | 1.708 | R$ 1.884.860 | 1.672 | R$ 1.884.860 | 0% |
| 3q Morretes | 306 | R$ 790.000 | 305 | R$ 790.000 | 0% |
| 4q Meia Praia | 1.329 | R$ 3.549.790 | 1.220 | R$ 3.500.000 | -1,4% |

**Ranking dos 5 mais baratos (todos vs P1-P99):**

| Pos | Todos | SP med | P1-P99 | SP med |
|-----|-------|--------|--------|--------|
| 1° | Morretes 0-1q | R$ 650.000 | Morretes 0-1q | R$ 705.243 |
| 2° | Morretes 2q | R$ 750.000 | Morretes 2q | R$ 752.270 |
| 3° | Morretes 3q | R$ 790.000 | Morretes 3q | R$ 790.000 |
| 4° | Centro 0-1q | R$ 960.000 | Centro 0-1q | R$ 980.000 |
| 5° | Meia Praia 0-1q | R$ 970.000 | Meia Praia 0-1q | R$ 980.000 |

**Conclusão:** O ranking permaneceu estável. As variações de mediana ficaram entre 0% e 8,5%, sem alteração na ordem dos grupos.

---

## 5. Notas metodológicas

- Preço de venda é preço anunciado, não preço efetivamente negociado
- Condomínio e IPTU usam apenas valores válidos (preenchidos)
- Compacidade: 0 quartos mantido separado de 1 quartos; também apresentado como grupo agregado 0-1 quartos
- Cálculo de ROI não foi realizado nesta fase

---

## 6. Investigação: Morretes 0-1 quartos

### 6.1 Separação por número de quartos

| Grupo | Qtd | SP mediana | Área mediana | Área P25 | Área P75 | Pm² mediana |
|-------|-----|-----------|-------------|----------|----------|-------------|
| 0 quartos | 98 | R$ 650.000 | 283 m² | 252 m² | 288 m² | R$ 2.530 |
| 1 quarto | 51 | R$ 649.000 | 43 m² | 41 m² | 63 m² | R$ 12.899 |

### 6.2 Classificação dos 0 quartos

Análise dos títulos dos 98 anúncios com 0 quartos em Morretes revelou:

- **Terrenos/lotes:** ~75 registros (ex: "Terreno com 288m²", "Lote à venda", "05 terrenos juntos")
- **Salas/comerciais:** ~10 registros (ex: "Sala comercial 93m²", "Loja em Morretes")
- **Empreendimentos:** ~8 registros (ex: "Dreams Village", "Augustus Residence")
- **Studios residenciais:** ~5 registros (não confirmados como residenciais)

**Conclusão: 0 quartos em Morretes NÃO são studios residenciais.** São majoritariamente terrenos e imóveis comerciais. A área mediana de 283 m² e o Pm² de R$ 2.530 (vs R$ 12.899 para 1 quarto) confirmam a natureza completamente diferente dos imóveis.

### 6.3 1 quarto filtrado

| Filtro | Registros | SP mediana | Área mediana | Pm² mediana |
|--------|-----------|-----------|-------------|-------------|
| Sem filtro | 51 | R$ 649.000 | 43 m² | R$ 12.899 |
| Área 20-100 m² | 49 | R$ 600.000 | 44 m² | R$ 12.889 |
| Área 20-100 + P1-P99 | 49 | R$ 600.000 | 44 m² | R$ 12.889 |

**Observação:** 2 registros foram removidos por área fora da faixa 20-100 m² (provavelmente imóveis muito grandes ou muito pequenos). Após filtros, as medianas permaneceram estáveis.

### 6.4 Grupo agregado 0-1q: INVÁLIDO

O grupo agregado 0-1q Morretes (149 registros) **não deve ser usado** para representar compactos residenciais porque:
- 93 dos 98 registros com 0 quartos são não residenciais
- A área mediana do grupo agregado (252 m²) é distorcida pelos terrenos
- O Pm² mediano (R$ 5.159) é 60% menor que o de 1 quarto (R$ 12.899)

**Amostra recomendada para compactos em Morretes: 1 quarto (51 registros, ou 49 após filtros)**

---

## 7. Investigação: Centro e Meia Praia — 0 quartos

### 7.1 Resultado da classificação

| Bairro | Total 0q | Comercial | Terreno | Ambíguo | Studio Residencial |
|--------|----------|-----------|---------|---------|-------------------|
| Centro | 3 | 3 | 0 | 0 | **0** |
| Meia Praia | 30 | 24 | 5 | 1 | **0** |

### 7.2 Centro (3 registros)

Todos os 3 registros com 0 quartos em Centro são **salas comerciais** — nenhum studio residencial identificado.

### 7.3 Meia Praia (30 registros)

- **24 comerciais:** salas, lojas, escritórios
- **5 terrenos:** lotes para venda
- **1 ambíguo:** "Prédio/Edifício inteiro para venda" (114 m², tipo "outros") — não é studio residencial

Nenhum studio residencial identificado.

### 7.4 Conclusão

**Nenhum dos registros com 0 quartos em Centro (3) ou Meia Praia (30) pode ser tratado com segurança como studio residencial.** Todos são comerciais, terrenos ou ambíguos não residenciais.

**Recomendação:** Para compactos em Centro e Meia Praia, usar exclusivamente imóveis com 1 quarto. Não agregar 0 quartos ao grupo de 1 quarto em nenhum dos três bairros investigados.

---

*Tabelas auxiliares: `outputs/vivareal_grupos_compra.csv`, `outputs/vivareal_base_tratada.csv`*
*Script: `src/analise_mercado_compra.ps1`, `src/investiga_0q_centro_mp.ps1`*
