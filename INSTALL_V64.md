# Instalação V64 — 2 novos + 24 substituições

Requer V63 completa. V64: 2 módulos NOVOS + 24 SUBSTITUIÇÕES. Pare Play, crie os dois novos no ServerScriptService, substitua as fontes completas e reinicie. 07P1_CAPTURE_ENGINE: substituir em ReplicatedStorage ou criar se ausente. Não use NOVO/SUBSTITUIR no nome. Nenhum passe/produto novo. Guia: INSTALL_V64.md.

## Criar primeiro — NOVOS

| Nome exato | Tipo | Local | Linhas |
|---|---|---|---:|
| `09B11_DATA_BUDGET` | ModuleScript | ServerScriptService | 21 |
| `09B12_PRIVATE_LOOKS` | ModuleScript | ServerScriptService | 42 |

## Substituir nas instâncias existentes

| Nome exato | Tipo | Local | Linhas |
|---|---|---|---:|
| `07G2_LOCAL_WORLDS` | ModuleScript | ReplicatedStorage | 65 |
| `07G4_WORLD_SCENERY` | ModuleScript | ReplicatedStorage | 134 |
| `07G6_WORLD_DETAILS` | ModuleScript | ReplicatedStorage | 72 |
| `07K15_TRUCO_TABLE` | ModuleScript | ReplicatedStorage | 113 |
| `07K5_TRUCO_UI` | ModuleScript | ReplicatedStorage | 167 |
| `07P1_CAPTURE_ENGINE` | ModuleScript | ReplicatedStorage | 44 |
| `09A1_SHOP_LAYOUT` | ModuleScript | ReplicatedStorage | 192 |
| `09B3_PLAYER_INSPECT` | ModuleScript | ServerScriptService | 60 |
| `09B9_GLOBAL_LOOKS` | ModuleScript | ServerScriptService | 175 |
| `09C1_SHOP_LOOKS` | ModuleScript | ReplicatedStorage | 190 |
| `09C2_SHOP_CATALOG` | ModuleScript | ReplicatedStorage | 260 |
| `09C6_AVATAR_PREVIEW` | ModuleScript | ReplicatedStorage | 119 |
| `09C7_COMMUNITY_FEED` | ModuleScript | ReplicatedStorage | 149 |
| `09C9_PLAYER_INSPECT` | ModuleScript | ReplicatedStorage | 70 |
| `09I2_ASSISTANT_ENGINE` | ModuleScript | ServerScriptService | 43 |
| `09I3_OUTFIT_BUILDER` | ModuleScript | ServerScriptService | 115 |
| `09I4_ASSISTANT_UI` | ModuleScript | ReplicatedStorage | 130 |
| `09I5_ASSISTANT_QUESTIONNAIRE` | ModuleScript | ReplicatedStorage | 54 |
| `09I6_ASSISTANT_RESULTS` | ModuleScript | ReplicatedStorage | 131 |
| `07P_PHOTO_MODE` | LocalScript | StarterPlayer > StarterPlayerScripts | 171 |
| `09B_SHOP_SERVER` | Script | ServerScriptService | 249 |
| `09C_SHOP_CLIENT` | LocalScript | StarterPlayer > StarterPlayerScripts | 384 |
| `09I_ASSISTANT_CLIENT` | LocalScript | StarterPlayer > StarterPlayerScripts | 90 |
| `09I_ASSISTANT_SERVER` | Script | ServerScriptService | 122 |

## Instalação e primeira verificação

1. Pare Play. Crie primeiro os dois módulos novos no **ServerScriptService**. Copie a fonte inteira de cada script listado e mantenha exatamente o nome, tipo e local da tabela.
2. `07P1_CAPTURE_ENGINE` já era uma dependência do estúdio original e agora tem uma fonte completa no instalador. **Substitua o ModuleScript existente em ReplicatedStorage. Se estiver ausente, crie-o nesse local.** Não deixe duas instâncias com esse nome.
3. Reinicie Play. Abra IA, envie um pedido, toque **Nova conversa** e envie outro. O formulário agora vive fora das mensagens; limpar o chat não o destrói. A nova conversa cancela o pedido anterior e seus resultados atrasados, mantendo os limites e as coleções salvas.
4. Abra **Meus looks**. O botão **↻** fica ao lado da pesquisa. Uma leitura pendente mantém os cards anteriores e pede nova consulta; não salva uma lista vazia no lugar dos seus dados. Um registro antigo inválido é identificado por `[Looks V64] INVALID_RECORDS` no Output e bloqueia edições para preservá-lo.
5. Abra Comunidade e **Carregar mais**. Avatares de jogadores usam miniaturas do Roblox; o arquivo global continua sendo verificado e gravado aos poucos. O índice é compartilhado entre usuários, tem pausa/cache e respeita orçamento. Os mesmos DataStores e códigos da V61 permanecem em uso.
6. No Photo Mode, teste fundo da loja, emote na cópia, **Tirar foto**, **Salvar última foto** e **Compartilhar última foto** no aplicativo publicado. Cancelar o salvamento não deve informar sucesso. Um erro nativo gera `[Photo V64] CAPTURE_START`, `CAPTURE_TIMEOUT`, `SAVE_PROMPT` ou `SHARE_PROMPT` no Output.
7. Toque em outro jogador no mapa. O painel é pequeno, com uma cópia imediata do avatar visível e quatro ações: **Ver roupa**, **Curtir**, **Usar look**, **Enviar Robux**. O proprietário continua podendo desativar cópias; a permissão é conferida novamente no servidor.
8. Teste Truco com pessoas e bots: três cartas privadas, duplas identificadas, cartas públicas menores, linha das três vazas, avisos curtos de pontuação/chamada e revanche/placar de sessão. Nenhuma regra, recompensa, chance ou vantagem de compra foi alterada.
9. Troque pelos seis mundos. Confira madeira, pedra, telhado, vegetação, água, detalhes próprios e iluminação/céu. Os cenários continuam locais e ao ar livre. A paisagem tem teto de **780 partes**, 25 partes de chão reutilizadas, até 8 luzes e animação limitada de água/vegetação. Reduzir movimento continua disponível.

## O que as fotos mostram

Os avisos `ACP_GlobalLookSeeds_V61` indicam excesso de pedidos no índice ordenado. A versão anterior podia iniciar repetidamente uma consulta ordenada mesmo sem novos registros. A V64 remove esse ciclo rápido, compartilha o índice e reserva orçamento para operações pessoais. Não apaga nem troca o armazenamento existente.

O aviso `FoundationProvider`/`UIBlox` está dentro de **CorePackages do Roblox**. As fotos não mostram uma linha de falha dos nossos scripts do Photo Mode. A captura foi atualizada para a API de objeto de captura atual, com callback único, bloqueio de pedidos duplicados, timeout e resultado verdadeiro. Esta atualização não substitui nem tenta modificar os módulos internos do Roblox; se o aviso persistir, compare no aplicativo atualizado e registre qual botão o acionou.

## IA: capacidades e limites

O assistente pesquisa o catálogo, entende estilos/cores e refinamentos, confere preços novamente e tenta criar a aparência antes de mostrar o resultado. Reserva parte do orçamento para não gastar tudo no cabelo antes de encontrar camisa/calça. Opções do formulário definem preservação, formato e orçamento. Combinações parciais são informadas.

**Não exige chave da OpenAI.** É um planejador de looks com respostas de ajuda específicas do jogo, não um chat generativo geral. Não existe garantia de reconhecimento de qualquer personagem, de coincidência visual perfeita ou de disponibilidade de todas as peças do Roblox. Nenhum look é comprado automaticamente.

## Enviar Robux

Não precisa criar passe nem Developer Product. O botão abre uma confirmação de valor, depois usa `MarketplaceService:PromptRobuxTransferAsync` no servidor e recibos específicos de transferência, separados do único `ProcessReceipt` de produtos.

O Roblox exige **Roblox Plus** e verifica a elegibilidade. Valores oficiais: **10 a 500 Robux** por transferência. A janela informa **90% para o jogador e 10% para a experiência**. O jogo não concede vantagem, moeda ou item por transferir; não trata o fechamento do prompt como pagamento confirmado.

## Documentação consultada

- [Orçamentos, filas e limites de DataStore](https://create.roblox.com/docs/cloud-services/data-stores/error-codes-and-limits)
- [DataStoreRequestType](https://create.roblox.com/docs/reference/engine/enums/DataStoreRequestType)
- [CaptureService](https://create.roblox.com/docs/reference/engine/classes/CaptureService)
- [UICaptureMode](https://create.roblox.com/docs/reference/engine/enums/UICaptureMode)
- [Robux transfers e recibos](https://create.roblox.com/docs/production/monetization/robux-transfers)

## Validação

31 cenários simulados com Lua 5.4 e doubles de serviços; incluem três ciclos do LocalScript real da IA, cancelamento no servidor, armazenamento pendente/corrompido, cache/índice/paginação, preços e seleção de looks, captura nativa simulada, permissões/transferências, seis geometrias de interface e seis cenários. O pacote também verifica sintaxe de todas as fontes efetivas, hashes, dependências e o JavaScript real de cópia/sincronização do instalador.

Esses testes não executam o motor Roblox. Renderização, FPS, texturas nativas, elegibilidade de transferência, catálogo remoto, galeria e sensação da partida precisam de teste no Roblox. O acabamento usa materiais nativos e geometria original; não depende de texturas externas ainda sem ID/permissão. A configuração de público/idade continua no Creator Dashboard.
