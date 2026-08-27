# Validação de Retorno — Comparação Investimento

**Data:** 2026-08-26
**Base validada:** `outputs/comparacao_investimento.csv`

---

## 1. Tabela validada (recálculo direto pelas fórmulas)

| Segmento | Bairro | Qrt | Qtd Airbnb | DM | P25 | Robustez | Qtd VR | SP mediana | Ret55% | RetP25_55% | Oc7% |
|----------|--------|-----|-----------|-----|-----|----------|--------|-----------|--------|-----------|------|
| Morretes 3q | Morretes | 3 | 8 | R$ 650 | R$ 600 | insuficiente | 306 | R$ 790.000 | 16,52% | 15,25% | 23,3% |
| Morretes 1q | Morretes | 1 | 2 | R$ 480 | R$ 480 | insuficiente | 49 | R$ 600.000 | 16,06% | 16,06% | 24,0% |
| Morretes 2q | Morretes | 2 | 43 | R$ 464 | R$ 399 | **adequada** | 1.243 | R$ 750.000 | 12,42% | 10,68% | 31,0% |
| Meia Praia 1q | Meia Praia | 1 | 17 | R$ 490 | R$ 471 | pequena | 62 | R$ 880.000 | 11,18% | 10,74% | 34,4% |
| Centro 2q | Centro | 2 | 61 | R$ 583 | R$ 500 | **adequada** | 92 | R$ 1.140.000 | 10,27% | 8,80% | 37,5% |
| Centro 1q | Centro | 1 | 76 | R$ 450 | R$ 427 | **adequada** | 25 | R$ 890.000 | 10,15% | 9,63% | 37,9% |
| Meia Praia 2q | Meia Praia | 2 | 156 | R$ 450 | R$ 400 | **adequada** | 243 | R$ 1.080.000 | 8,36% | 7,44% | 46,0% |
| Meia Praia 3q | Meia Praia | 3 | 273 | R$ 697 | R$ 580 | **adequada** | 1.708 | R$ 1.884.860 | 7,42% | 6,18% | 51,9% |
| Centro 3q | Centro | 3 | 39 | R$ 750 | R$ 692 | **adequada** | 442 | R$ 2.100.000 | 7,17% | 6,62% | 53,7% |
| Meia Praia 4q | Meia Praia | 4 | 47 | R$ 900 | R$ 900 | **adequada** | 1.329 | R$ 3.549.790 | 5,09% | 5,09% | 75,6% |

**Classificação de robustez:** insuficiente (<10), pequena (10-29), adequada (>=30)

---

## 2. Verificação dos cálculos

Fórmulas aplicadas:
- `retorno_55 = diaria_mediana × 365 × 0.55 / preco_compra_mediano`
- `retorno_p25_55 = diaria_p25 × 365 × 0.55 / preco_compra_mediano`
- `ocupacao_7 = 0.07 × preco_compra_mediano / (diaria_mediana × 365)`

Todos os valores foram recalculados diretamente das medianas. Resultados consistentes com o CSV original.

---

## 3. Respostas solicitadas

### 1. Maior retorno entre segmentos com amostra adequada

**Morretes 2q: 12,42%** (DM R$ 464, SP R$ 750.000, 43 listings Airbnb, 1.243 VR)

### 2. Maior retorno entre segmentos com amostra pequena

**Meia Praia 1q: 11,18%** (DM R$ 490, SP R$ 880.000, 17 listings Airbnb, 62 VR)

### 3. Melhor segmento por critérios simultâneos

Critérios: retorno 55% alto, desempenho com P25, amostra adequada (>=30), VR >=30, consistência residencial.

**Morretes 2q** atende todos:
- Retorno 55%: 12,42% (maior entre adequadas)
- Retorno P25: 10,68% (ainda acima de 7%)
- Amostra Airbnb: 43 listings (adequada)
- Amostra VR: 1.243 anúncios
- Consistência: todos apartamentos residenciais em bairro majoritariamente residencial

### 4. Diferença entre Morretes 2q, Centro 1q e Centro 2q

| Métrica | Morretes 2q | Centro 1q | Centro 2q |
|---------|-------------|-----------|-----------|
| Retorno 55% | 12,42% | 10,15% | 10,27% |
| Retorno P25 | 10,68% | 9,63% | 8,80% |
| Oc7% | 31,0% | 37,9% | 37,5% |
| Qtd Airbnb | 43 | 76 | 61 |
| Qtd VR | 1.243 | 25 | 92 |
| SP mediana | R$ 750k | R$ 890k | R$ 1.140k |

- **Morretes 2q** tem retorno ~2pp maior que Centro 1q/2q e menor preço de entrada
- **Centro 1q** tem melhor retorno P25 relativo ao DM (perda de apenas 0,5pp)
- **Centro 2q** tem a maior perda com P25 (-1,47pp), indicando maior variabilidade
- **Centro 1q** tem amostra VR menor (25) que os outros (92 e 1.243)

### 5. Cálculos anteriores estavam incorretos?

**Não.** Os cálculos recalculados diretamente das fórmulas são consistentes com o CSV original. As diferenças são de arredondamento decimal (centavos percentuais).

---

## 4. Notas

- Nenhum retorno exige ocupação acima de 100% para atingir 7%
- Meia Praia 4q (75,6%) é o segmento mais desafiador em termos de ocupação
- Todos os segmentos com amostra adequada atingem pelo menos 5% de retorno bruto no cenário de 55%
- O critério de P25 não altera significativamente o ranking dos 3 primeiros

---

## 5. Confirmação: preço Centro 1q

**Valor no CSV:** R$ 890.000 (25 anúncios VR)

**Valor anterior (tabela de bairro x quartos):** R$ 960.000 (agregava 0q + 1q, 28 anúncios)

**Explicação:** O valor de R$ 960.000 era o preço mediano do grupo "0-1 quartos" no VivaReal. Após investigação (seção 7 de `mercado_compra_vivareal.md`), os 0 quartos em Centro são todos comerciais (3 registros), não studios residenciais. Portanto, o grupo de compactos passou a ser exclusivamente 1 quarto (25 registros), com preço mediano de R$ 890.000.

| Métrica | Antes (0-1q) | Depois (1q) |
|---------|-------------|-------------|
| Registros VR | 28 | 25 |
| SP mediana | R$ 960.000 | R$ 890.000 |
| Área mediana | 54 m² | 54 m² |
| Pm² mediana | R$ 20.433 | R$ 19.905 |

A redução de R$ 70.000 (7,3%) reflete a remoção de 3 imóveis comerciais que distorciam o grupo.

---

*Script: `src/valida_retorno.ps1`*
