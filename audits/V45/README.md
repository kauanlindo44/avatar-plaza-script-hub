# Auditoria V45 — Avatar Plaza

Base conferida: GitHub main `9aae6c202e6a539e4330c772c755b88dd3c8cf7f`, árvore `5eb17b42faa5d8ba53a65efc57168dbe12b44b84`. Os 76 blobs da publicação V44 foram comparados com os hashes Git do workspace antes das alterações. O handoff já havia sido lido integralmente na sessão. As novas fotos anunciadas pelo usuário ainda não chegaram; não se alegou inspeção visual dessas imagens.

Esta versão entrega **14 substituições, nenhuma instância nova**. O snapshot de 55 fontes é mantido em `scripts/V45` para reprodução da auditoria; somente 14 aparecem como itens da atualização. V44 e V45 estão embutidas no HTML offline. `09A_SHOP_UI` continua com quatro partes, sem bloco inteiro exposto. [INSTALL_V45.md](../../INSTALL_V45.md) identifica tipos e locais. Dependências, IDs e dados persistidos da V44 permanecem.

## Causas e comportamento

- O antigo curador criava combinações de camisa/calça/acessório do catálogo. Agora consulta avatares atuais de jogadores, preserva a descrição inteira e elimina assinaturas repetidas, a conta oficial Roblox e looks sem itens suficientes. Metadados dos itens são consultados em lotes; pacotes de corpo resolvem peças indisponíveis individualmente. Preço desconhecido não vira gratuito. Perfil exato aceita @/ID; busca por personagem filtra os perfis encontrados. Não se promete encontrar todos os cosplays, montar um milhão de looks previamente ou confirmar a aparência só pelo nome do usuário.
- Referências de personagem: seis existentes mais Sasuke, Kakashi, Sakura, Zoro, Nami, Tanjiro, Nezuko, Anya, Loid e Yor. Identificação continua exigindo duas roupas distintas compatíveis; rótulos conservadores quando não há evidência.
- A antiga frente branca tapava o visual da carta. A arte agora permanece visível na frente e no verso; índices e naipe usam áreas opacas de contraste. Acabamento físico local varia entre plástico, metal e vidro. Imagem personalizada fica nos dois lados. Cartas cobertas e mão de ferro não revelam rank/naipe.
- A antiga posição de câmera atravessava o rosto em determinados avatares. O novo enquadramento usa altura do personagem e direção da mesa. Transparência local e controles móveis são guardados/restaurados, com câmera mantida durante a partida. Mão contém três peças 3D locais à câmera e cópias das mãos R6/R15 quando disponíveis. Raycast analítico sobre os planos das cartas permite toque/mouse, sem enviar mão alheia; teclado 1/2/3 também funciona. Ações ainda são validadas pelo servidor.
- Loja/inventário: Frame fixo com páginas laterais, seis itens em paisagem/quatro em retrato; prévia e comprar/equipar/virar permanecem no quadro. Caixas garantidas conservam escolha antes de abrir e animação pulável. Não existe sorteio ou nova monetização.
- Ateliê: ID/link, prévia de frente/verso, zoom, enquadramento por arraste, indicação de carregamento e salvar/equipar. `ImageLabel.IsLoaded` impede confirmar imagem que não aparece; metadados do servidor validam Image/Decal. Carregamento não é prova de titularidade de direitos autorais. Passe existente é atualizado ao reabrir o inventário.
- `SetEnabled` normaliza o valor para booleano antes de atribuir propriedades nativas. Os mocks anteriores aceitavam nil; os testes V45 passam a rejeitá-lo, reproduzindo essa falha real de propriedade.
- Comunidade tem duas linhas completas, cards ampliados e abas pagos/grátis. Mantém pool de 50 cards, 12 páginas em cache e consulta limitada, com retry/backoff em páginas vazias/erro. Catálogo amplia área de imagem e conserva 5×2 em paisagem; seleção de jogos ganha cartões por categoria.

## Verificações

| Suíte | Casos | Verificação |
|---|---:|---|
| `test_v45.py` | 14 | Sintaxe das 55 fontes, limites, avatar, duas linhas de catálogo, X, HUD, comunidade/cache, pose e bots. |
| `test_games_commerce.py` | 9 | Regras, 72 partidas, privacidade, dez produtos/recibos, preços, moedas e torneios. |
| `test_integration.py` | 15 | Avatar/carrinho, permissões, avatares reais pagos/grátis, preço nativo, layouts, Ateliê e Photo Mode. |
| `test_server_flows.py` | 5 | Salas, fechamento, duplas, chegada e reconexão com fontes reais e serviços simulados. |
| `test_changes.py` | 6 | 400 combinações carta/visual; páginas sem rolagem; imagem indisponível; duas linhas de comunidade; corpo em pacote gratuito; câmera/mão 3D/toque e restauração. |
| `test_installer_logic.cjs` | 1 | Hashes/partes da atualização, base offline V44, versão/cache, copiar, adulteração e fechar durante carregamento. |
| **Total** | **50** | Simulação; não substitui QA nativo. |

```sh
python audits/V45/build_installer.py
python audits/V45/test_v45.py
python audits/V45/test_games_commerce.py
python audits/V45/test_integration.py
python audits/V45/test_server_flows.py
python audits/V45/test_changes.py
node audits/V45/test_installer_logic.cjs
```

## QA no Roblox

1. Instalar V44 completa, parar Play e substituir os 14 itens V45 sem instâncias duplicadas. Conferir Output e dependências.
2. Truco em celular retrato/paisagem, R6/R15 e acessórios grandes: câmera olhando para a mesa, rosto invisível só para o dono, mão em leque visível, cartas clicáveis e mesa pública descoberta. Conferir sair, reconectar e respawn; câmera, controles móveis e transparência devem voltar ao valor anterior.
3. Loja/visuais/caixas em telas com notch e tamanho de texto ampliado: nenhuma rolagem vertical, páginas alcançam todas as opções, ações e X visíveis. Preço exibido deve coincidir com prompt nativo; testar compras e reentrada no place publicado.
4. Ateliê com imagem/decal público aprovado, ID/link, zoom, arraste e frente/verso: salvar deve equipar no inventário e aparecer durante a partida. Imagem inexistente, privada, pendente/reprovada ou API indisponível deve produzir estado de carregamento/falha, sem sucesso falso.
5. Comunidade em servidor publicado: descrição atual preservada, categorias pagas/grátis com metadados/pacotes reais, diversidade, sem conta Roblox/looks repetidos, nomes de cosplay conservadores, item X e quatro ângulos. Conferir tempo de resposta, quotas de API, páginas vazias, retry e voltar na lista. Thumbnail pode ter cache próprio da Roblox, mesmo quando a descrição atual já foi atualizada.
6. Catálogo/Photo Mode/carrinho/avatar, regras, bots e torneios continuam sujeitos ao QA da V44. Esta alteração não mexe nas regras do Truco ou nos produtos existentes.

## Fontes primárias consultadas

- [ImageLabel](https://create.roblox.com/docs/reference/engine/classes/ImageLabel/IsLoaded): Image aceita imagem/decal; imagens reprovadas não chegam ao estado carregado.
- [BasePart](https://create.roblox.com/docs/reference/engine/classes/BasePart): LocalTransparencyModifier não replica para o servidor.
- [Camera](https://create.roblox.com/docs/reference/engine/classes/Camera): projeção e raios por viewport para selecionar planos 3D.
- [GuiService](https://create.roblox.com/docs/reference/engine/classes/GuiService): TouchControlsEnabled desativa UI/controles de movimento no cliente, restaurados ao sair.
- [AvatarEditorService](https://create.roblox.com/docs/reference/engine/classes/AvatarEditorService): metadados em lote, preços e pacotes por asset.
- [Naruto oficial](https://naruto-official.com/en/special/wallpaper), [One Piece oficial](https://one-piece.com/character/), [Demon Slayer oficial](https://kimetsu.com/anime/risshihen/character/), [Spy×Family oficial](https://spy-family.net/tvseries/): novas referências de personagem. Nome inferido nos itens continua exigindo evidência consistente.

Não foram feitas compras, alterações de preços no painel Roblox ou execução do place no Studio/Studio Lite. Os resultados simulados não certificam renderização/toque nativos nem conformidade jurídica integral. A decisão de monetização permanece na [auditoria V44](../V44/LEGAL_AND_RULES.md).
