# Instalação V59 — somente 4 substituições

Requer V58 completa. V59: somente 4 SUBSTITUIÇÕES da IA; nenhum script novo. Pare Play, substitua as fontes completas nos locais indicados e reinicie Play. Recarregar IA compara o assistente com o exemplo oficial. Respostas em inglês neste teste de compatibilidade. Guia: INSTALL_V59.md.

| Nome exato | Tipo | Local | Linhas |
|---|---|---|---:|
| `09I2_ASSISTANT_ENGINE` | ModuleScript | ServerScriptService | 87 |
| `09I4_ASSISTANT_UI` | ModuleScript | ReplicatedStorage | 129 |
| `09I_ASSISTANT_CLIENT` | LocalScript | StarterPlayer > StarterPlayerScripts | 79 |
| `09I_ASSISTANT_SERVER` | Script | ServerScriptService | 121 |

## Instalar

Use o HTML V59 novo ou sincronize o instalador permanente. **A V58 completa precisa estar instalada.** Pare Play, substitua as quatro fontes completas nas instâncias existentes e reinicie Play para limpar o cache de ModuleScript. Não acrescente “SUBSTITUIR” ao nome da instância. Não há script, passe ou produto novo.

## O que estava errado

Na V58, mesmo um pedido escrito em inglês recebia uma instrução interna para responder em português e preferir JSON. Por isso o teste em inglês não isolava idioma/formato. A sonda curta “READY” também tinha uma instrução diferente da solicitação real. Ela podia funcionar enquanto o pedido do jogador falhava.

A V59 solicita **resposta em inglês e texto simples**, com idioma identificado na conversa. Os botões e configurações continuam em português. Os atalhos de look enviam pedidos em inglês; mensagens próprias continuam passando pelo filtro Roblox. Não há tradução automática nem chave OpenAI. Essa é uma medida de compatibilidade para testar a chamada nativa; não comprova que o idioma causou o HTTP 400 observado.

O transporte normaliza acentos e retira símbolos problemáticos depois da moderação. O gerador fica em Workspace e usa os parâmetros válidos do exemplo oficial. Esses ajustes não são apresentados como prova de que a posição do objeto ou os valores padrão causaram o erro.

## Teste no Roblox

1. Instale as quatro substituições e reinicie Play.
2. Abra IA e toque **Recarregar IA**. Aguarde a conclusão; cada chamada pode levar até 18 segundos.
3. Toque **Look emo** e confirme a criação. O atalho envia `Create an emo avatar look`. Para testar só a resposta, escolha **Pedir ajuda** e envie `Help with Photo Mode`.
4. Confira o **Output do servidor** procurando `[IA V59]`. Recarregar compara duas chamadas independentes:

| Registro | Chamada |
|---|---|
| `modo=HEALTH` | Instrução completa do assistente, inglês/texto simples e o mesmo limite do pedido real. |
| `modo=REFERENCE` | Exemplo mínimo oficial: instrução de NPC, pedido em inglês e limite de 50 tokens. |
| `modo=ASK` | Pedido real do jogador, já moderado e normalizado. |

A linha `diagnóstico=` mantém os resultados separados. **REFERÊNCIA OK não anuncia o assistente disponível se HEALTH falhou.** Uma falha inclui modo, etapa, número do pedido e erro original; não imprime a mensagem privada do jogador.

| Resultado | O que ele permite concluir |
|---|---|
| Referência OK, assistente HTTP 400 | O exemplo mínimo funcionou, mas o contrato completo foi recusado. É preciso comparar a instrução/pedido, sem atribuir a causa apenas ao idioma. |
| Referência HTTP 400, assistente HTTP 400 | O exemplo mínimo também foi recusado nesse ambiente. Isso desloca a investigação para disponibilidade/contrato nativo e contexto da experiência; ainda não identifica uma causa exata. |
| Ambos OK, ASK HTTP 400 | As sondas funcionaram, mas a geração daquele pedido falhou. O modo ASK conserva a etapa e a causa nativa. |
| Ambos OK e resposta na conversa | A chamada real funcionou naquele teste. A busca do catálogo e montagem do look têm suas próprias etapas. |

O estado agora mostra **verificada**, evitando confundir uma sonda com garantia de todas as solicitações. Falhas da geração atualizam o botão de recuperação e continuam devolvendo o limite diário e da sessão. Comprar plano exige que a sonda completa do assistente funcione, além das verificações existentes de armazenamento/produto.

## Interface

Recarregar e X têm posições separadas. As abas Looks/Salvos/Perfil reservam uma linha para recuperação em telas estreitas. As mensagens do jogador ficam à direita; a função duplicada que anulava essa posição foi removida. O compositor fica acima do teclado e “Nova conversa” restaura a mensagem inicial.

## Validação e limites

Foram aprovados **14 cenários simulados** em Lua 5.4, incluindo o controlador real do cliente, reembolso, bloqueio de compra quando só a referência funciona, respostas inválidas, timeout e recuperação. A geometria foi conferida em seis tamanhos de tela, quatro abas e dois estados de conexão. A sintaxe das **98 fontes efetivas** e o JavaScript real do instalador foram verificados.

Os testes locais não executam o TextGenerator real nem renderizam a interface no motor Roblox. Não há confirmação de que o HTTP 400 foi resolvido no serviço. Esta atualização fornece uma correção concreta da instrução e um teste que separa os caminhos que estavam misturados.

Referências consultadas: [TextGenerator — documentação Roblox](https://create.roblox.com/docs/reference/engine/classes/TextGenerator) e [relato de idioma/caracteres com resposta da equipe Roblox em 2025](https://devforum.roblox.com/t/textgenerators-can-only-return-english-characters/4018138). O relato é histórico; não é tratado como prova de restrição permanente em 2026.
