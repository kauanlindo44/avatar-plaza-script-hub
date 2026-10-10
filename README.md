# Avatar Plaza — V57

Correção sobre a V56 publicada (753693692bde6760da0356982e12c08e885aefa2): **7 substituições e nenhum script novo**. Requer V56 completa; 97 fontes efetivas, com até 380 linhas em cada fonte desta atualização.

Abra [AVATAR_PLAZA_V57.html](AVATAR_PLAZA_V57.html) ou o [instalador permanente](AVATAR_PLAZA_SCRIPT_HUB_PERMANENTE.html). [INSTALL_V57.md](INSTALL_V57.md) lista os sete nomes, tipos e locais. Pare Play, substitua os existentes e reinicie. O módulo 09C4_OUTFIT_LIBRARY continua na V55: a exigência incorreta de V56 foi removida do cliente.

O verificador usa a classificação da descrição efetivamente aplicada pelo Roblox. Cabelo solicitado como camada mas corrigido nativamente para rígido aceita Handle Part com SpecialMesh, sem exigência de WrapLayer. Roupa 3D permanece estrita: instância exata por ID, malha, camada ativa, R15 e corpo com WrapTarget. O fluxo completo preserva peças e aplica o look no mapa, com restauração em falha e aparência lembrada pelo sistema existente.

A comparação de aparência também passou a ordenar os mesmos IDs de emote, evitando recriar a prévia no Photo Mode por uma mudança na ordem do dicionário.

Diagnóstico mostra item/tipo/requisito quando há evidência, distingue validação, erro de script, exceção nativa, conteúdo, timeout e configuração; mantém causa original e código no Output. Erro do cliente também chega ao servidor, que valida o ID/tipo contra seu próprio avatar. Procure `[Avatar V57] FALHA` com o código da janela.

41 cenários simulados cobrem cabelo rígido corrigido com roupa em camadas, aplicação pelo cliente real ao fechar catálogo, carrinho V55, falhas genuínas por item, relatórios, rollback, prévias e Photo Mode. Sintaxe das 97 fontes, hashes da base V56 e JavaScript real do instalador também foram conferidos. [Relatório](audits/V57/README.md).

**Não houve execução no motor Roblox nem confirmação visual do gato abacaxi no mapa publicado.** Malhas, cages e replicação precisam de teste na experiência. Os IDs nos testes são metadados simulados; não carregam os assets reais.

Recursos Halloween, seis cenários locais do Photo Mode, IA, música, catálogo e jogos da V56 continuam instalados; veja [guia V56](INSTALL_V56.md). Não há novos passes/produtos, mudança de preço ou alteração de ProcessReceipt nesta correção.
