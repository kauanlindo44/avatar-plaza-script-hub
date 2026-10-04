# Auditoria V46 — Avatar Plaza

Base remota: main `1033f19c840b794a3df2004c993572f222f37c0f`, árvore `7dbcdfb1a670b480c9217a966b943adcc5f5ac35`. Os 78 blobs da publicação V45 foram comparados com os hashes Git locais antes das alterações: nenhuma divergência. O handoff já havia sido lido integralmente nesta sessão. A foto `786acbe5-54a4-4421-ac5c-43c58e6c5973.jpg` foi aberta e inspecionada: referência do catálogo, prévia à esquerda, cinco miniaturas por linha e duas linhas. Ela não mostra um bug nativo de Truco.

Entrega: **30 substituições, zero novas instâncias**, cumulativas desde a V44. V44 e V46 estão no HTML offline; o manifesto online mantém a V45 histórica. Snapshot: 56 fontes. `08B_AVATAR_DATA` é a substituição da dependência original, não uma nova instância. `09A_SHOP_UI`: exatamente quatro partes concatenadas no mesmo ModuleScript, sem bloco inteiro exposto. [Instalação](../../INSTALL_V46.md).

## Causas corrigidas

- A câmera do Truco não conhecia a área livre entre HUD e mão. Ela agora projeta os cantos dos quatro lugares das cartas e ajusta posição/distância nessa área, conservando câmera por arraste e Centralizar. A mão 3D calcula tamanho pela altura do espaço reservado; os três botões ficam abaixo dela. O toque só joga ao soltar sem arraste. A validação de qualquer carta/turno continua no servidor.
- A cadência de 1,15–1,4 segundo não dava tempo de acompanhar bots. Contra bots usa 2,8 segundos por decisão e pausa de 3,2 segundos após completar vaza. Entre mãos há 3,5 segundos. As jogadas humanas agendam a próxima decisão. A interface remove o tema Treino e gritos de decoração; chamadas válidas usam TRUCO/SEIS/NOVE/DEZ/DOZE conforme os perfis existentes.
- Loja abria em caixas ainda vazias, com ações pouco explícitas. Agora abre em Loja e explica Minhas caixas/Meus visuais, comprar, equipar e abrir. Arte de frente/verso recebeu figuras, coroas, constelações e vitrais originais, com índices e naipes protegidos. Sem alteração de IDs, preços, inventários ou recibos.
- O Ateliê recriava a imagem a cada zoom/arraste, reiniciando o carregamento. A imagem é reutilizada; Carregar/Recarregar forçam nova tentativa. PreloadAsync e IsLoaded determinam prontidão, após oito segundos há fallback rbxthumb, após mais oito há mensagem de falha. ID/link e estado thumb são persistidos e validados; uma imagem que não carrega não recebe confirmação de salvamento.
- Corpo começava em partes individuais normalmente fora de venda; agora começa em pacotes BodyParts/DynamicHeadAvatar. Filtro de roupa não substitui os tipos de pacote ao trocar para Corpo; gratuitos não são removidos pela regra de preço mínimo do catálogo.
- Detalhe do catálogo cobria a prévia e exigia procurar as ações. Agora é um popover com Comprar/Experimentar e X de 48px. Mudanças na prévia são aplicadas ao personagem após debounce; AcceptApplied não provoca loop, respostas antigas não sobrescrevem novas edições. Um look escolhido fora do catálogo é aplicado ao retornar.
- Comunidade é uma janela limitada de descrições reais: primeiro lote de até 50, botão manual Carregar mais, máximo 100 registros com descarte em grupos de dez, 50 slots GUI, 600 assinaturas recentes. Rolagem não inicia nova busca. Erros preservam botão de retry. Metadados de amigos e nomes têm cache; no máximo quatro consultas de descrição simultâneas. Pagos/gratuitos exigem preços conhecidos, incluindo pacotes de corpo. Diversidade depende dos perfis encontrados, não de skins inventadas.
- Photo Mode usa seleção direta com raycast nas partes do modelo, manequim, mover/girar, alças coloridas de 44px, histórico e confirmação. Rig do cenário executa emote real R15; congelamento captura Transform em ordem XYZ coerente e permite continuar editando. Saída durante criação/reprodução assíncrona não reabre o cenário. Alças e Highlight são destruídos ao fechar. Título transparente elimina o bloco ao lado do X. Cinco cenários e luz foram melhorados com geometria/cores próprias.

## Referências verificadas

Foi pesquisada a referência pedida em tempo real. A busca de imagens não forneceu dez fotos distintas atuais do Photo Mode; páginas de imagens antigas e títulos de vídeos não foram tratados como imagens inspecionadas. Foi possível baixar a demonstração pública do tópico de 2023 abaixo, extrair e inspecionar dez quadros. Observações: manequim ao lado do avatar, selecionar membro, alternar mover/girar, alças de eixos, Reset/Apply fixos, câmera livre. A implementação é própria; não foram copiados arquivos de arte, áudio ou scripts do jogo. Esses dez quadros não comprovam como está a interface em outubro de 2026.

- [Demonstração pública do editor CAC](https://devforum.roblox.com/t/pose-editor-similar-to-catalog-avatar-creator/2701661), [vídeo vinculado](https://devforum-uploads.s3.dualstack.us-east-2.amazonaws.com/uploads/original/5X/3/4/7/f/347f7107f732c3b4def6a728a0da976ae0c3c71e.mp4).
- [CatalogSearchParams](https://create.roblox.com/docs/reference/engine/datatypes/CatalogSearchParams): tipos de pacote/asset e busca.
- [Camera](https://create.roblox.com/docs/reference/engine/classes/Camera): projeção, câmera e raios por viewport.
- [Workspace](https://create.roblox.com/docs/reference/engine/classes/Workspace): raycast para seleção de parte.
- [Humanoid](https://create.roblox.com/docs/reference/engine/classes/Humanoid): PlayEmoteAsync no modelo de avatar.
- [CFrame](https://create.roblox.com/docs/reference/engine/datatypes/CFrame): ToEulerAnglesXYZ compatível com a recomposição XYZ da pose.
- [ContentProvider](https://create.roblox.com/docs/reference/engine/classes/ContentProvider): pré-carregamento de imagem; [ImageLabel](https://create.roblox.com/docs/reference/engine/classes/ImageLabel): IsLoaded.
- [Players](https://create.roblox.com/docs/reference/engine/classes/Players): GetFriendsAsync e descrição atual de avatar.
- [MegaJogos — próprias regras de Truco](https://www.megajogos.com.br/truco-online/regras): três cartas, baralho de 40, chamadas e liberdade de carta. Perfis/ties mantêm as regras e fontes documentadas na [V44](../V44/LEGAL_AND_RULES.md), incluindo as variantes paulista, mineira e goiana. Não foi acrescentada regra de maior carta obrigatória.

## Verificações

| Suíte | Casos | Escopo |
|---|---:|---|
| test_v46.py | 13 | Sintaxe/limites das 56 fontes, catálogo 5×2, X, HUD, prévias, mundos, comunidade, pose e xadrez. |
| test_games_commerce.py | 9 | Perfis reais, 72 partidas, mãos privadas, moedas, dez produtos, persistência e torneios. |
| test_integration.py | 15 | Avatar/carrinho, privacidade, preços, comunidade real, layouts, Ateliê e controlador Photo Mode. |
| test_server_flows.py | 5 | Salas, fechamento, duplas, chegada, reconexão e torneios. |
| test_changes.py | 6 | 400 combinações carta/visual, páginas fixas, imagem indisponível, duas linhas, pacote gratuito, mão 3D/restauração. |
| test_features.py | 7 | Cantos públicos/privados em cinco telas × quatro lugares, câmera/seleção, ritmo, 50/100/retry, auto Apply, Corpo, animação/congelamento/pose e concorrência nativa simulada. |
| test_installer_logic.cjs | 1 | 30 hashes, quatro partes do 09A, base V44 offline, versão/cache, copiar, adulteração e fechamento durante carga. |
| **Total** | **56** | Serviços e UI simulados; não é execução do place. |

```sh
python audits/V46/build_installer.py
python audits/V46/test_v46.py
python audits/V46/test_games_commerce.py
python audits/V46/test_integration.py
python audits/V46/test_server_flows.py
python audits/V46/test_changes.py
python audits/V46/test_features.py
node audits/V46/test_installer_logic.cjs
```

## QA nativo pendente

1. Após substituir os 30 itens e a dependência 08B, iniciar Play sem nomes duplicados. Conferir Output e serviços da base V44.
2. Truco retrato/paisagem, quatro lugares, R6/R15, acessórios grandes: cantos e índices das três cartas visíveis, mesa legível, placar/ações, arraste/centralizar, qualquer carta, espera de bots, vaza concluída, saída/respawn/reconexão. Projeção simulada não comprova nitidez de pixels ou comportamento de todos os avatares.
3. Loja e inventário em celular com notch: todas as páginas alcançáveis, comprar/equipar/abrir explícitos, nenhum scroll vertical. Preço no cliente deve coincidir com o prompt regional/personalizado.
4. Passe Ateliê comprado: reabrir e conferir desbloqueio; imagem/decal público aprovado com Carregar, Recarregar, zoom, arraste, frente/verso, salvar/equipar, persistência e partida. IDs inexistentes, privados ou moderados devem falhar com retry e sem salvar sucesso falso.
5. Catálogo e Corpo em place publicado: 5×2 em paisagem, descrições compactas, comprar nativo, experimentar/remoção/escala no personagem com preservação; Restaurar com confirmação. Disponibilidade e latência dos pacotes ainda dependem da API.
6. Comunidade: lote real, itens compatíveis com a descrição, preço desconhecido, gratuitos/pagos, diversidade, botão manual, descarte/voltar, limites de API, erro/retry e quatro ângulos. Thumbnail pode manter cache da Roblox diferente da descrição recém-consultada.
7. Photo Mode: eixos/drag por membro e manequim, Aplicar/Cancelar/undo/redo, R6 e R15, emotes nativos R15, velocidade, congelar, sete animações acessíveis sem scroll, cinco fundos, 360 graus, luz, captura e saída durante cargas. Alças projetadas precisam de teste tátil real e editor não oferece toda a edição de acessórios do CAC.

Não foram executados Studio/Studio Lite, compras, price changes ou publicação de place. IDs e nomes públicos de compras permanecem; caixas continuam com escolha conhecida sem sorteio, conforme a decisão técnica documentada na V44. Isso não certifica renderização, conformidade integral ou quotas reais de serviços.
