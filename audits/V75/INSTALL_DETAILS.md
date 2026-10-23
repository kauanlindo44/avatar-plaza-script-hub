## Instalar sem duplicar

1. Abra `AVATAR_PLAZA_V75.html` e selecione **V75**. A base é a **V74 completa**; este delta não recria todos os scripts do jogo.
2. Pare Play no Studio Lite. Crie `07G9_COMMAND_PANEL` e `07UI_GAME_AUDIO` como **ModuleScript em ReplicatedStorage**. Há um único script de cada nome.
3. Substitua o conteúdo inteiro dos 35 nomes do segundo grupo, respeitando o local. Os módulos de servidor não vão em ReplicatedStorage, e LocalScripts não vão em ServerScriptService.
4. Copie a fonte inteira. Se usar as duas partes, cole-as em sequência na **mesma instância**, sem duplicar o nome e sem colar texto explicativo.
5. Reinicie Play apenas ao terminar. Procure no Output os diagnósticos V75 e teste a abertura da IA antes de iniciar os jogos.

A foto 2 mostrou ausência de `09I25_PLAN_PRODUCTS`. A conversa agora abre mesmo sem esse módulo. Para consultar/comprar os planos existentes, confira que a V74 completa inclui esse ModuleScript em ReplicatedStorage, com o nome exato. Se ele estiver ausente ou inválido, a compra fica indisponível; a V75 não inventa preço, concessão ou produto. O módulo pode ser recuperado no grupo NOVOS da V74. Não refaça o restante da V74 depois de instalar a V75.

## O que conferir

- **HUD:** Catálogo no topo; Jogos/Comunidade/Meus looks à esquerda; IA/Patrocinar/Avatar à direita; Fotos/Música/Carrinho/Ajustes embaixo. O centro permanece livre. **Avatar → Comandos** ou `/commands` abre a janela de comandos pessoais.
- **Avatar:** Carregar, Vestindo agora e Restaurar têm superfícies coloridas. Restaurar continua pedindo confirmação e preservando o histórico de edição.
- **IA:** acesso direto; conversa independente da consulta de planos; reconexão quando o servidor aparece depois. Looks em cards pequenos, até cinco por coluna, com rolagem horizontal se necessário. Cor negada e termos completos são considerados na busca. É o planejador nativo de catálogo existente, com validação; não foi adicionado um modelo externo pago.
- **Photo Mode:** avatar mantém o enquadramento ao abrir Emotes/Fundos. Cinco colunas e até quatro linhas por página; telas muito baixas mostram menos linhas para conservar alvos de toque. **Opções** reúne busca, pacotes, velocidade, pausa e compra do item selecionado. Tocar na miniatura somente experimenta.
- **Mundo:** inicia no Vale da aventura; a seleção manual em Ajustes continua disponível. Cenários usam menos árvores, copas e detalhes. Isso reduz geometria, mas não comprova FPS no aparelho.
- **Truco/Xadrez/Damas:** composição, cores e áudio revistos; cartas públicas posicionadas por assento, último lance e material visíveis nos tabuleiros. Os motores de regras, bots, relógios, privacidade das cartas e recibos anteriores permanecem os mesmos.
- **Música:** a saída fica mais baixa durante partidas e volta ao nível escolhido depois; o valor salvo pelo jogador não muda.

## Botão do Caos

O piso é um retângulo verde de **128 × 88**, com o botão e sem paredes, obstáculos decorativos, bordas invisíveis ou piso infinito. Sair da borda permite cair; cair 16 studs abaixo do piso elimina. A fila, os tempos e os doze efeitos anteriores continuam presentes.

**Empurrar:** chegue a até **6 studs**, olhe para um participante vivo e use o botão. Há **3 segundos** de intervalo. O servidor escolhe o alvo e confere fase, vida, participação, distância, direção, obstáculo e proteção. Não aceita força/dano/vítima do cliente. O escudo bloqueia. O impulso é físico e limitado; empurrar para fora pode causar queda. A pontuação anterior de armas/bomba/vitória não foi estendida para premiar quedas.

A bomba nuclear mostra o objeto descendo, explode na altura do chão e só pode eliminar o alvo marcado. O som começa no evento de explosão; a abertura imediata do resultado não o corta. Sair limpa o áudio e os efeitos locais. Não há `Explosion` física global que cause dano em espectadores.

## Áudio

`07UI_GAME_AUDIO` centraliza IDs de efeitos encontrados na Creator Store. Nenhum asset executável externo foi importado. O limite é seis sons simultâneos, volume até 0,35 e duração limitada. Som/permissão/moderação precisam ser conferidos na experiência publicada. Se um áudio não carregar, a interface e a partida continuam; o Output identifica a falha. Não é necessário criar produtos ou ativar serviços pagos.

## Teste nativo ainda necessário

A entrega contém testes com serviços simulados e reconstruções de layout. Instale em uma cópia de teste e confira duas rodadas com 2–8 jogadores, empurrão sob latência, nuke/escudo, queda, saída/retorno e troca de jogo. Confira R6/R15/corpos personalizados, toque/joystick/pulo, captura, streaming, sons e memória/FPS no celular. Não houve publicação automática no Roblox nem medição no Motorola Moto 5G.

Pesquisa, fontes e limite de acesso aos vídeos: `audits/V75/RESEARCH.md`. Resultados e histórico: `audits/V75/README.md` e `HISTORY.md`.
