# Auditoria V76

Base: V75 publicada, commit `b7bfbea37b52765f608e4384c2699193c4e53daf`. Delta: **2 novos + 12 substituições**, máximo **397 linhas** por fonte; **175 fontes efetivas**.

## Resultado

- **190 cenários simulados em 14 suítes.** Fontes reais executadas com Lua 5.4 e doubles de serviços Roblox. Três testes da disposição anterior do HUD foram substituídos por verificações de destinos, geometria e toque da V76; testes de regras foram mantidos.
- **175 fontes compiladas**, hashes declarados atuais conferidos e **1.003 caminhos históricos preservados** byte a byte. Onze hashes declarados divergentes na V37 continuam registrados como herança. Uma fonte efetiva legada não tem hash declarado.
- **Restrição real do processo:** seccomp recusou sockets e execução de comandos com EPERM; Lua sem acesso ao shell, ambiente ou arquivos arbitrários. Memória de 1 GiB e CPU de 60 s por processo. Isso limita o teste; não certifica o servidor Roblox.
- **Instalador:** JavaScript real em Node com DOM simulado; cópia integral/partes, hashes, fallback, nomes/tipos/locais e contadores verificados. Esses testes não renderizam CSS.
- **21 reconstruções visuais:** HUD, +, estúdio, fundos, emotes, comandos e Truco em computador/celular em pé/deitado. Mídia ilustrativa, sem renderização Roblox, identificada nas imagens.
- **Chromium não executado:** o pacote Playwright estava disponível; o download do navegador recebeu arquivos inválidos para ZIP. O relatório registra not_run.

## Cobertura

| Área | Evidência |
|---|---|
| HUD | 15 ações/destinos, alvos mínimos de 44 px, sete geometrias com/sem toque, controles visíveis sem sobreposição e região de pulo reservada |
| Referência | Catálogo/Patrocinar no alto; Comunidade/Emotes à esquerda; Looks/Carregar à direita; utilidades e +. Telas baixas recolhem funções secundárias no + |
| Avatar | Corpo abre os controles existentes; Carregar/Vestindo/Restaurar conservam cores; nenhuma aplicação/compra automática |
| IA | Plus 3717699383 e Pro 3717699454, chave Studio preservada para Plus; chat, cancelamento, lotes e pesquisa cobertos pelas regressões |
| Produtos | Preço público não autoriza produto de outra experiência; 200 preflights usam duas consultas de detalhes e uma listagem oficial; IDs não configurados são recusados |
| Recibos | 100 repetições não estendem a validade; produto incompatível, identificador vazio e UserId inválido são recusados; um único proprietário de ProcessReceipt |
| RPC da IA | 1.000 prompts repetidos abrem um prompt; produto/preço/recibo forjados no payload não concedem plano |
| Payload | NaN, infinitos, ciclos, objetos, UTF-8 inválido, profundidade/tamanho e chaves inválidos recusados; 16 mensagens e carrinho de 100 itens continuam válidos |
| Frequência | 1.000 chamadas alternando 15 ações não ultrapassam o lote compartilhado; cancelamento funciona; 25ª chamada concorrente recusada; liberação duplicada não corrompe contagem |
| Patrocinar | 1.001 atualizações simultâneas produzem uma chamada ao feed; dados cíclicos recusados antes de gravar. RPC/guarda reais com doubles do feed e armazenamento |
| Fundos/emotes | Fundos 3 colunas × até 3 linhas; emotes 5×4; paginação e compra separada de experimentar |
| Câmera/cópia | LocalScript real do Photo Mode: 50 mudanças mantêm posição/direção da câmera e pivot da mesma cópia; avatar do mapa preservado |
| Captura | 100 toques iniciam uma captura; timeout recupera a interface; saída restaura câmera/HUD anteriores |
| Truco | Corrigida a sobreposição de carta pública e mão em telas baixas; caso com quatro cartas públicas testado; regras/bots/relógios preservados |
| Xadrez/Damas | Motores, bots, sessões, relógios e regras byte a byte na base; regressões de partida e composição mantidas |
| Mapa/Caos | Vale inicial, cenário reduzido, fila, arena aberta, bomba de alvo único, empurrão e restauração da V75 mantidos e cobertos |

## Legado

`08L_COMMUNITY` é um módulo original do place, fora das fontes arquivadas, já documentado nas V43/V53/V61/V74. O delta não recria seus dados/códigos. A instalação exige V75 completa, incluindo esse módulo existente. Os testes usam seu contrato simulado; a implementação original não pôde ser auditada neste repositório.

## Pesquisa

Metadados de trinta vídeos de 2026 conferidos e vinte referências selecionadas. **Nenhum assistido integralmente:** storyboards retornaram HTML, legendas vazias/ausentes e mídia não decodificada. O critério de vinte gameplays completos, atuais e analisados minuto a minuto permanece pendente. Não há certificação de cópia integral do Photo Studio. Consulte [RESEARCH.md](RESEARCH.md), [video_references.json](video_references.json) e [PROMPT_REVIEW.md](PROMPT_REVIEW.md).

## Reproduzir

Na raiz do repositório, em Linux com Python, liblua5.4, Node e Pillow:

```bash
python audits/V76/test_sandbox.py
python audits/V76/run_checks.py
python audits/V76/build_installer.py
python audits/V76/test_package.py
node audits/V76/test_installer_logic.cjs
node audits/V76/test_counters.cjs
node audits/V76/test_installer_browser.cjs
python audits/V76/export_layouts.py hud tools photo background studio commands truco
python audits/V76/render_layouts.py
python audits/V76/build_zip.py
```

## Pendente no Roblox

Sem execução nativa no Studio Lite, aparelho ou servidor publicado. Validar renderização real, controles físicos/toque, R6/R15/corpos, captura/galeria, produtos/preços/recibos reais, streaming, áudio, multiplayer e FPS/memória. A publicação entrega scripts no GitHub e não instala/publica o place automaticamente. Nenhum teste garante ausência absoluta de falhas.
