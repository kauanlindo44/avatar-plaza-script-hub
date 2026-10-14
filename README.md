# Avatar Creator Plaza — V64

Atualização sobre a V63 publicada (`232164b3de7987a1036d65dff020fc3700062418`): **2 módulos novos + 24 substituições**. Requer V63 completa. [Guia com nomes, tipos, locais e teste Roblox](INSTALL_V64.md).

Abra [AVATAR_PLAZA_V64.html](AVATAR_PLAZA_V64.html) ou sincronize o [instalador permanente](AVATAR_PLAZA_SCRIPT_HUB_PERMANENTE.html). Fontes recolhidas, botão copiar, última linha, nomes exatos e hashes; instalação offline V44/V55–V64. O 09A_SHOP_UI continua em quatro partes. Crie primeiro os dois novos no ServerScriptService. 07P1_CAPTURE_ENGINE era uma dependência anterior: substituir em ReplicatedStorage ou criar se estiver ausente.

A IA agora tem formulário independente e conversa ocupando a área segura. Nova conversa deixa de destruir os controles; cancela pedidos anteriores sem receber respostas atrasadas nem reiniciar limites. O planejador entende refinamentos de estilo/cor/escopo, reserva orçamento para peças posteriores, confere preços e testa a aparência. Não exige chave externa; continua sendo um assistente específico de looks, sem prometer chat generativo geral ou precisão perfeita.

Meus looks mantém cache por sessão, botão de recarregar e proteção de dados após falha de leitura. Dados antigos inválidos têm diagnóstico e bloqueiam edições destrutivas. A comunidade compartilha o índice entre jogadores, limita consultas e respeita orçamento para não disputar com dados pessoais; guarda os mesmos registros e códigos da V61. O catálogo recebe acabamento e cards com imagem maior/Robux compacto, preservando itens equipados, remoção por X, cinco colunas e duas linhas em paisagem.

Seis mundos ao ar livre com acabamentos próprios, materiais nativos, sombras seletivas, vegetação/margens/telhados/madeira/pedra, iluminação e céu. Até 780 partes de cenário, 25 de chão reutilizadas e 8 luzes; água/vegetação animadas de forma limitada. Truco mantém regras e sessões/revanche, com cartas públicas menores, donos/duplas explícitos, progresso das três vazas e feedback breve sem reiniciar a coleta a cada snapshot.

Clicar num jogador abre um painel pequeno com prévia imediata e quatro ações: ver roupa, curtir, usar look e enviar Robux. Cópias respeitam a permissão do dono. Transferências usam confirmação/recibos oficiais do Roblox, exigem Plus/elegibilidade, custam 10–500 Robux e informam 90% ao destinatário/10% à experiência; nenhuma vantagem por transferir. ProcessReceipt de produtos permanece único.

Photo Mode usa a captura nativa atual, evita pedidos duplicados, trata timeout e informa o resultado real de salvar/compartilhar. O aviso FoundationProvider/UIBlox nas fotos é de CorePackages; não se modifica código interno do Roblox nem se promete remover esse aviso. [Auditoria e limites de validação](audits/V64/README.md).

**31 cenários simulados**, 120 fontes com sintaxe válida, seis geometrias de UI/cenário e JavaScript real do instalador. Motor Roblox, qualidade visual, FPS e permissões/serviços remotos precisam de teste publicado. Nenhum passe, Developer Product ou textura externa nova precisa ser criado.
