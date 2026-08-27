**Transcrição do vídeo de apresentação**

*Abertura*

Olá, eu sou o Lucas. Neste desafio, analisei dados do Airbnb e do VivaReal para recomendar qual perfil de imóvel a Seazone deveria adquirir em Itapema para locação de curta duração.

*Caminho da análise*

Primeiro, auditei as cinco bases e consolidei informações de localização, características, diárias anunciadas e preços de venda.
Como nem todos os anúncios tinham dados de preço suficientes, apliquei filtros de qualidade, controlei valores extremos e comparei apenas grupos com amostras minimamente confiáveis.

*Descoberta importante*

Um ponto importante foi a classificação dos imóveis de zero quarto. Inicialmente, esses registros poderiam ser interpretados como studios. Porém, ao investigar títulos, áreas e tipologias, identifiquei que eram principalmente terrenos e imóveis comerciais. Por isso, não misturei esses registros com apartamentos residenciais de um quarto.

*Recomendação*

Depois, comparei a diária anunciada de cada perfil com o preço mediano de aquisição.
A minha recomendação é um apartamento residencial de dois quartos em Morretes, com preço anunciado próximo de 750 mil reais. Esse perfil apresentou o melhor equilíbrio entre retorno bruto estimado, preço de entrada e qualidade das amostras.
No cenário-base, o retorno bruto simplificado foi de 12,42%, permanecendo competitivo em uma análise mais conservadora.

*Tese da Seazone*

A Seazone apresentou a hipótese de que studios ou apartamentos de um quarto no Centro seriam a opção mais eficiente. Os dados sustentaram essa tese parcialmente.
Apartamentos de um quarto no Centro apresentaram boa eficiência por hóspede e retorno competitivo. Porém, tinham preço de aquisição maior e retorno estimado inferior ao de Morretes com dois quartos. Além disso, a parte da hipótese referente a studios não pôde ser confirmada com segurança na base de compra.

*Uso da IA*

Usei o OpenCode para explorar os dados, criar scripts em PowerShell, cruzar as bases e revisar os resultados. Mas não aceitei as respostas automaticamente. Investiguei anomalias, corrigi classificações e descartei segmentos com retornos maiores quando as amostras eram insuficientes.

*Encerramento*

Com mais tempo, eu adicionaria dados realizados de ocupação, reservas, custos operacionais e sazonalidade anual.
Com os dados disponíveis, Morretes com dois quartos foi a alternativa mais equilibrada. Obrigado.
