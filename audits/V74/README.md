# Auditoria V74 — Botão do Caos V1 e navegação

Base verificada: GitHub `kauanlindo44/avatar-plaza-script-hub`, `main`, commit `144dcc4d8168536b87d8e046b117a965714c5312` (V73). O manifesto resolve 155 fontes anteriores; o delta contém 16 novos nomes e 12 substituições, totalizando 171 fontes efetivas. Nenhuma pasta histórica é editada. O maior arquivo do delta tem 280 linhas, abaixo do teto de 400.

## Implementação

| Pedido | Implementação | Fontes principais |
|---|---|---|
| Patrocinar com fundo discreto e preço explícito | Cards neutros; imagens originais; preço mais forte; grade 6 × 4 preservada | `09C5_UGC_STORES` |
| HUD maior, profissional e claro | Ações nomeadas; grafite moderado; Avatar agrupa atalhos; engrenagem identificada | `07G_HUB_UI` |
| Categoria de jogos e propriedade clara | Biblioteca Nossos jogos; cards próprios; painel lateral no PC; navegação com retorno no celular | `07H11_GAME_LIBRARY`, `07H1_GAME_LOBBY`, `07H_GAME_UI` |
| Arena independente e avatar preservado | Piso 96 × 96 a 6.000 studs de altura; ocultação local para não participantes; personagem atual e clearance nativo; confirmação do runtime | `BC_ArenaBuilder`, `BC_PlayerState`, `BC_Integration`, `BC_Server` |
| Fila e ciclo do GDD | FIFO até 8, nono espera; 12 s + 5 s + 150 s + 10 s; treino separado 90 s | `BC_Queue`, `BC_RoundManager`, `BC_Config` |
| Botão justo e recuperação | ProximityPrompt; distância/vida/fase no servidor; trava atômica; sem repetição de posição consecutiva; verificação de obstáculos | `BC_ButtonController`, `BC_ArenaBuilder` |
| 12 efeitos e combate | Pesos/elegibilidade; sem repetição; nuke 1×; direção/token/munição/cadência/raio validados; escudo e temporizadores | `BC_EffectRegistry`, `BC_EffectExecutor`, `BC_Combat` |
| Saída, resultado e espectador | Vitória entre sobreviventes antes do +5; empate; zero vivos; confirmação de saída; câmera; reinscrição somente explícita | `BC_RoundManager`, `BC_HUD`, `BC_Client` |
| Não prejudicar catálogo/outros jogos | Guarda e devolução de ferramentas; espera por mochila de respawn; efeitos/câmera/foco restaurados; bloqueio de salas simultâneas e de edição durante a rodada | `BC_Integration`, `07G_SETTINGS_SERVER`, `07G3_PERSONAL_TOOLS`, `09B5_AVATAR_RUNTIME`, servidores de salas |
| Falha de Plus/Pro | Consulta do produto e lista oficial, IDs alternativos da resposta nativa, distinção entre fora de venda/experiência errada/serviço incompleto; sem concessão pelo prompt | `09I25_PLAN_PRODUCTS`, `09I7_ASSISTANT_PROFILE`, `09I_ASSISTANT_SERVER` |
| Ajuda integrada | Caminho e regras concretas do novo minijogo | `09I9_GAME_GUIDE` |

Onda de impacto usa deslocamento limitado de até 8 studs, validando destino/obstáculo, em vez de impulso físico ilimitado. A força fica previsível no celular e não produz dano. Superpulo interpreta 1,8× como altura: a potência recebe √1,8. Essas decisões implementam os limites do GDD sem alterar seus parâmetros.

A indisponibilidade dos planos anteriores não é atribuída ao usuário. O código antigo dependia de `IsForSale==true` em uma única resposta e mostrava um motivo genérico. A V74 distingue as respostas e aceita uma confirmação de produto desta experiência quando esse campo é omitido. Um `IsForSale=false` explícito continua bloqueando. Os produtos efetivos, a venda e a compra só podem ser conferidos no Roblox.

## Verificações executadas

- `python audits/V74/run_checks.py`: **180 cenários** em 12 suítes, executando as fontes efetivas em Lua 5.4 compatível, com serviços/instâncias/relógio/colisões de teste. Inclui 23 cenários específicos do novo modo e 7 de interface/integração/planos/efeitos locais.
- `python audits/V74/test_package.py`: compila 171 fontes, verifica hashes, integridade da base, metadados/locais e único recibo. Confere que regras, bots e relógios dos jogos existentes não mudaram.
- `node audits/V74/test_installer_logic.cjs` e `node audits/V74/test_counters.cjs`: JavaScript real do HTML com DOM simulado. Confere fontes, cópia inteira, fontes divididas, recuperação offline/online, hashes e contadores independentes 1/16 NOVO e 1/12 SUBSTITUIR. Não testa CSS no navegador.
- `python audits/V74/export_layouts.py` e `render_layouts.py`: 21 reconstruções para revisar Patrocinar, HUD, biblioteca, seleção de jogo e fila/partida/resultados do Caos. Sete geometrias são também verificadas nas suítes. Mídia e avatares das reconstruções são ilustrativos.

As colisões dos testes verificam caixas e interseções específicas; não são um motor físico. A mira/disparo usa fixtures explícitas de colisão, sem alegar medição de rede, precisão física, latência justa ou desempenho real. A filtragem/chats dos jogos anteriores permanece no TextChatService e conserva sua validação já existente.

## Matriz do GDD

Todos os itens abaixo permanecem **PENDENTES DE TESTE NATIVO**, mesmo quando há cobertura simulada.

| GDD | Cobertura simulada realizada | Conferência nativa necessária |
|---|---|---|
| T01 · uma pessoa | Espera competitiva e treino explícito de 90 s | Entrada real e feedback no celular |
| T02 · duas pessoas | Preparação/contagem/rodada/pontuação | Duas contas reais, partida completa |
| T03 · oito pessoas | Oito participantes e spawns distintos | Streaming, espaço e estabilidade |
| T04 · nona pessoa | FIFO mantém a nona na próxima fila | Saída/reinscrição sob rede real |
| T05 · pressões simultâneas | Uma reivindicação e um ponto | Latência e percepção de justiça |
| T06 · eliminado pressiona | Servidor rejeita | Prompt nativo após morte/reset |
| T07 · arma atinge catálogo | Validação de elenco impede dano | Física/raycast e isolamento reais |
| T08 · alvo de nuke | Alvo fixo, 4 s, sem troca retroativa | Marcador, aviso e visibilidade |
| T09 · escudo | Um bloqueio de dano/nuke; duração | Sincronia visual sob latência |
| T10 · desconexão | Fila/participante saem; alvo cancelado | Desconectar as contas de verdade |
| T11 · cronômetro zero | Sobreviventes/empate antes do +5 | Tempo e atualizações de rede |
| T12 · desistência | Restaura personagem e ferramentas | Inventário e câmera nativos |
| T13 · duas rodadas | Novo ID, sem poderes/armas anteriores | Duas partidas reais consecutivas |
| T14 · celular menor | Sete geometrias; alvos ≥44 px | Toque, recortes, joystick e pulo |
| T15 · R6/R15 | Identidade/altura nativas preservadas | Corpos personalizados e ferramentas |
| T16 · falha de efeito | Falha injetada não prende botão; recuperação reinicia conexão | Falha de recurso real e Output |
| T17 · mudar de minijogo | Travas de participação e limpeza | Trocar entre os quatro jogos |
| T18 · desempenho | Nenhuma medição física | Medir FPS/memória no aparelho; meta 30 FPS |

**Aprovação de lançamento: PENDENTE.** Não houve acesso ao motor Roblox/Studio Lite, aparelho físico, conta do criador ou servidor publicado. A entrega é uma implementação revisada e verificável para instalação/teste; não comprova os critérios nativos de conclusão do GDD.

## Segurança, armazenamento e limites

- Sem produtos, apostas, moeda, ranking ou serviço pago no Caos. Pontos e resultados do modo são da rodada, sem novos DataStores.
- Não aceita ID de efeito, dano, horário, vítima ou pontuação do cliente. Raycast parte da posição do personagem; arma exige token vigente, estar equipada, munição, cadência e pertencimento à rodada.
- Efeitos visuais são locais e limitados. Apagão pertence à câmera, sem alterar Lighting/Gravity globais; dano fica no servidor. Avisos e animações não controlam o relógio.
- Em erro inesperado do Tick, restaura participantes e reconstrói arena/conexão. Em espera da mochila nativa, as ferramentas originais permanecem guardadas até o evento nativo concluir o retorno.
- Os IDs de planos existentes e o único ProcessReceipt são preservados. Nenhuma compra, preço ou assinatura nova foi ativada por esta entrega.

## Fontes oficiais consultadas

- [ProximityPrompt](https://create.roblox.com/docs/ui/proximity-prompts): interação nativa e parâmetros.
- [Fronteira cliente-servidor](https://create.roblox.com/docs/scripting/security/client-server-boundary): validar pedidos, distâncias e privilégios no servidor.
- [Raycasting](https://create.roblox.com/docs/workspace/raycasting): origem/direção e filtros do disparo.
- [RemoteEvents/RemoteFunctions](https://create.roblox.com/docs/scripting/events/remote): transporte de pedidos/estado.
- [Player](https://create.roblox.com/docs/reference/engine/classes/Player): foco adicional e streaming.
- [Model](https://create.roblox.com/docs/reference/engine/classes/Model): persistência por participante e transformações.
- [Developer Products](https://create.roblox.com/docs/production/monetization/developer-products) e [MarketplaceService](https://create.roblox.com/docs/reference/engine/classes/MarketplaceService): informações/lista de produtos, prompt oficial e recibo.
- [Maturidade](https://create.roblox.com/docs/production/promotion/content-maturity): atualizar o questionário com o conteúdo efetivo. A classificação da experiência não foi alterada aqui.
- [Studio Lite — FAQ](https://devforum.roblox.com/t/studio-lite-tips-and-faq/3191419/): a página apresentou bloqueio antirrobô nesta consulta; não foi usada como comprovação de compatibilidade.

Não foram usados scripts executáveis de Toolbox ou de terceiros. As imagens de auditoria são produzidas a partir de nossas próprias instâncias de interface.
