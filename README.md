# Avatar Plaza — V53

Atualização baseada no GitHub `main`, V52, commit `b397dfe12ebebed3ca61c91df530dbcbc69ca902`. **19 substituições + 2 módulos novos**, somente o delta para quem já instalou a V52 completa.

Abra [AVATAR_PLAZA_V53.html](AVATAR_PLAZA_V53.html) ou [AVATAR_PLAZA_SCRIPT_HUB_PERMANENTE.html](AVATAR_PLAZA_SCRIPT_HUB_PERMANENTE.html). O [INSTALL_V53.md](INSTALL_V53.md) lista nome exato, tipo e local. Pare Play, crie primeiro os dois módulos novos e depois substitua os 19 existentes. Código oculto, última linha e copiar inteiro/em duas partes; todos os itens têm menos de 400 linhas.

## Avatar e catálogo

Prévia, personagem e Photo Mode usam um carregamento compartilhado, com verificação de descrição, estrutura do corpo, acessórios físicos e downloads de malhas/texturas. Roupas 3D selecionam R15 quando necessário. A reconstrução é rejeitada antes de substituir o personagem se vier incompleta. Prévias maiores oferecem nova tentativa; a prévia principal evita avisos/botões duplicados. Fundo neutro mais claro e enquadramento 360° mantêm a leitura de avatares claros e escuros.

O gato abacaxi `72779265740934` é uma camisa 3D, não um pacote de corpo. O caminho simulado preserva camisa/calça clássicas e outros acessórios ao experimentá-la. **Layered Clothing deve estar permitido no projeto**; scripts não podem habilitar a propriedade protegida. Não houve teste dessa malha no motor Roblox; IDs e cages presentes não garantem a deformação visual final de todo asset.

O catálogo reaproveita até 40 instâncias de card ao rolar, preservando duas linhas visíveis e até cinco cards por linha conforme o espaço. Miniaturas amplas, Robux compactos embaixo e itens equipados com X permanecem. O botão **+ CARRINHO** nos detalhes adiciona sem trocar o avatar. Experimentar também adiciona uma vez.

O carrinho do outfit consulta pacotes de corpo/pares de sapatos, evita peças duplicadas e mantém escolhas desmarcadas. Compra aguarda a consulta; itens indisponíveis/já possuídos são excluídos. O total é estimativa ou subtotal conhecido; valores desconhecidos ficam para consulta no Roblox. Cotações de pacotes usam resultados limitados, sem promessa de encontrar a combinação global mais barata.

## Jogos e Truco

Abas Truco/Dama/Xadrez mostram quatro ações do jogo escolhido, em grafite/verde suave. Moedas no cabeçalho, perfis verticais de bots **Nico, Lia e Dante**, ligados aos níveis reais das IAs existentes. Tabuleiros de dama/xadrez continuam grandes e centrados.

Salas humanas de Truco mostram duas duplas e começam depois de os quatro confirmarem **Estou pronto**. O anfitrião pode reservar o assento oposto para um amigo Roblox por dois minutos e compartilhar o código. A confirmação é limpa ao reentrar. O fluxo de código entre servidores usa a viagem existente; não envia mensagens automáticas ao amigo.

Mesa 2D maior, quatro jogadores, cartas públicas no centro, três cartas próprias tocáveis e uma faixa de ações embaixo. TRUCO permite dez segundos de resposta; o servidor encerra chamadas vencidas e a interface usa somente aumentos legais da variante. A revanche exige todos os votos, retém os assentos e reinicia mãos/placar; não aparece nos torneios. As artes de cartas ficaram menos carregadas, com valor/naipe explícitos.

Compra direta, Ateliê, visuais salvos, baralho cheio/limpo/personalizado, regras e progressão da V52 continuam. IDs e preços do painel não foram alterados; sem novas ofertas de caixas. Éter Visual `3716300364` permanece desativado.

## Verificação

**76 fontes efetivas com sintaxe válida, 40 cenários Lua simulados e JavaScript real do instalador com cópia/hashes conferidos.** Um cenário inclui 72 partidas completas de bots. Geometria e alvos de toque amostrados de 320×568 a 1920×1080, incluindo deitado 568×320. Relatório em [audits/V53/README.md](audits/V53/README.md), fontes em [audits/V53/RESEARCH.md](audits/V53/RESEARCH.md).

Não houve execução no Roblox, compra ou publicação do place. Renderização/deformação de assets, toque físico e viagens reais entre servidores precisam de teste no aparelho. Versões anteriores permanecem no histórico; este instalador não é cumulativo.

