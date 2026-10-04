# Auditoria V47

## Base e evidência

Base GitHub main: `bb96f275811b106ff5996e7f4865ff78df4b69cf` (V46), árvore `0f6645e0bd42cfde2a67645270819d2af5617978`. Antes de alterar fontes, as 56 fontes V46, o manifest e o HTML foram comparados pelo SHA de blob Git. O handoff e o histórico visível foram lidos. Nenhuma fonte V46 foi editada.

As três imagens da solicitação foram abertas. Mostram cards grandes, faixa inferior ociosa, erro de Avatar Discovery com nomes de scripts e layout do Truco. Não há imagem nova de uma renderização nativa da V47.

## Causas e correções

A consulta de nomes era necessária para descobrir candidatos. O UserService limita a quantidade de resultados por minuto; páginas grandes e repetidas podiam consumir a cota antes das descrições. Na V47, nomes são opcionais. Amigos e jogadores online fornecem nomes já disponíveis; há cache, lotes de até 32, orçamento global de até 180 IDs por minuto e cooldown após falha. O fluxo mantém descrições reais, limita concorrência a quatro e não inventa autoria. Falhas de descrições permitem retry sem cache negativo de três minutos. Recomendações em cache e autorizações ficam por visitante.

A lista inicial parava em 50 e descartava a sobra do lote recebido. A V47 guarda essa sobra, consome até dez por pedido e lembra o fim da página até esvaziar a fila. O histórico máximo de 600 assinaturas, janela de 100 looks e pool de 50 slots continuam limitados. Rolagem não faz pedidos automáticos. Três linhas dependem de pelo menos 282px disponíveis na grade; nas telas mais curtas são duas para preservar as miniaturas.

Ateliê tratava IsLoaded sem verificar previamente o tipo/ID. Agora pede metadados Image/Decal ao servidor. Image usa o ID original. Decal pode ser resolvido por AssetService:LoadAssetAsync, respeitando as permissões existentes; o modelo permanece sem Parent e é destruído após ler Decal.Texture. Nenhuma opção de importação é ativada. O servidor ignora textura enviada pelo cliente e persiste a textura canônica. Carregar/Recarregar têm token, limite de 12s para metadados e tentativas de imagem direta/thumbnail de 8s cada. Salvar exige metadados correspondentes e IsLoaded; isso não é certificação de moderação. Zoom/arraste não recarregam a imagem. Custom vazio não pode ser equipado.

ScreenGui era configurado via pares de propriedades, tornando a ordem entre IgnoreGuiInset e ScreenInsets incerta. Configuração final explícita garante backdrop de tela inteira. Guias separados medem Core UI no topo e DeviceSafeInsets nas laterais/base. O catálogo observa ambos, usa a faixa inferior e mantém o recorte físico. O teste reserva artificialmente 100px de Core UI na base e confirma sua recuperação, preservando 22px de DeviceSafeInsets.

Jogos agora coloca as três categorias no topo e conserva todos os callbacks e controles do servidor original. Campos ficam em um painel compacto; Busy/Waiting bloqueiam troca de categoria. A composição de espera foi ajustada para que Cancelar não cubra o código em paisagem curta.

Photo Mode troca a barra horizontal por seis ferramentas laterais. O avatar continua no Workspace local, com ações em painéis sem rolagem. Faixas de emote podem aparecer depois de PlayEmoteAsync; a V47 observa Animator.AnimationPlayed e aguarda até dois segundos, com cancelamento por geração, parada natural e restauração da pose. Os cinco cenários originais usam 58–144 partes e até 20 elementos animados, com atualização limitada a 20Hz. Não colidem nem respondem a raycast. A pausa e destruição desconectam animações. Todos os cantos da geometria de fundo foram verificados atrás do plano do avatar nos quatro ângulos; o piso é a exceção intencional, abaixo dele.

## Verificação executada

| Suíte | Casos |
|---|---:|
| test_v47.py | 13 |
| test_integration.py | 15 |
| test_changes.py | 6 |
| test_features.py | 7 |
| test_games_commerce.py | 9 |
| test_server_flows.py | 5 |
| test_fixes.py | 12 |
| JavaScript real do instalador | 1 |
| **Total** | **68** |

As suítes Lua usam o interpretador Lua 5.4 e doubles de serviços, UI, geometria e agendamento. Não executam rede Roblox, física nativa, moderação, renderização ou pagamento. Incluem 72 partidas completas nos três perfis/níveis, 400 combinações carta/visual, validação de turno/revisão, persistência e recibos, privacidade, aplicação do avatar, navegação e fechar durante operações pendentes. A suíte do instalador executa o JavaScript extraído do HTML: offline V47/V44, hashes, reconstrução exata das partes, 32 SUBSTITUIR/0 CRIAR, quatro partes da 09A, cache antigo, fallback e fechamento durante carga. Não testa CSS.

```sh
python audits/V47/test_v47.py
python audits/V47/test_integration.py
python audits/V47/test_changes.py
python audits/V47/test_features.py
python audits/V47/test_games_commerce.py
python audits/V47/test_server_flows.py
python audits/V47/test_fixes.py
node audits/V47/test_installer_logic.cjs
```

Dependências dos doubles da V43 e fixtures de regressão V42/V43 são preservadas no repositório. build_installer.py é reexecutável e gera manifest, HTML e INSTALL_V47.md com hashes atualizados. O snapshot tem 56 fontes, 18 diferentes da V46; o instalador cumulativo inclui 32 substituições, nenhuma instância nova. Todas as fontes têm até 400 linhas e não usam atribuição composta.

## Fontes oficiais consultadas

- [UserService — creator-docs](https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/UserService.yaml): até 250 resultados/minuto, resultados fora de ordem, IDs inválidos omitidos e pcall em falhas. A V47 reserva no máximo 180 IDs/minuto neste serviço do projeto.
- [ScreenGui](https://create.roblox.com/docs/reference/engine/classes/ScreenGui) e [fonte oficial YAML](https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/ScreenGui.yaml): acoplamento IgnoreGuiInset/ScreenInsets e guias de área segura.
- [AssetService](https://create.roblox.com/docs/reference/engine/classes/AssetService#LoadAssetAsync): carregamento nativo em sandbox e permissões para assets de terceiros. A V47 lê uma textura, não insere o resultado nem muda configuração.
- [ImageLabel](https://create.roblox.com/docs/reference/engine/classes/ImageLabel#Image): conteúdo de imagem/decal e IsLoaded.
- [ContentProvider](https://create.roblox.com/docs/reference/engine/classes/ContentProvider#PreloadAsync): pré-carregamento nativo.
- [Humanoid](https://create.roblox.com/docs/reference/engine/classes/Humanoid#PlayEmoteAsync) e [Animator](https://create.roblox.com/docs/reference/engine/classes/Animator): execução de emotes e acompanhamento de faixas. Não se usa PlayEmoteAndGetAnimTrackById, que tem RobloxScriptSecurity.

## QA ainda necessário

Instalar o conjunto correspondente no Studio Lite, sem misturar partes ou duplicar instâncias. Conferir as mesmas telas em retrato/paisagem; código/cancelamento de sala; prévia e popover do catálogo; 2/3 linhas da comunidade e recuperação real; imagem pública aprovada em frente/verso e nas cartas da mesa; emotes R15, pose, cinco cenários, 360 graus, ocultar UI e captura. O serviço pode negar um asset ou thumbnail; nesse caso a interface permite nova tentativa e não promete acesso. Compras reais não foram feitas. IDs e preços do painel permanecem os fornecidos pelo criador.

A decisão existente de desativar sorteios e oferecer escolhas conhecidas continua em [LEGAL_AND_RULES.md](../V44/LEGAL_AND_RULES.md). Não foi alterada nesta versão.
