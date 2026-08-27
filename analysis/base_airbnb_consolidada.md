# Validação — Base Analítica Consolidada Airbnb

**Data:** 2026-08-26
**Arquivo:** `outputs/base_airbnb_consolidada.csv`

---

## 1. Resumo

| Métrica | Valor |
|---------|-------|
| Total de listings | 999 |
| Uma linha por listing | **Confirmado** (999 IDs únicos = 999 linhas) |

---

## 2. Regras de construção aplicadas

1. **Price_AV:** Para cada (airbnb_listing_id, date), mantida a captura mais recente (max aquisition_day)
2. **Filtro:** Apenas IDs com correspondência em Details (999 de 1.005)
3. **Métricas calculadas por listing:**
   - `datas_estadia`: quantidade de datas de estadia disponíveis
   - `diaria_mediana`: mediana das diárias
   - `diaria_media`: média das diárias
   - `diaria_p25`: percentil 25 das diárias
   - `diaria_p75`: percentil 75 das diárias
   - `potencial_bruto_anunciado`: soma dos preços anunciados no período observado
4. **Joined com Details + Mesh** por airbnb_listing_id
5. **Não inclui** Hosts
6. **Não altera** CSVs originais

---

## 3. Distribuição da quantidade de datas por listing

| Datas | Listings | % |
|-------|----------|---|
| 2-10 | 24 | 2,4% |
| 11-20 | 50 | 5,0% |
| 21-30 | 98 | 9,8% |
| 31-40 | 105 | 10,5% |
| 41-50 | 108 | 10,8% |
| 51-60 | 126 | 12,6% |
| 61-70 | 153 | 15,3% |
| 71-80 | 142 | 14,2% |
| 81-90 | 122 | 12,2% |
| 91-105 | 71 | 7,1% |

**Resumo:**
- Mínimo: 2 datas
- Máximo: 105 datas
- Mediana: 62 datas
- Exatamente 105 datas: 1 listing
- Pelo menos 90 datas: 74 listings
- Menos de 30 datas: 140 listings

A maioria dos listings (73,4%) possui entre 41 e 90 datas de estadia disponíveis, indicando cobertura razoável do período observado.

---

## 4. Valores ausentes

| Coluna | Ausentes | % |
|--------|----------|---|
| min_nights | 999 | 100,0% |
| cleaning_fee | 46 | 4,6% |
| star_rating | 22 | 2,2% |
| number_of_reviews | 22 | 2,2% |
| is_professional | 11 | 1,1% |
| number_of_bathrooms | 9 | 0,9% |
| number_of_bedrooms | 8 | 0,8% |
| number_of_beds | 6 | 0,6% |

**Nota:** `min_nights` está 100% zerada — o campo existe no Details mas não está preenchido adequadamente. As demaisausentes são pequenas (≤4,6%).

---

## 5. Cinco linhas de exemplo

| airbnb_listing_id | datas | mediana | suburb | type | bedrooms | reviews |
|-------------------|-------|---------|--------|------|----------|---------|
| 881204142086821328 | 68 | R$ 550 | Meia Praia | apartamento | 3 | 43 |
| 39051477 | 92 | R$ 1.500 | Meia Praia | apartamento | 4 | 10 |
| 22648075 | 65 | R$ 348 | Centro | apartamento | 2 | 16 |
| 748336742434217963 | 44 | R$ 450 | Meia Praia | apartamento | 2 | 45 |
| 1226856286781952840 | 86 | R$ 732 | Centro | apartamento | 2 | 12 |

---

## 6. Colunas da base

`airbnb_listing_id`, `datas_estadia`, `diaria_mediana`, `diaria_media`, `diaria_p25`, `diaria_p75`, `potencial_bruto_anunciado`, `suburb`, `listing_type`, `number_of_bedrooms`, `number_of_bathrooms`, `number_of_beds`, `number_of_guests`, `number_of_reviews`, `star_rating`, `is_professional`, `can_instant_book`, `is_guest_favorite`, `cleaning_fee`, `min_nights`

---

## 7. Observações

- A base contém **apenas listings com preço** (999 de 4.441 = 22,50%). Ver `analysis/representatividade_price_av.md` para análise de viés de seleção.
- `potencial_bruto_anunciado` **NÃO é receita realizada** — é a soma dos preços anunciados nas datas disponíveis.
- `min_nights` não está preenchido e não deve ser utilizado.
- Para uso futuro, considerar join com Hosts após deduplicação (regra: manter host_snapshot_date mais recente).

---

*Script: `src/base_consolidada.ps1`*
