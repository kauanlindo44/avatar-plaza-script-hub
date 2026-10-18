## Instalação

1. Instale a **V68 completa** antes desta atualização. Pare Play e guarde uma cópia do lugar.
2. Crie os **oito ModuleScripts NOVOS** da primeira tabela, nos locais indicados.
3. Crie o **Script `09I_ACTIVITIES_SERVER`** e o **LocalScript `09I_ACTIVITIES_CLIENT`**. São dois scripts diferentes, com tipos e locais diferentes.
4. Substitua a fonte inteira dos **35 scripts existentes** da segunda tabela. Mantenha uma única instância de cada nome.
5. Reinicie Play somente depois de instalar o conjunto. Não acrescente `(NOVO)` ou `(SUBSTITUIR)` ao nome da instância.

O HTML mantém o código recolhido, nome/tipo/local, última linha e **Copiar script inteiro**. As duas partes são opcionais. O `09A_SHOP_UI` continua nas quatro partes anteriores: não há nova substituição dele. Não crie passes, produtos ou chaves para a V69. Nenhum serviço externo pago foi ativado.

## Direção visual

As definições do responsável estão em [DIRETRIZES_VISUAIS.md](DIRETRIZES_VISUAIS.md): **BUSCAR O EQUILÍBRIO ENTRE EXCESSO E FALTA.** Legal significa bem feito, divertido, com personalidade e agradável de observar. Lindo significa uma composição cuidadosa, sem repetição ou preenchimento sem propósito.

A base agora é clara, com tinta azul acinzentada, verde principal e detalhes de cor conforme a função. Catálogo, HUD, looks, comunidade, patrocínio, assistente, música, configurações e ferramentas de foto seguem essa família. Seleção usa texto/borda além da cor. O avatar mantém o destaque e os itens equipados com X continuam abaixo da prévia. A prévia usa um cinza médio para separar roupas claras e escuras. O Halloween continua opcional, agora com decoração contida; Automático termina em **01/11/2026, 00h de Brasília**.

Truco recebe feltro verde, borda de madeira clara e identificação de dupla/rivais. Xadrez e damas usam casas creme e verde, peças persistentes entre atualizações e movimento visual curto. Essas animações acompanham o estado recebido; não seguram jogadas, relógios ou respostas. Regras, dificuldade dos bots, turnos, pontuação, produtos e recibos permanecem preservados.

Árvores deixam as fileiras regulares e passam a grupos assimétricos planejados, com clareiras e passagem central. Cada mundo tem variações coerentes de escala, copa e cor. Grama, madeira, areia e pedra usam materiais nativos: não é necessário enviar texturas. A decoração continua local, com limites de partes e sem colisão; o sistema existente de chão/respawn não foi substituído.

## Conversa privada de cada partida

O botão **Conversa** abre o chat próprio em truco, xadrez e damas. Só participantes humanos da mesma partida entram. Partidas com bots sem outro humano apresentam uma explicação; bots não simulam mensagens de jogadores.

O servidor cria um `TextChannel` exclusivo e define seus participantes a partir da partida real. Envio usa `SendAsync`; recebimento aceita somente mensagens confirmadas pelo Roblox naquele canal. Texto não passa pelos RemoteEvents do projeto. O módulo consulta permissões oficiais, marca a conversa privada e usa `ShouldDeliverCallback` sem espera para restringir remetente e destinatário. Bloqueios, filtragem e elegibilidade continuam sob controle do Roblox; o script não libera comunicação negada pela plataforma. Não há alternativa sem filtro quando uma consulta falha.

Revanche cria outra conversa; sair ou encerrar a sessão remove o acesso. Xadrez/damas encerram o canal ao terminar a partida; truco conserva a conversa na mesa até sair, fechar ou começar uma revanche. O chat padrão do Roblox permanece disponível. Denúncias usam o menu oficial Roblox > Denunciar.

**Configuração necessária:** a experiência deve usar o chat oficial atual (`TextChatService`) e permitir comunicação na configuração da plataforma. Use duas contas elegíveis para testar; classificação 16+ por si só não garante acesso ao chat para todas as contas. As permissões de uma conta não podem ser habilitadas por estes scripts.

## Quatro atividades de criação assistida

Abra **Patrocinar + assistente > Assistente > Criar com amigos**. O guia do assistente também explica cada atividade. O sistema usa o montador e a busca real de catálogo existentes: é criação assistida por regras e catálogo, sem uma IA geral externa ou cobrança nova.

| Atividade | Funcionamento |
|---|---|
| Look em colaboração | Até quatro participantes no mesmo servidor, por convite aceito. Cada um contribui com uma parte escolhida do próprio avatar. Estilo, paleta e limite de preço ficam claros; contribuições identificadas. Aplicar e guardar exigem ação explícita. |
| Duplas com personalidade | Dois participantes escolhem seus próprios estilos e compartilham uma paleta. O montador busca um look distinto para cada um. Cada participante aplica ou guarda o próprio resultado. |
| Ensaio temático | Escolha estilo/paleta e abra um roteiro de três enquadramentos no Photo Mode. Os passos ajustam a cópia e dão instruções de pose; você avança, volta ou oculta o roteiro. O avatar do mapa não é movido pelo roteiro. |
| Remix autorizado | O criador compartilha uma combinação por código, autoriza explicitamente e pode revogar. Outro jogador abre o código e solicita uma variação. A identificação do criador original e a cadeia de origem acompanham o resultado e o look guardado. |

Convites duram três minutos; sessões em memória expiram após trinta minutos. Quem recebe precisa aceitar. Sair do servidor encerra sua participação. Aplicar, guardar e compartilhar são ações separadas; não há compra automática. As sessões são por servidor; códigos de remix são persistentes.

**Remix e autoria:** compartilhar cria primeiro um código **bloqueado**. Em Meus códigos, o criador escolhe autorizar ou revogar. Uma colaboração só pode ser publicada depois de **todos os participantes que contribuíram autorizarem a composição atual**; alterar as contribuições reinicia essas autorizações. O remix conserva a autoria original e exige a autorização válida de cada origem da cadeia. O servidor confirma novamente a permissão depois da geração e antes das ações do fluxo; falhas de armazenamento não autorizam compartilhamento. Até vinte códigos por criador e oito níveis de origem limitam custo e complexidade.

Revogar bloqueia novos usos no fluxo de remix. Isso não retira itens do inventário Roblox, não desfaz avatares já aplicados e não apaga cópias já guardadas. A autoria permanece nos metadados. Não é uma proteção contra reprodução manual de um avatar público.

Os resultados são guardados na coleção **Atividades** do assistente, com colaboradores e origem quando houver. O orçamento é validado pelos itens cotáveis no catálogo; preços que não possam ser confirmados impedem a conclusão. Os limites diários dos planos existentes continuam valendo. Erros ou cancelamentos devolvem a reserva de geração uma vez. Não há garantia de compreensão visual infalível nem de disponibilidade de qualquer combinação de preço/estilo no catálogo Roblox.

## Verificações realizadas e pendências

- **126 cenários simulados em Lua 5.4:** catálogo, música, avatares, formulários e regressões, mais isolamento dos canais, permissões negadas, convites, orçamento, créditos, autorização/revogação, cancelamento e integração dos clientes/servidor.
- **146 fontes efetivas compiladas**, hashes e dependências conferidos, históricos preservados e único proprietário de `ProcessReceipt` mantido.
- **Sete geometrias de tela/teclado** nas verificações dos novos controles. Layouts de computador, celular em pé e deitado também foram extraídos do código e inspecionados como imagens ilustrativas.
- JavaScript real do instalador verificado em Node: cópia integral/partes, hashes, fallback offline, cache antigo, status online/offline e nomes/tipos/locais.

**Não houve execução no Roblox Studio/Player nem em um celular físico.** As imagens de auditoria são reconstruções geométricas com assets ilustrativos, não capturas nativas. Conferir no Roblox publicado:

1. Duas mesas simultâneas, participantes e espectadores: envio/recebimento filtrado somente na própria mesa; repetir com bloqueio, conta sem permissão, saída e revanche.
2. Convite, contribuição, geração, aplicar, guardar e reabrir a coleção; autorização de todos os colaboradores e revogação durante uma geração de remix.
3. Computador e celular real, em pé/deitado: recortes, teclado, texto, toque e sobreposição de janelas. Testar movimento reduzido e Halloween ligado/desligado.
4. Aparência das peças/cartas, prévias/avatares reais, áudio, emotes, permissões de assets, materiais, FPS e física nos mapas.

Problemas anteriores de assets negados, fundos indisponíveis ou malhas de avatares não são apresentados como universalmente corrigidos por uma reformulação visual. Os diagnósticos existentes continuam disponíveis. Avisos de `CorePackages/UIBlox` pertencem à interface interna do Roblox.

## Referências

- [Truco — MegaJogos](https://www.megajogos.com.br/truco-online): mesa como foco, identificação dos jogadores e cartas públicas agrupadas.
- [Xadrez — apresentação do Chess.com](https://www.chess.com/article/view/chesscom-live-going-away): tabuleiro dominante e painel auxiliar; a referência ilustrada não é apresentada como captura atual de todas as telas.
- [Ajustes de Live Chess](https://support.chess.com/en/articles/8614003-how-do-i-manage-my-live-chess-settings): informação de partida separada de preferências visuais.
- [Damas — MegaJogos](https://www.megajogos.com.br/damas-online): casas contrastantes e distinção de peças, com tabuleiro central.
- [Roblox: diretrizes de chat](https://create.roblox.com/docs/chat/guidelines), [TextChannel](https://create.roblox.com/docs/reference/engine/classes/TextChannel), [TextChatService](https://create.roblox.com/docs/reference/engine/classes/TextChatService) e [interface própria](https://create.roblox.com/docs/chat/examples/simple-custom-frontend-ui): implementação dos canais e restrições oficiais.
- [Roblox: cache de DataStore](https://create.roblox.com/docs/cloud-services/data-stores/versioning-listing-and-caching): leitura sem cache para decisões de autorização.
- [Co-criação humano/IA](https://arxiv.org/abs/2204.13217) e [colagens/remix no Pinterest](https://newsroom.pinterest.com/news/introducing-new-ways-to-create-and-share-collages/): inspiração para atividades com escolha do jogador e crédito, sem importar código ou arte.
