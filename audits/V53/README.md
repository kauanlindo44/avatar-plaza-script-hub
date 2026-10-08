# Validação V53

Base: GitHub `main` V52, commit `b397dfe12ebebed3ca61c91df530dbcbc69ca902`. O handoff foi lido antes das alterações. As fontes efetivas locais da V52 foram comparadas com blobs remotos; somente arquivos diferentes e dois módulos novos entram no delta.

| Verificação | Resultado |
|---|---|
| Sintaxe | 76 fontes efetivas Lua 5.4 válidas |
| Avatar/carregamento | 5 cenários em avatar_results.json |
| Catálogo/carrinho | 5 cenários em catalog_results.json |
| Geometria/fluxo de jogos | 4 cenários em game_ui_results.json |
| Servidor de Truco | 5 cenários em server_results.json |
| Regressões selecionadas | 21 cenários em regression_results.json |
| Total de cenários Lua | 40 aprovados |
| Partidas completas de bots dentro de um cenário | 72: 3 variantes × 3 níveis × 8 |
| Instalador | JavaScript real, DOM mínimo, cópia inteira/em partes e hashes |
| Delta | 19 substituições + 2 novos, no máximo 373 linhas |

Os 72 jogos integram um cenário; não somam 72 testes independentes. Esta seleção não representa todos os testes históricos.

## O que foi conferido

Aparelhos amostrados: 320×568, 390×844, 568×320, 667×375, 851×392 e 1920×1080 nos cenários indicados. Regressões do catálogo também usam notch/recorte e coordenadas do Core UI. Alvos de ações ≥44px e saídas ≥48px.

- Roupa 3D sobre R15 sem apagar o outfit; malha/cage/acessório ausente rejeitado; download simulado falho com erro/retry; novo modelo incompleto não substitui o personagem; metadados/cores/formato da cabeça, roupas, expressão, salvar e respawn preservados.
- Photo Mode usa o mesmo carregamento; falha ao recriar para emote preserva o modelo anterior.
- Pacotes não vendidos por peça resolvidos uma vez; posse consultada por jogador; indisponível/valor desconhecido explícito; checkout aguarda resolução; seleção não volta sozinha; fechamento evita consultas em cada edição.
- 400 metadados do catálogo usam ≤40 cards GUI; click em card reciclado abre o item atual; adicionar ao carrinho não muda a skin; experimentar não duplica o item.
- Jogo escolhido, perfis verticais e X sem cruzar ações; sala 2v2, dupla pronta, código e reserva de amigo; três cartas tocáveis, quatro públicas e faixa de ações; countdown e resposta mineira 4→6.
- Quatro participantes humanos exigem confirmação, que é limpa ao reentrar; payload mostra somente mão própria; turno/revisão; amigo verificado em assento oposto; reserva libera após 120s; chegada de outro servidor valida token, convidado e universo.
- Servidor recusa resposta vencida aos 10s. Revanche requer quatro votos e o temporizador do resultado antigo não encerra a nova partida.
- Regras existentes, 72 partidas de bots, progressão, consentimento em torneios, Ateliê e controles de baralho personalizado passam nas regressões selecionadas.
- Instalador offline V53, cache antigo rejeitado, somente delta, rótulos/nome canônico/tipo/local/última linha, campos de fonte ocultos, hashes, cópia exata inteira e reconstrução por partes, fallback de clipboard e fonte, ONLINE verde.

## Limites

Doubles de instâncias/serviços/relógio/geometria em Lua 5.4. `asset_doubles.lua` não baixa assets: mesh, WrapTarget, WrapLayer, AccessoryDescription/GetAppliedInstance e sucesso/falha de PreloadAsync são fixtures explícitos. A configuração protegida é exposta no fixture; no Roblox sua leitura pode ser recusada e a conferência no editor continua necessária.

As reconstruções PIL em preview_layouts.py vêm de bounds reais do código e são diagnósticos, não capturas do Roblox. Não verificam fontes/texturas/cages/touch nativos nem concorrência/latência real. A viagem foi simulada com o payload produzido pelo código; não houve Teleport real.

A checagem de dependências do pacote considera os 76 arquivos efetivos e o legado `08L_COMMUNITY` já requerido pelo place/base anterior, fora do manifesto histórico. A V53 exige a V52 completa.

## Reproduzir

Na raiz, com Python, biblioteca Lua 5.4 e Node.js:

```bash
python audits/V53/test_avatars.py
python audits/V53/test_catalog.py
python audits/V53/test_game_ui.py
python audits/V53/test_servers.py
python audits/V53/test_regressions.py
python audits/V53/build_installer.py
python audits/V53/test_package.py
node audits/V53/test_installer_logic.cjs
```

O teste de regressões extrai cenários históricos e os executa com fontes V53 efetivas. Não muda os arquivos anteriores.

No Roblox, conferir Layered Clothing e gato abacaxi/Gumball/corpos realistas no perfil, catálogo, personagem e respawn, toque físico e câmera 360°, sala com quatro contas, reserva/código de outro servidor e revanche. Não houve compra ou publicação do place. Veja [INSTALL_V53.md](../../INSTALL_V53.md).

