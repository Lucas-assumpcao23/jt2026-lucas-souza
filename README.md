**Vídeo da apresentação:** (https://drive.google.com/file/d/1NT7ZNO6k04ZJqmyl7ymM6uErOSNeT6Ri/view?usp=sharing)

# Hackathon Jovens Talentos AI Builder 2026 — Seazone

## Recomendação de Investimento em Imóveis para Temporada em Itapema (SC)

---

## Resumo executivo

Análise combinada de dados de hospedagem (Airbnb) e mercado de compra (VivaReal) para estimar o retorno bruto simplificado de apartamentos residenciais em Itapema, SC.

**Recomendação:** Apartamento de 2 quartos em Morretes.

| Métrica | Valor |
|---------|-------|
| Preço mediano de aquisição | R$ 750.000 |
| Área útil mediana | 69 m² |
| Retorno bruto (55% ocupação) | 12,42% |
| Retorno com P25 (55%) | 10,68% |
| Ocupação para retorno de 7% | 31,0% |

---

## Recomendação final

**Apartamento residencial de 2 quartos em Morretes.**

Justificativa:
- Maior retorno bruto entre segmentos com amostra adequada;
- Menor preço de entrada entre os três primeiros do ranking;
- Amostra robusta em ambas as bases (43 Airbnb, 1.243 VivaReal);
- Boa resistência com diária P25;
- Morretes 2q exige 31,0% de ocupação para retorno de 7%, contra 37,9% de Centro 1q, mas a viabilidade prática não pode ser confirmada sem dados de ocupação realizada.

---

## Posição sobre a tese dos compactos no Centro

A tese preliminar — de que compactos no Centro seriam a aposta mais eficiente — é **parcialmente sustentada**.

**Sustentado:** Apartamentos de 1 quarto no Centro apresentam boa eficiência por hóspede (R$ 143), retorno competitivo (10,15%) e boa resistência com P25.

**Não sustentado:** Centro 1q não lidera em retorno bruto, possui preço R$ 140.000 superior a Morretes 2q, e exige ocupação 6,9pp maior para atingir 7%. Nenhum studio residencial pôde ser validado no VivaReal.

---

## Principais números

| Segmento | Ret55% | RetP25 | Oc7% | SP mediana |
|----------|--------|--------|------|-----------|
| Morretes 2q | 12,42% | 10,68% | 31,0% | R$ 750.000 |
| Centro 1q | 10,15% | 9,63% | 37,9% | R$ 890.000 |
| Centro 2q | 10,27% | 8,80% | 37,5% | R$ 1.140.000 |
| Meia Praia 1q | 11,18% | 10,74% | 34,4% | R$ 880.000 |

---

## Metodologia

1. Consolidação de dados Airbnb (4 arquivos) em base unificada de 999 listings
2. Deduplicação e padronização do VivaReal (8.293 registros)
3. Classificação e validação de imóveis residenciais vs comerciais/terrenos
4. Análise por bairro e número de quartos
5. Estimativa de retorno bruto simplificado em 3 cenários de ocupação (40%, 55%, 70%)
6. Cálculo de ocupação necessária para retorno de 7%
7. Análise de sensibilidade com diária P25

**Filtros:** Listings com >=30 datas de estadia e diária entre R$ 150 e R$ 2.500.

**Cobertura:** Base de preços Airbnb cobre 22,5% dos listings (viés moderado). Dados de janeiro a abril de 2025.

---

## Estrutura do repositório

```
├── data/                          # Dados originais (nunca alterados)
│   ├── Details_Itapema.csv
│   ├── Hosts_ids_Itapema.csv
│   ├── Mesh_Ids_Data_Itapema.csv
│   ├── Price_AV_Itapema.csv
│   └── VivaReal_Itapema.csv
├── analysis/                      # Relatórios de análise
│   ├── auditoria_dados.md
│   ├── base_airbnb_consolidada.md
│   ├── comparacao_investimento.md
│   ├── mercado_compra_vivareal.md
│   ├── perfil_localizacao_airbnb.md
│   ├── qualidade_diaria.md
│   ├── representatividade_price_av.md
│   └── validacao_retorno.md
├── outputs/                       # Saídas intermediárias
│   ├── base_airbnb_consolidada.csv
│   ├── comparacao_investimento.csv
│   ├── vivareal_base_tratada.csv
│   ├── vivareal_grupos_compra.csv
│   └── airbnb_grupos_comparaveis.csv
├── src/                           # Scripts de análise (PowerShell)
│   ├── base_consolidada.ps1
│   ├── analise_mercado_compra.ps1
│   ├── analise_perfil_localizacao.ps1
│   ├── comparacao_investimento.ps1
│   ├── investiga_0q_centro_mp.ps1
│   ├── investiga_morretes_01q.ps1
│   └── valida_retorno.ps1
├── ai-log/                        # Logs de conversas com IA
├── relatorio.md                   # Relatório completo
└── README.md                      # Este arquivo
```

---

## Como reproduzir a análise

PowerShell 5.1 ou superior.

```powershell
powershell -ExecutionPolicy Bypass -File src/base_consolidada.ps1
powershell -ExecutionPolicy Bypass -File src/analise_perfil_localizacao.ps1
powershell -ExecutionPolicy Bypass -File src/analise_mercado_compra.ps1
powershell -ExecutionPolicy Bypass -File src/investiga_morretes_01q.ps1
powershell -ExecutionPolicy Bypass -File src/investiga_0q_centro_mp.ps1
powershell -ExecutionPolicy Bypass -File src/comparacao_investimento.ps1
powershell -ExecutionPolicy Bypass -File src/valida_retorno.ps1
```

---

## Limitações

- Diária anunciada não é receita realizada
- Preço de venda anunciado não é preço negociado
- Retorno bruto simplificado não é ROI líquido
- Ocupação é premissa de cenário, não dado da base
- Base de preços cobre 22,5% dos listings (viés moderado)
- Dados de janeiro a abril de 2025 (não captura sazonalidade completa)
- Não inclui custos operacionais, impostos ou depreciação
- Não inclui valorização do imóvel

---

## Relatório completo

O relatório completo está em [`relatorio.md`](relatorio.md).

---

## Sobre a pasta ai-log/

A pasta `ai-log/` contém os logs das conversas realizadas com ferramentas de IA durante o desenvolvimento da análise. Esses registros documentam o processo de investigação, tratamento de dados e tomada de decisão.

---

*Seazone — Jovens Talentos AI Builder 2026*
