## Instalar sobre a V65

1. Pare Play. Crie os cinco **ModuleScripts NOVOS** da tabela. Apenas `07P11_EMOTE_RESOLVER` fica em **ServerScriptService**; os outros quatro ficam em **ReplicatedStorage**.
2. Substitua a fonte inteira das 19 instâncias existentes. Os dois scripts com nome `09I_ASSISTANT_SERVER` e `09B_SHOP_SERVER` são **Script em ServerScriptService**. Confira a tabela para os três LocalScripts.
3. Reinicie Play depois de terminar tudo. Não acrescente NOVO/SUBSTITUIR ao nome, não deixe versões duplicadas e não remova fontes que não aparecem na V66. O `09A_SHOP_UI` continua nas quatro partes anteriores e não entra nesta atualização.

Não é preciso criar passe, Developer Product, chave OpenAI ou imagem nova. A V66 usa os dados, compras anteriores e configurações existentes. O instalador mantém o código recolhido, nome/tipo/local, última linha e botão de copiar a fonte completa; há opção de duas partes para as fontes desta versão.

## O que mudou e como conferir

- **Fundos:** abra Photo Mode → Fundos e teste um item da loja. O servidor agora usa InsertService para abrir o recipiente AvatarBackground e ler `ImageId.Value` e `Color.Value`. O cliente confirma a imagem interna carregada antes de trocar o cenário. O ID do item não é tratado como ID de imagem. Se o Roblox negar o recipiente ou a imagem, o fundo anterior continua e aparece uma falha específica. Logs: `[Photo V66] BACKGROUND_INSERT`, `BACKGROUND_REFERENCE`; registre o ID mostrado se um fundo específico ainda falhar.
- **Emotes:** a função anterior `PlayEmoteAsync` recusava a cópia com “You can only play emotes for the LocalPlayer”, como nas fotos. O novo módulo resolve o item EmoteAnimation para o `Animation.AnimationId` contido, destrói o recipiente e envia somente a referência. O Animator carrega/toca o clip na mesma cópia R15 do estúdio. Teste velocidade, loop, parar, repetir e pose. Falha de permissão/duração não destrói a cópia. Logs: `[Photo V66] EMOTE_RESOLVE`, `EMOTE_LOAD`, `EMOTE_TRACK`.
- **Catálogo:** arraste o avatar para os lados. O modelo deve girar; câmera e chão da prévia permanecem parados. Zoom continua disponível. As prévias de looks e resultados usam o mesmo controlador.
- **Meus looks:** quatro ações principais: Usar look, Atualizar, Carrinho e Mais. Restaurar, Publicar/Retirar e Excluir ficam em Mais. Excluir pede confirmação. Cards têm cores mais discretas e menos efeitos concorrentes; os itens com X continuam embaixo da prévia. Leitura pendente mantém os cards anteriores. O botão Recarregar usa ícone vetorial, sem depender do caractere que apareceu como quadrado na foto.
- **Do zero:** em Meus looks, toque Do zero. Escolha Clássico R15, Clássico R6 ou Corpo atual sem roupas; escolha uma das 12 cores. O painel mostra a prévia antes de mudar o look. Criar e editar confirma e abre o Catálogo; fechar cancela. O histórico permite Desfazer, e os looks salvos não são apagados. R6 não oferece roupas em camadas.
- **IA/estilos:** há **90 estilos** com descrição, aliases e termos de busca, incluindo streetwear, skater, techwear, cyberpunk, Y2K, grunge, emo, gótico, punk, scene, gyaru, decora, jirai kei, academia, cottagecore, fantasia, animais, clássicos e memes. Explorar estilos abre uma lista pesquisável; o preço abre opções descritas ou aceita valor personalizado. Escolher não envia o pedido: ainda é preciso confirmar. A busca de peças e a verificação de preço/aparência continuam reais; o nome de um estilo não garante estoque compatível dentro de qualquer orçamento.
- **Guia da IA:** **35 assuntos** cobrem as funções do jogo. Pergunte “Como usar o catálogo?”, “Como jogar truco?” ou “Como usar música?”. Perguntas reconhecidas abrem ajuda diretamente, mesmo no modo criar look, e não consomem a quota de busca de looks. Mais ajuda abre a lista de assuntos. Nova conversa preserva o formulário e permite continuar. É um planejador e guia específico do jogo, sem chave externa; não é um modelo generativo geral, não faz pesquisa na web durante cada conversa nem reconhece qualquer personagem automaticamente.
- **Música:** falha de metadados, permissão ou conteúdo tenta outra faixa da fila/biblioteca também para escolha manual e última música salva. A biblioteca aguarda a leitura inicial de preferências antes de iniciar uma sugestão, evitando substituir a escolha salva. IDs recusados não se repetem na mesma sequência; há limite de 12 falhas por sequência. Sem alternativa, o player mostra a falha e oferece Recarregar. O sucesso exige preload concluído, IsLoaded e duração positiva. Volume inicial pessoal de 40%, fila e salvos continuam. Logs: `[Music V66] METADATA` / `CONTENT_LOAD`.
- **Mundos:** composições mais discretas, menos árvores e detalhes, centro plano e livre. Bosque mais claro, luz/cores menos fortes. As nuvens locais são removidas antes de restaurar as originais, corrigindo a duplicação ao trocar de tema. Até 300 partes de cenário, além do chão visual reutilizado. A praça e os temas são composições próprias, sem copiar mapas ou assets de outro jogo.

## O que as oito fotos mostram

A primeira foto orienta a lista com opções e descrições; a segunda mostra Meus looks. Duas fotos mostram o erro de emotes restrito ao LocalPlayer e o aviso de mais de uma Cloud. Os demais registros mostram `FoundationProvider`/`CorePackages.UIBlox` em módulos internos do Roblox. A V66 corrige os dois problemas identificados nos scripts do projeto. Não modifica UIBlox nem afirma que um aviso interno comprova erro de cópia do seu script.

## Pesquisa consultada em 16/10/2026

- [Imagem de AvatarBackground: InsertService no servidor e envio ao cliente](https://devforum.roblox.com/t/how-to-get-the-image-id-of-an-avatar-background-in-a-local-script/4756010)
- [Recipiente com ImageId.Value e Color.Value](https://devforum.roblox.com/t/getting-a-players-background-image/4809017)
- [InsertService e limites de LoadAsset](https://create.roblox.com/docs/reference/engine/classes/InsertService)
- [Animator e LoadAnimation](https://create.roblox.com/docs/reference/engine/classes/Animator)
- [Relato da restrição PlayEmote no LocalPlayer](https://devforum.roblox.com/t/a-very-specific-issue-with-roblox-emotes-that-bothers-me/3949324)
- [Diferença entre item de emote e AnimationId](https://devforum.roblox.com/t/does-anyone-have-the-robot-animation-id/534527)
- [Áudio: assets e permissões](https://create.roblox.com/docs/audio/assets)
- [Discussão de estilos de avatar no Reddit](https://www.reddit.com/r/RobloxAvatars/comments/1egy5wf/every_single_roblox_avatar_style/)
- [Outras listas de estilos de jogadores](https://www.reddit.com/r/RobloxAvatars/comments/1pvibkg/guys_im_tryna_make_avatarpls_gimme_list_of_ava/)
- [Referências de moda japonesa: Decora](https://roblox-outfit-styles.fandom.com/wiki/Decora), [Gyaru](https://roblox-outfit-styles.fandom.com/wiki/Gyaru)
- [Catalog Avatar Creator, referência geral de experiência](https://www.roblox.com/games/7041939546/Catalog-Avatar-Creator)

Os estilos foram selecionados e descritos para este jogo; as classificações comunitárias não são regras oficiais. O novo painel Do zero é uma implementação própria da função solicitada; não foi confirmada uma reprodução exata da interface atual do CAC. A pesquisa distingue contratos de API e relatos de desenvolvedores de referências visuais/comunitárias.

## Validação e limites

**65 cenários simulados em Lua 5.4**, **127 fontes efetivas** com sintaxe verificada, hashes/dependências e JavaScript real do instalador. Geometrias: 320×568, 390×844, 568×320, 667×375, 851×392 com recortes e 1920×1080. Os novos testes reproduzem a restrição LocalPlayer que faltava no double anterior; simular só uma resposta positiva de PlayEmote não confirmava o funcionamento na cópia.

Não há motor Roblox neste ambiente. Estes testes verificam fluxo, contratos simulados e medidas numéricas; não confirmam renderização, FPS, colisões, deformação de roupas nem permissão real de cada áudio, imagem ou emote. O código não contorna recusas do Roblox: conserva o estado anterior e informa a etapa. A reprodução real precisa ser conferida no aplicativo publicado depois da instalação completa.
