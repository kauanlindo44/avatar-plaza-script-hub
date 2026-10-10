# Validação V57

Base remota V56: 753693692bde6760da0356982e12c08e885aefa2; árvore 88ea2d81c733177de7eef726e4bd00eff662842b. Delta: 7 substituições, nenhum novo. Os sete arquivos estão separados em scripts/V57; base V56 e versões anteriores permanecem preservadas no GitHub.

41 casos em seis suítes de Lua 5.4 com serviços simulados. Não representam execução no Roblox. Doze casos de regressão cobrem classificação nativa corrigida de Hair, Part/SpecialMesh sem WrapLayer, metadado antigo, camisa/cabelo realmente em camadas com falha real, ID exato, aplicação com cabelo rígido+camisa no mapa, cliente real/carrinho V55/aplicação com catálogo fechado, exceção nativa, janela e envio de prova validada ao servidor. Casos existentes cobrem prévias, conteúdo, confirmação e restauração, Photo Mode, itens/X, preços e IA.

O mock de ServerStorage é uma Instance, permitindo testar a substituição do personagem e a restauração após a troca. O mock de classificação é explícito: só corrige Hair quando a fixture pede. A ordem dos emotes não muda mais a comparação de aparência; o teste garante que a lista salva permanece na sua ordem e mudanças reais de emote/rig continuam detectadas.

Nenhum teste baixa malhas/texturas dos IDs nem comprova a classe real desses assets. API e renderização nativas ainda precisam de execução no Roblox.

97 fontes efetivas passaram na sintaxe. Hashes dos 32 arquivos da V56 permaneceram corretos, dependências existem e há um único dono de ProcessReceipt. O instalador executou seu JavaScript real em Node com DOM mínimo: sete fontes, substituição sem NOVO, copiar inteiro/partes, fallback manual, hashes, cache, ONLINE verde e offline. Não houve teste de CSS no navegador.

Documentação primária consultada:
- [AccessoryDescription](https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/AccessoryDescription.yaml): IsLayered pode ser corrigido na aplicação; GetAppliedInstance usa descrição aplicada sob Humanoid.
- [WrapLayer](https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/WrapLayer.yaml): Enabled controla a existência funcional da camada.
- [HumanoidDescription](https://create.roblox.com/docs/reference/engine/classes/HumanoidDescription).

Veja INSTALL_V57.md para instalação e conferência no Roblox. Não houve cobrança, publicação da experiência Roblox ou acesso ao Studio do usuário.
