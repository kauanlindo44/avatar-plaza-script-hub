# Validação V56

Base remota V55: dce69725a36e62a8ca371bd9824aa6308c4287cf, árvore 70d2a37ceffce879d0bc12504aa3b8f57bd6a988. Históricos preservados. Delta: 28 substituições + 4 novos, 97 fontes efetivas. Nenhuma alteração nos IDs, ProcessReceipt ou regras.

54 cenários executados com Lua 5.4 e serviços simulados; não representam execução/renderização no motor Roblox. O JavaScript real do HTML foi executado em Node com DOM mínimo, sem teste de CSS.

Cobertura: erro nativo por ID/etapa/código, rollback e ferramentas, conteúdo cliente/servidor, cópia do personagem, seis cenários fixos, fantasma e olhos juntos, emote inválido preservando pose, tema em janelas tardias sem bloquear toque/arte, controlador de música legado, IA real adaptada com saúde e escolhas inline, resultados/X, orçamento e edição de cabelo, preços individuais, recibos, prazo/convites, carrinho, seis tamanhos/cutouts e regras de xadrez/damas/truco.

As prévias de geometria geradas por preview_layouts.py são reconstruções de retângulos e textos dos testes. Não são screenshots Roblox nem prova de malhas/renderização nativa.

Fontes oficiais verificadas nesta tarefa:
- [GuiService e movimento reduzido](https://create.roblox.com/docs/reference/engine/classes/GuiService)
- [TextGenerator](https://create.roblox.com/docs/reference/engine/classes/TextGenerator)
- [ContentProvider](https://create.roblox.com/docs/reference/engine/classes/ContentProvider)
- [StarterPlayer](https://create.roblox.com/docs/reference/engine/classes/StarterPlayer)
- [Roupas em camadas](https://create.roblox.com/docs/art/accessories/layered-accessories)
- [Gato abacaxi](https://www.roblox.com/catalog/72779265740934/Pineapple-Cat-Suit)

Limites reais pendentes: WrapLayers/cages e aparência no mapa, acesso do projeto a TextGenerator, áudio autorizado, DataStores e cobrança. Veja INSTALL_V56.md para roteiro.
