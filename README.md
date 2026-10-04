# Avatar Plaza — V46

Atualização para Roblox Studio Lite, feita sobre a última V45 publicada no GitHub. O instalador entrega **30 SUBSTITUIR / 0 CRIAR**, cumulativas desde a V44 completa. Não é necessário instalar a V45 antes. O snapshot auditável contém 56 fontes, incluindo o `08B_AVATAR_DATA` original atualizado; o pacote de substituições contém apenas 30.

Abra [AVATAR_PLAZA_SCRIPT_HUB_PERMANENTE.html](AVATAR_PLAZA_SCRIPT_HUB_PERMANENTE.html), selecione **V46**, pare Play e substitua as instâncias indicadas. Se ainda estiver instalando a V44, termine os seus 55 itens primeiro. A base original do handoff e suas dependências continuam necessárias. [INSTALL_V46.md](INSTALL_V46.md) lista nomes, tipos, locais e partes. **09A_SHOP_UI são exatamente quatro partes no mesmo ModuleScript**, sem fonte inteira exposta.

## Mudanças

- Truco reserva espaço para a mesa e enquadra as cartas nos quatro lugares, inclusive em paisagem estreita. Três cartas completas ficam acima dos botões individuais, com placar no topo e ações abaixo. A câmera gira por arraste e possui Centralizar. Um toque joga somente ao soltar, evitando jogar ao arrastar. Qualquer carta própria é permitida; o servidor mantém a validação de turno e revisão.
- Bots esperam 2,8 segundos entre decisões nas partidas contra bots; vazas completas permanecem 3,2 segundos. Entre mãos há pausa. O rótulo é Contra bots. TRUCO, SEIS, NOVE, DEZ e DOZE seguem os valores de cada perfil; Aceitar/Correr são decisões reais. Não há novos valores ou regras inventadas.
- Jogos têm categorias e ações explícitas. A loja de baralhos abre em Loja; Meus visuais e Minhas caixas explicam onde equipar/abrir. Páginas fixas mantêm ações e prévias visíveis sem rolagem vertical. Os visuais ganharam coroas, constelações, vitrais, gravações e figuras, preservando rank/naipe legíveis. Frente e verso recebem o visual.
- Ateliê tem **Carregar/Recarregar**, pré-carregamento nativo, tentativa alternativa de thumbnail e falha com nova tentativa. Ajustar zoom/recorte não destrói e recarrega a imagem. Imagens não carregadas não podem ser salvas como sucesso. O passe existente e a validação Image/Decal são mantidos.
- Catálogo mantém **5 colunas × 2 linhas em paisagem**, com miniaturas maiores. Toque abre um painel compacto de Comprar/Experimentar, mantendo a prévia visível. Roupas, remoção por X e proporções aplicam automaticamente no personagem, com debounce e preservação das partes não editadas. O botão Aplicar continua disponível. Corpo passa a buscar pacotes reais BodyParts/DynamicHeadAvatar e inclui gratuitos.
- Comunidade consulta avatares atuais de jogadores reais, sem criar skins sintéticas. Até 50 looks no lote inicial, **Carregar mais** manual, janela máxima de 100 com descarte em grupos de dez e 50 cards de UI reciclados. APIs de amigos e metadados em lote ajudam a encontrar perfis; no máximo quatro descrições são carregadas simultaneamente. Todos, Robux, Grátis e Publicados têm busca/retry. Preço desconhecido não é gratuito. Nomes de estilo são inferências conservadoras dos itens; cosplay exige evidência consistente nas duas roupas.
- Photo Mode permite selecionar e arrastar uma parte no avatar do cenário ou no manequim 2D. Alças coloridas, mover/girar, desfazer/refazer, Aplicar/Cancelar ficam disponíveis sem rolagem. Animações usam o rig real do cenário com PlayEmoteAsync em R15; é possível parar, mudar velocidade e congelar como pose. Cinco fundos receberam melhorias visuais e o ambiente tem luz/exposição ajustáveis. O fundo do título ao lado do X foi retirado.

Regras, moedas, privacidade, carrinho, torneios e dados persistidos permanecem. A atualização não modifica preços no painel Roblox, não compra produtos e não adiciona IDs.

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

**56 casos passaram**: 55 em Lua 5.4 com serviços simulados e um no JavaScript real do instalador. Incluem sintaxe das 56 fontes, 72 partidas de bots, 400 combinações carta/visual, projeção das cartas em cinco telas e quatro lugares, câmera/toque, aplicação do avatar, 50/100 looks, concorrência limitada, preços, persistência, pose, animação e fechar durante chamadas pendentes.

A foto enviada foi inspecionada. Para poses foram analisados dez quadros de um vídeo público demonstrando o editor do Catalog Avatar Creator, publicado em um tópico de 2023; **não são dez fotos distintas da versão atual**. Nenhuma arte ou código desse jogo foi copiado. As referências e causas estão em [audits/V46/README.md](audits/V46/README.md).

Ainda exige teste no Roblox/Studio Lite: renderização, toque físico, imagens aprovadas, compra real, limite de serviços e latência. Os testes geométricos não certificam nitidez dos pixels no dispositivo. A comunidade não é uma coleção pronta de um milhão de skins, nem reconhece visualmente todo personagem; thumbnails podem manter cache próprio da Roblox. A decisão de monetização continua documentada em [audits/V44/LEGAL_AND_RULES.md](audits/V44/LEGAL_AND_RULES.md).
