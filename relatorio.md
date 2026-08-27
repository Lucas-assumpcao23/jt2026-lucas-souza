# Desafio Jovens Talentos AI Builder 2026 — Seazone

## Recomendação de Investimento em Imóveis para Temporada em Itapema (SC)

---

## 1. Resumo executivo

Análise combinada de dados de hospedagem (Airbnb) e mercado de compra (VivaReal) para estimar o retorno bruto simplificado de apartamentos residenciais em Itapema, SC.

**Recomendação principal:** Apartamento residencial de 2 quartos em Morretes.

| Métrica | Valor |
|---------|-------|
| Preço mediano de aquisição anunciado | R$ 750.000 |
| Área útil mediana | 69 m² |
| Diária anunciada mediana (Airbnb) | R$ 464 |
| Retorno bruto anual (55% ocupação) | 12,42% |
| Retorno bruto com diária P25 (55%) | 10,68% |
| Ocupação necessária para retorno de 7% | 31,0% |
| Amostra Airbnb | 43 listings |
| Amostra VivaReal | 1.243 anúncios |

A tese preliminar da Seazone — de que compactos no Centro seriam a aposta mais eficiente — é parcialmente sustentada. Apartamentos de 1 quarto no Centro apresentam boa eficiência por hóspede e retorno competitivo, mas não lideram em retorno bruto simplificado e possuem preço de entrada superior. Morretes 2 quartos mostrou melhor equilíbrio entre preço, retorno e robustez de amostra.

---

## 2. Problema e objetivo

A Seazone busca orientar a aquisição de imóveis para locação curta em Itapema (SC). O objetivo é identificar qual perfil residencial (bairro + tamanho) oferece o melhor retorno bruto estimado entre os segmentos com dados suficientes para sustentar uma decisão.

---

## 3. Dados utilizados

| Fonte | Descrição | Registros |
|-------|-----------|-----------|
| Details_Itapema.csv | Cada anúncio de Airbnb: título, reviews, star rating, descrição, host_id, nº de quartos, tipo de imóvel | 4.441 linhas |
| Hosts_ids_Itapema.csv | Dados do anfitrião: nº de reviews, anos como host, superhost, taxa de resposta | 4.440 linhas, 3.057 owner_id únicos |
| Mesh_Ids_Data_Itapema.csv | Latitude/longitude + bairro de cada anúncio | 4.441 linhas |
| Price_AV_Itapema.csv | Preço por anúncio, por data de estadia e por data de captura | 118.839 linhas, 1.005 IDs presentes, 999 com correspondência em Details |
| VivaReal_Itapema.csv | Anúncios de venda: preço, condomínio, área, vendedor | 8.329 linhas, 8.293 após deduplicação |

**Período de cobertura:** Janeiro a abril de 2025 (hospedagem).

**Base consolidada Airbnb:** 999 listings com preço por noite, após regras de seleção e deduplicação.

**Cobertura de preço:** A base de preços cobre 22,5% dos listings (999 de 4.441), com viés moderado (+7,4pp para Centro, mediana de quartos 3 vs 2 na base completa).

**Filtros da análise principal:** Listings com pelo menos 30 datas de estadia e diária mediana entre R$ 150 (P1) e R$ 2.500 (P99). Amostra resultante: 847 listings.

---

## 4. Critério de melhor investimento

Definimos como melhor segmento aquele que maximiza o retorno bruto simplificado entre os segmentos com:

- Amostra Airbnb adequada (30 ou mais listings);
- Pelo menos 30 anúncios residenciais no VivaReal;
- Consistência residencial comprovada (excluídos terrenos, comerciais e imóveis sem tipologia residencial confirmada).

O retorno bruto simplificado é calculado como:

`retorno = diaria_mediana × 365 × ocupacao / preco_compra_mediano`

**Ocupação é uma premissa de cenário (40%, 55%, 70%), não um dado da base.**

---

## 5. Tratamento e validação dos dados

### VivaReal

- Padronização de bairros: 8 registros com grafia inconsistente (ex: "Tabuleiro" → "Tabuleiro dos Oliveiras")
- Duplicatas: 35 exatas removidas, 1 duplicata diferente (mantida aquisição mais recente)
- Base tratada: 8.293 registros

### Morretes 1 quarto

- Investigação revelou que 0 quartos em Morretes são majoritariamente terrenos e comerciais
- Amostra validada: área 20-100m², controle P1-P99 → 49 registros, SP mediana R$ 600.000

### Centro e Meia Praia — 0 quartos

- Centro: 3 registros, todos comerciais
- Meia Praia: 30 registros, 24 comerciais, 5 terrenos, 1 ambíguo
- **Não foram identificados studios residenciais comprováveis** nos registros analisados

### Consequência

O grupo "0-1 quartos" **não deve ser usado** para nenhum dos três bairros. Para compactos, usar exclusivamente 1 quarto.

---

## 6. Análise do Airbnb

### Bairros com pelo menos 30 listings

| Bairro | Listings | DM mediana | DM por hóspede |
|--------|----------|-----------|----------------|
| Meia Praia | 524 | R$ 595 | R$ 89 |
| Centro | 189 | R$ 509 | R$ 123 |
| Morretes | 69 | R$ 471 | R$ 85 |

### Grupos combinados (>=10 listings)

| Grupo | Listings | DM mediana | DM/hóspede |
|-------|----------|-----------|------------|
| Meia Praia apt 4q | 47 | R$ 900 | R$ 90 |
| Centro apt 3q | 39 | R$ 750 | R$ 94 |
| Meia Praia apt 3q | 273 | R$ 697 | R$ 87 |
| Centro apt 2q | 61 | R$ 583 | R$ 97 |
| Centro apt 1q | 76 | R$ 450 | R$ 143 |
| Meia Praia apt 2q | 156 | R$ 450 | R$ 75 |
| Meia Praia apt 1q | 17 | R$ 490 | R$ 123 |
| Morretes apt 2q | 43 | R$ 464 | R$ 93 |

### Análise de sensibilidade

Ranking dos bairros e grupos combinados permaneceu estável entre amostra principal e totalidade dos 999 listings.

---

## 7. Análise do mercado de compra

### Segmentos residenciais (10 segmentos analisados)

| Segmento | Qtd VR | SP mediana | Área mediana | Pm² mediana |
|----------|--------|-----------|-------------|-------------|
| Centro 1q | 25 | R$ 890.000 | 54 m² | R$ 19.905 |
| Centro 2q | 92 | R$ 1.140.000 | 86 m² | R$ 13.029 |
| Centro 3q | 442 | R$ 2.100.000 | 131 m² | R$ 15.789 |
| Meia Praia 1q | 62 | R$ 880.000 | 47 m² | R$ 21.250 |
| Meia Praia 2q | 243 | R$ 1.080.000 | 85 m² | R$ 13.033 |
| Meia Praia 3q | 1.708 | R$ 1.884.860 | 129 m² | R$ 14.957 |
| Meia Praia 4q | 1.329 | R$ 3.549.790 | 188 m² | R$ 18.428 |
| Morretes 1q | 49 | R$ 600.000 | 44 m² | R$ 12.889 |
| Morretes 2q | 1.243 | R$ 750.000 | 69 m² | R$ 11.086 |
| Morretes 3q | 306 | R$ 790.000 | 100 m² | R$ 8.333 |

**Nota:** Preço de venda é preço anunciado, não preço efetivamente negociado.

---

## 8. Estimativa de retorno

### Ranking por retorno bruto (cenário 55%)

| Pos | Segmento | Ret55% | RetP25_55% | Oc7% | Robustez Airbnb |
|-----|----------|--------|-----------|------|----------|
| 1° | Morretes 3q | 16,52% | 15,25% | 23,3% | insuficiente |
| 2° | Morretes 1q | 16,06% | 16,06% | 24,0% | insuficiente |
| 3° | Morretes 2q | 12,42% | 10,68% | 31,0% | **adequada** |
| 4° | Meia Praia 1q | 11,18% | 10,74% | 34,4% | pequena |
| 5° | Centro 2q | 10,27% | 8,80% | 37,5% | **adequada** |
| 6° | Centro 1q | 10,15% | 9,63% | 37,9% | **adequada** |
| 7° | Meia Praia 2q | 8,36% | 7,44% | 46,0% | **adequada** |
| 8° | Meia Praia 3q | 7,42% | 6,18% | 51,9% | **adequada** |
| 9° | Centro 3q | 7,17% | 6,62% | 53,7% | **adequada** |
| 10° | Meia Praia 4q | 5,09% | 5,09% | 75,6% | **adequada** |

Segmentos com maior retorno bruto (Morretes 3q, Morretes 1q) não foram escolhidos devido à amostra Airbnb insuficiente (8 e 2 listings).

---

## 9. Comparação das alternativas

| Métrica | Morretes 2q | Centro 1q | Centro 2q |
|---------|-------------|-----------|-----------|
| Retorno 55% | 12,42% | 10,15% | 10,27% |
| Retorno P25 | 10,68% | 9,63% | 8,80% |
| Oc7% | 31,0% | 37,9% | 37,5% |
| SP mediana | R$ 750.000 | R$ 890.000 | R$ 1.140.000 |
| Área mediana | 69 m² | 54 m² | 86 m² |
| Qtd Airbnb | 43 | 76 | 61 |
| Qtd VR | 1.243 | 25 | 92 |
| DM/hóspede | R$ 93 | R$ 143 | R$ 97 |

**Nota sobre Centro 1q:** Possui 76 listings Airbnb (amostra adequada), mas apenas 25 registros no VivaReal (abaixo do limiar de 30 registros usado para decisão primária). Os preços de aquisição para Centro 1q devem ser interpretados com cautela.

---

## 10. Recomendação final

**Apartamento residencial de 2 quartos em Morretes.**

| Métrica | Valor |
|---------|-------|
| Preço mediano de aquisição anunciado | R$ 750.000 |
| Área útil mediana | 69 m² |
| Retorno bruto anual (55% ocupação) | 12,42% |
| Retorno bruto com P25 (55%) | 10,68% |
| Ocupação para retorno de 7% | 31,0% |
| Amostra Airbnb | 43 listings (adequada) |
| Amostra VivaReal | 1.243 anúncios |

**Justificativa:**
- Maior retorno bruto entre segmentos com amostra adequada;
- Menor preço de entrada entre os três primeiros do ranking;
- Amostra robusta em ambas as bases (Airbnb e VivaReal);
- Boa resistência com diária P25 (perda de apenas 1,74pp);
- Morretes 2q exige 31,0% de ocupação para retorno de 7%, contra 37,9% de Centro 1q, mas a viabilidade prática não pode ser confirmada sem dados de ocupação realizada.
- Todos os imóveis são apartamentos residenciais confirmados.

---

## 11. Posição sobre a tese dos compactos no Centro

### Teste da tese preliminar: compactos no Centro

**Hipótese original:** A análise preliminar interna da Seazone sugeria que apartamentos compactos, studio ou 1 quarto, no Centro seriam a aposta mais eficiente.

#### Comparação direta

| Métrica | Centro 1q | Morretes 2q |
|---------|-----------|-------------|
| Retorno 55% | 10,15% | 12,42% |
| Retorno P25 | 9,63% | 10,68% |
| Oc7% | 37,9% | 31,0% |
| SP mediana | R$ 890.000 | R$ 750.000 |
| DM/hóspede | R$ 143 | R$ 93 |
| Qtd Airbnb | 76 | 43 |
| Qtd VR | 25 | 1.243 |

#### Partes da tese sustentadas

- Apartamentos de 1 quarto no Centro apresentam boa eficiência por hóspede (R$ 143 vs R$ 93 em Morretes 2q);
- Possuem retorno bruto competitivo (10,15% no cenário de 55%);
- Apresentam boa resistência quando utilizada a diária P25 (perda de apenas 0,52pp);
- Constituem uma alternativa relevante de investimento, especialmente para quem prioriza localização central e eficiência por hóspede.

#### Partes da tese não sustentadas

- Centro 1 quarto **não apresentou o maior retorno bruto simplificado** entre segmentos com amostra adequada;
- Possui preço mediano anunciado **aproximadamente R$ 140.000 superior** ao de Morretes 2 quartos;
- Exige ocupação **6,9 pontos percentuais maior** para atingir retorno bruto de 7% (37,9% vs 31,0%);
- Os 3 registros de 0 quarto no Centro eram salas comerciais — **não foram identificados studios residenciais comprováveis** nos registros analisados;
- A hipótese referente a **studios não pôde ser confirmada** porque não foram identificados studios residenciais comprováveis na base de VivaReal para Centro (nem para Meia Praia nem Morretes).

#### Conclusão sobre a tese

A tese dos compactos no Centro é **parcialmente sustentada**. O perfil apresenta eficiência relevante e retorno competitivo, mas os dados não o apontam como a alternativa mais eficiente entre os segmentos com amostras adequadas. Apartamentos de 2 quartos em Morretes apresentaram melhor equilíbrio entre preço de entrada, retorno bruto estimado, ocupação necessária e robustez das amostras.

**Ressalva importante:** A diferença observada (12,42% vs 10,15%) não garante desempenho futuro. O retorno bruto simplificado não é ROI líquido e não inclui custos operacionais, impostos, manutenção ou vacância implícita.

---

## 12. Limitações

- **Diária anunciada não é receita realizada.** Preços de hospedagem variam por sazonalidade, dia da semana e promoções.
- **Preço de venda anunciado não é preço negociado.** Descontos e condições de pagamento podem alterar o custo real.
- **Retorno bruto simplificado não é ROI líquido.** Não inclui condomínio, IPTU, manutenção, seguros, taxa de administração, imposto de renda ou depreciação.
- **Ocupação é premissa de cenário**, não um dado empírico da base.
- **Cobertura de preço:** A base Airbnb cobre 22,5% dos listings, com viés moderado para Centro e imóveis maiores.
- **Período de dados:** Janeiro a abril de 2025 — não captura sazonalidade anual completa.
- **Amostras pequenas:** Morretes 1q (2 listings) e 3q (8 listings) não permitem conclusões robustas.
- **Não há dados de taxa de ocupação real** — todos os cálculos dependem de premissas.
- **Não inclui valorização do imóvel** como componente de retorno.

---

## 13. O que seria feito com mais uma semana

1. **Integrar taxa de ocupação real** de dados observados de ocupação, reservas e receita provenientes de fonte autorizada ou de sistemas operacionais.
2. **Adicionar custos operacionais** (condomínio, IPTU, manutenção, administração) para calcular ROI líquido.
3. **Analisar sazonalidade** com dados de 12 meses para identificar meses de alta e baixa demanda.
4. **Validar preços de negociação** com dados de transações efetivas (cartórios).
5. **Expandir a amostra** para outros bairros e tipos de imóvel.
6. **Modelar fluxo de caixa** descontado com diferentes cenários de financiamento.

---

*Relatório completo: `relatorio.md`*
*Dados: `data/` (originais, inalterados)*
*Saídas: `outputs/` (análises intermediárias)*
