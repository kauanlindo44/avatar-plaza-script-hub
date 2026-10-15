# Avatar Creator Plaza — V65

Atualização sobre a V64 publicada (`b1d6048498ad5c7b73b00051b7033f2258cdda02`): **2 módulos novos em ReplicatedStorage + 18 substituições**. Requer V64 completa. [Nomes, tipos, locais e verificação no Roblox](INSTALL_V65.md).

Abra [AVATAR_PLAZA_V65.html](AVATAR_PLAZA_V65.html) ou sincronize o [instalador permanente](AVATAR_PLAZA_SCRIPT_HUB_PERMANENTE.html). O código continua recolhido, com nome/local, última linha e botão de copiar a fonte completa. Há pacote offline V44/V55–V65 e verificação de novas versões no GitHub. O `09A_SHOP_UI` permanece em quatro partes.

Crie primeiro **07UI_PAN_GRID** e **08B6_AVATAR_MOVEMENT**, ambos **ModuleScript em ReplicatedStorage**. Os 18 demais substituem fontes existentes; não coloque NOVO/SUBSTITUIR no nome. Nenhum passe, Developer Product ou textura externa nova precisa ser criado.

O posicionamento de corpos usa a altura de apoio do Humanoid nativo. Trocar corpo ou proporções não transfere inclinação/velocidade do anterior, nem mede uma roupa grande como se fosse uma perna. Há verificação posterior limitada, diagnóstico de movimento e fallback de animação que cede ao Animate funcional. A estrutura e aparência continuam verificadas antes de substituir o avatar anterior.

Photo Mode mantém juntas modernas cinemáticas durante os emotes, deixa o Animator controlar a cópia e confirma uma faixa de animação carregada. Repetir um emote registrado reutiliza o modelo; falha preserva a cópia anterior. Também pode abrir a partir do avatar atual antes do catálogo. Música espera o resultado do carregamento e tenta outra sugestão após falha, com limite de oito tentativas iniciais; IDs manuais, volume pessoal de 40%, salvos e fila permanecem.

Patrocinar jogos/comunidades tem canvas real nos dois eixos, duas linhas quando há espaço/registros, arraste com mouse sem abrir um card ao soltar e cabeçalho que aproveita a faixa das categorias em paisagem. Itens recebem o mesmo controle de gesto. Só o jogo e a comunidade fornecidos são registros iniciais nessas seções; não há exemplos fictícios de jogos/grupos. Os exemplos temporários de itens e a substituição um a um continuam.

IA prioriza camisa e calça antes dos opcionais, reconfirma preço/aparência e não entrega cabelo isolado como look completo. É um planejador do catálogo, sem chave externa, não um chat generativo geral. Salão de jogos com mesas ilustradas, caminhos de entrada claros e perfis de bots em destaque; configurações mais compactas e HUD sem o atalho ambíguo de restaurar. Restaurar permanece no editor com confirmação. Comunidade mantém Todos/Grátis, códigos e reciclagem de slots, com mais espaço para as miniaturas em paisagem.

Seis cenários próprios, tranquilos e planos, com vegetação nas bordas, materiais e iluminação por tema. Sem construções, pontes, arcos, morros ou montanhas. Até 520 partes de cenário, 25 de chão visual reutilizadas e no máximo oito luzes. Reaparecimento/piso físico do servidor, DataStores, compras, permissões e regras dos jogos permanecem os anteriores.

**48 cenários simulados**, 122 fontes efetivas com sintaxe válida, seis geometrias e JavaScript real do instalador. [Auditoria e limites](audits/V65/README.md). Não há motor Roblox neste ambiente: aparência, FPS, física e permissões reais de áudio/emotes precisam de teste publicado. As fotos mostram avisos de `CorePackages/UIBlox`; esta atualização não modifica módulos internos do Roblox nem promete remover esses avisos.
