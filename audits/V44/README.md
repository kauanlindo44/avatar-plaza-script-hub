# Auditoria V44 — Avatar Plaza

Base conferida no GitHub: V43, commit `369b6f45fe42377f60ca698cf7c5d10e748f0405`, árvore `46fbb3df4fb4656081a368c35225b3bd705721ab`. O handoff completo foi lido antes das alterações. As imagens apontadas no histórico desta sessão não estavam nos caminhos fornecidos. Não se alegou inspeção dessas imagens nem coleta de vinte capturas do Creator Avatar Studio.

## Instalação e fontes

Pacote de 55 scripts, **22 CRIAR / 33 SUBSTITUIR**, de até 393 linhas, sem atribuição composta. `07A_CHESS`, `07B_CHECKERS`, `07C_POISON_POTATO` e `07W_WINS_SERVICE` substituem os scripts existentes do handoff. As regras de xadrez/damas originais no servidor e as cópias de cliente da V37 têm a mesma lógica; diferenças conferidas são cabeçalho e linha final. O script antigo de Batata Envenenada vira uma desativação curta, para evitar serviço duplicado.

O pacote mantém sete fontes já usadas pela V43 para assegurar uma atualização consistente. Instale tudo com Play parado. [INSTALL_V44.md](../../INSTALL_V44.md) contém os locais e as dependências da V43/base original. O instalador incorpora as 55 fontes como fallback offline; versões anteriores e seus hashes são mantidos no manifesto. `09A_SHOP_UI` tem quatro partes exatas e nenhum bloco de código completo exposto no instalador.

## Comportamentos implementados

- HUD com Plus abrindo a assinatura nativa, sem página intermediária; utilidades independentes, fechamento com alvo de 48 px e restauração de outfit confirmada. O reset acidental ao lado do carrinho foi removido.
- Catálogo de cinco colunas e duas linhas totalmente visíveis em paisagem/desktop, seguindo a preferência mais recente. Retrato adapta a quantidade. Item aberto mostra foto, criador, preço, descrição e ações fixas; somente a descrição pode rolar. Ações da prévia e ajuste de corpo ficam separados. O carrinho filtra itens já possuídos, consulta preços atuais e separa selecionados/outfit. Cada compra nativa agrupa até vinte itens e informa o restante.
- Avatar: roupa isolada preserva peças, acessórios, cores, emotes e alterações atuais do personagem. Ajustes de corpo são aplicados no jogo pelo estado de avatar existente. Prévias calculam enquadramento pela geometria visível; somente a raiz é ancorada, sem parede atrás. Fundo muda com a luminosidade do look. São permitidos giro 360°, zoom e retenção do ângulo. Meus looks usa prévia selecionada maior e cards compactos.
- Photo Mode: cinco cenários locais, fundo sempre atrás da prévia, iluminação e ambiente em um painel sem rolagem. Editor de manequim 2D permite arraste direto de membros, confirmar/cancelar, desfazer/refazer e R6/R15; suporta Motor6D e AnimationConstraint, restaurando `IsKinematic`. O modo sai quando começa uma partida, para evitar conflito de câmera. Captura usa a funcionalidade nativa e callbacks atrasados não reabrem o estúdio.
- Configurações: seis categorias coloridas, mundo, som, câmera, interface, privacidade e comandos. Cinco visuais locais alteram Sky/atmosfera, luz, material e decoração sem mexer no servidor ou criar colisões. Skyboxes usam recursos stock; não foram produzidas cinco texturas novas. Comandos próprios limitam velocidade, salto, voo e escala e são suspensos em partidas. Não há comandos para matar ou prejudicar outros.
- Comunidade: o filtro inicial usa composições consultadas do catálogo para seis referências conhecidas, até cinco conjuntos de IDs diferentes por personagem. Faixas internas são grátis, 1–55, 56–150, 151–300, 301–600 e 601+ Robux, além de preço desconhecido. Créditos distinguem publicador e criadores das peças. O filtro Roblox adicional consulta usuários reais, tem capacidade de até um milhão de registros paginados, pool de 50 cards, cache de doze páginas e preparação depois de trinta posições. Isso não é uma base já curada de um milhão nem uma garantia de qualidade visual de todos os usuários.
- Inspeção: clique/toque em jogador próximo abre avatar 360°, itens, uso e curtida. Uso de look começa desativado, exige consentimento e é conferido ao aplicar/salvar; revogação ou saída do dono impede aplicar a fonte ainda em uso. Curtida é única por visitante. Isso controla o fluxo dentro do jogo; não impede reconstruir itens públicos fora dele.
- Jogos: lobby completo para xadrez, damas e Truco, criação/código/dupla/regra/treino, salas entre servidores, inventário e convites. Layout curto em paisagem mantém controles principais acessíveis. Sair de uma partida exige confirmar a desistência; salas terminadas liberam a associação do jogador e a mesa.
- Truco: três perfis documentados, quatro assentos e duplas opostas, câmera de primeira pessoa, três cartas na mão privada, mesa e vira públicas. Bots fácil/médio/difícil usam decisões distintas e somente informações permitidas. Manual casual e denúncia com prova; torneio automático. Reconexão preserva assento por três minutos. Visuais da mesa podem ser do próprio baralho, de cada jogador ou clássicos.
- Economia: nove baralhos originais e Ateliê. Três passes fornecidos, posse validada no servidor e preço nativo. Produtos repetíveis sem IDs ficam bloqueados. Caixas têm conteúdo escolhido/garantido, sem sorteio; cada visual é permanente e não se consomem escolhas duplicadas. Compras diretas por moedas/Robux são bloqueadas quando as caixas no inventário já cobrem os visuais restantes, evitando gastar duas vezes pelo mesmo benefício dentro da loja. Abrir 1–3 caixas anima os nomes conhecidos e permite pular. Ateliê tem prévia no celular, frente/verso, imagem, zoom 1–2 e arraste do recorte, com limites de servidor. Ver preços em [README.md](../../README.md).
- Classificação/moedas: resultado é verificado no servidor, não enviado pelo cliente. Bots, partidas curtas/inválidas, irregularidades e resultados repetidos não geram classificação ou prêmio. Vitórias válidas dão até 100 moedas e derrotas até 35, limitadas a 1.200/dia e cinco confrontos por grupo de adversários/dia. Não há aposta nem moeda comprada com Robux.
- Torneios: top dez indivíduos no xadrez/damas e top dez duplas no Truco. Convite até quatro dias antes, até 48 h para responder, check-in de T−15 até T−5 minutos e reservas online que já aceitaram. Sábado 22:00 UTC xadrez, 23:00 UTC damas; domingo 22:00 UTC Truco. Prêmio somente em título. Um líder por torneio e heartbeat de partidas tratam queda de servidor, sem aceitar resultado de um host antigo. Empate gera nova partida. Leituras assíncronas acontecem fora dos callbacks de DataStore UpdateAsync.

## Testes executados

Ambiente: Lua 5.4 por `ctypes`/liblua, Python, JavaScript real do instalador em Node com DOM mínimo. Os serviços e a geometria de GUI são doubles determinísticos. Não representam motor, rede ou compras reais da Roblox.

| Suíte | Casos | Evidência |
|---|---:|---|
| `test_v44.py` | 14 | Sintaxe das 55 fontes; limites; sete telas; 5×2; prévias; comunidade; configurações; pose; bots de xadrez. |
| `test_games_commerce.py` | 8 | Regras; privacidade das cartas; 72 partidas completas; tempo Goiano; inventário/recibos; política; moedas; torneios e host perdido. |
| `test_integration.py` | 14 | Preservação do avatar; controlador de catálogo; carrinho; permissões; composição; mobile; Ateliê; comandos; captura e AnimationConstraint. |
| `test_server_flows.py` | 5 | Servidores reais das fontes com serviços simulados; salas; fechamento durante yield; duplas; chegada/reconexão. |
| `test_installer_logic.cjs` | 1 | 55 hashes, fontes offline, cache antigo, cópia/seleção, remontagem exata das quatro partes, adulteração e fechar durante carregamento. |
| **Total** | **42** | Asserções aprovadas; não são testes nativos. |

Para reproduzir a partir da raiz do repositório:

```sh
python audits/V44/build_installer.py
python audits/V44/test_v44.py
python audits/V44/test_games_commerce.py
python audits/V44/test_integration.py
python audits/V44/test_server_flows.py
node audits/V44/test_installer_logic.cjs
```

Os testes reutilizam os doubles V43 e regressões da V42 para detectar perda do avatar e falhas em fluxos existentes. A simulação falha se um serviço assíncrono for chamado dentro do callback UpdateAsync. Não foram criados testes que apenas comparam texto de interface com texto da implementação.

## QA obrigatório no place de teste

1. Instalar todos os nomes nos locais corretos, iniciar com V43/base original completa e conferir Output. Não deixar uma cópia ativa da batata nem dois proprietários de ProcessReceipt.
2. Catálogo e looks no celular deitado/em pé: preços legíveis, prévia inteira, frente/costas/lados de R6/R15, skin clara/escura, acessórios altos/largos e X do carregamento. Aplicar uma camisa deve preservar o restante; aplicar corpo deve mudar o personagem real.
3. Photo Mode: arrastar todos os membros com toque e mouse, desfazer/refazer, confirmar/cancelar, girar o personagem e confirmar cenário atrás. Conferir iluminação real, rig com AnimationConstraint, captura e retorno de câmera/ambiente ao sair.
4. Duas contas: inspeção bloqueada por padrão, permitir/revogar look, sair do servidor, curtir repetidamente; conferir textos filtrados e limites de privacidade do fluxo.
5. Comprar os passes com uma conta que ainda não os possui, durante o preço de teste. Confirmar concessão, equipar, sair/reentrar e não recomprar benefício. A conta criadora pode já possuir seus próprios passes. Conferir UI com preço nativo e os Developer Products sem IDs desativados.
6. Depois de criar produtos no painel, colocar os IDs em `07K6_CARD_CATALOG.Products` e testar compra/recibo, retry e reentrada. Não habilitar compras aleatórias. Falha de DataStore deve bloquear gasto em moedas e manter recibo pendente, sem perder a compra.
7. Truco com quatro contas: duplas opostas, ninguém recebe mão alheia, carta coberta não vaza, vira/manilha/pedido/correr/empate/mão de 11 ou 10. Conferir mesa 3D e animação, manual topo/fundo, fraude comprovada, saída confirmada e reconexão. Verificar todos os três níveis de bots e partidas de xadrez/damas.
8. Dois servidores publicados: criar/entrar por código, reserva de assento, falha de Teleport e troca de servidor; MemoryStore/Teleport não são demonstrados pelo modo Play isolado. Simular convite, reserva, horário, empate e host que cai, em uma cópia de teste com horários controlados.
9. Serviços publicados: CatalogSearch/avatares reais, carregamento rápido e retorno de rolagem, limites por orçamento, cache, throttling e ausência de resultados. A composição por nome precisa de revisão visual antes de divulgação; não se promete volume pronto ou reconhecimento universal.

Limitações pendentes: execução nativa de todas essas verificações; IDs dos Developer Products; ajuste fino de iluminação, toque e arte após teste visual. A consulta de metadados de imagem verifica tipo e disponibilidade da API, não certifica que o criador detém direitos autorais. Regras/leis e decisões estão em [LEGAL_AND_RULES.md](LEGAL_AND_RULES.md).
