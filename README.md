# Avatar Plaza — V51

Atualização feita sobre a última V50 do GitHub, commit `3a46d5547042db04a47268d29900bbc13bb073a8`. **Somente 12 itens: 11 substituições e 1 NOVO**, para quem terminou a V50 (ou os mesmos 11 itens da V49 sobre a V48 completa). Não é um pacote cumulativo.

Baixe [AVATAR_PLAZA_V51.html](AVATAR_PLAZA_V51.html) ou [AVATAR_PLAZA_SCRIPT_HUB_PERMANENTE.html](AVATAR_PLAZA_SCRIPT_HUB_PERMANENTE.html), abra V51 e siga [INSTALL_V51.md](INSTALL_V51.md). Pare Play. Crie primeiro `08B2_BODY_DESCRIPTION`, um ModuleScript em ReplicatedStorage, e depois substitua os onze existentes. Os novos da V50 já existem e agora são substituições. 09A_SHOP_UI mantém quatro partes no mesmo ModuleScript; os demais têm duas. Todas as fontes entregues têm até 374 linhas.

O instalador conserva os cartões compactos: nome e ação, tipo, local, última linha e copiar. O código fica oculto e somente é revelado para cópia manual se as tentativas automáticas falharem. ONLINE usa verde; sem conexão, o HTML inclui V51 e V44. O histórico V49/V50 continua disponível online.

## Corpos nativos

Pacotes usam a descrição nativa do outfit, suas proporções, formato da cabeça, expressão estática e acessórios do corpo. Roupas vestidas são mantidas. Consulta de metadados do cartão não impede um pacote nativo de abrir; um extra indisponível não rejeita um corpo que já foi resolvido. Os pedidos têm uma nova tentativa e cache limitado.

Prévia e personagem preservam metadados de BodyPartDescription. O servidor parte de uma cópia da descrição real e mantém mudanças recentes que não foram editadas. A criação usa verificação de tipos de assets; o rig e os IDs efetivos são conferidos antes de confirmar. Formatos da cabeça que mudam com o mesmo ID também provocam reconstrução. Falhas mostram mensagem e **Tentar novamente** na prévia. Não se informa que um corpo genérico é o solicitado. Uma confirmação sem mudança visual reaproveita a prévia pronta ou em carregamento, sem cancelar e repetir o pedido; fechar o catálogo suspende novos pedidos de prévia.

## Tela do celular

O cálculo agora usa a origem real de CoreUISafeInsets. Isso remove a margem inferior criada por misturar coordenadas, preservando o recorte físico do aparelho. Busca/filtros aproveitam o topo livre ao lado dos controles Roblox quando cabem; caso contrário ficam abaixo. A orientação e alterações dos controles nativos recalculam o layout.

A prévia usa mais altura e largura, com rotação e zoom em uma faixa própria. Itens equipados continuam embaixo com imagem e X separados. Catálogo deitado mostra **5 cards por linha e 2 linhas nas telas com largura suficiente**; retrato e telas pequenas adaptam as colunas. Imagem ocupa a parte principal do card e o preço fica em um rodapé pequeno abaixo. Janelas e X permanecem dentro da área segura; abertura curta respeita a preferência de movimento reduzido.

## Validação

**106 verificações Lua 5.4 com serviços/geometria simulados + 1 caso do JavaScript real do instalador.** Incluem 15 novos casos: metadados nativos, expressão/cílios, roupa isolada, salvamento/respawn, falha e retry, IDs divergentes, confirmação sem pedido duplicado, origem da tela, cinco colunas/duas linhas, X e controles, mudança de orientação e enquadramento de 360°.

Os testes não carregam meshes reais, não validam o toque físico e não executam compras. Ainda é necessário testar o **Funky Ehh Kid Meme (Gumball)**, o gato abacaxi e corpos realistas no Roblox/Studio Lite. Não foi confirmado um ID de bundle específico do Gumball nem a causa de falha desse asset em execução. Esta atualização corrige causas reproduzíveis no código e acrescenta diagnóstico/retry.

Veja [audits/V51/README.md](audits/V51/README.md) e as referências oficiais em [audits/V51/RESEARCH.md](audits/V51/RESEARCH.md). O place não foi publicado; as fontes e o instalador são atualizados no GitHub.

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

## Limites de validação

Os resultados atuais estão em [audits/V51/README.md](audits/V51/README.md). A V51 tem 107 verificações, incluindo os fluxos de recibos, imagem, comunidade, jogos e as correções de corpo/tela. São doubles de serviços e geometria, mais JavaScript real com DOM mínimo; não simulam renderização de meshes ou pagamentos reais.

A pesquisa pública não encontrou cinco fotos verificáveis de cada fundo do Catalog Avatar Creator; os cinco ambientes são originais. Não foram usados paths históricos de imagens ausentes como evidência. Nenhum código ou asset do CAC foi incorporado.

Ainda é necessário testar no Roblox/Studio Lite/place publicado: renderização, toque físico, emotes reais, imagens aprovadas, compras e latência. Os testes simulados não certificam nitidez no aparelho nem disponibilidade de assets. A comunidade consulta perfis reais sob demanda; não é uma coleção pronta de um milhão de skins nem reconhecimento visual universal de personagens. Esta atualização publica fontes no GitHub, sem publicar o place ou fazer compras.
