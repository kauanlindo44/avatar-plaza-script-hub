# Avatar Plaza — V54

Atualização baseada na V53 mais recente do GitHub, commit `f99494623aa804cf43bd04712e50e33220a19b26`. **18 substituições + 3 módulos novos**, em 21 locais de instalação, com 19 fontes diferentes. Requer a V53 completa.

Abra [AVATAR_PLAZA_V54.html](AVATAR_PLAZA_V54.html) ou [AVATAR_PLAZA_SCRIPT_HUB_PERMANENTE.html](AVATAR_PLAZA_SCRIPT_HUB_PERMANENTE.html). O [INSTALL_V54.md](INSTALL_V54.md) mostra cada nome, tipo e local. Pare Play, crie os três NOVOS e substitua os existentes. As regras 07A0_CHESS_RULES e 07B0_CHECKERS_RULES precisam do mesmo código em **ReplicatedStorage e ServerScriptService**. Não duplique instâncias dentro da mesma pasta. Código oculto, última linha e copiar inteiro/em duas partes; todas as fontes têm menos de 400 linhas.

## Interfaces

Jogos com abas, moedas no cabeçalho, quatro ações claras, retratos originais de Nico/Lia/Dante e painéis em azul escuro/jade com acentos e efeitos. Opções têm um único X; ele cancela a espera da sala. Mesa 2D de Truco com madeira/feltro, duplas destacadas, cartas públicas no centro e coleta animada da vaza, três cartas próprias acima dos botões e decisão com dez segundos. Tabuleiros de dama/xadrez grandes e centrados; promoção permite quatro escolhas também contra bots.

Meus looks tem prévia principal maior sobre palco iluminado, cards compactos, ações visíveis e itens embaixo com X separado. Salvar abre uma tela com prévia e formulário. Comunidade tem duas skins lado a lado, busca/filtro, fundo iluminado e detalhes 360°. Os dados reais e a janela virtual limitada continuam: 50 slots, até 100 looks em memória e Carregar mais.

Carrinho separa Itens escolhidos e Look completo, apresenta estimativa/quantidade, marcação e remoção, Recarregar e prévia lateral quando há largura. Falha de cotação libera nova tentativa; abrir ou comprar não muda a skin. Preços finais e compras continuam nos prompts oficiais.

As telas usam os mesmos cálculos seguros do catálogo: aproveitam o topo livre ao lado dos controles Roblox quando cabe e chegam ao limite inferior seguro, respeitando cutouts e margens nativas. Catálogo e sua faixa de itens equipados continuam.

## Persistência e regras

A última aparência aplicada e confirmada no personagem entra em uma fila de salvamento do servidor. Ao entrar de novo, o jogo tenta restaurá-la antes do perfil padrão. Há confirmação de gravação e aviso de falha; abrir o catálogo sem editar não grava o perfil padrão sobre uma restauração que falhou. A fila agrupa edições e faz flush na saída/shutdown. O token de sessão bloqueia escrita tardia de um servidor antigo, mas não recupera dados ainda não gravados antes de uma queda ou transferência.

As regras de dama brasileira e os casos de promoção/empate/repetição de xadrez foram revisados nas duas cópias. Fontes oficiais em [audits/V54/RESEARCH.md](audits/V54/RESEARCH.md).

## Validação e instalação

**79 fontes efetivas com sintaxe válida, 61 cenários Lua simulados e JavaScript real do instalador com cópia/hashes conferidos.** Um cenário inclui 72 partidas completas de bots. Geometria amostrada de 320×568 a 1920×1080, incluindo 568×320. Relatório em [audits/V54/README.md](audits/V54/README.md).

Não houve execução no Roblox, compra ou publicação do place. Teste renderização, toque físico, viagem entre servidores e persistência real no jogo publicado. DataStores precisam estar disponíveis; teste em Studio exige acesso às APIs habilitado. Para camadas, Layered Clothing precisa estar permitido nas configurações do projeto; scripts não podem alterar a propriedade protegida.

Passes, produtos e preços continuam os existentes. Compra direta, Ateliê e visuais salvos permanecem. Éter Visual 3716300364 continua desativado; sem novas ofertas de caixas. Versões anteriores estão no histórico; o instalador da V54 é somente o delta depois da V53.
