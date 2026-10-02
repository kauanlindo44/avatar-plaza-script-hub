# Auditoria V42 — Avatar Plaza

Base GitHub: `700189e0f8f3f56b158131245b468ea0addd826a` (V41). Handoff completo lido antes das alterações. Scripts existentes conferidos com a revisão publicada; fontes antigas do Photo Mode e contratos dos jogos foram recuperados dos instaladores anteriores antes da substituição.

A V42 entrega **4 módulos novos e 16 substituições**. As versões antigas continuam no manifesto. Nenhum script ultrapassa 400 linhas ou usa atribuição composta. O instalador entrega `09A_SHOP_UI` somente em **4 partes**, que recompõem o arquivo exato, com hash SHA-256.

## O que mudou

- Prévia do catálogo mais clara, sem a parede que bloqueava as costas; câmera considera largura/profundidade ao girar. Aplicar, Salvar, Restaurar, Carrinho, Configurar corpo e itens com X ficam abaixo da prévia. No celular deitado, esse rodapé pode rolar para preservar espaço do avatar.
- Catálogo/UGC chegam a 5 colunas × 6 linhas em 1920×1080. Meus looks chega a 5 × 4; no celular, a galeria usa a largura inteira e a prévia selecionada abre com X. A grade reduz a quantidade simultânea em telas menores para manter imagens e preços legíveis.
- Aplicar no jogo envia as proporções R15 e preserva cabelo, rosto, roupas, cores, acessórios e alterações recentes do personagem. Escalas exigem um personagem R15; escolher R15 na prévia não substitui automaticamente o rig R6 do personagem em jogo.
- Plus consulta `Player.HasRobloxSubscription` no servidor e abre `PromptRobloxSubscriptionPurchase`, a assinatura oficial Roblox Plus. Não usa game pass, preço inventado nem o evento de tentativa como confirmação de assinatura.
- Jogos ocupam o viewport inteiro, com categorias horizontais no topo. No celular deitado, criar/entrar em sala ficam próximos e visíveis. Regras, tabuleiros, treino e contratos dos servidores antigos continuam.
- Códigos de sala globais usam MemoryStoreHashMap, validade de 10 minutos, renovação de presença do anfitrião e reserva atômica de um convidado. O convidado é teletransportado para o servidor público do anfitrião; os dois jogam no mesmo servidor. A chegada depende dos dados verificados no servidor e do cliente pronto para receber os eventos do tabuleiro. Reserva de viagem: 120 segundos. Falhas liberam a vaga; salas encerradas retornam uma mensagem. Servidores privados/Studio usam códigos locais.
- Photo Mode usa um clone local do avatar, articulações R6/R15 com ângulos editáveis, Confirmar/Cancelar e restauração de pose. A pose confirmada permanece no estúdio. Cinco fundos: Estúdio suave, Céu de algodão, Pôr do sol, Jardim e Noite violeta. Exposição, intensidade, hora, contraste, saturação e perfis de luz são ajustáveis. Captura sem interface, câmera 360° e restauração da iluminação/câmera/HUD ao sair.
- O ambiente principal ficou um pouco mais claro, mantendo o mapa existente.

## Instalação

Requer V41 instalada, `07UI_DESIGN_SYSTEM`, `08B_AVATAR_DATA`/`08D_SKIN_STATE` V41, regras `07A0_CHESS_RULES`/`07B0_CHECKERS_RULES` e `07P1_CAPTURE_ENGINE` existente. Pare Play antes de alterar os scripts. Instale os 20 itens do instalador; os quatro módulos a criar são:

| Módulo novo | Local |
|---|---|
| 07UI_SCREEN_BOUNDS | ReplicatedStorage |
| 07P3_POSE_EDITOR | ReplicatedStorage |
| 07P4_STUDIO_UI | ReplicatedStorage |
| 07H3_CROSS_SERVER_ROOMS | ServerScriptService |

Os outros 16 são substituições de instâncias existentes, nos locais indicados no instalador. Não duplique módulos. Apague o código antigo do `09A_SHOP_UI` uma única vez e cole as quatro partes, em ordem, no mesmo ModuleScript. Inicie um Play novo depois de instalar todos os itens.

## Verificação executada

- `python audits/V42/test_revision.py`: 12 casos, incluindo sintaxe/limites dos 20 scripts, sete tamanhos de tela, barra nativa dinâmica, campos da UI, aplicação incremental real de 08B/08D/09B/09C, pacotes, histórico, corpo, HUD, carrinho e assinatura Plus.
- `python audits/V42/test_features.py`: 10 casos de escalas aplicadas, galerias, UGC, geometria dos jogos, poses, fundos/ambiente/câmera, Photo Mode, captura com erro/timeout/callback antigo, reserva global, chegada e expiração.
- `python audits/V42/test_games.py`: 7 casos com os controladores V42 e regras existentes. Inclui criação/join/cancel, bot de xadrez/batata, tabuleiro/relógios/HUD, servidor 01C real com serviços simulados, dois jogadores sentados, chegada de viagem, anfitrião saindo durante reserva/matching e duas partidas simultâneas em mesas distintas.
- `node audits/V42/test_installer_logic.cjs`: JavaScript real do HTML com DOM mínimo, pacote offline V42, 20 hashes, cache antigo, remontagem de todas as partes, 4 criações/16 substituições, cópia/seleção e fallback de fonte adulterada.
- `python audits/V42/inspect_layouts.py`: revisão aproximada das instâncias reais em 1920×1080, 844×390 com recortes e 360×640. Catálogo, corpo, carrinho, looks, jogos, tabuleiro e editor de pose. Fontes e viewports são substitutos de inspeção; imagens geradas localmente ficam em `layout_previews`.

Total: **29 casos funcionais/sintaxe**, além dos checks do instalador e da inspeção de layouts. Os testes usam Lua 5.4 (`liblua5.4`), Python e serviços simulados; a inspeção usa Pillow. **Não houve execução no Studio Lite/Roblox, renderização 3D real, teleporte de rede nem compra/captura nativa.**

## Conferência no Roblox

Confira em celular e computador: roupa nova sem apagar o resto do outfit; X individual; corpo R15 aplicado; skins claras/escuras visíveis em todos os ângulos; thumbnails e cards; Carrinho/Plus isolados; vinte looks e prévia com X; seleção de articulação, giro, pose confirmada e cancelada; cinco fundos e controles do ambiente; sair do Photo Mode restaurando HUD/câmera; captura e galeria nativas. Para amigos, use dois servidores públicos do jogo publicado: crie o código, entre no outro servidor, viaje, comece a partida e confira saída/falha/servidor cheio. TeleportService não funciona no playtest do Studio.

Referências oficiais consultadas: [Roblox Plus](https://create.roblox.com/docs/production/monetization/roblox-plus), [MemoryStoreHashMap](https://create.roblox.com/docs/cloud-services/memory-stores/hash-map), [Teleport](https://create.roblox.com/docs/projects/teleport), [Player.GetJoinData](https://create.roblox.com/docs/reference/engine/classes/Player), [Motor6D](https://create.roblox.com/docs/reference/engine/classes/Motor6D), [RunService.PreSimulation](https://create.roblox.com/docs/reference/engine/classes/RunService), [CaptureService](https://create.roblox.com/docs/reference/engine/classes/CaptureService), [GuiService.TopbarInset](https://create.roblox.com/docs/reference/engine/classes/GuiService).
