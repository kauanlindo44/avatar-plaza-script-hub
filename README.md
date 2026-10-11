# Avatar Plaza — V58

Atualização sobre a V57 publicada (**b918b7d1baf28448855f97fdc00868e01e4704b2**): **26 substituições + 1 novo**, com até 380 linhas por fonte. Requer V57 completa. Fontes históricas preservadas.

Abra [AVATAR_PLAZA_V58.html](AVATAR_PLAZA_V58.html) ou o [instalador permanente](AVATAR_PLAZA_SCRIPT_HUB_PERMANENTE.html). [INSTALL_V58.md](INSTALL_V58.md) lista nome, tipo e local de cada arquivo. Pare Play, crie primeiro **07UI_SLIDER — ModuleScript em ReplicatedStorage**, substitua os 26 existentes e reinicie. O instalador exibe somente botões de copiar e a última linha; mantém inteiro/partes, hashes, fallback offline e sincronização pelo GitHub.

A IA continua usando **TextGenerator do Roblox, sem chave OpenAI**. A chamada foi reduzida e normaliza o transporte de texto; o teste de conexão não exige JSON, respostas textuais válidas são aceitas e HTTP 400 recebe rastreio/recuperação curta. Conexão e armazenamento têm estados separados. Sem DataStore, há ajuda temporária gratuita e nenhuma confirmação falsa de plano/coleção; a compra de plano exige serviço e armazenamento disponíveis.

A conversa usa área ampla com barra lateral recolhível, mensagens à direita, compositor embaixo e perfil dividido em Plano/Aparência/Amigos. Música usa popup compacto com progresso e volume contínuos, nomes/IDs salvos, fila e minimizar, adotando o áudio legado. Carrinho usa adicionar explícito, selecionados/look inteiro e prévia recolhível. Catálogo ganhou filtro Halloween com itens reais e preservou os itens equipados/X.

A roupa replicada é conferida pelo ID da instância exata confirmada no servidor, junto da verificação física. Isso evita tratar a ausência de histórico local de GetAppliedInstance como prova de roupa ausente. Malha, WrapLayer, corpo, tipo e rig continuam obrigatórios conforme o acessório. Diagnóstico, preservação do look e rollback permanecem.

Photo Mode tem dez fundos locais, cinco dark incluindo Salem/Halloween, luz para destacar o avatar, ambiente em barras e movimentos para vídeo. Câmera/cópia se movem sem mover o cenário. Truco tem cartas menores com dono, parceiro/rivais explícitos, ajuda contextual e três cartas privadas visíveis. As regras existentes e o prazo de resposta foram preservados. Configurações usam categorias e X fixo; Halloween ganhou lua, teias e morcegos nos cantos.

**76 cenários simulados**, sintaxe das **98 fontes efetivas**, seis resoluções e JavaScript real do instalador foram verificados. [Relatório](audits/V58/README.md). Não houve execução no motor Roblox, cobrança ou confirmação visual do gato no mapa. TextGenerator real, renderização das roupas e aparência no aparelho ainda precisam dos testes do guia.

Produtos existentes preservados: IA Studio 3717699383, IA Pro 3717699454 e Salem 3717699522. Não há produto/passe novo nem segundo ProcessReceipt. Compartilhamento de IA não compartilha conta/credenciais Roblox. O HTML permanente continua consultando manifest.json da branch main deste repositório.
