# Avatar Plaza — V59

Atualização pequena sobre a V58 publicada (`eee3fb7a7114b8cdb6828436c78556817938ecf5`): **quatro substituições da IA, nenhum script novo**. Requer V58 completa.

Abra [AVATAR_PLAZA_V59.html](AVATAR_PLAZA_V59.html) ou sincronize o [instalador permanente](AVATAR_PLAZA_SCRIPT_HUB_PERMANENTE.html). [INSTALL_V59.md](INSTALL_V59.md) lista nomes, tipos, locais e o teste nativo. Pare Play, substitua as quatro fontes completas e reinicie.

Na V58, um pedido em inglês ainda recebia instrução para responder em português e preferir JSON. A V59 remove essa exigência e usa **inglês/texto simples durante o teste de compatibilidade**, identificado na conversa. Continua usando **TextGenerator do Roblox, sem chave OpenAI**. Os controles permanecem em português; os atalhos enviam pedidos em inglês. Não há tradução automática nem resposta local disfarçada de IA.

**Recarregar IA** compara a instrução completa do assistente com o exemplo mínimo oficial. O Output `[IA V59]` distingue HEALTH, REFERENCE e ASK e conserva o erro original. A referência funcionar não oculta falha na instrução real. A disponibilidade mostra “verificada”; cada pedido ainda pode falhar. Compras exigem saúde completa e as verificações existentes de armazenamento/produto. Falhas continuam devolvendo os limites.

Recarregar e X têm posições separadas, as abas estreitas reservam espaço para recuperação, mensagens do jogador ficam à direita e o compositor permanece acima do teclado. A função duplicada que anulava o alinhamento foi removida.

**14 cenários simulados**, seis resoluções, quatro abas, dois estados de conexão, sintaxe das **98 fontes efetivas** e JavaScript real do instalador verificados. [Auditoria](audits/V59/README.md). **O HTTP 400 ainda não foi confirmado como resolvido no TextGenerator real.** O guia descreve o teste no Roblox e a interpretação dos dois resultados.

O catálogo, os itens/X abaixo da prévia, música, carrinho, Photo Mode, jogos e o diagnóstico de roupa da V58 continuam no pacote. Os produtos existentes e o único ProcessReceipt foram preservados. O HTML inclui V59/V58/V57/V56/V55 e a instalação V44 para uso offline, além da sincronização pelo GitHub.
