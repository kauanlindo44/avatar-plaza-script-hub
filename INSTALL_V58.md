# Instalação V58 — 26 substituições + 1 NOVO

Requer V57 completa. V58: 26 SUBSTITUIÇÕES + 1 NOVO: 07UI_SLIDER (ModuleScript em ReplicatedStorage). Pare Play, crie esse módulo primeiro, substitua as fontes completas nos locais indicados e reinicie Play. Não duplique scripts. Guia: INSTALL_V58.md.

## Criar primeiro

| Nome exato | Tipo | Local | Linhas |
|---|---|---|---:|
| `07UI_SLIDER` **(NOVO)** | ModuleScript | ReplicatedStorage | 36 |

## Substituir estes 26 scripts

| Nome exato | Tipo | Local | Linhas |
|---|---|---|---:|
| `07G1_HUB_SETTINGS` | ModuleScript | ReplicatedStorage | 107 |
| `07K15_TRUCO_TABLE` | ModuleScript | ReplicatedStorage | 111 |
| `07K5_TRUCO_UI` | ModuleScript | ReplicatedStorage | 150 |
| `07M1_MUSIC_UI` | ModuleScript | ReplicatedStorage | 54 |
| `07P0_STUDIO_PRESETS` | ModuleScript | ReplicatedStorage | 25 |
| `07P2_STUDIO_AVATAR` | ModuleScript | ReplicatedStorage | 207 |
| `07P6_STUDIO_SETS` | ModuleScript | ReplicatedStorage | 145 |
| `07UI_HALLOWEEN_THEME` | ModuleScript | ReplicatedStorage | 124 |
| `08B2_BODY_DESCRIPTION` | ModuleScript | ReplicatedStorage | 96 |
| `08B3_AVATAR_VERIFY` | ModuleScript | ReplicatedStorage | 91 |
| `08B4_AVATAR_LOAD` | ModuleScript | ReplicatedStorage | 120 |
| `08B_AVATAR_DATA` | ModuleScript | ReplicatedStorage | 360 |
| `09A1_SHOP_LAYOUT` | ModuleScript | ReplicatedStorage | 188 |
| `09A4_UTILITY_SKIN` | ModuleScript | ReplicatedStorage | 70 |
| `09C2_SHOP_CATALOG` | ModuleScript | ReplicatedStorage | 253 |
| `09C4_OUTFIT_LIBRARY` | ModuleScript | ReplicatedStorage | 207 |
| `09I1_ASSISTANT_ACCOUNTS` | ModuleScript | ServerScriptService | 121 |
| `09I2_ASSISTANT_ENGINE` | ModuleScript | ServerScriptService | 63 |
| `09I4_ASSISTANT_UI` | ModuleScript | ReplicatedStorage | 125 |
| `09I7_ASSISTANT_PROFILE` | ModuleScript | ReplicatedStorage | 65 |
| `07M_MUSIC_CLIENT` | LocalScript | StarterPlayer > StarterPlayerScripts | 117 |
| `07P_PHOTO_MODE` | LocalScript | StarterPlayer > StarterPlayerScripts | 200 |
| `09C12_AVATAR_FEEDBACK` | LocalScript | StarterPlayer > StarterPlayerScripts | 116 |
| `09C_SHOP_CLIENT` | LocalScript | StarterPlayer > StarterPlayerScripts | 380 |
| `09I_ASSISTANT_CLIENT` | LocalScript | StarterPlayer > StarterPlayerScripts | 77 |
| `09I_ASSISTANT_SERVER` | Script | ServerScriptService | 121 |

## Copiar sem confusão

Use o **AVATAR_PLAZA_V58.html novo** ou sincronize o instalador permanente. Abra V58: aparecem somente os 27 arquivos desta atualização, com nome, tipo, local, última linha e botão **COPIAR SCRIPT**. O código permanece recolhido. A divisão opcional em duas partes continua disponível. O HTML funciona também sem conexão.

Requer **V57 completa**, incluindo os scripts novos da V56. Pare Play antes da instalação. Crie primeiro `07UI_SLIDER`, do tipo **ModuleScript**, em **ReplicatedStorage**. Cole as 26 substituições nas instâncias existentes e reinicie Play para limpar o cache de require. Os nomes das instâncias não recebem “NOVO” ou “SUBSTITUIR”. Cada fonte desta atualização tem no máximo 380 linhas. O `09A_SHOP_UI` existente e suas quatro partes permanecem instalados.

O carrinho `09C4_OUTFIT_LIBRARY` recebe agora uma substituição V58 real. O cliente aceita essa versão e as bases compatíveis. Não crie um segundo carrinho. Não é necessário criar passes ou produtos novos: os IDs IA Studio **3717699383**, IA Pro **3717699454** e Salem **3717699522** continuam no fluxo de produtos existente. Há somente um processador de recibos, `07K10_CARD_COMMERCE`.

## IA: o que foi corrigido e como conferir

As fotos do Output mostraram `GenerateTextAsync` retornando **HTTP 400**. A falha ocorre na chamada nativa, antes da busca e montagem do look. O motor agora usa uma chamada mínima: teste de conexão curto, instrução e transporte de texto sem caracteres Unicode, sem obrigar JSON ou reutilizar contexto entre solicitações. Uma resposta textual válida também é aceita; ela não derruba o serviço por falta de JSON. O usuário continua podendo escrever em português; os acentos são normalizados somente no transporte ao gerador.

A IA usa **TextGenerator do Roblox**. Não requer chave OpenAI. O código não consegue conceder acesso a um recurso nativo que o Roblox tenha indisponibilizado para a experiência. Não trata uma resposta simulada como se fosse IA funcionando.

Abra IA, toque **Recarregar** e faça um pedido curto. Se a chamada nativa funcionar, o estado fica disponível e a resposta aparece na conversa. Se falhar, procure **`[IA V58]`** no Output: o registro contém etapa, código de rastreio e causa nativa original. A pausa de recuperação é curta; uma falha não fica mais armazenada como indisponível durante cinco minutos. Uma disponibilidade antiga negativa também não impede uma tentativa real por solicitação.

Conexão da IA e armazenamento são mostrados separadamente. Se o DataStore estiver indisponível, há ajuda gratuita temporária no Normal, sem inventar plano pago, coleção salva ou confirmação de compra. Compras de planos ficam bloqueadas enquanto serviço e armazenamento não estiverem verificados. O recibo continua só sendo confirmado após salvar o benefício.

Para testar persistência no Studio, use uma experiência de teste publicada com **Enable Studio Access to API Services** habilitado, conforme a documentação Roblox. Essa configuração de armazenamento não é uma correção para HTTP 400 de TextGenerator. O limite existente de oito solicitações independentes por sessão continua aplicado; não há memória de conversa entre solicitações ou sessões. Compartilhamento continua restrito ao perfil de IA dentro da experiência, sem credenciais ou conta Roblox compartilhadas.

## Música, carrinho e catálogo

Música abre em uma janela compacta com ID, Carregar/Recarregar, tocar/pausar, volume contínuo, silenciar e barra de progresso. Salvos permitem busca por nome/ID; Fila oferece anterior/próxima e avanço quando a música termina. Minimizar mantém o som. O volume inicial continua **40%**, com a preferência existente respeitada. O controlador adota o Sound legado e evita duplicar as músicas da praça. Os áudios ainda precisam de permissão Roblox para esta experiência; falha de carregamento aparece na interface. A fila é da sessão; músicas salvas e preferência usam o servidor existente.

Experimentar um item não o adiciona automaticamente ao carrinho. Adicionar é uma ação explícita. O carrinho separa **selecionados** e **look inteiro**, usa linhas compactas e pode abrir/fechar sua prévia para liberar a lista. A compra continua consultando preço/posse no servidor. Os itens equipados e seus X abaixo da prévia foram preservados.

A categoria **HALLOWEEN** pesquisa itens reais do catálogo Roblox. Filtros de roupas, acessórios, corpo e grátis ficam dentro dela. “Grátis” exige preço confirmado igual a zero; preço ausente não é anunciado como grátis. Nenhum ID de item inventado foi usado.

## Roupa no mapa e diagnóstico

Uma descrição aplicada no servidor pode chegar ao aparelho sem o histórico local necessário a `AccessoryDescription:GetAppliedInstance()`. Esse erro não prova sozinho que a roupa desapareceu. O servidor agora grava o ID na instância exata que ele verificou. O cliente pode conferir essa identidade replicada junto da aparência esperada enviada pelo servidor, em vez de exigir uma aplicação local prévia.

A verificação continua exigindo a geometria apropriada: ID/tipo correto, Handle visível, malha, WrapLayer ativo, corpo com WrapTarget e R15 para roupa 3D. Outro acessório do mesmo tipo não confirma o item. Cabelo rígido corrigido nativamente continua aceito sem exigir WrapLayer. A aplicação completa, restauração em falha e aparência lembrada permanecem no fluxo existente.

A leitura local aguarda a replicação e o conteúdo; um snapshot ainda indisponível é mostrado como pendente com tentativas limitadas, em vez de ser anunciado imediatamente como roupa quebrada. Falhas reais mantêm item, etapa, requisito, Client/Server e causa original. Parte do fluxo de diagnóstico preservado ainda usa o prefixo **`[Avatar V57]`** no Output. Procure também o código de rastreio mostrado na janela. Não há confirmação visual automatizada do gato abacaxi real nesta entrega.

## Photo Mode, truco e aparência

Photo Mode tem **dez fundos locais diferentes**, incluindo Salem/Halloween, Grafite, Rua Neon, Terraço e Biblioteca. O cenário é montado com peças fixas; mover a câmera ou girar a cópia do avatar não gira o fundo. A iluminação prioriza o personagem. Os fundos são construídos pelos scripts, sem scripts de terceiros ou asset de mapa obrigatório.

As escolhas de fundo ficam visíveis no painel, sem rolagem. Ambiente reúne luz, temperatura, horário, contraste e cor em barras contínuas. Emotes continuam animando a cópia; o menu **Movimentos para vídeo** oferece orbitar câmera, girar avatar, zoom suave e travelling lateral. A saída restaura câmera/iluminação e remove o cenário local.

No truco, as cartas jogadas no centro são menores e mostram o dono. Parceiro e rivais têm rótulos e cores de equipe. As três cartas da mão e as ações permanecem visíveis; a ajuda explica valor da mão, aceitar, aumentar e correr conforme a variante. Motivos de uma ação indisponível são apresentados. As regras e o tempo de resposta de dez segundos não foram alterados.

IA, carrinho, música, configurações e painéis usam seus espaços seguros; telas com recorte preservam a área do Roblox. Halloween ganhou lua, teias e morcegos discretos nos cantos. Aparência permite desativar o tema e reduzir animações. Configurações usam categorias claras com voltar e X fixos.

## Conferência final na experiência

1. Instale o módulo novo primeiro e as 26 substituições; reinicie Play.
2. Abra IA, use Recarregar e peça um look. Confira o estado de conexão e armazenamento. Se falhar, leia `[IA V58]` no Output.
3. Experimente um item: ele não deve entrar sozinho no carrinho. Adicione explicitamente e teste selecionados/look inteiro.
4. Teste o gato abacaxi **72779265740934** junto do cabelo, aplique, feche o catálogo e confira o mapa, respawn e reentrada. Em falha, compare o mesmo rastreio em Client/Server.
5. Carregue um áudio permitido, teste volume/progresso, salvar, fila e minimizar. Confira que só uma música toca.
6. Teste os fundos e movimentos do Photo Mode; confirme que somente câmera/cópia se movem e o cenário some ao sair.
7. Jogue truco em celular deitado e em pé: confira nomes das cartas, parceiro/rivais, vira, mão e botões de resposta.

**Validação:** 76 cenários em Lua 5.4 com serviços simulados; sintaxe das 98 fontes efetivas; geometria em seis resoluções; JavaScript real do instalador com DOM mínimo. Os testes não baixam as malhas dos IDs, não executam TextGenerator real, não fazem cobrança e não representam execução no motor Roblox. A confirmação final da IA nativa, roupa renderizada e interface no aparelho depende dos testes acima.
