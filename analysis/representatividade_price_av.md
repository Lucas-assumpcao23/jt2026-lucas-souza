# Representatividade do Price_AV — Análise de Viés de Seleção

**Data:** 2026-08-26 (segunda auditoria)
**Objetivo:** Verificar se os 999 listings com preço no Price_AV são representativos dos 4.441 listings do Details.

---

## 1. Composição dos grupos

| Grupo | Quantidade | % do total |
|-------|-----------|-----------|
| Com preço (Price_AV) | 999 | 22,50% |
| Sem preço | 3.442 | 77,50% |
| **Total Details** | **4.441** | **100%** |

---

## 2. Comparação por variável

### 2.1 Bairro (suburb)

| Bairro | Com preço | % | Sem preço | % | Diferença (pp) |
|--------|----------|---|-----------|---|----------------|
| Meia Praia | 632 | 63,3% | 2.228 | 64,7% | -1,4 |
| Centro | 205 | 20,5% | 452 | 13,1% | **+7,4** |
| Morretes | 61 | 6,1% | 380 | 11,0% | -4,9 |
| Tabuleiro dos Oliveiras | 27 | 2,7% | 102 | 3,0% | -0,3 |
| Casa Branca | 14 | 1,4% | 74 | 2,1% | -0,7 |
| Outros | 60 | 6,0% | 206 | 6,0% | 0,0 |

**Observação:** O grupo com preço tem **proporção maior de Centro** (20,5% vs 13,1%, diferença de 7,4 pp) e **menor de Morretes** (6,1% vs 11,0%, diferença de 4,9 pp). Meia Praia é similar entre os grupos.

### 2.2 Quartos (number_of_bedrooms)

| Quartos | Com preço | % | Sem preço | % | Diferença (pp) |
|---------|----------|---|-----------|---|----------------|
| 0 | 14 | 1,4% | 216 | 6,3% | -4,9 |
| 1 | 17 | 1,7% | 162 | 4,7% | -3,0 |
| 2 | 348 | 34,8% | 1.728 | 50,2% | **-15,4** |
| 3 | 405 | 40,5% | 1.030 | 29,9% | **+10,6** |
| 4 | 160 | 16,0% | 236 | 6,9% | **+9,1** |
| 5+ | 55 | 5,5% | 70 | 2,0% | +3,5 |

| Estatística | Com preço | Sem preço |
|-------------|----------|-----------|
| **Mediana quartos** | **3** | **2** |

**Observação:** O grupo com preço concentra-se em imóveis maiores (3-4 quartos). O grupo sem preço tem maioria de 2 quartos. A diferença na mediana (3 vs 2) e na proporção de 2 quartos (34,8% vs 50,2%) é significativa.

### 2.3 Tipo de imóvel (listing_type)

| Tipo | Com preço | % | Sem preço | % | Diferença (pp) |
|------|----------|---|-----------|---|----------------|
| apartamento | 857 | 85,8% | 2.853 | 82,9% | +2,9 |
| casa | 68 | 6,8% | 375 | 10,9% | -4,1 |
| outros | 58 | 5,8% | 187 | 5,4% | +0,4 |
| hotel | 16 | 1,6% | 27 | 0,8% | +0,8 |

**Observação:** Proporções relativamente similares. Apartamentos são maioria em ambos os grupos. Casas têm proporção levemente maior no grupo sem preço.

### 2.4 Capacidade (number_of_guests)

| Estatística | Com preço | Sem preço |
|-------------|----------|-----------|
| **Mediana hóspedes** | **6** | **4** |

**Observação:** Imóveis com preço tendem a ter maior capacidade anunciada.

### 2.5 Reviews (number_of_reviews)

| Estatística | Com preço | Sem preço |
|-------------|----------|-----------|
| Mediana reviews | 16 | 1 |
| Média reviews | 47,3 | 22,8 |

**Observação:** O grupo com preço tem mediana de 16 reviews vs 1 no grupo sem preço. Isso indica que os listings com preço são, em média, mais maduros e com mais histórico na plataforma.

### 2.6 Rating (star_rating)

| Estatística | Com preço | Sem preço |
|-------------|----------|-----------|
| Mediana stars | 4,93 | 4,50 |

**Observação:** O grupo com preço tem mediana de rating levemente superior.

### 2.7 Profissional (is_professional)

| Valor | Com preço | % | Sem preço | % |
|-------|----------|---|-----------|---|
| false | 940 | 94,1% | 3.339 | 97,0% |
| true | 59 | 5,9% | 103 | 3,0% |

**Observação:** Proporção levemente maior de profissionais no grupo com preço (5,9% vs 3,0%).

---

## 3. Síntese das diferenças

| Variável | Magnitude da diferença | Interpretação |
|----------|----------------------|---------------|
| Bairro Centro | +7,4 pp | Moderada — mais listings de Centro no grupo com preço |
| Bairro Morretes | -4,9 pp | Moderada — menos listings de Morretes no grupo com preço |
| Quartos (mediana) | 3 vs 2 | Significativa — grupo com preço tem imóveis maiores |
| 2 quartos | -15,4 pp | Significativa — proporção muito menor de 2 quartos no grupo com preço |
| 3 quartos | +10,6 pp | Significativa — proporção maior de 3 quartos no grupo com preço |
| Hóspedes (mediana) | 6 vs 4 | Moderada |
| Reviews (mediana) | 16 vs 1 | Forte — grupo com preço tem muito mais histórico |
| Stars (mediana) | 4,93 vs 4,50 | Fraca |
| Profissional | 5,9% vs 3,0% | Fraca |

---

## 4. Conclusão

**Há evidência de diferença entre os grupos**, mas a magnitude varia:

- **Diferenças fortes:** Reviews (mediana 16 vs 1) e quartos (mediana 3 vs 2). O grupo com preço é composto por imóveis maiores e mais maduros na plataforma.
- **Diferenças moderadas:** Bairro (Centro sobre-representado, Morretes sub-representado) e capacidade.
- **Diferenças fracas:** Tipo de imóvel, rating, profissional.

**Classificação:** O viés de seleção **existe** e é **moderado**. Os listings com preço no Price_AV não são perfeitamente representativos do total de listings do Details. Qualquer análise de receita ou ROI baseada nesses 999 listings deve considerar que:

1. Imóveis menores (1-2 quartos) estão sub-representados
2. Bairro Morretes está sub-representado
3. Listings com pouco histórico (poucos reviews) estão sub-representados

**Risco não confirmado:** A magnitude do viés é suficiente para gerar distorção em estimativas de receita, mas não é tão extrema a ponto de invalidar a análise. Recomenda-se reportar resultados com e sem ajuste por bairro e quartos.

---

*Tabela detalhada: `outputs/representatividade_price_av.csv`*
*Script: `src/repr_viva_analysis.ps1`*
