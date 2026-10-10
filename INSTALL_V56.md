# Instalação V56 — 28 substituições + 4 NOVOS

Requer V55 completa. Desative 07M_PLAZA_MUSIC se ele estiver instalado: 07M_MUSIC_CLIENT será o único controlador de música. V56: 32 instalações = 28 SUBSTITUIÇÕES + 4 NOVOS. Pare Play. Crie primeiro os novos ModuleScripts nos locais indicados, depois os novos Scripts/LocalScripts e substitua os existentes. Não duplique nomes. (NOVO)/(SUBSTITUIR) não faz parte do nome. Cada fonte tem até 400 linhas. Não substitua 09A_SHOP_UI nem regras de jogos nesta versão. Guia: INSTALL_V56.md.

## Criar — 4 NOVOS

| Nome exato | Tipo | Local | Linhas |
|---|---|---|---:|
| `07UI_HALLOWEEN_THEME` | ModuleScript | ReplicatedStorage | 120 |
| `08B5_AVATAR_DIAGNOSTICS` | ModuleScript | ReplicatedStorage | 58 |
| `07UI_THEME_CLIENT` | LocalScript | StarterPlayer > StarterPlayerScripts | 4 |
| `09C12_AVATAR_FEEDBACK` | LocalScript | StarterPlayer > StarterPlayerScripts | 102 |

## Substituir — 28 existentes

| Nome exato | Tipo | Local | Linhas |
|---|---|---|---:|
| `07K16_ATELIER_UI` | ModuleScript | ReplicatedStorage | 129 |
| `07K7_CARD_STYLES` | ModuleScript | ReplicatedStorage | 160 |
| `07K9_CARD_INVENTORY_UI` | ModuleScript | ReplicatedStorage | 170 |
| `07M1_MUSIC_UI` | ModuleScript | ReplicatedStorage | 48 |
| `07P0_STUDIO_PRESETS` | ModuleScript | ReplicatedStorage | 21 |
| `07P2_STUDIO_AVATAR` | ModuleScript | ReplicatedStorage | 202 |
| `07P4_STUDIO_UI` | ModuleScript | ReplicatedStorage | 119 |
| `07P6_STUDIO_SETS` | ModuleScript | ReplicatedStorage | 91 |
| `07UI_DESIGN_SYSTEM` | ModuleScript | ReplicatedStorage | 161 |
| `07UI_SURFACE_EFFECTS` | ModuleScript | ReplicatedStorage | 65 |
| `08B3_AVATAR_VERIFY` | ModuleScript | ReplicatedStorage | 40 |
| `08B4_AVATAR_LOAD` | ModuleScript | ReplicatedStorage | 102 |
| `09A1_SHOP_LAYOUT` | ModuleScript | ReplicatedStorage | 178 |
| `09A2_PREVIEW_LAYOUT` | ModuleScript | ReplicatedStorage | 62 |
| `09A4_UTILITY_SKIN` | ModuleScript | ReplicatedStorage | 68 |
| `09B5_AVATAR_RUNTIME` | ModuleScript | ServerScriptService | 213 |
| `09I2_ASSISTANT_ENGINE` | ModuleScript | ServerScriptService | 37 |
| `09I3_OUTFIT_BUILDER` | ModuleScript | ServerScriptService | 84 |
| `09I4_ASSISTANT_UI` | ModuleScript | ReplicatedStorage | 105 |
| `09I5_ASSISTANT_QUESTIONNAIRE` | ModuleScript | ReplicatedStorage | 56 |
| `09I6_ASSISTANT_RESULTS` | ModuleScript | ReplicatedStorage | 130 |
| `09I7_ASSISTANT_PROFILE` | ModuleScript | ReplicatedStorage | 51 |
| `07M_MUSIC_CLIENT` | LocalScript | StarterPlayer > StarterPlayerScripts | 79 |
| `07P_PHOTO_MODE` | LocalScript | StarterPlayer > StarterPlayerScripts | 180 |
| `09B_SHOP_SERVER` | Script | ServerScriptService | 211 |
| `09C_SHOP_CLIENT` | LocalScript | StarterPlayer > StarterPlayerScripts | 380 |
| `09I_ASSISTANT_CLIENT` | LocalScript | StarterPlayer > StarterPlayerScripts | 77 |
| `09I_ASSISTANT_SERVER` | Script | ServerScriptService | 121 |

## Copiar e instalar

Esta atualização é um delta sobre a **V55 completa**. Pare Play antes de copiar. Crie os quatro NOVOS no tipo/local indicado e substitua os 28 existentes. NOVO/SUBSTITUIR são rótulos, fora do nome da instância. Não duplique scripts.

O instalador mostra nome, tipo, local, última linha e botão de copiar, com código escondido. Copiar inteiro instala a fonte completa; partes 1/2 são alternativa no mesmo script. Todas têm até 400 linhas. O 09A_SHOP_UI de quatro partes e as regras de jogos permanecem instalados.

**Música:** desative o LocalScript `07M_PLAZA_MUSIC` em StarterPlayerScripts se ele existe. Mantenha `07M_MUSIC_CLIENT` como único controlador. A V56 também desativa a cópia antiga no cliente, remove seu ACP_MusicPanel e adota ACPPlazaMusicV2/ACPPlazaMusic quando presentes.

ONLINE verde no HTML confirma consulta ao GitHub. O arquivo novo contém V56 e V55 para cópia offline, além da base histórica V44; isso não substitui dependências históricas de quem ainda não instalou V55.

## Photo Mode

Cada jogador abre uma sala de blocos criada **somente no seu cliente**, longe do mapa compartilhado. Copia o personagem do mapa quando sua aparência corresponde à selecionada; caso contrário, cria a cópia pela descrição nativa completa. Corpo, cores, roupas e acessórios passam pela verificação da prévia. A cópia ancorada não muda a pose de outros jogadores.

- **Girar avatar:** modo inicial. Arrastar e Frente/Costas/Lados giram só a cópia.
- **Mover câmera:** modo separado para mudar a visão; os blocos continuam fixos.
- **Câmera:** corpo inteiro, meio corpo, rosto, zoom e giro automático do avatar.
- **Pose:** arraste personagem ou manequim; Aplicar confirma, Cancelar restaura.
- **Emotes:** animações reais na cena. Se o novo emote não iniciar, a pose/cópia anterior permanece.
- **Sem interface / Foto:** limpa controles para vídeo pelo dispositivo ou captura de foto pelo Roblox. Sair restaura câmera e iluminação.

Seis cenários: Estúdio Editorial, Céu de Algodão, Passarela, Jardim de Outono, Rua Criativa e Salem — Halloween. Centro livre, iluminação clara, detalhes nas laterais. Halloween tem abóboras com rosto, lanternas, lua e pequenos fantasmas. Movimento dos detalhes começa desligado. As peças não colidem nem bloqueiam toque/raycast do editor. Girar o avatar nunca reposiciona o cenário.

## Visual e utilidades

Tema compartilhado em HUD, catálogo, comunidade, meus looks, carregar/salvar avatar, carrinho, configurações, jogos, baralhos, ateliê, música, IA e Photo Mode, inclusive janelas criadas depois da entrada. Fundo ameixa escuro, laranja, lilás, teias e abóboras, com acabamento de botões. Enfeites não capturam toque. Tema neutro oculta decoração e movimento reduzido continua respeitado. Menus/prompt de compra nativos do Roblox mantêm o visual oficial.

Cartas/tabuleiros conservam sua arte funcional. Salem ganhou rostos de abóbora e folhas; Nyxar usa gravura botânica. Rank, naipe e pips ficam legíveis. A loja atualiza preços individualmente com timeout; falha em um não prende os demais em “consultando”. Recarregar preços aparece em telas largas; fechar/reabrir também refaz a consulta. Robux só libera com preço confirmado.

**Itens com X individual continuam abaixo da prévia.** Looks usam uma linha de seis ações quando há largura, liberando altura para os cards. Catálogo/comunidade mantêm cinco cards lado a lado e duas filas no celular deitado, com adaptação em pé e área segura. Carrinho mantém itens escolhidos/look completo, miniaturas, estimativa e recarregar.

Ateliê conserva imagem real, carregou/falhou, arraste, zoom, rotação, luz, frente/verso e visuais salvos. Controles de rotação usam palavras; Recarregar usa ícone vetorial. Não há sucesso inventado para imagem sem autorização/moderada/indisponível.

Música: popup pequeno com ID/link, Carregar, Ouvir/Pausar, Recarregar, Salvar, volume e Salvos no mesmo popup. Inicial 40% só para primeira configuração; volume salvo continua. Som pessoal, até 24 favoritos. Áudio precisa de permissão real na experiência.

## Avatar IA e produtos

Menu recolhível, conversa central, sugestões e mensagem na base. Escolhas de criação e resultados 3D aparecem na conversa. Usar, Salvar e Ver são diretos; Ver abre edição com itens/X, carrinho e comparação. Respostas de ajuda não apagam os últimos looks. Conectando/online/indisponível e erros aparecem claramente.

Continua usando **TextGenerator real do Roblox**, em pedidos independentes de estilo/ajuda. O visual de conversa não significa serviço ChatGPT, pesquisa geral da internet ou memória permanente. Catálogo nativo fornece IDs/tipos/preços. Alterar apenas cabelo/roupas/acessórios/corpo preserva as outras peças do look escolhido.

Normal: 1 look/pedido e 10 solicitações/dia. Studio: até 2 variações e 30/dia. Pro: até 5 e 60/dia. Até oito interações por sessão, limite diário compartilhado pelo grupo. Falhas tentam devolver limite e informam quando armazenamento não confirma. O modelo nativo é o mesmo; planos mudam ferramentas/limites.

| Benefício | Tipo existente | ID | Valor sugerido |
|---|---|---:|---:|
| IA Studio, 30 dias corridos | Developer Product | 3717699383 | 15 Robux |
| IA Pro, 30 dias corridos | Developer Product | 3717699454 | 25 Robux |
| Salem, visual permanente após aquisição | Developer Product | 3717699522 | 10 Robux ou 900 moedas |

**Não crie passes/produtos novos.** Preços do painel não foram alterados; interface lê o valor real. Planos renovam manualmente, contam tempo offline: 30 dias = 720 horas = 2.592.000 segundos. Único ProcessReceipt continua `07K10_CARD_COMMERCE`. Éter Visual desativado continua fora das compras. Salem é sazonal do jogo, sem troca/sorteio/vantagem de partida.

Cada jogador usa seu próprio UserId Roblox. Até três amigos aceitam convite de plano com a conta deles; nunca compartilham conta real/senha/Robux. Looks/preferências persistem, conversa privada não. Publicidade da coleção continua rotulada e condicionada à validação do ativo/criador. Sem serviço real da IA, compra de plano fica bloqueada.

## Roupa 3D e diagnóstico

Gato abacaxi `72779265740934` é **ShirtAccessory em camadas sobre R15**, não pacote de corpo. A aplicação preserva descrição completa e distingue as etapas:

| Código | Verificação |
|---|---|
| DESCRIPTION/MERGE | Descrição e preservação das peças |
| CREATE | CreateHumanoidModelFromDescriptionAsync |
| STRUCTURE | Rig, Humanoid, Root e partes |
| LAYERS | WrapTarget, Handle/MeshPart, WrapLayer e instância exata |
| MAP/CONFIRM | Aplicação e aparência nativa no mapa |
| CONTENT | Malhas/texturas no aparelho |
| SAVE | Aparência nativa lembrada pelo sistema existente |

Servidor verifica descrição/estrutura nativa; cliente confere conteúdo da versão replicada. Texturas descarregadas no servidor não servem como prova da renderização do jogador. Malhas de Tool equipada não interferem.

Se falhar, janela mostra **etapa, origem, IDs, esperado/encontrado, erro original e código**. Procure `[Avatar V56] FALHA` e o mesmo código no Output. Erro completo fica no Output; janela tem texto limitado, X, Tentar aplicar novamente e Abrir catálogo. Avatar antigo fica disponível até confirmação final no servidor para restauração em falha.

Isso não comprova visualmente que o gato renderiza no mapa publicado. O relatório distingue estrutura confirmada de textura/camada que não chega ao aparelho. Layered Clothing desativado deve ser corrigido nas configurações do projeto; propriedade protegida não é forçada pelo script.

## Conferência no Roblox

1. Confirme V55 completa, quatro NOVOS, 28 substituições, tipos/locais e ausência de duplicatas. Desative 07M_PLAZA_MUSIC.
2. Experimente gato, feche catálogo, confira mapa, respawn e reentrada. Em falha, leia etapa/código na janela e no Output.
3. Photo Mode: gire avatar, mova câmera separadamente, teste seis fundos, pose/emote e saída. Fundo deve ficar no lugar ao girar a cópia.
4. No celular em pé/deitado, confira X, itens abaixo da prévia, catálogo/comunidade, looks, música, chat e teclado aberto.
5. Confirme TextGenerator online antes dos planos. Teste preço, recibo, prazo e convite usando produtos existentes.
6. Teste imagem/áudio autorizados e ID inválido; erro deve liberar recarregar sem afirmar sucesso.

Validação automatizada usa serviços simulados em Lua 5.4 e JavaScript real do instalador. **Não houve execução no motor Roblox, cobrança real ou publicação da experiência Roblox.** Renderização 3D, acesso à IA, áudio, DataStores e compras ainda precisam de teste na experiência publicada.

