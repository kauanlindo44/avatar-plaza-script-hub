## Como instalar sem duplicar

1. Use a **V73 completa** como base. Se o jogo ainda estiver numa versão mais antiga, conclua as atualizações pendentes no instalador antes deste delta; a V74 contém somente os 28 arquivos acima.
2. Pare Play antes de colar. Um `ModuleScript` em ReplicatedStorage é diferente de um `Script` em ServerScriptService e de um `LocalScript` em StarterPlayer → StarterPlayerScripts. Não cole o código de um no outro.
3. Crie primeiro os 16 nomes novos, uma única instância por nome. Em seguida substitua o conteúdo inteiro dos 12 nomes existentes. Use o botão **Copiar script**; as partes são uma alternativa de cópia e pertencem à mesma instância.
4. Reinicie Play depois de terminar os dois grupos. O contador de cada grupo é independente. O rótulo NOVO/SUBSTITUIR e os números não fazem parte do nome da instância.

As versões e fontes antigas permanecem no histórico. `09A_SHOP_UI`, regras dos tabuleiros, regras/bots do Truco e o recibo `07K10_CARD_COMMERCE` não devem ser recriados nesta instalação. Os servidores de salas recebem somente travas para impedir participação simultânea no Botão do Caos e em outro jogo.

## O que muda

- **Nossos jogos:** biblioteca das implementações do Avatar Catalog & Games. Botão do Caos, Truco, Xadrez e Damas têm cards próprios. No computador, a seleção de outro jogo fica ao lado das opções; no celular há uma navegação com retorno. Rodovia 061 continua fora desta versão.
- **HUD:** Catálogo, Nossos jogos e Patrocinar + IA ganham nomes grandes e cores moderadas. Comunidade e Meus looks continuam diretos. Avatar reúne editar, carregar, emotes, vestindo agora, novo avatar, salvar na conta, restaurar e Roblox Plus. Fotos, Música, Carrinho e a engrenagem de Ajustes mantêm acesso direto. Os atalhos rolam quando a altura exige, sem reduzir o alvo de toque.
- **Patrocinar:** mantém 6 itens por linha × 4 linhas completas, fundos neutros e miniaturas originais, sem camada escura. Os preços ficam mais fortes. Filtros, favoritos, publicação gratuita e compra oficial continuam funcionando.
- **Plus/Pro:** usa os mesmos produtos `3717699383` e `3717699454`. Preço real e disponibilidade vêm do Roblox. Quando a primeira resposta não confirma a venda, confere a lista oficial de produtos desta experiência. Fora de venda, produto de outro jogo e falha de consulta têm diagnósticos diferentes. Nenhum valor é inventado, nenhuma compra é automática e somente o recibo existente concede o benefício.
- **Assistente:** conhece o caminho e as regras do novo minijogo. Criação de looks, planos e atividades anteriores permanecem disponíveis.

## Botão do Caos V1

Abra **Nossos jogos → Botão do Caos**. Participar entra na fila do servidor. Com 2 pessoas, a preparação de 12 segundos começa; entram até 8 na ordem de inscrição. O nono aguarda a próxima rodada. Há 5 segundos de contagem e 150 segundos de disputa. **Treinar sozinho** oferece 90 segundos, sem vitórias ou pontos persistentes.

A arena plana de **96 × 96** fica a aproximadamente **6.000 studs acima da praça**, com oito spawns separados, oito posições verificadas do botão e limites físicos. Não há mudança de Place. O mesmo personagem usado no catálogo entra na arena, após a confirmação de carregamento do avatar pelo runtime existente. Para quem continua no catálogo, a arena também é ocultada localmente.

Aproxime-se do botão e use o `ProximityPrompt` nativo, com teclado/toque. O servidor valida participante, vida, fase e distância de até 6 studs. Uma única pressão ganha 1 ponto. O primeiro botão aparece após 4 segundos; o próximo após 8. Sem pressão por 15 segundos, muda de lugar. Um obstáculo inesperado é registrado no Output e provoca reposicionamento.

| Efeito | Peso inicial | Comportamento da V1 |
|---|---:|---|
| Blaster de energia | 14 | 3 disparos; 35 de dano; alcance 55; intervalo 0,9 s; dura 12 s |
| Bomba de espuma | 8 | 1 lançamento; alcance 50; espera 1,8 s; raio 9; dano 45, inclusive ao lançador; ferramenta expira em 10 s |
| Bomba Nuclear | 4 | 1 por rodada; adversário fixo; alerta e marcador por 4 s; somente o alvo pode ser eliminado; escudo bloqueia |
| Congelamento | 12 | Um adversário com velocidade 0 por 3 s |
| Supervelocidade | 12 | Velocidade 24 por 9 s; base da arena 16 |
| Escudo | 10 | Bloqueia 1 dano ou bomba nuclear; dura 12 s |
| Troca de posições | 10 | Destinos conferidos e proteção de dano de 0,75 s |
| Superpulo | 8 | Altura 1,8× por 8 s; `JumpPower` usa √1,8 e `JumpHeight` usa 1,8 |
| Onda de impacto | 8 | Raio 14; deslocamento limitado e seguro, sem dano |
| Botão traiçoeiro | 6 | Velocidade 9 por 5 s; mantém o ponto do botão |
| Cura surpresa | 4 | Recupera até 50 de vida, no máximo 100 |
| Apagão | 4 | 5 s somente no cliente dos participantes ativos; HUD legível |

Pesos são recalculados entre efeitos elegíveis. Não há repetição consecutiva e efeitos que precisam de adversário não entram no treino individual. O sorteio é gratuito e não possui produtos, moedas, apostas ou ranking.

Eliminação com sua ferramenta ou sua bomba nuclear rende +2. Vence o último vivo; no prazo, vencem os líderes empatados entre os sobreviventes. Sem vivos, não há vencedor. O bônus +5 vem **depois** da definição dos vencedores. A tela de resultados dura 10 segundos. Continuar inscreve explicitamente na próxima fila; voltar ao catálogo encerra a participação.

Eliminados podem assistir com a câmera e alternar sobreviventes ou voltar. Respawn não recoloca alguém na rodada. Armas, efeitos e foco de câmera/streaming são limpos no retorno. Ferramentas anteriores ficam guardadas no servidor e voltam à mochila; se a mochila nativa estiver reaparecendo, continuam preservadas até ela existir.

## Diagnóstico

- `[BC][BOOT]`: falta de base/módulo, tipo incorreto ou `BC_Server` duplicado.
- `[BC][CLIENT]`: cliente duplicado ou servidor incompleto. Confira também `BC_Request`, `BC_Push` e `BC_Fire` gerados em PracaKit → Remotes.
- `[BC][ENTRY]` / `[BC][RESTORE]` / `[BC][RETURN]`: entrada, restauração ou espera de personagem/mochila. O runtime do avatar continua responsável por reaparecer com o look salvo.
- `[BC][BUTTON]` / `[BC][EFFECT]`: posição bloqueada ou falha do efeito. O ciclo tenta continuar; o ponto aceito é preservado.
- `[BC][TICK]` / `[BC][RECOVERY]`: erro inesperado da rodada; restaura participantes e reconstrói a arena/conexão do botão. `PracaKit.BC_ServerError` identifica uma recuperação que também falhou.
- `[BC][AUDIO]`: sinal curto nativo indisponível naquele aplicativo. A partida e os avisos visuais continuam. Conferir som/volume no Roblox.
- `[Planos V74]`: produto, experiência, método e etapa exatos. Os IDs precisam ser **Developer Products desta mesma experiência** e estar disponíveis na Roblox. Confirmar no jogo publicado; esta entrega não verifica os produtos na sua conta.

## Verificação realizada e pendências

**180 cenários simulados**, em 12 suítes, executam código Lua compatível com Luau com contratos simulados de serviços e geometria. Há conferência de sintaxe/hashes de 171 fontes, da integridade histórica, do JavaScript real do instalador e de 7 geometrias de tela: 320×568, 390×844, 568×320, 667×375, 851×392 com recortes, 1280×720 e 1920×1080. As 21 imagens de auditoria são reconstruções do layout, com arte ilustrativa; não são capturas do Roblox.

**PENDENTE DE TESTE NATIVO:** pelo GDD, o minijogo ainda não pode ser considerado aprovado para lançamento. Instalar no Studio Lite/Roblox e conferir:

1. **2 jogadores reais**, duas rodadas completas: inscrições, pressão simultânea, vitória, saída, retorno e ausência de ferramentas/efeitos residuais.
2. **8 jogadores + o nono na fila**, desconexão/reset e troca com Truco/Xadrez/Damas. Confirmar que o catálogo continua normal para quem não entra.
3. **Celular e computador:** joystick/pulo nativos, mira/disparo, prompts, recortes, textos, mochila, espectador, câmera e carregamento da arena. Conferir R6/R15 e corpos/roupas personalizados, incluindo o gato de abacaxi.
4. **Desempenho no aparelho de referência:** medir FPS e memória durante efeitos. Meta do GDD: 30 FPS; nenhum resultado físico foi medido aqui.
5. **Roblox:** confirmar permissões de áudio, streaming e produtos Plus/Pro. Atualizar o questionário de maturidade para refletir as eliminações estilizadas e o restante da experiência. Isso depende do painel do criador; esta entrega não altera a classificação do jogo.

Relatório e matriz: [audits/V74/README.md](audits/V74/README.md). Publicar os scripts no GitHub não instala nem publica automaticamente a experiência Roblox.
