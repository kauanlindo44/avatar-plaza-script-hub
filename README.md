# Avatar Plaza — V52

Atualização sobre a V51 mais recente do GitHub, commit `24dad1296cabb261eb67bf1aed5a449f6cac3cf9`. **23 substituições + 5 módulos novos**, para quem já instalou a V51 completa. A entrega contém somente os 28 scripts que mudaram; não é um pacote cumulativo.

Abra [AVATAR_PLAZA_V52.html](AVATAR_PLAZA_V52.html) ou [AVATAR_PLAZA_SCRIPT_HUB_PERMANENTE.html](AVATAR_PLAZA_SCRIPT_HUB_PERMANENTE.html). [INSTALL_V52.md](INSTALL_V52.md) lista nome exato, tipo e local de cada item. Pare Play, crie primeiro os cinco módulos novos em ReplicatedStorage e depois substitua os 23 existentes. Todos têm até 357 linhas. O código fica oculto, com última linha e botões para copiar inteiro ou em duas partes.

## Comunidade, avatares e tela

Comunidade usa pesquisa, filtro e outfits, sem faixa permanente de categorias. São quatro colunas nas telas largas ou três nas menores, e até cinco linhas quando há espaço legível. O pool recicla até 50 cartões e limita o histórico carregado a 100 registros. As consultas continuam trazendo perfis reais, sem prometer um milhão de looks prontos ou reconhecer personagens automaticamente.

Meus avatares abre a prévia do look selecionado, mantendo os itens equipados embaixo. No retrato, a prévia ocupa a parte superior; no deitado, fica ao lado da grade. A área disponível ao lado dos controles Roblox é aproveitada quando cabe, respeitando notch, recorte físico e botões nativos.

Roupas 3D que mudam a silhueta agora selecionam R15 na prévia, no personagem e nos looks salvos. Os pacotes preservam metadados nativos e as roupas já equipadas. A confirmação exige acessórios físicos com Handle/WrapLayer; só ter os IDs na descrição não é suficiente. **Confira Layered Clothing nas propriedades/Avatar Settings do projeto. LoadCharacterLayeredClothing não pode ser alterada por scripts.**

## Jogos e visuais

O lobby tem três painéis com arte própria e Partida rápida, Criar sala, Entrar na sala e Contra bots. No retrato, os painéis ficam empilhados e amplos; em telas largas, aparecem lado a lado. Moedas ficam junto ao cabeçalho. Xadrez e dama usam tabuleiro maior e centrado.

Truco usa mesa 2D verde, jogadores ao redor, sua mão embaixo e cartas públicas no centro, com coleta visual para o canto depois da vaza. A partida rápida separa variante e baralho cheio/limpo. Criar permite escolher valores/naipes e salvar uma configuração. Mesas personalizadas ficam fora de ranking e moedas competitivas. A distribuição é automática; cartas dos adversários continuam privadas.

A loja vende **visuais diretamente** e mostra três cartas de amostra. Cada tema tem desenho próprio; valor e naipe permanecem legíveis. Ateliê permite carregar/recarregar imagem ou decal, arrastar, ampliar, girar, ajustar luz, escolher moldura/faixa e ver frente/verso. Salvos permite guardar e reequipar até 12 visuais por conta.

As caixas foram retiradas das novas ofertas e das compras por moedas. Créditos antigos podem ser resgatados sem nova cobrança; recibos pendentes continuam sendo processados para preservar compras anteriores. Não há resultado aleatório. IDs de passes/produtos diretos e preços do painel permanecem os mesmos; a interface consulta o preço atual na Roblox. Éter Visual (3716300364) continua desativado.

## Validação

**74 fontes efetivas com sintaxe válida, 25 cenários Lua simulados e testes do JavaScript real do instalador.** Os cenários incluem 72 partidas completas de bots, persistência, recibos idempotentes, privacidade, corpos nativos e geometria em ambas as orientações. Detalhes em [audits/V52/README.md](audits/V52/README.md), referências oficiais em [audits/V52/RESEARCH.md](audits/V52/RESEARCH.md).

Não houve execução no Roblox real nem compras. Meshes específicos, toque físico, imagens aprovadas, preços nativos e latência ainda precisam de teste no aparelho. As duas referências enviadas foram abertas e usadas para orientar a composição; a arte e o código desta entrega são próprios. O place não foi publicado. Versões anteriores e seus instaladores continuam no histórico.
