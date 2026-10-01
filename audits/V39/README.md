# Avatar Plaza V39

Continuação da V38.1, commit-base `0739b53bddcda7af541c641f7f4931365dfd2221`. O handoff completo e as cinco imagens foram lidos antes das alterações. O erro `invalid order function for sorting` mostrado no Output foi reproduzido em teste.

## Alterações entregues

| Script | Resultado |
|---|---|
| 07G_HUB_UI | Texto legível, alvos maiores, menu compacto automático, ajustes com foco e integração de música mantida. |
| 07H_GAME_UI | Pontuação aleatória calculada antes de ordenar, desempate estável, tarefas do bot vinculadas à partida, bloqueio de duplo toque na Batata, menu e tabuleiro adaptados ao espaço disponível. |
| 09A_SHOP_UI | Editor com áreas sem sobreposição, botão de busca, prévia acessível em tela estreita, controles de corpo e emotes com rolagem, ações de looks adaptadas à largura e carrinho organizado. |
| 09B_SHOP_SERVER | Filtragem de nome fora da transformação do DataStore; validação do limite e dos itens enviados para compra. |
| 09C_SHOP_CLIENT | Prévias de emotes R15 com controle de parada, preservação do preset durante inicialização, retomada da prévia após fechamento, buscas de avatar canceladas quando obsoletas, câmera sem reconstruir o modelo a cada giro/zoom. |
| 09C1_SHOP_LOOKS | Prévias de cards carregadas conforme visibilidade, grades ajustáveis, giro/zoom sem reconstrução e avisos corretos quando o salvamento é somente da sessão. |
| 09C2_SHOP_CATALOG | Busca respeita a categoria selecionada, resultados seguem a ordem da API, emotes usam todas as páginas, duplicatas removidas e respostas antigas descartadas. Descoberta mostra pagos; preço máximo zero e a categoria GRÁTIS continuam disponíveis. |
| 09C4_OUTFIT_LIBRARY | Carrinho sem duplicatas, subtotal explícito quando falta preço, seleção de até 20 itens e controles de corpo integrados ao histórico. |
| 09C5_UGC_STORES | Consulta real por criador ou grupo, carregamento sob demanda, paginação e cancelamento de respostas antigas. |

O mapa e os servidores de jogos seguem a base V38.1. Os contratos de `PracaKit`, `PracaAvatar_V2`, `OpenRequest`, `HudAction`, `AvatarShopLauncherGui` e `TopMusic` permanecem compatíveis. Os campos exportados pelo 09A anterior foram conferidos. Os módulos existentes 08B/08D, música, comunidade e regras continuam necessários.

## Instalação sobre a V38.1

Abra `AVATAR_PLAZA_SCRIPT_HUB_PERMANENTE.html` e escolha **V39**. Pare o teste antes da substituição.

| Tipo e local | Scripts a substituir |
|---|---|
| LocalScript — StarterPlayer > StarterPlayerScripts | 07G_HUB_UI, 07H_GAME_UI, 09C_SHOP_CLIENT |
| Script — ServerScriptService | 09B_SHOP_SERVER |
| ModuleScript — ReplicatedStorage | 09A_SHOP_UI, 09C1_SHOP_LOOKS, 09C2_SHOP_CATALOG, 09C4_OUTFIT_LIBRARY, 09C5_UGC_STORES |

Mantenha os nomes existentes. No **09A_SHOP_UI**, apague o código antigo uma vez e cole as **quatro partes em ordem no mesmo ModuleScript**. Os botões preservam as quebras de linha. O código inteiro desse módulo não aparece na interface do instalador. Após substituir os nove scripts, inicie um novo teste.

O manifesto conserva o histórico e aponta para V39. O instalador inclui os nove arquivos V39 para uso offline, evita retornar a um cache V36A antigo, confere SHA-256 quando o navegador fornece Web Crypto e permite seleção manual de cada parte.

## Validação realizada

- Nove scripts analisados com o parser Lua 5.4, todos com até 400 linhas e sem operadores de atribuição composta. Isso não substitui o compilador/runtime Luau do Roblox.
- Nove casos de regressão com serviços e GUI simulados, incluindo integração adicional com o 08B extraído do handoff anterior.
- Ordenação antiga falhou em 1.000 tentativas do cenário de reprodução; V39 passou em 5.000 ordenações. As regras reais de xadrez e damas produziram 1.000 movimentos legais em três dificuldades.
- Limites geométricos do editor verificados em cinco tamanhos de tela; menu compacto e ajustes conferidos em três tamanhos. O teste calcula posições/tamanhos, sem simular tipografia ou renderização Roblox.
- Catálogo verificado com categoria + palavra-chave, preço máximo zero, 24 emotes na primeira página e mais itens na seguinte, deduplicação, respostas fora de ordem e preços inválidos.
- Carrinho verificado com preço desconhecido, repetição de item, compra de 20 itens e rejeição de 21. Servidor conferido com repetição da transformação do DataStore sem filtragem dentro dela.
- JavaScript real do instalador executado em Node.js com DOM mínimo: nove hashes, reconstrução exata das partes, quatro partes exclusivas do 09A, cópia/seleção, cache antigo, arquivo remoto divergente e fechamento durante carregamento.

Os resultados estão em `results.json` e `installer_logic_results.json`. O teste Playwright está disponível em `test_installer.cjs`, mas não foi executado até o fim: este ambiente não tem Chromium instalado. Não houve teste visual em navegador nem execução no Roblox Studio/Studio Lite.

Para reproduzir a validação lógica:

```sh
python audits/V39/test_regressions.py
node audits/V39/test_installer_logic.cjs
```

Para executar a verificação adicional do instalador em um ambiente com Playwright e Chromium:

```sh
node audits/V39/test_installer.cjs
```

## Conferência no Studio Lite/Roblox

1. Abrir Catálogo, Looks, Comunidade, Lojas, Música e ajustes em celular na vertical e horizontal. Conferir legibilidade e inset dos controles do Roblox.
2. Buscar uma palavra dentro de ROUPAS, avançar páginas e abrir EMOTES. Experimentar e parar um emote R15; conferir a escolha explícita de R15 a partir de R6.
3. Girar/zoomar a prévia, mudar o corpo, desfazer, aplicar e salvar. Sair e entrar novamente para confirmar persistência com os serviços habilitados.
4. Adicionar itens repetidos, um item sem preço e mais de 20 selecionados. Conferir o prompt oficial e os preços finais; a mensagem confirma abertura da compra, não sua conclusão.
5. Jogar xadrez, damas e Batata contra o bot, sair e iniciar outra partida. Conferir cancelamento da fila e a partida online em dois jogadores.

Animações, serviços de catálogo, filtro de texto, DataStore e compras dependem do runtime e das permissões do Roblox; permanecem pendentes dessa conferência.

## Próximas melhorias recomendadas

Após esse playtest, priorizar ajustes de tipografia em aparelhos reais, navegação por controle e uma galeria de looks em largura total no celular. Para produto, os próximos recursos com maior utilidade seriam comparação antes/depois do look e favoritos privados de itens. Essas novas funções precisam de regras de dados e UX próprias; não estão implementadas na V39.
