# Pesquisa V48 — 04/10/2026

## Monetização e Brasil

Três fontes oficiais distintas da Roblox foram verificadas nesta versão, além da lei brasileira:

1. [Paid random items](https://create.roblox.com/docs/production/monetization/paid-random-items): itens aleatórios pagos exigem revelar resultados e probabilidades numéricas reais antes do gasto e respeitar restrições por jogador com PolicyService. As probabilidades devem corresponder à distribuição efetiva. Não basta inventar chances na interface.
2. [PolicyService](https://create.roblox.com/docs/reference/engine/classes/PolicyService): `GetPolicyInfoForPlayerAsync` informa restrições aplicáveis, incluindo `ArePaidRandomItemsRestricted`. Essas restrições devem controlar o acesso, sem inferir data de nascimento pela idade da conta.
3. [Brazil Digital ECA Updates](https://en.help.roblox.com/hc/en-us/articles/48706630819476-Brazil-Digital-ECA-Updates): a orientação oficial informa restrições de itens aleatórios pagos no Brasil para menores de 18 e uso das verificações de idade/restrições nativas da plataforma. Também trata declarações exigidas do criador. Não é correto afirmar que Roblox não dispõe desses mecanismos.

A [Lei 15.211/2025, texto consolidado oficial](https://www.planalto.gov.br/ccivil_03/_ato2023-2026/2025/lei/l15211.htm), art. 20, proíbe loot boxes em jogos eletrônicos direcionados ou de acesso provável por crianças e adolescentes. O art. 41-A informa vigência em 17/03/2026. O fato de Roblox ter restrições por idade não foi tratado como dispensa automática dessa obrigação para este projeto.

**Decisão do projeto:** manter desativado todo sorteio pago e oferecer um visual conhecido que o jogador escolhe antes de pagar. Cada opção exibe `100% ao escolher`; não são três probabilidades de um sorteio. Compra do produto concede uma caixa recuperável pelo servidor e a UI abre a escolha assim que o crédito é confirmado. O pacote continua tendo embalagem e inventário, mas não resultado aleatório. As moedas são ganhas em partidas PvP validadas, sem venda de moeda. Nenhum mecanismo de coleta própria de idade/documento foi incluído. Isso é uma decisão técnica conservadora para este jogo acessível a menores, não uma certificação jurídica abrangente.

## APIs e correções

- [MarketplaceService.ProcessReceipt](https://create.roblox.com/docs/reference/engine/classes/MarketplaceService#ProcessReceipt) e [Developer Products](https://create.roblox.com/docs/production/monetization/developer-products): concessão deve ocorrer pelo recibo no servidor; fechamento/sucesso do prompt não prova concessão. V48 conserva o ProcessReceipt existente e apenas observa cancelamento do próprio jogador no cliente.
- [Players.GetHumanoidDescriptionFromOutfitIdAsync](https://create.roblox.com/docs/reference/engine/classes/Players#GetHumanoidDescriptionFromOutfitIdAsync) e [Atualização manual de cabeças](https://create.roblox.com/docs/avatar/heads/manually-updating-catalog-heads): pacotes podem conter item UserOutfit cuja descrição nativa carrega proporções/cores além das peças. A V48 incorpora esses campos sem substituir roupas e acessórios não editados.
- [CatalogSearchParams](https://create.roblox.com/docs/reference/engine/datatypes/CatalogSearchParams) e [SalesTypeFilter](https://create.roblox.com/docs/reference/engine/enums/SalesTypeFilter): Collectibles filtra a busca nativa. A vitrine Limiteds também verifica a indicação no próprio resultado, descartando itens comuns.
- [ImageLabel](https://create.roblox.com/docs/reference/engine/classes/ImageLabel), [ContentProvider](https://create.roblox.com/docs/reference/engine/classes/ContentProvider) e [AssetService.LoadAssetAsync](https://create.roblox.com/docs/reference/engine/classes/AssetService#LoadAssetAsync): IsLoaded/preload não dão diagnóstico conclusivo da causa de uma falha. A mensagem do Ateliê identifica estados observados e apresenta permissão, moderação ou conexão somente como possibilidades. Não se ativa importação de terceiros e não se insere o modelo carregado.

## Referência visual

Foram feitas buscas públicas atuais por Photo Mode, poses e fundos do Catalog Avatar Creator, com mecanismos de busca e busca de imagens. [Página oficial do jogo](https://www.roblox.com/games/7041939546/Catalog-Avatar-Creator) identifica o produto de referência. Resultados genéricos, miniaturas sem contexto e páginas de terceiros não foram tratados como comprovação de um fundo específico.

O vídeo público do editor de pose já usado no projeto oferece referência para manipulação do personagem e confirmar/restaurar, mas não documenta cinco ambientes atuais. Não foram encontradas cinco fotografias verificáveis para cada um de cinco fundos (25 imagens). V48 entrega **cinco cenários originais**, com conceitos de galeria, ilhas, costa, jardim e cidade, mais detalhes e controle local de luz, mantendo uma limitação explícita: não é uma cópia verificada dos ambientes do CAC.

Não foram identificadas novas imagens anexadas disponíveis nesta solicitação. Paths históricos ausentes não foram tratados como fotos inspecionadas. Também não há screenshot nativo da V48. Qualidade de renderização e usabilidade no aparelho ainda dependem de teste dentro do Roblox.

