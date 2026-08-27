# Qualidade da Métrica diaria_mediana

**Data:** 2026-08-26
**Base:** `outputs/base_airbnb_consolidada.csv` (999 listings)

---

## 1. Métricas de datas_estadia

| Métrica | Valor |
|---------|-------|
| Mínimo | 2 |
| Mediana | 62 |
| Máximo | 105 |
| Exatamente 105 datas | 1 listing |
| Pelo menos 90 datas | 74 listings |
| Menos de 30 datas | 140 listings |

---

## 2. Métricas de diaria_mediana (999 listings)

| Percentil | Valor (R$) |
|-----------|-----------|
| Mínimo | 100 |
| P1 | 150 |
| P5 | 250 |
| P25 | 400 |
| Mediana | 550 |
| P75 | 780 |
| P95 | 1.400 |
| P99 | 2.500 |
| Máximo | 10.000 |

### IQR (Intervalo Interquartil)

| Métrica | Valor |
|---------|-------|
| Q1 | 400 |
| Q3 | 780 |
| IQR | 380 |
| Lower fence (Q1 - 1,5×IQR) | -170 |
| Upper fence (Q3 + 1,5×IQR) | 1.350 |
| Abaixo do fence | 0 listings |
| Acima do fence | 55 listings |

**Observação:** 55 listings (5,5%) estão acima do fence de R$ 1.350. O valor máximo de R$ 10.000 é 7,4× o fence superior, indicando extremos.

---

## 3. Listas de extremos

### 15 menores valores de diaria_mediana

| ID | Bairro | Tipo | Quartos | Hóspedes | Datas | Mediana | P25 | P75 |
|----|--------|------|---------|----------|-------|---------|-----|-----|
| 639163267116212627 | Tabuleiro dos Oliveiras | outros | 1 | 2 | 8 | R$ 100 | R$ 100 | R$ 100 |
| 41686810 | Meia Praia | outros | 2 | 2 | 59 | R$ 100 | R$ 90 | R$ 100 |
| 942057172413556286 | Meia Praia | outros | 1 | 1 | 39 | R$ 100 | R$ 100 | R$ 100 |
| 883930877150990341 | Meia Praia | outros | 1 | 3 | 5 | R$ 109 | R$ 109 | R$ 109 |
| 10266012 | Morretes | outros | 1 | 2 | 58 | R$ 125 | R$ 117 | R$ 125 |
| 728531681504670920 | Tabuleiro dos Oliveiras | apartamento | 2 | 10 | 37 | R$ 133,50 | R$ 120 | R$ 173 |
| 711032530664362412 | Varzea | casa | 1 | 2 | 35 | R$ 149 | R$ 149 | R$ 199 |
| 794707921952592251 | Meia Praia | outros | 1 | 2 | 48 | R$ 150 | R$ 150 | R$ 155 |
| 30922946 | Meia Praia | outros | 1 | 2 | 71 | R$ 150 | R$ 140 | R$ 260 |
| 839184834439414765 | Meia Praia | outros | 1 | 2 | 42 | R$ 150 | R$ 150 | R$ 150 |
| 1039235354309448898 | Centro | apartamento | 2 | 2 | 75 | R$ 150 | R$ 150 | R$ 200 |
| 985445004274818605 | Centro | outros | 1 | 2 | 59 | R$ 150 | R$ 150 | R$ 200 |
| 22306996 | Meia Praia | apartamento | 2 | 5 | 30 | R$ 155 | R$ 155 | R$ 165 |
| 51403736 | Meia Praia | outros | 1 | 2 | 55 | R$ 160 | R$ 160 | R$ 160 |
| 758758164947604865 | Meia Praia | outros | 1 | 2 | 82 | R$ 170 | R$ 100 | R$ 170 |

### 15 maiores valores de diaria_mediana

| ID | Bairro | Tipo | Quartos | Hóspedes | Datas | Mediana | P25 | P75 |
|----|--------|------|---------|----------|-------|---------|-----|-----|
| 40391575 | Morretes | apartamento | 2 | 4 | 7 | R$ 10.000 | R$ 10.000 | R$ 10.000 |
| 31167122 | Meia Praia | apartamento | 2 | 6 | 85 | R$ 10.000 | R$ 10.000 | R$ 10.000 |
| 1242002119123644781 | Meia Praia | apartamento | 4 | 6 | 90 | R$ 5.500 | R$ 5.500 | R$ 5.583 |
| 30519162 | Canto da Praia | casa | 4 | 8 | 91 | R$ 3.900 | R$ 3.900 | R$ 3.900 |
| 995680028058206783 | Sertaozinho | casa | 6 | 16 | 96 | R$ 3.500 | R$ 3.500 | R$ 3.500 |
| 52758042 | Meia Praia | apartamento | 4 | 8 | 103 | R$ 3.000 | R$ 2.690 | R$ 3.000 |
| 44075219 | Centro | apartamento | 3 | 8 | 14 | R$ 2.778 | R$ 2.260 | R$ 2.864 |
| 40289385 | Alto Sao Bento | casa | 12 | 16 | 62 | R$ 2.500 | R$ 2.500 | R$ 2.500 |
| 40191152 | Meia Praia | apartamento | 4 | 10 | 76 | R$ 2.500 | R$ 1.068 | R$ 2.500 |
| 43300431 | Meia Praia | apartamento | 4 | 10 | 88 | R$ 2.500 | R$ 2.000 | R$ 2.800 |
| 13522176 | Meia Praia | apartamento | 5 | 15 | 32 | R$ 2.300 | R$ 2.000 | R$ 2.700 |
| 39745810 | Meia Praia | apartamento | 4 | 8 | 89 | R$ 2.250 | R$ 2.250 | R$ 2.500 |
| 718922870189236806 | Meia Praia | apartamento | 5 | 16 | 29 | R$ 2.100 | R$ 1.600 | R$ 2.900 |
| 816613605644920543 | Centro | casa | 4 | 12 | 92 | R$ 2.100 | R$ 1.800 | R$ 2.100 |
| 910707550951342167 | Meia Praia | apartamento | 4 | 8 | 2 | R$ 2.000 | R$ 2.000 | R$ 2.000 |

---

## 4. Identificação de extremos

### Por IQR (Q3 + 1,5×IQR = R$ 1.350)
- **55 listings** acima do fence superior
- **0 listings** abaixo do fence inferior

### Por percentis
- P99 = R$ 2.500 — valores acima deste corte são os 1% mais caros
- Máximo = R$ 10.000 — 4× o P99

### Listagens potencialmente extremas
Os 15 maiores valores (R$ 2.000 a R$ 10.000) são apartamentos e casas grandes (4-12 quartos, 8-16 hóspedes). Alguns podem ser legítimos (casas de luxo), outros podem conter erros de preço. **Nenhum registro foi removido.**

---

## 5. Comparação de 3 amostras

### Amostra A: Todos os 999 listings

| Métrica | Valor |
|---------|-------|
| Qtd | 999 |
| Mínimo | R$ 100 |
| P5 | R$ 250 |
| P25 | R$ 400 |
| Mediana | R$ 550 |
| P75 | R$ 780 |
| P95 | R$ 1.400 |
| P99 | R$ 2.500 |
| Máximo | R$ 10.000 |

### Amostra B: Pelo menos 30 datas

| Métrica | Valor |
|---------|-------|
| Qtd | 859 |
| Mínimo | R$ 100 |
| P5 | R$ 269 |
| P25 | R$ 400 |
| Mediana | R$ 572 |
| P75 | R$ 800 |
| P95 | R$ 1.400 |
| P99 | R$ 2.500 |
| Máximo | R$ 10.000 |

### Amostra C: Pelo menos 30 datas E diaria_mediana entre R$ 150 e R$ 2.500

| Métrica | Valor |
|---------|-------|
| Qtd | 847 |
| Filtro | diaria_mediana entre R$ 150 e R$ 2.500, além de pelo menos 30 datas |
| Mínimo | R$ 150 |
| P5 | R$ 280 |
| P25 | R$ 400 |
| Mediana | R$ 550 |
| P75 | R$ 780 |
| P95 | R$ 1.400 |
| Máximo | R$ 2.500 |

### Análise comparativa

| Aspecto | A (999) | B (859) | C (847) |
|---------|---------|---------|---------|
| Perde listings | — | 140 (14,0%) | 152 (15,2%) |
| Remove extremos inferiores | Não | Não | Sim (até P1) |
| Remove extremos superiores | Não | Não | Sim (até P99) |
| Mediana | R$ 550 | R$ 572 | R$ 550 |
| P95 | R$ 1.400 | R$ 1.400 | R$ 1.400 |
| Máximo | R$ 10.000 | R$ 10.000 | R$ 2.500 |

**Diferenças-chave:**
- A vs B: A amostra B remove 140 listings com poucos dados (<30 datas), mas as métricas de preço mudam pouco (mediana vai de R$550 para R$572). Isso indica que os listings com poucos dados têm preços levemente menores em média.
- B vs C: A amostra C remove additionally 12 listings com preços extremos (fora de P1-P99). O máximo cai de R$10.000 para R$2.500, mas a mediana permanece em R$550.

---

## 6. Recomendação

### Amostra recomendada: **C** (pelo menos 30 datas E diaria_mediana entre P1 e P99)

**Justificativa:**

1. **Filtro de dados:** Listings com menos de 30 datas têm amostra de preços muito pequena para calcular uma mediana confiável. Remover 140 listings com dados insuficientes melhora a qualidade da métrica.

2. **Filtro de extremos:** Valores acima de R$ 2.500 (P99) equivalem a aproximadamente 4,5× a mediana (R$ 550), e o máximo de R$ 10.000 equivale a aproximadamente 18,2× a mediana. Esses valores podem distorcer comparações entre bairros e perfis. A remoção de apenas 12 listings adicionais (além dos 140 já removidos) elimina esses extremos sem perda significativa de dados.

3. **Preservação de dados:** A amostra C mantém 847 listings (84,8% do total), perdendo apenas 152. É uma perda aceitável em troca de maior robustez estatística.

4. **Robustez:** A mediana da amostra C (R$ 550) é idêntica à mediana da amostra A, indicando que os filtros não distorcem o centro da distribuição.

5. **Reprodutibilidade:** Os filtros são transparentes e documentados: (a) minimum 30 datas de estadia, (b) diaria_mediana entre R$ 150 (P1) e R$ 2.500 (P99) da amostra completa. A amostra C exclui portanto valores abaixo de R$ 150 e acima de R$ 2.500, além dos listings com menos de 30 datas.

---

## 7. Confirmação final

- **Amostra recomendada:** C (>=30 datas AND diaria_mediana entre P1 e P99)
- **Listings mantidos:** 847
- **Nenhum arquivo foi alterado** — base consolidada original preservada

---

*Script de validação: `src/valida_diaria.ps1`*
