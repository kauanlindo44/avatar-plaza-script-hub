# Instalação V61 — 8 novos + 37 substituições

Requer V60 completa. V61: 8 scripts NOVOS + 37 SUBSTITUIÇÕES. Pare Play, crie primeiro os oito módulos novos nos locais indicados, substitua as 37 fontes completas e reinicie Play. Não inclua NOVO/SUBSTITUIR no nome da instância. Nenhum passe ou produto novo. Guia: INSTALL_V61.md.

## Criar primeiro — NOVOS

| Nome exato | Tipo | Local | Linhas |
|---|---|---|---:|
| `07G4_WORLD_SCENERY` | ModuleScript | ReplicatedStorage | 82 |
| `07G5_CHAT_COMMANDS` | ModuleScript | ReplicatedStorage | 18 |
| `07H6_GAME_MOMENTS` | ModuleScript | ReplicatedStorage | 35 |
| `07M2_AUDIO_LIBRARY` | ModuleScript | ServerScriptService | 35 |
| `07P9_STUDIO_CATALOG` | ModuleScript | ReplicatedStorage | 46 |
| `09B9_GLOBAL_LOOKS` | ModuleScript | ServerScriptService | 154 |
| `09C3_CATALOG_FILTERS` | ModuleScript | ReplicatedStorage | 38 |
| `09C9_SPONSOR_PICKER` | ModuleScript | ReplicatedStorage | 44 |

## Substituir nas instâncias existentes

| Nome exato | Tipo | Local | Linhas |
|---|---|---|---:|
| `07G1_HUB_SETTINGS` | ModuleScript | ReplicatedStorage | 111 |
| `07G2_LOCAL_WORLDS` | ModuleScript | ReplicatedStorage | 110 |
| `07G3_PERSONAL_TOOLS` | ModuleScript | ReplicatedStorage | 56 |
| `07H2_GAME_BOARD` | ModuleScript | ReplicatedStorage | 155 |
| `07K2_TRUCO_MATCH` | ModuleScript | ServerScriptService | 75 |
| `07K5_TRUCO_UI` | ModuleScript | ReplicatedStorage | 150 |
| `07M1_MUSIC_UI` | ModuleScript | ReplicatedStorage | 56 |
| `07P2_STUDIO_AVATAR` | ModuleScript | ReplicatedStorage | 208 |
| `07P4_STUDIO_UI` | ModuleScript | ReplicatedStorage | 121 |
| `07P7_ROBLOX_BACKGROUNDS` | ModuleScript | ReplicatedStorage | 34 |
| `07P8_BACKGROUND_RESOLVER` | ModuleScript | ServerScriptService | 33 |
| `09B1_AVATAR_DISCOVERY` | ModuleScript | ServerScriptService | 129 |
| `09B4_CURATED_LOOKS` | ModuleScript | ServerScriptService | 145 |
| `09B8_FREE_HIGHLIGHTS` | ModuleScript | ServerScriptService | 159 |
| `09C2_SHOP_CATALOG` | ModuleScript | ReplicatedStorage | 257 |
| `09C5_UGC_STORES` | ModuleScript | ReplicatedStorage | 146 |
| `09C7_COMMUNITY_FEED` | ModuleScript | ReplicatedStorage | 146 |
| `09I0_ASSISTANT_CONFIG` | ModuleScript | ReplicatedStorage | 10 |
| `09I2_ASSISTANT_ENGINE` | ModuleScript | ServerScriptService | 30 |
| `09I3_OUTFIT_BUILDER` | ModuleScript | ServerScriptService | 102 |
| `09I4_ASSISTANT_UI` | ModuleScript | ReplicatedStorage | 131 |
| `09I7_ASSISTANT_PROFILE` | ModuleScript | ReplicatedStorage | 53 |
| `01B_HUB_WORLD` | Script | ServerScriptService | 122 |
| `01C_HUB_CHALLENGES` | Script | ServerScriptService | 225 |
| `07A_CHESS` | Script | ServerScriptService | 346 |
| `07B_CHECKERS` | Script | ServerScriptService | 327 |
| `07G_HUB_UI` | LocalScript | StarterPlayer > StarterPlayerScripts | 99 |
| `07G_SETTINGS_SERVER` | Script | ServerScriptService | 54 |
| `07H_GAME_UI` | LocalScript | StarterPlayer > StarterPlayerScripts | 244 |
| `07K_TRUCO_SERVER` | Script | ServerScriptService | 277 |
| `07M_MUSIC_CLIENT` | LocalScript | StarterPlayer > StarterPlayerScripts | 137 |
| `07M_MUSIC_SERVER` | Script | ServerScriptService | 21 |
| `07P_PHOTO_MODE` | LocalScript | StarterPlayer > StarterPlayerScripts | 185 |
| `09B_SHOP_SERVER` | Script | ServerScriptService | 250 |
| `09C_SHOP_CLIENT` | LocalScript | StarterPlayer > StarterPlayerScripts | 381 |
| `09I_ASSISTANT_CLIENT` | LocalScript | StarterPlayer > StarterPlayerScripts | 85 |
| `09I_ASSISTANT_SERVER` | Script | ServerScriptService | 105 |

## Instalar sobre a V60

Use **AVATAR_PLAZA_V61.html** ou sincronize o instalador permanente. A **V60 completa precisa estar instalada**. Pare Play; crie os oito ModuleScripts NOVOS da tabela; substitua as 37 fontes completas nas instâncias existentes; reinicie Play para limpar o cache. Não duplique scripts substituídos. Use os nomes exatos, sem escrever “NOVO” ou “SUBSTITUIR” no nome da instância.

O HTML mostra nome, tipo, local, última linha e botões de copiar, com fontes recolhidas. O delta contém somente mudanças da V61. `09A_SHOP_UI` não mudou: sua instalação histórica continua em quatro partes. Todas as fontes deste delta têm no máximo 400 linhas.

Mantenha também os módulos originais já usados pela instalação completa: `07Z_BOARD_VISUALS` no ServerScriptService, e `07P1_CAPTURE_ENGINE`/`08L_COMMUNITY` nos locais do projeto existente. Eles são dependências anteriores, não scripts novos deste pacote; seu código não está entre as 109 fontes versionadas auditadas.

**Nenhum Game Pass, Developer Product, chave OpenAI ou servidor externo novo é necessário.** Os produtos antigos IA Studio `3717699383` e IA Pro `3717699454` devem permanecer fora de venda. Não exclua compras/recibos: direitos já comprados continuam reconhecidos até expirar. Salem `3717699522` permanece. A V61 não reabre vendas de planos.

Para testar persistência no Studio, publique a experiência e configure o acesso às APIs de DataStore conforme seu projeto. Comandos usam o chat moderno `TextChatService`. A disponibilidade **16+** deve ser configurada no Creator Dashboard; scripts não substituem a classificação nem a verificação de idade Roblox.

## Música pronta ao abrir

**Descobrir, Fila e Salvos** ficam no painel compacto, com ID/link sempre acessível. A pesquisa inicial consulta músicas do Creator Store usando “lofi”. Até oito resultados formam a fila inicial; o primeiro áudio confirmado toca a **40%** quando não existe preferência anterior. Preferências salvas têm prioridade.

Buscar por nome consulta o catálogo; Mais avança a página. A biblioteca inicial usa cache de dez minutos e atualiza enquanto Descobrir está aberto sem pesquisa digitada. ID/link procura um áudio específico, cujo tipo é confirmado no servidor. Fila permite anterior/próxima, pausa e adição; Salvos mantém favoritos. Ao terminar uma faixa, começa a próxima. Cada pessoa escolhe sua música e volume; abrir catálogo/IA não precisa parar o áudio.

**Não existe acesso universal a toda música privada ou moderada.** A pesquisa retorna o catálogo acessível ao serviço Roblox; reprodução depende das permissões da experiência. Falha de consulta/reprodução tem aviso, sem IDs fictícios ou anúncio de sucesso.

## Patrocinar + IA

Destaques passa a **Patrocinar + IA**, com duas abas. A vitrine mantém um item ativo por pessoa por **24 horas**, sem cobrança, prioridade paga ou duplicação simultânea do mesmo item. Reenvio não aumenta o prazo; retirar não libera antecipadamente outro envio.

Fluxo: **Publicar grátis → procurar nome ou colar ID/link → escolher → Conferir → Publicar grátis**. A pesquisa já oferece exemplos antes de digitar, com filtros de roupas/acessórios/corpos/emotes. O servidor confirma tipo, disponibilidade e preço. Selecionar não publica automaticamente.

Quando não existe patrocínio ativo no índice global, são mostrados itens reais identificados como **Exemplo temporário**. Publicações atualizam a vitrine local por evento; entre servidores, MessagingService notifica quando disponível e a atualização periódica recupera falhas. Depois que o último item expira, os exemplos voltam. Exemplos não são publicações de jogadores.

Em celular deitado com espaço suficiente são duas/três linhas horizontais, até sete cards visíveis por linha e no máximo 45 por página. Telas mais baixas reduzem a quantidade para preservar leitura e toque. Busca/filtros continuam. **♡** salva favoritos sem adicionar ao carrinho. Tocar no card abre detalhes/compra oficial. Favoritos persistem como marcadores depois da expiração.

### Limites da IA

É um **assistente de looks por pesquisa no catálogo**, com estilos, cores, orçamento e formato de roupa. Não é chatbot generativo geral nem uma cópia funcional do ChatGPT. Looks não dependem mais do gerador de texto que retornava HTTP 400 e não pedem chave externa.

O texto passa pelo filtro Roblox; o planejador identifica estilo e busca peças reais; consulta novamente preços e orçamento; valida a aparência com o carregador do projeto antes de entregar. Falta de peças, aparência inválida ou preço acima do limite gera aviso e devolve a solicitação reservada. IDs não são inventados, e o avatar não é aplicado automaticamente. A validação não garante perfeição estética de toda combinação.

Normal entrega um look. Direitos Studio/Pro comprados anteriormente conservam os limites de dois/cinco até vencer, quando existem resultados válidos. Ajuda responde sobre funções suportadas do jogo e informa seu limite. A interface mantém tema Halloween, histórico da sessão e salvar/experimentar. Não armazena a conversa no perfil persistente nem cria senha Roblox ou compartilhamento de conta Roblox. Quotas/consentimentos existentes permanecem.

## Comunidade — Todos e Grátis

Existem somente **Todos** e **Grátis**. Todos inclui descoberta de jogadores e publicações manuais. A busca aceita códigos, com preço mínimo/máximo. Grátis exige preço conhecido zero; preço não verificado não vira grátis. Preço arquivado representa a última consulta e pode mudar no Roblox.

Cada entrada consulta páginas públicas de amigos e registra IDs descobertos no índice global. Outra pessoa contribui com novos IDs; sair não apaga gravações confirmadas. 200 + 500 contas diferentes ficam acessíveis no acervo global. Contas repetidas são eliminadas; aparências iguais verificadas compartilham o código do arquivo.

Miniaturas são paginadas sem esperar todos os modelos 3D. Há até 50 slots reutilizados e uma janela limitada de dados no cliente. A fila persistente verifica uma aparência por etapa e registra checkpoints; retoma após reiniciar, inclusive além dos primeiros 50 contribuidores. Leituras do índice e cache de trabalhos são limitados. Nenhum lote com centenas de avatares é instanciado de uma vez.

**Conta registrada e look arquivado são etapas diferentes.** Snapshot só é anunciado após confirmação do DataStore. APIs indisponíveis/limites deixam verificação pendente ou geram aviso. Não promete todas as skins instantaneamente nem cada mudança futura feita por um amigo.

| Código/dado | Significado |
|---|---|
| `AV-<UserId>` | Aparência atual da conta Roblox com cache temporário; não é snapshot imutável. |
| `LK-<16 dígitos hexadecimais>` | Aparência salva no arquivo global. Looks iguais compartilham código; aparência diferente gera outro. Busca recupera o corpo salvo. |
| Código `AP` publicado | Publicação manual existente; também aparece em Todos. |
| Meus looks | Armazenamento privado de looks salvos manualmente. |
| Última aparência aplicada/confirmada | Continua restaurada ao voltar quando a gravação confirmou. |

Cards mostram **Look de jogador + código**. A origem em amizades não vira categoria visual. Apenas dados públicos via Roblox são consultados, sem credenciais, mensagens ou dados privados dos amigos.

## Photo Mode — fundos da loja e emotes na cópia

Fundos abre lista lateral de `AvatarBackground` à venda, com pesquisa, Mais, Testar e **Comprar** oficial. Posse não é requisito para experimentar. O servidor confirma tipo/disponibilidade e tenta obter imagem sem executar scripts do conteúdo carregado. O cliente confirma carregamento antes de trocar. Se a imagem direta não carregar, pode usar a miniatura oficial daquele mesmo asset, identificada como **Prévia oficial da loja**. Se ambas falharem, mantém o fundo anterior e informa o erro.

Fundos de perfil são **2D**, não mapas 3D. A cópia fica horizontalmente centralizada e acima dos controles inferiores; girar o avatar não gira o fundo. Emotes consulta o catálogo real e encaminha a seleção para humanoid/animator da própria cópia. Parar interrompe o emote; Neutro remove o fundo. Compra não é requisito para prévia permitida pelo serviço. Fundos/emotes e renderização precisam de confirmação nativa; poses, cópia exata e itens/X permanecem.

## Configurações, comandos e mundos

Categorias coloridas ficam em fileiras quando a altura permite, ou grade compacta em tela baixa; X separado. Comandos mostram descrição/ação e também funcionam no chat.

| Comando | Ação pessoal |
|---|---|
| `/fly`, `/unfly` | Iniciar/parar voo; no celular use movimento/pulo e direção da câmera. |
| `/speed 16` até `/speed 32`, `/walk` | Ajustar velocidade ou restaurar 16. |
| `/jump 50` até `/jump 80`, `/unjump` | Ajustar pulo ou restaurar 50. |
| `/size 0.9` até `/size 1.15`, `/unsize` | Escala pessoal limitada/restauração, sujeita à compatibilidade do corpo. |
| `/normal` | Restaurar ajustes de movimento. |
| `/fov 60` até `/fov 90` | Campo de visão da câmera. |
| `/catalog`, `/photo`, `/music`, `/commands` | Abrir catálogo, estúdio, música ou lista. |

Comandos afetam quem digitou. Movimento personalizado é restaurado/bloqueado em partidas; não há matar/expulsar/alterar outro jogador. A lista é própria, via TextChatCommand; não se afirma que seja a lista exata do Catalog Avatar Creator.

**Anime, Neon, Costa, Halloween e Nuvens** usam arquitetura original: vila/pagoda/dojo; avenida/torres; praia/píer; casas assombradas/cercas; arcos/nuvens. Visual, chão e iluminação mudam localmente. Original restaura o mapa. Não importa conteúdo de franquias.

Construções são limitadas; chão acompanha deslocamento. O servidor mantém blocos físicos próximos dos jogadores/spawn, removendo os demais; cada cliente reutiliza 25 partes visuais ao redor da posição. Não replica uma grade de 15.000 studs inteira. A borda antiga de 385 foi removida; recuperação de queda permanece. Contínuo não significa coordenadas matematicamente infinitas: o motor tem limites numéricos/físicos.

## Partidas com continuidade

Xadrez/damas mantêm último tabuleiro, resultado e placar da sessão. Há **Rever tabuleiro, Revanche e Outro adversário**. Contra pessoas, revanche exige as duas confirmações, alterna os lados e expira em dois minutos; torneios não usam revanche informal. Tokens antigos/alheios são rejeitados. Contra bots, nova partida conserva placar da sessão, sem novo prêmio/ranking.

Truco mostra placar das partidas vencidas pela dupla e oferece até dois minutos para decisão de revanche. Pedidos de truco conservam resposta em dez segundos e regras/variantes anteriores. Não muda hierarquia de cartas nem inventa jogadas para criar animações.

## Filtros do catálogo

Preço em Robux, Criador, Disponibilidade e Formato de roupa ficam separados, com Aplicar/X. Preço negativo, decimal, não numérico ou mínimo maior que máximo mantém painel aberto com aviso. O botão indica filtros ativos. **Clássicas 2D** e **Roupas 3D** substituem opções redundantes. Catálogo geral inclui grátis por padrão; prioridade de pagos fica na categoria Corpo. Prévia, itens equipados/X e diagnóstico de aplicação da base anterior permanecem.

## Testar no Roblox depois de instalar

1. Instale oito novos/37 substituições; reinicie Play; confira módulos/Output. Teste celular em pé/deitado.
2. Abra música: lista + ID devem aparecer juntos. Confira fila, 40%, pausa/próxima, nome/ID permitido e áudio bloqueado; falha não deve ser sucesso.
3. Abra Patrocinar vazio: exemplos identificados. Procure nome, confira/publique, favorite e abra compra. Confira outro servidor e exemplos após expiração/retirada.
4. Peça look emo com orçamento/formato. Confira preços/peças/aparência. Resultado inválido não deve aplicar nada; ajuda informa limite e planos continuam fora de venda.
5. Use duas contas com listas públicas distintas, aguarde verificação, reinicie servidor e busque AV/AP/LK. Confira Todos/Grátis/preços. A primeira abertura não garante fila concluída.
6. Teste fundo da loja não possuído, compra, emote e giro da cópia. Confira centro. Asset bloqueado mantém fundo anterior e informa falha.
7. Teste chat/lista de comandos, bloqueio de movimento em partidas e mundo local independente de outro jogador.
8. Caminhe além da borda antiga, confira chão/partes limitadas, temas e restauração Original.
9. Termine partidas reais e contra bots, revise tabuleiro e confirme revanche dos dois. Confira dupla/placar/tempo no truco.
10. Teste filtros válidos/inválidos, roupa layered e corpo incomum na prévia/mapa. Se falhar, use diagnóstico existente no Output; V61 não declara todo corpo aprovado pela simulação.

## Validação e referências

**31 cenários simulados** (19 de regras/serviços + 12 de interface/controladores), seis geometrias, sintaxe das **109 fontes efetivas**, hashes/dependências históricos e JavaScript real do instalador passaram. Simulações não compram itens, não usam serviços reais nem renderizam o motor Roblox. Testes nativos acima continuam necessários.

Referências primárias: [AudioSearchParams](https://create.roblox.com/docs/reference/engine/classes/AudioSearchParams), [AssetService](https://create.roblox.com/docs/reference/engine/classes/AssetService), [permissões de áudio](https://create.roblox.com/docs/audio/assets), [CatalogSearchParams](https://create.roblox.com/docs/reference/engine/datatypes/CatalogSearchParams), [AvatarEditorService](https://create.roblox.com/docs/reference/engine/classes/AvatarEditorService), [AvatarAssetType](https://create.roblox.com/docs/reference/engine/enums/AvatarAssetType), [Humanoid/emotes](https://create.roblox.com/docs/reference/engine/classes/Humanoid), [TextChatCommand](https://create.roblox.com/docs/reference/engine/classes/TextChatCommand), [DataStore](https://create.roblox.com/docs/cloud-services/data-stores), [MemoryStoreSortedMap](https://create.roblox.com/docs/reference/engine/classes/MemoryStoreSortedMap) e [MessagingService](https://create.roblox.com/docs/reference/engine/classes/MessagingService).

Gratuidade não garante isenção das [Community Standards](https://about.roblox.com/community-standards) ou [Advertising Standards](https://en.help.roblox.com/hc/en-us/articles/13722260778260-Advertising-Standards). É recomendação voluntária de itens do catálogo, sem contrapartida/anúncio pago; não representa certificação de aprovação Roblox.
