# Avatar Plaza — V45

Correções para a V44 instalada no Roblox Studio Lite: comunidade de jogadores, câmera/mão do Truco, arte completa das cartas, Ateliê e seleção dos jogos. A base do handoff e a instalação V44 continuam necessárias.

Abra [AVATAR_PLAZA_SCRIPT_HUB_PERMANENTE.html](AVATAR_PLAZA_SCRIPT_HUB_PERMANENTE.html) e selecione **V45**. São **14 SUBSTITUIR / 0 CRIAR**, até 280 linhas por script alterado. Se ainda estiver instalando a V44, conclua os 55 scripts primeiro. As duas versões estão no HTML offline, e versões publicadas são consultadas no GitHub.

`09A_SHOP_UI` continua dividido em exatamente quatro partes no mesmo ModuleScript. Tipos, locais e nomes estão em [INSTALL_V45.md](INSTALL_V45.md); os avisos (SUBSTITUIR) não fazem parte do nome no Roblox.

## O que mudou na V45

- Comunidade usa a descrição atual de jogadores reais, com itens conferidos. Sem composições sintéticas de catálogo; conta Roblox e looks repetidos são excluídos. Abas Jogadores (pagos), Grátis, Publicados e Em alta; duas linhas inteiras em telas verificadas. Valores desconhecidos nunca são classificados como gratuitos. Partes de corpo em pacotes gratuitos também são consultadas.
- Referências reconhecidas passaram de seis para dezesseis. O nome do cosplay só aparece quando as duas roupas têm uma referência compatível; isso não garante que perfis encontrados contenham todos esses personagens.
- Câmera do Truco olha para fora do rosto. Corpo/acessórios originais ficam ocultos somente no cliente, controles móveis não cobrem cartas e os valores anteriores são restaurados na saída. Três cartas 3D privadas, em leque junto de cópias das mãos, aceitam toque, mouse ou teclas 1/2/3.
- Visuais alteram frente, verso, gravação, cores e acabamento da carta. Índices e naipe usam áreas com contraste protegido. Imagem do Ateliê aparece nos dois lados; cartas cobertas/ocultas continuam sem revelar identidade.
- Inventário e loja usam páginas laterais, com até seis escolhas em paisagem ou quatro em retrato. Compras, equipar, virar e abrir caixas ficam fixos e não exigem rolagem vertical.
- Ateliê aceita ID ou link de imagem/decal, verifica carregamento, mantém prévia/zoom/arraste e salva já equipando. Imagem que não carrega não recebe confirmação de sucesso. Preços indisponíveis desativam compras sem atribuir valores vazios a propriedades booleanas da Roblox.
- Jogos usam cartões de categoria, cores de seleção e ações fixas de partida rápida, amigos ou treino. Catálogo mantém cinco colunas e duas linhas em paisagem com menos margem e mais imagem nos cards.

Sistemas de regras, torneios, bots, moedas, privacidade, carrinho e Photo Mode da V44 continuam presentes. Os IDs de monetização e preços do painel Roblox não foram alterados.

## Passes e preços

Os preços de teste informados pelo criador são **1 Robux** para passes e produtos. A interface consulta preços regionais/personalizados no cliente e bloqueia a compra se os metadados não estiverem disponíveis. Scripts não alteram o painel de preços.

| ID de Game Pass | Benefício permanente | Sugestão após os testes |
|---|---|---:|
| 1951234105 | Ateliê: imagem no baralho, zoom e ajuste | 249 Robux |
| 1962433436 | Regent | 35 Robux |
| 1966813498 | Zenith | 65 Robux |

| Coleção | Conteúdo conhecido | Moedas por escolha ou visual direto | Sugestão por escolha ou visual direto |
|---|---|---:|---:|
| Nox | Onyx, Veyra, Nyxar | 500 | 15 Robux |
| Reign | Regent, Aurum, Valor | 1.200 | 35 Robux |
| Eclipse | Zenith, Vaelis, Nova | 2.500 | 65 Robux |

Os **dez Developer Products estão configurados** em `07K6_CARD_CATALOG.Products`:

| Produto | ID |
|---|---:|
| Caixa Nox | 3716296910 |
| Caixa Reign | 3716298871 |
| Caixa Eclipse | 3716298939 |
| Visual Onyx | 3716298994 |
| Visual Veyra | 3716299051 |
| Visual Nyxar | 3716299236 |
| Visual Aurum | 3716300186 |
| Visual Valor | 3716300285 |
| Visual Vaelis | 3716300668 |
| Visual Nova | 3716300484 |

Éter Visual (3716300364) foi desativado pelo criador e não é usado. Os nomes Vesper/Hex/Aether permanecem apenas como chaves internas para preservar inventários; os nomes públicos são Veyra/Nyxar/Vaelis. As telas de nomes próprios não usam tradução automática. A tradução dos nomes na compra nativa da Roblox é configurada no painel de Localização.

Compras por moedas e os três passes também estão implementados. Moedas são ganhas em partidas PvP validadas; não existe venda direta de moedas. Faça os testes dentro do jogo; os produtos de escolhas limitadas não devem ser habilitados para venda externa.

## Decisão sobre ECA Digital

Caixas aleatórias estão desativadas para todas as contas. O jogador escolhe um visual permanente conhecido, sem sorteio. `PolicyService` e `AccountAge` não são tratados como prova de maioridade. Não se coletam documento, data de nascimento ou declaração de idade no jogo.

A análise técnica usa a Lei 15.211/2025 e o Decreto 12.880/2026, além de três documentos distintos de monetização da Roblox. Fontes, regras regionais e limites estão em [audits/V44/LEGAL_AND_RULES.md](audits/V44/LEGAL_AND_RULES.md). Essa decisão não é uma certificação de conformidade integral.

## Validação e limites

**50 casos passaram**: 49 de lógica/sintaxe em Lua 5.4 com serviços simulados e um do JavaScript real do instalador. Incluem 72 partidas completas de bots, 400 combinações carta/visual, toque/raycast, restauração da câmera, geometrias móveis, imagem indisponível, pacotes gratuitos, compras, avatar e recuperação de salas/torneios.

Ainda é necessário conferir no Roblox/Studio Lite a renderização 3D, o toque físico, compras, serviços publicados e limites de API. As fotos anunciadas nesta solicitação ainda não foram recebidas. A comunidade pesquisa perfis reais sob demanda; não é uma coleção pronta de um milhão de skins. Nome de personagem é inferido dos títulos das roupas e não de reconhecimento visual universal. IDs/nomes/preços de compra permanecem conforme a V44.

Resultados, fontes e roteiro de QA: [audits/V45/README.md](audits/V45/README.md). A decisão de monetização segue documentada na [auditoria V44](audits/V44/LEGAL_AND_RULES.md).
