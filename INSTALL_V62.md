# Instalação V62 — 3 novos + 25 substituições

Requer V61 completa. V62: 3 scripts NOVOS + 25 SUBSTITUIÇÕES. Pare Play, crie primeiro os três módulos novos nos locais indicados, substitua as 25 fontes completas e reinicie Play. Não inclua NOVO/SUBSTITUIR no nome da instância. Nenhum passe ou produto novo. Guia: INSTALL_V62.md.

## Criar primeiro — NOVOS

| Nome exato | Tipo | Local | Linhas |
|---|---|---|---:|
| `07H7_BOARD_SESSIONS` | ModuleScript | ServerScriptService | 79 |
| `07P10_VIDEO_MOTION` | ModuleScript | ReplicatedStorage | 54 |
| `09C10_SPONSOR_DESIGN` | ModuleScript | ReplicatedStorage | 17 |

## Substituir nas instâncias existentes

| Nome exato | Tipo | Local | Linhas |
|---|---|---|---:|
| `07G2_LOCAL_WORLDS` | ModuleScript | ReplicatedStorage | 64 |
| `07G4_WORLD_SCENERY` | ModuleScript | ReplicatedStorage | 170 |
| `07M2_AUDIO_LIBRARY` | ModuleScript | ServerScriptService | 61 |
| `07P2_STUDIO_AVATAR` | ModuleScript | ReplicatedStorage | 213 |
| `07P4_STUDIO_UI` | ModuleScript | ReplicatedStorage | 121 |
| `07P7_ROBLOX_BACKGROUNDS` | ModuleScript | ReplicatedStorage | 35 |
| `07P8_BACKGROUND_RESOLVER` | ModuleScript | ServerScriptService | 34 |
| `07P9_STUDIO_CATALOG` | ModuleScript | ReplicatedStorage | 47 |
| `09B8_FREE_HIGHLIGHTS` | ModuleScript | ServerScriptService | 162 |
| `09C2_SHOP_CATALOG` | ModuleScript | ReplicatedStorage | 259 |
| `09C5_UGC_STORES` | ModuleScript | ReplicatedStorage | 156 |
| `09C9_SPONSOR_PICKER` | ModuleScript | ReplicatedStorage | 43 |
| `09I2_ASSISTANT_ENGINE` | ModuleScript | ServerScriptService | 30 |
| `09I4_ASSISTANT_UI` | ModuleScript | ReplicatedStorage | 136 |
| `01B_HUB_WORLD` | Script | ServerScriptService | 123 |
| `01C_HUB_CHALLENGES` | Script | ServerScriptService | 93 |
| `07A_CHESS` | Script | ServerScriptService | 3 |
| `07B_CHECKERS` | Script | ServerScriptService | 3 |
| `07H_GAME_UI` | LocalScript | StarterPlayer > StarterPlayerScripts | 242 |
| `07M_MUSIC_CLIENT` | LocalScript | StarterPlayer > StarterPlayerScripts | 141 |
| `07M_MUSIC_SERVER` | Script | ServerScriptService | 25 |
| `07P_PHOTO_MODE` | LocalScript | StarterPlayer > StarterPlayerScripts | 171 |
| `09B_SHOP_SERVER` | Script | ServerScriptService | 251 |
| `09I_ASSISTANT_CLIENT` | LocalScript | StarterPlayer > StarterPlayerScripts | 87 |
| `09I_ASSISTANT_SERVER` | Script | ServerScriptService | 108 |

## Instalação e checagem de versões

Este é um delta sobre a **V61 completa**, publicada em `dd885215d58637d426142d912560214c0d07cfe0`. Use **AVATAR_PLAZA_V62.html** ou sincronize o instalador permanente. Pare Play, crie os três módulos NOVOS primeiro, substitua as 25 fontes completas nas instâncias da tabela e reinicie Play. Não duplique instâncias e não escreva NOVO/SUBSTITUIR no nome.

Os oito módulos criados na V61 continuam necessários. Se algum não existir, instale-o pela seção V61 do HTML antes da V62. O pacote V62 não é uma instalação completa a partir de um projeto antigo. `09A_SHOP_UI` não mudou; continua com as quatro partes históricas. Todos os scripts deste delta têm até 400 linhas.

**Nenhum passe/produto, chave OpenAI ou serviço externo novo é necessário.** Planos antigos de IA continuam fora de venda, conservando direitos previamente comprados até vencer. ProcessReceipt/Salem não foram alterados. A disponibilidade 16+ continua sendo uma configuração do Creator Dashboard.

### O que as fotos comprovam

A foto do servidor contém `[IA V59]` e `origem=TextGenerator.GenerateTextAsync`, portanto o gerador antigo ainda estava sendo chamado. O painel atrás da console mostra o fluxo antigo de fundos possuídos. Isso comprova execução de caminhos anteriores, mas não permite distinguir sozinho entre fonte antiga, módulo em local errado, instância duplicada ou cache de Play. Não é evidência de que você copiou errado.

Confira especialmente:

| Componente | Instância e local que devem estar atualizados |
|---|---|
| Gerador antigo/HTTP 400 | `09I2_ASSISTANT_ENGINE` e `09I_ASSISTANT_SERVER` — ServerScriptService; `09I_ASSISTANT_CLIENT` — StarterPlayer > StarterPlayerScripts. |
| Loja de fundos | `07P9_STUDIO_CATALOG`, `07P7_ROBLOX_BACKGROUNDS`, `07P_PHOTO_MODE` nos locais da tabela; `07P8_BACKGROUND_RESOLVER` e `09B_SHOP_SERVER` — ServerScriptService. |
| Patrocínio/filtros | `09B8_FREE_HIGHLIGHTS` — ServerScriptService; `09C5_UGC_STORES`, `09C9_SPONSOR_PICKER` e novo `09C10_SPONSOR_DESIGN` — ReplicatedStorage. |
| 1v1 2D | `01C_HUB_CHALLENGES`, `07A_CHESS`, `07B_CHECKERS` e novo `07H7_BOARD_SESSIONS` — ServerScriptService; `07H_GAME_UI` — StarterPlayer > StarterPlayerScripts. |

Depois de reiniciar, o Output deve mostrar `[IA V62] servidor=V62 motor=V62 protocolo=2`, `[Shop V62] patrocinar=V62 fundos=V62`, `[Music V62] biblioteca=V62` e a mensagem de xadrez/damas 2D sem assentos. Diagnósticos de avatar `[Avatar V57]` continuam porque esse carregador anterior não foi substituído.

A interface agora identifica o módulo antigo antes de pedir looks e valida o protocolo da sala antes de solicitar create/join/quick. Confira que há uma única instância de cada Script/LocalScript/ModuleScript pelo mesmo nome e local. O aviso FoundationProvider da outra foto vem de CorePackages/UIBlox, a interface interna Roblox; esta atualização não modifica o CoreGui.

## Música sem prender a biblioteca

A pesquisa foi retirada do caminho bloqueante do RPC. O servidor aquece a lista ao iniciar, compartilha cache entre jogadores e envia atualização quando uma página chega. Descobrir retorna rapidamente estado pendente ou dados já disponíveis; não espera o DataStore das preferências. ID/link, tocar áudio e salvar usam canais de requisição separados da pesquisa.

Resultados confirmados pelo serviço nativo alimentam a fila e evitam consultas repetidas de metadados. Cache se atualiza após dez minutos; APIs com erro entram em recuperação com intervalo, sem dezenas de buscas iguais. Um timeout apresenta aviso e mantém ID/link disponível. Fila, favoritos, volume inicial de 40% e preferências anteriores permanecem.

**Limite real:** não há liberação de toda música privada/moderada. Biblioteca e reprodução dependem da disponibilidade/autorização Roblox. Cache reduz espera quando existem dados, mas não torna uma API indisponível acessível. Nenhum ID/nome de música foi inventado como resposta.

## Patrocinar — itens pagos, envio gratuito

A vitrine contém somente itens com preço conhecido maior que zero. **Patrocinar continua grátis**, com um item por pessoa por 24 horas, sem prioridade paga. Item grátis/fora de venda/preço não confirmado é rejeitado antes de consumir o slot. Publicação antiga de item grátis pode ser substituída por um item pago, sem prender o dono na regra obsoleta.

Categorias visíveis: **Todos, Roupas 2D, Roupas 3D, Acessórios, Corpo, Emotes e Favoritos**. Pesquisa por nome/ID permanece. Foi corrigida a criação de filtros: `AssetTypes`/`BundleTypes` da API são listas somente leitura ao acessar a propriedade; agora são montadas em variável local e atribuídas de uma vez.

A galeria é uma grade com **rolagem vertical**, miniatura grande, nome/preço compacto e coração. Categorias rolam horizontalmente em telas estreitas. Mais itens adiciona a próxima página até uma janela de 120 cards, mantendo a interface limitada. A quantidade de colunas/linhas visíveis é adaptativa; telas baixas mostram uma linha e parte da seguinte, permitindo continuar para baixo. Não promete sete cards legíveis em qualquer tela.

Quando não há recomendação paga ativa na consulta do índice, aparecem **Exemplos** reais pagos, respeitando categoria/pesquisa. Uma recomendação recebida substitui esses exemplos; expiração/retirada permitem que voltem. Há notificação local, comunicação entre servidores quando MessagingService responde e atualização periódica de recuperação. Favoritar não adiciona ao carrinho; compra usa somente o diálogo oficial Roblox e sua disponibilidade/preço final.

Patrocinar e IA usam superfícies, contrastes, bordas e acentos próprios: laranja para a vitrine, violeta para o estúdio de looks. A conversa ganhou painel de boas-vindas, ações e mensagem com hierarquia visual. Não há integração nova de publicidade paga.

## Catálogo — pagos primeiro

Todas as categorias gerais iniciam a busca com preço mínimo de 1 Robux. Após percorrer os pagos, **Ver itens grátis** consulta a mesma seleção com preço zero. Uma categoria explicitamente grátis ou filtro máximo zero continua consultando grátis diretamente. Preços/consulta/formatos existentes são preservados; entradas inválidas mantêm o painel aberto com aviso.

Priorizar pagos não significa esconder a categoria Grátis da comunidade. A comunidade da V61 e seu arquivo global não mudaram nesta atualização.

## IA sem o gerador HTTP 400

O motor V62 é o assistente de looks por pesquisa/validação do catálogo introduzido na V61. Ele não usa `TextGenerator.GenerateTextAsync`, não pede chave externa e não é um chatbot generativo geral. Texto é filtrado; estilo/cor/orçamento/formato orientam busca por peças reais; preço e aparência montada são validados antes do resultado. Falta de peças/erro não aplica o avatar e conserva a recuperação de quota.

Os novos protocolos detectam um motor/servidor antigo ou duplicado, mostrando instância e local. A confirmação do módulo ocorre antes de reservar quota no servidor atual. Um script antigo que permaneça ativo precisa ser substituído/removido como duplicata; o código novo não apaga fontes do seu projeto automaticamente.

## Photo Mode: loja de fundos e emotes na cópia

Fundos abre **Loja de fundos** pelo catálogo nativo `AvatarBackground`, com pesquisar, testar, próximos resultados e comprar. Não consulta inventário nem pede posse. O servidor confirma tipo/disponibilidade; tenta a imagem real e pode usar a miniatura oficial do mesmo asset quando necessário. Se nenhuma imagem carregar, o cenário anterior é mantido. O resolver mantém cache de imagem para evitar recarregar repetidamente o asset.

Fundos de perfil são imagens 2D. A cópia fica centralizada; giro/animação não gira o fundo. Emotes abre uma lista pequena lateral do catálogo `EmoteAnimation` e toca a seleção no humanoid/animator da cópia. Não é uma imagem demonstrativa. Emotes nativos exigem rig compatível R15; falha mantém o avatar anterior e informa a situação. Comprar continua no diálogo oficial.

Em **Câmera → Movimentos para vídeo** há nove percursos: órbita 360°, arco suave, aproximação, subida suave, travelling, percurso em oito, revelar look, inclinação leve e giro do avatar. Existem Pausar/Continuar, Restaurar, velocidade 0,5–2× e intensidade 0,5–1,5×. Cada percurso acelera suavemente; emotes são independentes. O enquadramento usa limites estáveis do avatar para evitar que cada movimento de braço provoque um novo zoom. Fechar o estúdio desconecta o movimento.

## Xadrez/damas realmente 2D

Partidas entre pessoas usam **sessões no mesmo servidor**, sem assentos, salas físicas distantes ou teleporte. O personagem permanece onde estava. Código/partida rápida/criar/revanche não dependem de sentar ou de um avatar ser recriado. Não há transferência automática a outro servidor nesta modalidade; código de outra instância informa indisponibilidade local.

As regras existentes foram preservadas, com validação no servidor, turnos, captura obrigatória/maioria em damas, promoção, relógio 5+3, desistência e resultados. A transmissão possui oito linhas de oito casas, usando false para vazio. Peças deixam de depender de tabelas com índices nil, cujo transporte era ambíguo; um número de revisão impede aplicar lance de tabuleiro anterior. O cliente desenha peças 2D e conserva resultado/revisão/revanche da sessão.

Truco e as regras dos bots não foram reescritos. Torneios locais mantêm os callbacks do sistema anterior; a V62 não promete juntar classificados de servidores diferentes sem transferência. Chão físico continua acompanhando avatares de participantes de xadrez/damas, inclusive em partida competitiva.

## Mundos mais detalhados e limitados

| Tema | Cenário original |
|---|---|
| Anime | Vila de madeira com janelas/estrutura, telhados, portais, lanternas, pagoda, dojo, ponte, lago, cerejeiras e montanhas. |
| Neon | Avenidas/faixas, torres com janelas/vitrines, luminárias, bancos, fonte e portal urbano. |
| Costa | Mar/ondas, calçadão/píer, guarda-sóis, espreguiçadeiras, palmeiras, cabanas e pedras. |
| Halloween | Casas/telhas/torre, janelas iluminadas, varanda, árvores tortas, cercas, abóboras e lanternas. |
| Nuvens | Ilhas/arcos, jardim, flores, pavilhões/colunas, espelhos de água, escadas e horizonte. |

Cada tema cria seu Sky, horário, estrelas/sol/lua, atmosfera, nuvens e tratamento de luz. As texturas de céu são internas do Roblox, com esses parâmetros distintos; não é um pacote de seis imagens novas. Cenários são originais, sem personagens/logos de franquias.

Construção ocorre em lotes de 32 partes, com limite de 640 por tema. Partes são locais, ancoradas, sem colisão/toque/query/sombra; decoração distante é ocultada, alterando visibilidade somente ao atravessar o limite. Trocar mundo destrói o anterior e cancela construção pendente. Chão visual reutiliza 25 partes; blocos físicos perto dos jogadores/spawn continuam limitados. Alterar mundo não muda o visual de outro jogador. Original restaura céu, nuvens e iluminação anteriores.

## Conferir no Roblox depois de instalar

1. Pare Play, instale os três novos/25 substituições, confira a V61 completa e reinicie. Verifique as quatro mensagens V62 no Output e ausência de instâncias duplicadas.
2. Abra música durante o carregamento das preferências. Tente ID/link enquanto Descobrir está buscando. Confira dados/erro explícito, fila, 40%, pausa, próximos e áudio sem permissão.
3. Abra Patrocinar: role para baixo, troque 2D/3D/acessórios/corpos/emotes, procure por nome, confira e publique um item pago. Item grátis deve ser recusado sem consumir o prazo. Favorite e confira a compra oficial.
4. No catálogo, confira pagos em diferentes categorias e a continuação grátis. Máximo zero consulta grátis; mínimo negativo/max invertido não aplica.
5. Peça um look pela IA. Não deve existir chamada a TextGenerator. Mensagem de módulo antigo exige corrigir instância/local/reiniciar; não repetir pedidos esperando que o cache troque sozinho.
6. No estúdio, confirme loja de fundos sem inventário, fundo não possuído, emote na cópia e todos os nove movimentos. Pausar/Restaurar/velocidade/intensidade devem funcionar. Imagem ou animação bloqueada informa erro e mantém o anterior.
7. Use dois jogadores no mesmo servidor para xadrez/damas, execute vários lances/capturas, promoção/tempo/desistência e revanche. Avatares permanecem no mapa e peças sobrevivem à troca de turno. Código externo não teleporta.
8. Visite os cinco mundos, alterne rapidamente durante construção, caminhe para longe e restaure Original. Confira céu/luz/chão e independência de outro jogador. Meça FPS/memória no aparelho real.

## Validação e referências

**20 cenários simulados** (11 de regras/serviços + nove de interface/controladores), seis geometrias de tela, sintaxe de **112 fontes efetivas**, hashes/dependências históricos e JavaScript real do instalador passaram. Incluem arrays somente leitura, 64 casas transmitidas/32 peças desenhadas, filtros pagos, módulos antigos, cache/erro de áudio, fundos sem posse e movimentos. Simulações não usam serviços online, compras, renderização nem FPS reais; o teste nativo acima ainda é necessário.

Fontes primárias: [CatalogSearchParams e listas somente leitura](https://create.roblox.com/docs/reference/engine/datatypes/CatalogSearchParams), [AvatarEditorService](https://create.roblox.com/docs/reference/engine/classes/AvatarEditorService), [AssetService/limites de áudio](https://create.roblox.com/docs/reference/engine/classes/AssetService), [AudioSearchParams](https://create.roblox.com/docs/reference/engine/classes/AudioSearchParams), [tabelas em remotes](https://create.roblox.com/docs/scripting/events/remote), [Humanoid/emotes](https://create.roblox.com/docs/reference/engine/classes/Humanoid), [Sky](https://create.roblox.com/docs/reference/engine/classes/Sky), [Clouds](https://create.roblox.com/docs/reference/engine/classes/Clouds) e [otimização](https://create.roblox.com/docs/performance-optimization).
