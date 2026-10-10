# Auditoria V54

Base conferida no GitHub: V53, commit `f99494623aa804cf43bd04712e50e33220a19b26`, árvore `59ea8469bcb235943c933c5c37a97b21115a26a4`. As 76 fontes efetivas da base local correspondiam aos blobs remotos antes das alterações. Nenhuma versão histórica foi reescrita.

A entrega tem **18 substituições e 3 criações**, em 21 locais de instalação, com 19 fontes diferentes. As regras têm a mesma fonte em ReplicatedStorage e ServerScriptService, cujos originais já eram exigidos pelos scripts 07A_CHESS/07B_CHECKERS e pela nota da V37. Após instalar, há 79 nomes de fonte efetivos. Cada fonte V54 fica abaixo de 400 linhas.

## Verificação executada

Os cenários executam as fontes reais em **Lua 5.4 com serviços e objetos Roblox simulados**. Não equivalem à execução no motor Roblox. As reconstruções visuais derivam das posições/tamanhos criados pelo Lua; não renderizam avatares, assets, fontes Roblox ou gradientes nativos.

| Grupo | Arquivo | Casos |
|---|---|---:|
| Jogos e controles | game_ui_results.json | 6 |
| Avatar/roupas/prévias | avatar_results.json | 5 |
| Catálogo/carrinho | catalog_results.json | 5 |
| Salas/remotes Truco | server_results.json | 5 |
| Regressões | regression_results.json | 22 |
| Looks/comunidade/salvar/carrinho/cores | utility_results.json | 5 |
| Persistência da skin | persistence_results.json | 5 |
| Dama/xadrez | rules_results.json | 8 |
| **Total de cenários Lua** | | **61** |

Um cenário inclui 72 partidas completas de bots, distribuídas entre variantes e níveis. Há verificações do controlador real de jogos para promoção e cancelamento da fila, informações privadas das cartas, direitos de compra, reenquadramento 360°, erro/recarregar, atualização/reuso dos cards e ausência de alteração do avatar ao abrir o carrinho. Isso não comprova força competitiva dos níveis contra jogadores humanos.

Geometria amostrada: 320×568, 390×844, 568×320, 667×375, 851×392 e 1920×1080. Alvos principais com pelo menos 44px; X de 48px, margens dos controles Roblox, cutouts e insets recalculados. Prévias, ações e itens ficam separados. A reconstrução visual revelou descrições excessivas em paisagem e ordem ambígua do aro/feltro; ambos foram corrigidos. Gradientes são normalizados para conservar as cores após a multiplicação pela cor do objeto.

Os cenários de persistência verificam sessão nova, corpo nativo, emotes, escalas, falha antes da aplicação, coalescência de gravações, flush de saída/shutdown, token de sessão, callback UpdateAsync repetido, indisponibilidade do armazenamento e proteção de um look cuja restauração falhou. Um teste do controlador confirma que apenas abrir o catálogo não grava o perfil padrão por cima dessa skin.

O JavaScript real do instalador é executado em Node com DOM mínimo: cópia integral/em partes dos 21 itens, SHA-256, rótulos NOVO/SUBSTITUIR, local exato de cada cópia das regras, código oculto, cópia manual quando clipboard falha, pacote offline, sincronização online e fechamento durante carga. Este teste não renderiza CSS.

## Reproduzir

Na raiz do repositório, com Python, Node e liblua5.4:

```bash
python audits/V54/test_game_ui.py
python audits/V54/test_avatars.py
python audits/V54/test_catalog.py
python audits/V54/test_servers.py
python audits/V54/test_regressions.py
python audits/V54/test_utilities.py
python audits/V54/test_persistence.py
python audits/V54/test_rules.py
python audits/V54/build_installer.py
python audits/V54/test_package.py
node audits/V54/test_installer_logic.cjs
```

Com Pillow instalado, `python audits/V54/preview_layouts.py` produz reconstruções diagnósticas. Os dados de jogadores/outfits do teste são fixtures sintéticas; o produto continua usando a comunidade real já disponível no servidor.

## Limites e validação no Roblox

Não houve compra, teste de toque em aparelho, viagem entre servidores, leitura/gravação em DataStore Roblox nem publicação do place. Confira no jogo publicado a aparência final de roupas em camadas/cages, corpos específicos, diálogo de compra, persistência após reentrada/respawn, mesas com quatro contas e efeitos no aparelho. Configuração protegida de Layered Clothing continua dependendo do editor. IDs e preços de passes/produtos permanecem os existentes; compra direta, Ateliê e visuais salvos continuam.

O token impede que uma sessão antiga grave depois de outra assumir, mas não recupera alterações que ainda não foram gravadas antes de queda ou transferência. Falhas de armazenamento ficam visíveis, mantendo o registro anterior; reentrar com uma skin só pode ser confirmado após o teste real de gravação/leitura.

Fontes: [RESEARCH.md](RESEARCH.md). Lista exata: [INSTALL_V54.md](../../INSTALL_V54.md).
