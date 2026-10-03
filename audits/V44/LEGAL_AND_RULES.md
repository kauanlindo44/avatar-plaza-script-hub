# V44 — decisões de monetização e regras

Pesquisa consultada em 3 de outubro de 2026, nas fontes oficiais abaixo. O criador pediu análise das regras brasileiras e da Roblox antes dos scripts. A decisão do projeto é manter toda aleatoriedade paga desativada e oferecer benefícios conhecidos, garantidos e puramente visuais. Não é um parecer jurídico sobre todas as obrigações da experiência.

## Brasil

- [Lei 15.211/2025 — ECA Digital](https://www.planalto.gov.br/ccivil_03/_ato2023-2026/2025/lei/l15211.htm): arts. 1 e 2, definição de caixa de recompensa e alcance a serviços de acesso provável por menores; art. 7, privacidade protetiva por padrão; art. 20, vedação de caixas de recompensa nesses jogos. Não se adotou a ideia de liberar sorteio com base em uma idade declarada pelo jogador.
- [Decreto 12.880/2026](https://www.planalto.gov.br/ccivil_03/_ato2023-2026/2026/decreto/d12880.htm): art. 23 trata da restrição das caixas e da aferição etária. O §1 admite ausência de caixas ou acesso integralmente restrito por padrão para dispensar essa aferição nesse caso; art. 24 exige reduzir os dados usados para aferição. A implementação não pede documentos ou data de nascimento.

O fluxo adotado não tem prêmio aleatório: todas as três opções de cada coleção são apresentadas e cada caixa concede exatamente um visual escolhido pelo jogador, sem duplicatas consumidas. Abrir várias caixas exige escolhas distintas conhecidas; a animação mostra os resultados já escolhidos e pode ser pulada. Uma compra direta concede o visual exato. Não se comercializam moedas e nenhuma partida coloca moedas, Robux, itens ou valores em disputa.

Essa decisão reduz a questão específica de lootboxes. Classificação indicativa, informação ao consumidor, moderação, privacidade, direitos sobre imagens e configurações da experiência continuam sendo responsabilidades de publicação e operação do criador na plataforma.

## Roblox — três documentos distintos conferidos

1. [Paid random items](https://create.roblox.com/docs/production/monetization/paid-random-items): probabilidades e restrições de itens pagos aleatórios. A V44 não usa esse modelo, mesmo quando a consulta de política não indica restrição. Nunca apresenta probabilidades inventadas.
2. [Passes](https://create.roblox.com/docs/production/monetization/passes): benefícios permanentes. Os três IDs informados são usados como passes, com preço atual consultado por `MarketplaceService` e posse conferida no servidor.
3. [Developer products](https://create.roblox.com/docs/production/monetization/developer-products): compras repetíveis e entrega por `ProcessReceipt`. Caixas usam produtos próprios, com entrega persistente e idempotente; IDs ausentes desativam o botão, sem reaproveitar IDs de passe.

Também foram conferidos [PolicyService](https://create.roblox.com/docs/reference/engine/classes/PolicyService), [Player.AccountAge](https://create.roblox.com/docs/reference/engine/classes/Player/AccountAge) e [MarketplaceService](https://create.roblox.com/docs/reference/engine/classes/MarketplaceService). `ArePaidRandomItemsRestricted=false` não é tratado como certificado de 18 anos. `AccountAge` mede dias desde o cadastro, não a idade da pessoa. Falha de consulta nunca habilita sorteios.

O cliente consulta os preços nativos regionais/personalizados, conforme [Regional pricing](https://create.roblox.com/docs/production/monetization/regional-pricing). O servidor verifica disponibilidade para o prompt e entrega passes somente após conferir posse. Produtos usam um único registro de `ProcessReceipt`, preservando `PurchaseId` para impedir entrega repetida. Os dez IDs foram conferidos nas imagens fornecidas pelo criador; o produto Éter desativado não entra no registro. Compras sem configuração ou disponibilidade confirmada ficam bloqueadas. Produtos com limite de escolhas por coleção são destinados à loja dentro do jogo; não se recomenda habilitar venda externa desses produtos. Esses caminhos foram simulados; transações reais ainda precisam de QA.

## Truco

| Perfil implementado | Fonte | Principais diferenças |
|---|---|---|
| Paulista | [CAASP/ATB, regulamento 2026](https://www.caasp.org.br/siteold/JAP/doc/Regulamentos/Truco/Regulamento.pdf) | Vira, manilhas móveis, pontos 1/3/6/9/12, mão de 11, empates e distribuição em grupos de três. |
| Mineiro | [Copag — Truco Mineiro](https://wap.copag.com.br/regras/truco-mineiro) | Manilhas fixas, pontos 2/4/6/10/12, mão de 10 e mão de ferro. |
| Goiano | [APCEF-GO, Truco em dupla](https://apcefgo.org.br/portal/data/files/FD/36/1F/38/D118781066A79778403A91A8/Regulamento%20Tecnico%20do%20Truco%20Dupla.pdf) | Vira/manilhas móveis, 1/3/6/9/12, tratamento específico de empate na segunda vaza, distribuição em até 10 segundos e decisão normal de até 30 segundos. |

São três perfis definidos, não uma promessa de cobrir toda variante regional ou todo regulamento de torneio presencial. O digital exige adaptações de interface, corte, tempo, transporte entre servidores e ausência de fiscal humano. O servidor controla todas as cartas e só envia cada mão ao próprio jogador; cartas cobertas não expõem sua identidade no payload público.

No casual manual de Paulista/Goiano, retirar do topo ou fundo é legal quando a origem permanece a mesma. Meio ou troca de origem registram irregularidade. Uma denúncia exige evidência registrada no servidor e tem janela limitada antes da primeira carta jogada. A penalidade é perda da partida da dupla infratora, conforme o perfil adotado, sem inventar a regra de +1/−3 sugerida na conversa. Partidas com irregularidade não dão moedas nem classificação. Torneios usam distribuição automática.

Os gritos são quatro frases respeitosas de texto, com intervalo entre usos. Não se copiaram arquivos de áudio, música, personagens gráficos, logos ou arte de outro jogo de Truco. Baralhos são desenhos geométricos originais; a identificação das cartas continua legível. Isso não garante ausência de qualquer disputa de direitos. Imagens do Ateliê devem ser publicadas pelo jogador na Roblox com os direitos necessários; o servidor confere que o ID é de imagem/decal, e a plataforma controla acesso e moderação do ativo.

## Referências de personagens

As seis identidades iniciais têm referências oficiais: [Naruto Uzumaki](https://naruto-official.com/en/news/01_1610), [Son Goku](https://en.dragon-ball-official.com/news/01_23.html), [Monkey D. Luffy](https://one-piece.com/character/luffy/index.html), [Satoru Gojo](https://jujutsukaisen.jp/character/index_1st.php), [Peter Parker/Spider-Man](https://www.marvel.com/characters/spider-man-peter-parker) e [Tony Stark/Iron Man](https://www.marvel.com/characters/iron-man-tony-stark).

Os scripts pesquisam itens disponíveis no catálogo Roblox durante a execução. Nomes de camisa e calça precisam concordar com a referência; preços e autores dos itens vêm dos metadados reais. `@CAETANOYX` identifica quem publica a composição do projeto, e não substitui o crédito dos criadores dos itens. O rig é indicado separadamente. Não se fazem buscas externas na web a cada clique nem se promete identificar visualmente qualquer skin. Até cinco combinações usam IDs diferentes; uma revisão visual humana ainda pode detectar peças diferentes com aparência parecida.
