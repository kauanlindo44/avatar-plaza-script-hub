# Avatar Plaza — V47

Atualização para Roblox Studio Lite feita sobre a última V46 do GitHub (`bb96f275811b106ff5996e7f4865ff78df4b69cf`). O instalador entrega **32 SUBSTITUIR / 0 CRIAR**, cumulativos desde a V44 completa. Quem já concluiu a V46 precisa substituir somente os **18 scripts** listados em [INSTALL_V47.md](INSTALL_V47.md). O snapshot contém 56 fontes.

Baixe [AVATAR_PLAZA_SCRIPT_HUB_PERMANENTE.html](AVATAR_PLAZA_SCRIPT_HUB_PERMANENTE.html), abra **V47**, pare Play e substitua as instâncias indicadas. A base original e a V44 completa continuam necessárias; não instale V45/V46 separadamente. **09A_SHOP_UI são exatamente quatro partes consecutivas no mesmo ModuleScript**, sem fonte inteira exposta. Os demais têm duas partes. Nenhum passe, Developer Product ou preço novo.

## Mudanças desta versão

- **Jogos:** Xadrez, Damas e Truco no topo em ambas as orientações. Fundo carvão, categorias com ícones e opções compactas abaixo. Criar sala acompanha a categoria selecionada; categorias ficam bloqueadas durante pedidos e espera. Código e Cancelar não se sobrepõem em paisagem curta.
- **Caixas e cartas:** caixas têm embalagem própria com tampa, lateral, fita, selo e sombra. Frente e verso dos visuais continuam preservando rank/naipe legíveis. O Ateliê deixa mais área da imagem visível, sem apagar a identidade da carta.
- **Ateliê:** o servidor verifica se o ID corresponde a Image/Decal. Quando a permissão nativa permite carregar o Decal, lê sua textura e destrói o invólucro sem inserir nada no Workspace. Caso contrário, tenta o ID original e thumbnail nativo. Salvar exige metadados válidos e imagem carregada; respostas antigas, timeout e fechar não podem mostrar sucesso. Textura, zoom e recorte persistem. Custom sem imagem leva ao editor em vez de equipar um visual vazio.
- **Comunidade:** nomes de usuário são opcionais, com cache e limite global conservador; uma falha do UserService não interrompe descrições reais. Os candidatos são limitados por página e até quatro descrições são carregadas simultaneamente. Falha temporária não é armazenada como fim da lista. Até 50 looks no início, Carregar mais manual e janela de 100; os lotes restantes são reaproveitados e os antigos saem em grupos de dez. Até três linhas completas aparecem com altura suficiente, duas em telas curtas. Todos, Robux, Grátis e Publicados permanecem visíveis. Nenhuma skin sintética é adicionada; preço desconhecido continua distinto de gratuito. Erros internos ficam no servidor.
- **Catálogo:** aproveita a faixa inferior antes reservada pelo Core UI, preservando o recorte físico do dispositivo e os controles nativos no topo. Prévia e cards recebem mais altura; duas linhas do catálogo continuam legíveis. Aplicação de roupas e proporções preserva as partes não editadas.
- **Photo Mode:** ferramentas laterais, painéis contextuais e controles de luz/pose sem rolagem. Emotes R15 executam no avatar do cenário, com espera pela faixa real do Animator, parar, velocidade e congelar. Cinco ambientes originais — Galeria Aurora, Ilhas Celestes, Costa Dourada, Jardim Sakura e Cidade Prisma — têm camadas, detalhes e movimento limitado. Cenários ficam atrás do avatar nos quatro ângulos e são locais ao jogador. Sair restaura câmera e iluminação.

Regras, moedas, torneios, privacidade, carrinho e dados existentes continuam compatíveis. Decisões de monetização anteriores permanecem.

## Passes e preços

Os preços de teste informados pelo criador são **1 Robux** para passes e produtos. A interface consulta preços regionais/personalizados no cliente e bloqueia a compra se os metadados não estiverem disponíveis. Scripts não alteram o painel de preços.

| ID de Game Pass | Benefício permanente |
|---|---|
| 1951234105 | Ateliê: imagem no baralho, zoom e ajuste |
| 1962433436 | Regent |
| 1966813498 | Zenith |

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

**68 casos passaram:** 67 em Lua 5.4 com serviços e geometria simulados, mais um no JavaScript real do instalador. Incluem sintaxe das 56 fontes, 72 partidas completas, 400 combinações carta/visual, 50/100 looks, HTTP 429, recuperação e autorização por visitante, tipo/textura de imagem, cancelamento/timeout, cotas, controles e enquadramento em várias telas. Os cinco cenários têm 58–144 partes, com até 20 elementos móveis.

As três fotos desta solicitação foram inspecionadas. A base foi comparada às 58 entradas remotas da V46 antes de editar. Causas, fontes oficiais, testes e limites estão em [audits/V47/README.md](audits/V47/README.md).

Ainda é necessário testar no Roblox/Studio Lite/place publicado: renderização, toque físico, emotes reais, imagens aprovadas, compras e latência dos serviços. Os testes não certificam nitidez no aparelho nem disponibilidade de assets. A comunidade consulta perfis sob demanda; não é uma coleção pronta de um milhão de skins nem reconhecimento visual universal de personagens. Nenhuma arte ou código do Catalog Avatar Creator foi copiado.
