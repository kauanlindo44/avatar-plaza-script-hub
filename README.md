# Avatar Creator Plaza — V66

Atualização sobre a V65 publicada (`b07af6cac3395f3f893d4855ce3a3e625a7054b2`): **5 ModuleScripts novos + 19 substituições**. Requer V65 completa. [Nomes, tipos, locais e verificação](INSTALL_V66.md).

Abra [AVATAR_PLAZA_V66.html](AVATAR_PLAZA_V66.html) ou o [instalador permanente](AVATAR_PLAZA_SCRIPT_HUB_PERMANENTE.html). Código recolhido, nome/local, última linha e botão de copiar a fonte completa. Pacote offline V44/V55–V66 e sincronização com GitHub. `09A_SHOP_UI` permanece nas quatro partes anteriores.

Crie primeiro `07P11_EMOTE_RESOLVER` como **ModuleScript em ServerScriptService**. Crie `07UI_CHOICE_LIST`, `09C14_NEW_AVATAR`, `09I8_AVATAR_STYLES` e `09I9_GAME_GUIDE` como **ModuleScript em ReplicatedStorage**. Os demais substituem fontes existentes. Não acrescente NOVO/SUBSTITUIR aos nomes. Nenhum passe, Developer Product ou chave externa novo.

Fundos agora leem a imagem e cor reais de AvatarBackground via InsertService no servidor, incluindo `ImageId.Value` e `Color.Value`. Emotes resolvem o AnimationId e usam Animator na mesma cópia do estúdio, corrigindo a chamada restrita ao LocalPlayer fotografada. Permissão negada preserva o estado anterior e gera diagnóstico específico.

Catálogo gira o avatar mantendo câmera e cenário parados. Meus looks tem quatro ações principais, menu, confirmação de exclusão e estilo mais discreto, preservando os itens com X embaixo da prévia. **Do zero** oferece base R6/R15/cor e prévia antes de confirmar, sem apagar looks salvos.

IA com **90 estilos**, lista pesquisável com descrição, escolhas de orçamento e **35 assuntos** de ajuda sobre o jogo. Perguntas reconhecidas recebem ajuda sem gastar uma busca de look; nova conversa continua utilizável. O assistente busca peças reais e é um planejador/guia específico, sem chave OpenAI e sem prometer conversação generativa geral ou pesquisa web em cada mensagem.

Música tenta outra faixa após falha também em IDs manuais ou na última faixa salva. Leitura de preferências antecede a primeira sugestão; tentativas são limitadas e sucesso exige conteúdo carregado. Mundos ficam mais discretos e claros, com até 300 partes de cenário e sem duplicar nuvens ao trocar de tema.

**65 cenários simulados**, **127 fontes efetivas** compiladas, seis geometrias numéricas e JavaScript real do instalador. [Auditoria e limites](audits/V66/README.md). Motor Roblox, aparência visual, FPS e permissões reais precisam de teste publicado. Os avisos de CorePackages/UIBlox nas fotos são internos do Roblox; não são modificados pelo projeto.
