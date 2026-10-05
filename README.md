# Avatar Plaza — V50

Pacote reduzido baseado na V49 mais recente do GitHub (`43a2e678427e3d5e03540ba3589b106a4437f6b9`). **A aba V50 contém somente 11 itens: 8 substituições e 3 NOVOS**, para quem terminou a V48. São os mesmos códigos da V49. Se algum desses itens já recebeu o código da V49, não precisa substituir novamente; quem terminou os 11 não tem código adicional para instalar. O pacote cumulativo V49 continua no histórico para instalações anteriores.

Baixe [AVATAR_PLAZA_SCRIPT_HUB_PERMANENTE.html](AVATAR_PLAZA_SCRIPT_HUB_PERMANENTE.html), abra **V50** e siga [INSTALL_V50.md](INSTALL_V50.md). Pare Play e crie primeiro os três novos, somente se ainda não existem. Preserve nomes, tipos e locais das instâncias. 09A_SHOP_UI tem quatro partes consecutivas no mesmo ModuleScript; os demais têm duas. O HTML contém V44/V50 offline e mantém o histórico online. Nenhum passe, Developer Product ou preço adicional. A conferência da entrega está em [audits/V50/README.md](audits/V50/README.md).

Também disponível como [AVATAR_PLAZA_V50.html](AVATAR_PLAZA_V50.html), com o mesmo conteúdo e indicação ONLINE em verde quando sincronizado. Esta correção é somente do instalador; os 11 códigos Roblox continuam idênticos à V49.

O HTML usa cartões compactos com nome, tipo, local, última linha e botão de copiar, sem exibir o código inteiro. A divisão em partes continua disponível; se a cópia automática falhar, o código correspondente é aberto e selecionado para cópia manual.

## Correções de corpo

- Ao entrar, consulta a aparência **equipada** no perfil Roblox. Corpos próprios são construídos com as partes nativas e estrutura R15, sem o corpo imposto pelas Avatar Settings da experiência. Possuir um corpo sem equipá-lo no perfil não o veste automaticamente.
- Ao trocar corpo ou rig, reconstrói o personagem completo, preservando posição, roupas, acessórios, vida, velocidade e ferramentas; retoma o assento e vincula câmera/animações. Não muda apenas Humanoid.RigType.
- Confere os IDs das peças, proporções, estrutura e rig efetivos antes de informar sucesso. Falha de construção mantém o personagem anterior. Reaparecer após morrer recupera o último look confirmado na sessão.
- Pacotes usam todas as peças e proporções do outfit nativo. Camisas/calças/acessórios que não foram editados continuam. Pacote incompleto não é apresentado como aplicação concluída.

## Catálogo aprovado

Prévia quadrada, Aplicar em texto verde e Salvar/Restaurar/Carrinho/Corpo em ícones compactos. Itens equipados continuam embaixo, com miniatura e X ao lado da imagem. Área maior pode exibir mais itens. Duas linhas, cinco colunas nas telas largas e quatro quando necessário; retrato adapta para manter legibilidade. Preços continuam explícitos em Robux. Jogos, Truco 2D, Limiteds, comunidade e Photo Mode incorporam as correções V48.

## Validação

**91 casos Lua 5.4 com serviços simulados + 1 caso do JavaScript real do instalador.** Os 17 novos casos incluem entrada com corpo nativo, R6/R15, proporções, readback, falhas, substituição concorrente, respawn, câmera/animações e catálogo. Os doubles não carregam meshes reais nem executam compras. Ainda é necessário testar o **gato abacaxi equipado na conta**, corpos realistas e memes no Roblox/Studio Lite.

Detalhes, comandos reproduzíveis e limites em [audits/V49/README.md](audits/V49/README.md); referências oficiais em [audits/V49/RESEARCH.md](audits/V49/RESEARCH.md). A V44 completa e a base original continuam necessárias.

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

Os resultados atuais estão em [audits/V49/README.md](audits/V49/README.md). A V49 tem 92 casos executados, incluindo os fluxos de recibos, imagem, comunidade, jogos e as novas correções de corpo. São doubles de serviços e geometria, mais JavaScript real com DOM mínimo; não simulam renderização de meshes ou pagamentos reais.

A pesquisa pública não encontrou cinco fotos verificáveis de cada fundo do Catalog Avatar Creator; os cinco ambientes são originais. Não foram usados paths históricos de imagens ausentes como evidência. Nenhum código ou asset do CAC foi incorporado.

Ainda é necessário testar no Roblox/Studio Lite/place publicado: renderização, toque físico, emotes reais, imagens aprovadas, compras e latência. Os testes simulados não certificam nitidez no aparelho nem disponibilidade de assets. A comunidade consulta perfis reais sob demanda; não é uma coleção pronta de um milhão de skins nem reconhecimento visual universal de personagens. Esta atualização publica fontes no GitHub, sem publicar o place ou fazer compras.
