# Avatar Plaza — V55

Atualização sobre a V54 mais recente do GitHub, commit `71ecc10926b71518f8786fb13491a2daadcaf3d7`: **18 substituições + 14 scripts novos**, 32 instalações. Requer V54 completa. Há 93 fontes efetivas; o delta tem até 380 linhas por fonte.

Abra [AVATAR_PLAZA_V55.html](AVATAR_PLAZA_V55.html) ou o [instalador permanente](AVATAR_PLAZA_SCRIPT_HUB_PERMANENTE.html). O [INSTALL_V55.md](INSTALL_V55.md) lista nomes exatos, tipos e locais, com NOVO/SUBSTITUIR e instruções de compra/teste. Pare Play, crie primeiro os novos módulos e substitua somente os arquivos indicados. Não duplique instâncias. O 09A_SHOP_UI de quatro trechos e as regras de jogos não são substituídos nesta atualização.

A V55 recupera os itens equipados embaixo do catálogo, faz a aplicação no mapa continuar quando o catálogo fecha e reconstrói camadas pela mesma via nativa da prévia. Comunidade usa 5×2 em deitado e duas colunas no retrato, com dados reais e buffer limitado. Interfaces recebem decoração Halloween discreta, cartas com frente tradicional e Salem permanente por compra direta.

Avatar IA substitui o botão Limiteds. Usa TextGenerator real do Roblox, busca de catálogo com IDs/preços reais, enquete e resultados 3D. Há conversa breve e privada, looks salvos, versões/coleções e até três convidados com consentimento, sem senha ou compartilhamento de conta Roblox. Normal monta um look; Studio até dois; Pro até cinco variações do mesmo pedido. Planos são produtos repetíveis de 30 dias corridos, com renovação manual. Não há memória de chat entre sessões nem pesquisa geral da internet. Sem resposta real do serviço de IA, compras desses planos ficam bloqueadas.

Produtos: Studio `3717699383` (15 Robux sugeridos), Pro `3717699454` (25) e Salem `3717699522` (10 ou 900 moedas). Preços reais são lidos do Roblox e o painel não foi alterado. Recibos entram no único ProcessReceipt existente, com concessão idempotente e armazenamento confirmado. Produtos antigos continuam funcionando; Éter Visual permanece desativado. Salem é sazonal deste jogo, sem negociação ou sorteio; venda até 02/11/2026 23:59 UTC, propriedade permanente após aquisição.

Photo Mode tem cinco fundos menos dominantes, novo estúdio de outono, menus contextuais menores, emotes e poses reais na cena local. Música passa a abrir um popup compacto com ID, erro/repetição, salvar e volume inicial de 40%, ajustável até silêncio e persistente. Áudios precisam de autorização real na experiência.

Validação: 72 cenários com serviços simulados, seis tamanhos de tela, sintaxe de todas as 93 fontes e testes do JavaScript real de cópia/sincronização/hashes do instalador. **Não houve execução no motor Roblox, cobrança real nem publicação da experiência.** Acesso a TextGenerator, malhas/cages, áudio, DataStores e preços devem ser conferidos no jogo publicado. Relatório: [audits/V55/README.md](audits/V55/README.md). Fontes e decisões: [audits/V55/RESEARCH.md](audits/V55/RESEARCH.md).
