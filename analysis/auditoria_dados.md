# Auditoria Técnica — Dados Itapema (Snapshot Airbnb + VivaReal)

**Data da auditoria:** 2026-08-26 (versão corretiva)
**Base:** Snapshot estático do mercado imobiliário de Itapema (SC)
**Escopo:** Somente análise técnica — nenhuma decisão de investimento

---

## 1. Details_Itapema.csv — Listings Airbnb

| Métrica | Valor |
|---------|-------|
| Linhas | 4.441 |
| Colunas | 35 |
| Chave primária (airbnb_listing_id) | 4.441 valores, 4.441 únicos — sem duplicidades |

### Colunas

`airbnb_listing_id`, `url`, `ad_name`, `ad_description`, `space`, `house_rules`, `amenities`, `safety_features`, `number_of_bathrooms`, `number_of_bedrooms`, `number_of_beds`, `latitude`, `longitude`, `check_in`, `check_out`, `number_of_guests`, `number_of_reviews`, `cleaning_fee`, `owner_id`, `aquisition_date`, `star_rating`, `picture_count`, `min_nights`, `guest_satisfaction_overall`, `listing_type`, `can_instant_book`, `is_professional`, `accuracy_rating`, `checkin_rating`, `cleanliness_rating`, `communication_rating`, `location_rating`, `value_rating`, `is_new_listing`, `is_guest_favorite`

### Tipo aparente de cada variável

| Variável | Tipo | Observação |
|----------|------|------------|
| airbnb_listing_id | string/numérico | Chave primária |
| url | string | Link Airbnb |
| ad_name | string | Título do anúncio |
| ad_description | string | Descrição longa |
| space | string | Descrição do espaço (muitos vazios) |
| house_rules | string | Regras (JSON-like) |
| amenities | string | Comodidades (JSON-like) |
| safety_features | string | Segurança (JSON-like) |
| number_of_bathrooms | float | Ex.: 1.0, 2.0 |
| number_of_bedrooms | int | Ex.: 1, 2, 3 |
| number_of_beds | int | Ex.: 1, 2, 3 |
| latitude | float | Coordenada GPS |
| longitude | float | Coordenada GPS |
| check_in | string | Ex.: "Check-in: 14:00 - 20:00" |
| check_out | string | Ex.: "Checkout antes das 09:00" |
| number_of_guests | int | Capacidade |
| number_of_reviews | int | Reviews acumulados |
| cleaning_fee | float | Taxa de limpeza |
| owner_id | string | Chave para Hosts |
| aquisition_date | datetime | Data de captura (2025-01-13) |
| star_rating | float | Estrelas (0.0 a 5.0) |
| picture_count | int | Fotos |
| min_nights | int | Mínimo de noites |
| guest_satisfaction_overall | float | Satisfação (0 a 5) |
| listing_type | string | apartamento, casa, outros, hotel |
| can_instant_book | boolean | "true"/"false" como string |
| is_professional | boolean | "true"/"false" como string |
| accuracy_rating | float | Sub-rating |
| checkin_rating | float | Sub-rating |
| cleanliness_rating | float | Sub-rating |
| communication_rating | float | Sub-rating |
| location_rating | float | Sub-rating |
| value_rating | float | Sub-rating |
| is_new_listing | boolean | "true"/"false" como string |
| is_guest_favorite | boolean | "true"/"false" como string |

### Valores ausentes por coluna

Tabela completa salva em `outputs/details_ausentes.csv`. Valores exatos:

| Coluna | Ausentes | % |
|--------|----------|---|
| space | 2.092 | 47,11% |
| house_rules | 1.101 | 24,79% |
| guest_satisfaction_overall | 916 | 20,63% |
| star_rating | 916 | 20,63% |
| amenities | 520 | 11,71% |
| safety_features | 258 | 5,81% |
| ad_description | 114 | 2,57% |
| cleaning_fee | 60 | 1,35% |

**Fato:** As colunas `space`, `house_rules`, `amenities` e `safety_features` são textos longos com formatação JSON-like. Muitos registros possuem valores `<NA>` ou strings vazias. As colunas `guest_satisfaction_overall` e `star_rating` possuem exatamente 916 ausentes — possivelmente os mesmos listings.

### Distribuição por listing_type

| Tipo | Quantidade | % |
|------|-----------|---|
| apartamento | 3.710 | 83,54% |
| casa | 443 | 9,98% |
| outros | 245 | 5,52% |
| hotel | 43 | 0,97% |

### Inconsistências de formato

1. **Booleans como string**: `can_instant_book`, `is_professional`, `is_new_listing`, `is_guest_favorite` são "true"/"false" (string), não booleano
2. **number_of_bathrooms**: float (1.0, 2.0) enquanto outros são int
3. **check_in / check_out**: textos livres com horários variados
4. **amenities / house_rules / safety_features**: formato JSON-like inconsistente, com caracteres especiais corrompidos (encoding)
5. **aquisition_date**: data de captura única (2025-01-13) — snapshot estático

---

## 2. Hosts_ids_Itapema.csv — Dados dos Hosts

| Métrica | Valor |
|---------|-------|
| Linhas | 4.440 |
| Colunas | 11 |

### Colunas

`owner_id`, `owner`, `is_superhost`, `number_of_reviews_host`, `is_verified`, `star_rating_host`, `years_host`, `months_host`, `response_rate_shown`, `response_time_shown`, `host_snapshot_date`

### Valores ausentes

Tabela completa salva em `outputs/hosts_ausentes.csv`.

| Coluna | Ausentes | % |
|--------|----------|---|
| response_time_shown | 4.440 | 100,00% |
| response_rate_shown | 4.440 | 100,00% |

**Fato:** `response_rate_shown` e `response_time_shown` estão 100% vazios — não são utilizáveis.

### Chave owner_id

- **owner_id**: 4.440 linhas, **3.057 únicos**
- **509 owner_id aparecem mais de uma vez** (duplicados)
- **Todas as 509 duplicações são linhas DIFERENTES** (nenhuma idêntica)

### Análise de duplicidades

Todos os 509 owner_id duplicados possuem linhas diferentes entre si. Isso indica que o arquivo Hosts contém **snapshots múltiplos do mesmo host** coletados em datas diferentes (`host_snapshot_date`).

**Regra proposta para deduplicação:** Para cada owner_id, selecionar a linha com `host_snapshot_date` mais recente. Essa regra deve ser aplicada **antes** de qualquer join com Details.

**Risco:** Um join direto Details × Hosts (sem deduplicação) **multiplicaria linhas** — um listing com owner_id duplicado geraria 2+ linhas no resultado.

### Distribuição is_superhost

| Valor | Quantidade |
|-------|-----------|
| false | 3.496 |
| true | 944 |

---

## 3. Mesh_Ids_Data_Itapema.csv — Geolocalização

| Métrica | Valor |
|---------|-------|
| Linhas | 4.441 |
| Colunas | 8 |

### Colunas

`airbnb_listing_id`, `latitude`, `longitude`, `suburb`, `country`, `state`, `city`, `aquisition_date`

### Valores ausentes

| Coluna | Ausentes | % |
|--------|----------|---|
| suburb | 5 | 0,11% |

### Chave

- **airbnb_listing_id**: 4.441 valores, **4.441 únicos** → 1:1 com Details

### Distribuição por bairro (suburb)

| Bairro | Quantidade | % |
|--------|-----------|---|
| Meia Praia | 2.860 | 64,40% |
| Centro | 657 | 14,80% |
| Morretes | 441 | 9,93% |
| Tabuleiro dos Oliveiras | 129 | 2,90% |
| Casa Branca | 88 | 1,98% |
| Alto Sao Bento | 62 | 1,40% |
| Ilhota | 56 | 1,26% |
| Varzea | 43 | 0,97% |
| Canto da Praia | 28 | 0,63% |
| Sertao do Trombudo | 22 | 0,50% |
| Sertaozinho | 21 | 0,47% |
| Leopoldo Zarling | 18 | 0,41% |
| Areal | 5 | 0,11% |
| Jardim Praiamar | 5 | 0,11% |
| none | 5 | 0,11% |
| Lameiro | 1 | 0,02% |

### Inconsistências

- 5 registros com suburb = "none" → bairro não informado
- Aquisição dos dados varia: alguns de 2023, outros de 2025

---

## 4. Price_AV_Itapema.csv — Preços Airbnb

| Métrica | Valor |
|---------|-------|
| Linhas | 118.839 |
| Colunas | 4 |

### Colunas

`airbnb_listing_id`, `date`, `price`, `aquisition_date`

### O que cada linha representa

**Cada linha = 1 registro de preço anunciado para 1 listing em 1 data de estadia específica, capturado em 1 data de aquisição.**

### Diferença: data da estadia vs. data de captura

| Campo | Significado |
|-------|------------|
| `date` | Data de estadia (check-in) anunciada |
| `aquisition_date` | Data/hora em que o preço foi capturado (scraped) |

### Rodadas reais de captura

Extraindo somente o dia de `aquisition_date` (ignorando horário):

| Métrica | Valor |
|---------|-------|
| Rodadas de captura (dias únicos) | **3** |
| Período | 2025-01-06 a 2025-01-20 |

**Fato:** Existem apenas 3 rodadas reais de captura, não centenas. A base anterior indicava 4.172 datas de captura — isso era o resultado de incluir o horário (timestamp completo) como se fosse data diferente.

### Duplicidades por chaves

| Chave | Total | Únicos | Duplicados |
|-------|-------|--------|------------|
| listing_id + date | 118.839 | 59.040 | 33.588 |
| listing_id + date + aquisition_day | 118.839 | 118.839 | 0 |

**Interpretação:** Cada combinação listing_id + date + dia de captura é única. As 33.588 duplicações por listing_id + date existem porque o mesmo listing teve seu preço capturado em 2 ou 3 rodadas diferentes.

### Precos distintos entre capturas

| Métrica | Valor |
|---------|-------|
| Com variação de preço entre capturas | 15.617 (26,45%) |
| Sem variação (preço constante) | 43.423 (73,55%) |

### Frequência de mudança

Tabela detalhada salva em `outputs/price_freq_mudancas.csv`.

| Métrica | Valor |
|---------|-------|
| Média de mudanças por listing+data | 0,6 |
| Máximo de mudanças | 2 |
| Combinações com múltiplas capturas | 33.588 |

**Interpreção:** 73,55% dos listings mantiveram o mesmo preço entre as 3 rodadas de captura. Nos 26,45% que mudaram, a mudança foi de apenas 1 valor (ou seja, o preço subiu ou baixou uma única vez entre as capturas).

### Regra de consolidação proposta

**Regra:** Para cada combinação (listing_id, date), selecionar a captura mais recente disponível (maior aquisition_day).

**Justificativa:** A captura mais recente reflete a decisão de preço mais atual do host. Como há apenas 3 rodadas e a maioria dos preços não mudou, a diferença entre regras (média, mediana, mais recente) será pequena na maioria dos casos. A regra "mais recente" é a mais simples e defensável.

**Status:** Regra proposta e documentada. Não aplicada nesta etapa.

### Estatísticas de preço

| Métrica | Valor |
|---------|-------|
| Mínimo | R$ 63 |
| Máximo | R$ 29.000 |
| Média | R$ 713,10 |
| Mediana | R$ 607 |
| Registros com preço válido | 118.839 |

### Disponibilidade / Ocupação / Reserva

**A base NÃO contém:**
- Informação de disponibilidade (no/yes)
- Ocupação (% ou número de noites ocupadas)
- Reserva confirmada
- Check-in/check-out real
- Cancelamentos

**A base APENAS contém:** Preço anunciado (listed price) para datas futuras.

### Receita observada vs. receita potencial

| Conceito | Possível? | Justificativa |
|----------|-----------|---------------|
| Receita observada (real) | **NÃO** | Não há dados de reservas confirmadas ou check-ins |
| Receita potencial (máxima) | **Parcial** | Pode-se calcular preço × noites, mas sem taxa de ocupação é apenas teórico |

**Regra:** O preço anunciado **NÃO** é receita realizada.

### Reviews ≠ Reservas

**Número de reviews NÃO equivale a número de reservas.** Não é válido usar reviews como proxy direto de demanda ou ocupação.

---

## 5. VivaReal_Itapema.csv — Anúncios de Venda

| Métrica | Valor |
|---------|-------|
| Linhas | 8.329 |
| Colunas | 22 |

### Colunas

`listing_id`, `link_url`, `listing_title`, `business_types`, `listing_type`, `property_type`, `sale_price`, `rental_price`, `rental_period`, `yearly_iptu`, `monthly_condo_fee`, `amenities`, `usable_area`, `bathrooms`, `bedrooms`, `parking_spaces`, `state`, `city`, `suburb`, `advertiser_name`, `portal`, `aquisition_date`

### Valores ausentes — exatos

Tabela completa salva em `outputs/vivareal_ausentes.csv`.

| Coluna | Ausentes | % |
|--------|----------|---|
| rental_period | 8.327 | 99,98% |
| rental_price | 8.327 | 99,98% |
| yearly_iptu | 2.714 | 32,58% |
| monthly_condo_fee | 2.490 | 29,90% |
| suburb | 98 | 1,18% |
| state | 2 | 0,02% |

**Fato:** `rental_price` e `rental_period` estão 99,98% vazios. `yearly_iptu` possui 32,58% de ausentes (2.714 registros). `monthly_condo_fee` possui 29,90% de ausentes (2.490 registros). Estes campos **não estão quase totalmente vazios** — estão parcialmente preenchidos (67-70% dos registros possuem valor).

### Estatísticas de sale_price (percentis)

| Métrica | Valor |
|---------|-------|
| Registros válidos | 8.181 |
| Mínimo | R$ 10.000 |
| P5 | R$ 590.000 |
| P25 | R$ 900.000 |
| P50 (mediana) | R$ 1.725.000 |
| P75 | R$ 2.799.640 |
| P95 | R$ 6.158.563 |
| Máximo | R$ 9.998.800 |
| Média | R$ 2.230.068,22 |

### Estatísticas de usable_area (percentis)

| Métrica | Valor |
|---------|-------|
| Registros válidos | 8.329 |
| Mínimo | 0 m² |
| P5 | 61 m² |
| P50 (mediana) | 128 m² |
| P95 | 300 m² |
| Máximo | 188.000 m² |

**Nota:** O valor mínimo de 0 m² e máximo de 188.000 m² são extremos que merecem investigação.

### monthly_condo_fee

| Métrica | Valor |
|---------|-------|
| Registros válidos | 5.839 |
| Ausentes | 2.490 (29,90%) |
| Mínimo | R$ 0 |
| P50 (mediana) | R$ 290 |
| Máximo | R$ 3.150.000 |

**Nota:** O máximo de R$ 3.150.000 é um extremo provável (erro de registro).

### yearly_iptu

| Métrica | Valor |
|---------|-------|
| Registros válidos | 5.615 |
| Ausentes | 2.714 (32,58%) |
| Mínimo | R$ 0 |
| P50 (mediana) | R$ 150 |
| Máximo | R$ 2.800.000 |

**Nota:** O máximo de R$ 2.800.000 é um extremo provável (erro de registro).

### Preço por metro quadrado (price_per_m2)

Tabela completa salva em `outputs/vivareal_ppsm.csv`.

| Métrica | Valor |
|---------|-------|
| Registros válidos | 8.170 |
| Mínimo | R$ 12,77/m² |
| P5 | R$ 6.477,48/m² |
| P50 (mediana) | R$ 13.931,52/m² |
| P95 | R$ 30.801,95/m² |
| Máximo | R$ 669.000/m² |

**Nota:** Extremos (P5 e P95) devem ser investigados antes de uso em análise. Registros com preço/m2 abaixo de R$ 1.000 ou acima de R$ 50.000 podem conter erros.

### property_type

**Todos os 8.329 registros são "UNIT"** — não há casas, terrenos ou outros tipos.

### Quartos (bedrooms)

| Quartos | Quantidade | % |
|---------|-----------|---|
| 3 | 3.435 | 41,24% |
| 4 | 2.240 | 26,89% |
| 2 | 2.076 | 24,92% |
| 0 | 230 | 2,76% |
| 1 | 179 | 2,15% |
| 5 | 136 | 1,63% |
| 6+ | 33 | 0,40% |

### Distribuição por bairro

| Bairro | Quantidade | % |
|--------|-----------|---|
| Meia Praia | 3.467 | 41,63% |
| Morretes | 1.777 | 21,33% |
| Centro | 1.010 | 12,13% |
| Andorinha | 782 | 9,39% |
| Castelo Branco | 510 | 6,12% |
| Canto da Praia | 131 | 1,57% |
| Tabuleiro dos Oliveiras | 128 | 1,54% |
| Jardim Praia Mar | 104 | 1,25% |
| Casa Branca | 95 | 1,14% |
| Alto Sao Bento | 66 | 0,79% |
| Ilhota | 55 | 0,66% |
| Varzea | 47 | 0,56% |
| Sertao do Trombudo | 42 | 0,50% |
| Outros | 117 | 1,41% |

### listing_id duplicados

| Métrica | Valor |
|---------|-------|
| Total de linhas | 8.329 |
| listing_id únicos | 8.293 |
| listing_id duplicados | 36 |

### Análise dos 36 duplicados

Tabela completa salva em `outputs/vivareal_duplicidades.csv`.

| Categoria | Quantidade |
|-----------|-----------|
| Linhas idênticas (duplicatas exatas) | 35 |
| Linhas diferentes (mudança de preço/atributos) | 1 |

**Interpretação:** 35 dos 36 duplicados são linhas idênticas (duplicatas exatas de importação). Apenas 1 listing_id possui duas linhas com atributos diferentes (possível atualização de preço).

**Regra de deduplicação proposta:** Remover linhas idênticas (manter 1). Para o caso de atributos diferentes, manter a linha com `aquisition_date` mais recente.

**Status:** Regra proposta e documentada. Dados originais preservados.

### Inconsistências de bairro entre bases Airbnb e VivaReal

- Nomes de bairros **não são idênticos**:
  - Mesh: "Alto Sao Bento" vs VivaReal: "Alto São Bento" (acentuação)
  - Mesh: "Sertao do Trombudo" vs VivaReal: "Sertão do Trombudo"
  - VivaReal tem bairros extras: "Andorinha", "Castelo Branco", "Ocean Tower"
  - VivaReal tem variações: "Tabuleiro" vs "Tabuleiro dos Oliveiras"

### Custos de investimento NÃO disponíveis na base

| Custo | Disponível? |
|-------|------------|
| ITBI (imóveis) | **NÃO** |
| Registro/cartório | **NÃO** |
| Comissão corretor (comprador) | **NÃO** |
| Reforma/mobiliário | **NÃO** |
| Custos administrativos Airbnb | **NÃO** |
| Taxa de limpeza | Parcial (apenas no Airbnb) |
| Seguro | **NÃO** |
| Condomínio | Parcial (70,10% preenchidos) |
| IPTU | Parcial (67,42% preenchidos) |

---

## 6. Relacionamentos entre as bases

### Chaves de ligação

| Base A | Base B | Campo de ligação |
|--------|--------|------------------|
| Details | Mesh | `airbnb_listing_id` |
| Details | Price_AV | `airbnb_listing_id` |
| Details | Hosts | `owner_id` |
| VivaReal | (isolada) | Nenhuma chave direta com Airbnb |

### Details ↔ Mesh

| Métrica | Valor |
|---------|-------|
| Listings Details em Mesh | 4.441 / 4.441 |
| **Cobertura** | **100,00%** |
| Listings Mesh em Details | 4.441 / 4.441 |
| **Cobertura** | **100,00%** |

**Relação 1:1** — cada listing tem exatamente 1 registro de geolocalização.

### Details ↔ Price_AV

| Métrica | Valor |
|---------|-------|
| Listings Details em Price_AV | 999 / 4.441 |
| **Cobertura** | **22,50%** |
| Listings Price_AV em Details | 999 / 1.005 |
| **Cobertura** | **99,40%** |

**Relação 1:N** — cada listing pode ter múltiplos registros de preço (múltiplas datas de estadia × 3 rodadas de captura).

### Details ↔ Hosts (sem deduplicação)

| Métrica | Valor |
|---------|-------|
| Owner_id únicos em Details | 3.057 |
| Owner_id únicos em Hosts | 3.057 |
| Owners Details em Hosts | 3.057 / 3.057 |
| **Cobertura** | **100,00%** |

**ATENÇÃO:** Antes de classificar como N:1, é necessário deduplicar Hosts (509 owner_id duplicados com linhas diferentes). Sem deduplicação, um join Details × Hosts multiplicaria linhas.

### VivaReal (isolada)

A base VivaReal **não possui chave de ligação direta** com as bases Airbnb. Para conectar, seria necessário usar:
- Bairro + quartos + área (aproximação, não exata)
- Geolocalização (raio de proximidade)

---

## 7. Resumo de qualidades e limitações

### Qualidades

1. **Cobertura 100%** entre Details, Mesh e Hosts (antes de deduplicação)
2. **Dados geográficos completos** (latitude/longitude + bairro)
3. **Dados de venda abundantes** (8.329 anúncios)
4. **Snapshots com timestamps** permite análise temporal
5. **3 rodadas de captura** permitem verificar estabilidade de preços

### Limitações

1. **Apenas 22,50% dos listings têm dados de preço** — ver analysis/representatividade_price_av.md para análise de viés
2. **Preço é anunciado, não realizado** — não reflete receita real
3. **Sem dados de ocupação ou reservas** — impossível calcular receita diretamente
4. **Base isolada no tempo** (janeiro 2025) — não reflete sazonalidade completa
5. **Condomínio com 29,90% de ausentes e IPTU com 32,58% de ausentes** — parcialmente preenchidos
6. **Inconsistências de encoding** em textos (caracteres especiais corrompidos)
7. **Bairros com nomes diferentes** entre bases Airbnb e VivaReal
8. **Reviews ≠ reservas** — não usar como proxy de demanda sem ressalva
9. **Hosts com 509 duplicações** — requer deduplicação antes de join
10. **Extremos em preço/m2** (P5=R$ 6.477, P95=R$ 30.802) — requerem filtragem

---

*Auditoria gerada via `src/auditoria_corretiva.ps1`, `src/price_analysis.ps1`, `src/repr_viva_analysis.ps1`*
*Tabelas auxiliares: `outputs/auditoria_tabelas.csv`, `outputs/representatividade_price_av.csv`, `outputs/vivareal_ausentes.csv`, `outputs/vivareal_ppsm.csv`, `outputs/vivareal_duplicidades.csv`, `outputs/price_freq_mudancas.csv`, `outputs/details_ausentes.csv`, `outputs/hosts_ausentes.csv`, `outputs/hosts_duplicidades.csv`*
