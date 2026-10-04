# Avatar Plaza — V48

Atualização para Roblox Studio Lite feita sobre a última V47 do GitHub (`308f6706902576cb7a6e2f929cdc265f04866654`). O instalador entrega **36 SUBSTITUIR / 0 CRIAR**, cumulativos desde a V44 completa. Quem já concluiu a V47 substitui somente os **19 scripts** listados em [INSTALL_V48.md](INSTALL_V48.md). O snapshot contém 57 fontes.

Baixe [AVATAR_PLAZA_SCRIPT_HUB_PERMANENTE.html](AVATAR_PLAZA_SCRIPT_HUB_PERMANENTE.html), abra **V48**, pare Play e substitua as instâncias indicadas. A base original e a V44 completa continuam necessárias; V48 inclui V45, V46 e V47. **09A_SHOP_UI tem exatamente quatro partes consecutivas no mesmo ModuleScript**, sem fonte inteira exposta. Os demais têm duas partes. Nenhum passe, Developer Product ou preço novo.

## Mudanças desta versão

- **Jogos:** nova interface preta/verde, categorias Xadrez/Damas/Truco no topo e painel que usa toda a altura disponível. Partida rápida, Criar / entrar e Contra bots têm controles claros, com ilustração lateral nas telas largas. A área restante oferece três orientações visuais curtas sobre o jogo selecionado quando há espaço suficiente.
- **Truco 2D:** mesa com quatro posições públicas e três cartas privadas legíveis, placar e ações fixas. Pode jogar qualquer carta própria na sua vez. Cliente não cria mão 3D nem muda a câmera. Variantes, bots, gritos, regras e privacidade continuam no servidor.
- **Cartas e caixas:** nove edições receberam arte própria na frente/verso, mantendo rank e naipe. Caixas têm embalagem distinta. Todos os visuais aparecem antes de pagar, com **100% ao escolher**, sem sorteio. Após a confirmação efetiva do servidor, a escolha aparece recebida imediatamente; cancelar não concede nada. Cartas e resultado mantêm proporção.
- **Ateliê:** Carregar/Recarregar mostram sucesso verde ou falha vermelha. ID/tipo inválido e timeout são identificados. Na falha genérica, permissão, moderação ou conexão aparecem como possibilidades; não se inventa diagnóstico. Salvar exige metadados válidos e imagem carregada. Zoom/recorte, frente/verso e textura canônica continuam disponíveis.
- **Catálogo:** botão SUBCATEGORIA fica mais destacado. Corpo mostra pagos primeiro, com CORPOS GRÁTIS separado e MEMES / CRIATURAS. Pacotes nativos também carregam proporções/cores, preservando roupas e acessórios existentes. Prévia 360 e aplicação no personagem suportam geometria incomum.
- **Limiteds:** substitui a vitrine Lojas UGC. Filtro nativo Collectibles mais confirmação por item excluem itens comuns. Cards horizontais com destaque dourado, busca e Popular / Menor preço dão aparência diferente do catálogo.
- **Comunidade:** até três colunas e duas linhas maiores. Falhas transitórias recebem uma nova tentativa sem apagar looks carregados; pool e janela limitados mantêm o uso de memória. Itens de um look mostram imagem e nome; toque abre descrição, preço, Experimentar e Carrinho. Prévia e X de remoção/fechamento continuam.
- **Photo Mode:** painéis contextuais mais destacados e nenhum bloco inferior permanente com nome do fundo. Cinco ambientes originais receberam mais detalhes e movimento limitado: Galeria Aurora, Ilhas Celestes, Costa Dourada, Jardim Sakura e Cidade Prisma.

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

## Decisão sobre caixas

A escolha é conhecida e garantida, sem resultado aleatório. A decisão considera o art. 20 da Lei 15.211/2025 para este jogo acessível a menores. As restrições/verificações nativas da Roblox existem; não se infere idade pela idade da conta nem se coleta documento próprio. Fontes oficiais atuais, três documentos distintos da Roblox e limites estão em [audits/V48/RESEARCH.md](audits/V48/RESEARCH.md). Essa decisão não certifica conformidade integral do jogo.

## Validação e limites

**77 casos passaram:** 76 em Lua 5.4 com serviços e geometria simulados, mais um no JavaScript real do instalador. Incluem sintaxe das 57 fontes, 72 partidas completas, 400 combinações carta/visual, compras/recibos, cancelamento, 50/100 looks, HTTP 429/503, tipo/textura de imagem, tempo limite, proporções nativas e controles em várias telas. Os cinco cenários têm 72–159 partes, com até 20 elementos móveis. Testes, causas e evidências estão em [audits/V48/README.md](audits/V48/README.md).

A pesquisa pública não encontrou cinco fotos verificáveis de cada fundo do Catalog Avatar Creator; os cinco ambientes são originais. Não foram usados paths históricos de imagens ausentes como evidência. Nenhum código ou asset do CAC foi incorporado.

Ainda é necessário testar no Roblox/Studio Lite/place publicado: renderização, toque físico, emotes reais, imagens aprovadas, compras e latência. Os testes simulados não certificam nitidez no aparelho nem disponibilidade de assets. A comunidade consulta perfis reais sob demanda; não é uma coleção pronta de um milhão de skins nem reconhecimento visual universal de personagens. Esta atualização publica fontes no GitHub, sem publicar o place ou fazer compras.
