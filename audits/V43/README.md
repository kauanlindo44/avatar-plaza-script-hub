# Auditoria V43 — Avatar Plaza

Base GitHub conferida: `a535c3bad18cfb640ecb9e22471281ca61fbad7e` (V42). O handoff inteiro foi lido antes de alterar os scripts. As duas referências anexadas foram examinadas: catálogo horizontal 768×432 e manequim 2D colorido com aplicar/restaurar.

A V43 entrega **11 módulos novos e 16 substituições**. Os 27 scripts têm de 20 a 355 linhas e não usam atribuições compostas. `09A_SHOP_UI` permanece em **exatamente quatro partes**, no mesmo ModuleScript, com o código inteiro oculto no instalador. As partes recompõem os mesmos bytes e SHA-256 da fonte publicada.

## Alterações

- Configurações com quatro categorias coloridas, páginas internas, Voltar e X fixo de 48×48. Mudar mundo oferece Praça original, Ilhas de nuvens, Jardim sakura, Cidade neon e Costa dourada. Alterações de iluminação, cores e decoração são locais; colisão, regras e mapa do servidor são preservados.
- Plus abre diretamente `MarketplaceService:PromptRobloxSubscriptionPurchase(player)` pelo HUD, sem carregar o catálogo ou abrir uma página intermediária.
- Catálogo mostra cinco colunas e quatro linhas completas em 768×432, 800×360, 844×390 com recortes, 1460×821 e 1920×1080. No modo retrato, a quantidade se adapta. Aplicar, Salvar, Restaurar, Carrinho, Configurar corpo e itens com X ficam organizados abaixo da prévia. Preços compactos mantêm valor numérico e Robux.
- Prévia comum para catálogo, looks e Comunidade, com enquadramento calculado pelas peças visíveis e pelas dimensões do viewport. Giro frontal, traseiro e lateral, arraste, zoom e retenção do ângulo ao redimensionar. Fundo cinza neutro e luz clara; não há parede que cubra as costas. Modelos de requisições antigas são descartados.
- Meus looks tem prévia selecionada maior e cards menores. No computador, a prévia fica ao lado da galeria; em telas menores abre com X. Todas as seis ações cabem no rodapé da prévia de computador. Preços e remoção individual foram preservados.
- Photo Mode tem cinco cenários locais: Estúdio editorial, Nuvens, Horizonte dourado, Jardim e Portal neon. Decoração animada pode ser pausada; cenário permanece atrás do avatar ao girar. Luz, exposição, intensidade, hora, contraste, saturação, câmera, captura, ocultar interface e restauração continuam.
- Editor de pose usa manequim 2D amarelo/azul/verde. Arraste cabeça, cintura, braços ou pernas para girar ou mover; Frente/Lado troca o plano de edição. R15 permite selecionar ombro/cotovelo/pulso e quadril/joelho/pé. Aplicar conserva a pose no clone do estúdio; Cancelar/X restaura a pose confirmada. Restaurar, Aplicar e Cancelar ficam visíveis sem rolagem. A pose não altera o avatar de outros jogadores.
- Comunidade usa perfis confirmados pelo UserService e thumbnails nativos. Até 50 cards são reciclados, com preparação da próxima página após aproximadamente 30 entradas, cache de 12 páginas e recarregamento ao voltar. Avatares 3D são criados sob demanda. Publicações existentes continuam com seus códigos, corpos, autoria, curtidas, filtro semanal e destaque por recência. Respostas de filtros/telas antigos são descartadas.
- Detalhe da Comunidade ocupa a tela com fundo opaco, prévia grande, frente/costas/lados, arraste, alternância R6/R15, itens com imagem/X, preços e criadores reais. A seleção de usuários do Roblox exibe a curadoria `@CAETANOYX` e também o dono original do avatar. Publicações de jogadores mantêm o autor real.
- X de janelas ocupa pelo menos 48×48; fica fora da área rolável. X individuais de itens usam 40 px. Fechar Carregar avatar impede que o foco atrasado reabra o teclado. Carrinho e Carregar avatar abrem isoladamente e retornam à tela anterior.
- Bots: fácil escolhe jogadas legais sem busca; médio usa busca tática limitada; difícil aprofunda minimax com poda e mais nós. Busca verifica cancelamento e cede execução durante cálculos. Damas preserva captura obrigatória e sequências. Batata é treino de memória: as mesmas três posições perigosas são reveladas aos dois lados; níveis variam tempo de observação e recordação do bot, sem acesso a posições escondidas.

## Capacidade e identificação

A galeria suporta **20.000 páginas × 50 registros**, com limite de memória e consultas. Isso é capacidade para até um milhão, não um banco de um milhão de skins já reunidas e verificadas. Usuários inexistentes são descartados; páginas podem ter menos de 50 registros. Thumbnails e respostas dependem da disponibilidade e dos limites do Roblox.

A seleção consulta em tempo de execução o avatar, a autoria e os nomes de camisa/calça. A identificação de cosplay é uma **inferência dos nomes das roupas**, exigindo duas roupas distintas que apontem ao mesmo personagem. O detalhe informa essa base. A versão inicial reconhece conservadoramente Naruto Uzumaki, Son Goku e Spider-Man/Peter Parker, com nomes canônicos pesquisados em fontes oficiais. Referências ambíguas mantêm o nome do usuário. Reconhecer visualmente qualquer anime, filme ou série exigiria um serviço externo de pesquisa/classificação configurado; nenhum serviço externo ou resultado visual fictício foi incluído.

Fontes dos nomes: [Naruto oficial](https://naruto-official.com/en/news/01_1610), [Dragon Ball oficial](https://en.dragon-ball-official.com/news/01_23.html), [Marvel](https://www.marvel.com/characters/spider-man-peter-parker).

## Instalação

Requer **V42 completa**, incluindo `08B_AVATAR_DATA`/`08D_SKIN_STATE` V41, regras `07A0_CHESS_RULES`/`07B0_CHECKERS_RULES`, `07P1_CAPTURE_ENGINE` e `08L_COMMUNITY` existentes. Pare Play; crie estes módulos:

| Módulo novo | Local |
|---|---|
| 07G1_HUB_SETTINGS | ReplicatedStorage |
| 07G2_LOCAL_WORLDS | ReplicatedStorage |
| 07H4_BOT_ENGINE | ReplicatedStorage |
| 07P5_POSE_CANVAS | ReplicatedStorage |
| 07P6_STUDIO_SETS | ReplicatedStorage |
| 09A2_PREVIEW_LAYOUT | ReplicatedStorage |
| 09C6_AVATAR_PREVIEW | ReplicatedStorage |
| 09C7_COMMUNITY_FEED | ReplicatedStorage |
| 09C8_COMMUNITY_DETAILS | ReplicatedStorage |
| 09B1_AVATAR_DISCOVERY | ServerScriptService |
| 09B2_COSPLAY_METADATA | ServerScriptService |

Substitua os outros 16 scripts nas instâncias e locais indicados no instalador. Não duplique instâncias. Apague o código antigo de `09A_SHOP_UI` uma única vez; cole as quatro partes em ordem no mesmo ModuleScript. Instale todos os 27 itens antes do próximo Play.

## Verificação

- `python audits/V43/test_v43.py`: 15 casos, incluindo sintaxe/limites dos 27 scripts, sete viewports, 5×4, X fixos, mundo local/restauração, Plus, quatro ângulos e cancelamento de prévias, reciclagem por mais de 100 páginas, identificação conservadora, detalhes, looks, cinco cenários, pose direta e bots.
- `python audits/V43/test_regressions.py`: 12 casos, incluindo preservação da skin e mudanças recentes, pacote, histórico, proporções, aparência não carregada, carrinho, foco do carregador, captura/fechamento atrasado, salas online existentes, batata, páginas publicadas de até 47 registros, volta na galeria, filtro semanal e descarte de consultas antigas.
- `node audits/V43/test_installer_logic.cjs`: JavaScript real do HTML, pacote offline, rejeição de cache antigo, 27 hashes, remontagem exata, 11 criações/16 substituições, cópia/seleção, fallback para fonte adulterada e fechamento durante carregamento.
- `python audits/V43/inspect_layouts.py`: 40 telas aproximadas em 1920×1080, 768×432, 800×360, 844×390 com recortes e 360×640. Catálogo, looks/seleção, Comunidade/detalhe, configurações/mundos e manequim de pose; nenhum corte vertical de texto encontrado. Pillow usa fontes substitutas e placeholders das prévias, sem assets reais.

**27 casos funcionais/sintaxe aprovados**, além do instalador e da inspeção de layouts. Serviços simulados com Lua 5.4; não houve execução no Studio Lite/Roblox, renderização 3D nativa, compra, captura ou teste de carga real com um milhão de registros.

Dois SHA-256 incorretos das regras V37 foram corrigidos no manifesto após conferir os bytes existentes no GitHub. As regras e o mapa do servidor não foram alterados nem incluídos como substituições da V43.

Antes de considerar pronto no jogo publicado: conferir toque/arraste e X no celular, skins claras/escuras em todos os ângulos, poses e cenários 3D, thumbnails/consultas reais e retorno na Comunidade, aplicação de roupa/corpo, bots completos, assinatura e captura oficiais. O limite de consultas foi tratado com cache e controle de frequência, mas sua operação real precisa desse teste.

APIs oficiais consultadas: [UserService](https://create.roblox.com/docs/reference/engine/classes/UserService), [Roblox Plus](https://create.roblox.com/docs/production/monetization/roblox-plus), [MarketplaceService](https://create.roblox.com/docs/reference/engine/classes/MarketplaceService), [Motor6D](https://create.roblox.com/docs/reference/engine/classes/Motor6D), [RunService](https://create.roblox.com/docs/reference/engine/classes/RunService).
