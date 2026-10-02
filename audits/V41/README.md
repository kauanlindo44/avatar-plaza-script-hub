# Auditoria V41 — Avatar Plaza

Base consultada no GitHub: `8ef0db2ed689d25b5c8c123b33b3cf73fcdd4a5c` (V40.1). O handoff completo foi lido antes das alterações. As fontes existentes foram conferidas contra essa base; 08B_AVATAR_DATA foi recuperado do handoff, pois ainda não existia como arquivo publicado no repositório.

O pacote contém nove substituições e um módulo novo: **09A1_SHOP_LAYOUT**, em ReplicatedStorage. O instalador apresenta 09A_SHOP_UI exclusivamente em quatro partes que recompõem o arquivo exato. Todos os scripts têm até 400 linhas e não usam operadores de atribuição compostos.

## Validação executada

- `python audits/V41/test_revision.py`: 12 casos, incluindo sintaxe, campos usados por todos os controladores, sete tamanhos de tela, recortes, barra nativa dinâmica, prévia sempre visível, corpo com X sem cobrir a prévia, ícones sem tooltips, aplicação incremental, pacotes, restauração, histórico, escalas, carrinho e Plus.
- `python audits/V41/test_theme_compatibility.py`: 11 casos de compatibilidade do novo design system com a UI V40 e os jogos existentes: salas, falhas de comunicação, bot, tabuleiros, partida de Batata, camadas de fundo e fechamento.
- `node audits/V41/test_installer_logic.cjs`: JavaScript real do instalador, com DOM mínimo: pacote offline, dez hashes, rejeição de cache antigo, remontagem das partes, quatro partes sem código inteiro no 09A, cópia/seleção, fallback de fonte adulterada e fechamento durante carregamento.
- Revisão visual aproximada com as dimensões das instâncias geradas: desktop 1920×1080, celular 844×390 com recortes e 360×640. Catálogo, corpo e carrinho sem textos cortados no renderizador de inspeção; fontes e imagens desse renderizador não substituem as do Roblox.

O teste de aplicação usa as fontes reais de 08B, 08D, 09B e 09C. Ele troca uma camisa preservando calça, rosto, corpo, cores, acessórios rígidos/3D, emotes, propriedades fora do esquema antigo e mudanças feitas no personagem depois de abrir o editor. O X remove somente o item escolhido. Um outfit completo carregado, Limpar ou Restaurar continuam operações explícitas de substituição. Pacotes passam a adicionar somente suas peças, sem carregar o outfit completo que vinha junto; se uma peça não puder ser lida, a prévia não é alterada parcialmente.

## Limites e conferência no Studio Lite

Os testes usam Lua 5.4, serviços simulados e DOM simulado. **Não foi executado Roblox Studio, Studio Lite nem renderização 3D real.** É necessário conferir a leitura de skins brancas/pretas, thumbnails, emotes, resposta dos serviços Roblox e toques no aparelho.

Pare Play, instale os dez scripts e inicie um teste novo para recarregar os módulos. Confira: Catálogo e Lojas mais altos; nenhuma etiqueta ao tocar/selecionar ícones; prévia visível no celular; Aplicar/SALVAR/RESTAURAR/CARRINHO; Configurar corpo e X; itens equipados com X; Carrinho e Plus sem catálogo por trás; roupa nova sem perder o cabelo/rosto/restante do outfit. A grade adapta a quantidade à tela e chega a 5×6 em 1920×1080, mantendo células de pelo menos 132 pixels nos tamanhos auditados.

A compra Plus usa o passe real configurado em `PracaKit.PlusGamePassId`, dados/descrição/preço e propriedade consultados no Roblox. Com ID 0, informa indisponibilidade. Nenhum benefício pago foi inventado.

Referências primárias: [GuiService.TopbarInset](https://create.roblox.com/docs/reference/engine/classes/GuiService), [Humanoid.GetAppliedDescription e ApplyDescriptionResetAsync](https://create.roblox.com/docs/reference/engine/classes/Humanoid), [HumanoidDescription](https://create.roblox.com/docs/reference/engine/classes/HumanoidDescription), [AssetService.GetBundleDetailsAsync](https://create.roblox.com/docs/reference/engine/classes/AssetService).
