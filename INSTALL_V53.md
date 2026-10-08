# Instalação V53 — 19 substituições + 2 NOVOS

Requer a V52 completa já instalada. São 21 itens: 19 SUBSTITUIÇÕES e 2 NOVOS. Pare Play. Crie 08B4_AVATAR_LOAD como ModuleScript em ReplicatedStorage e 09B6_CART_RESOLVER como ModuleScript em ServerScriptService; depois substitua apenas os 19 existentes, sem duplicar instâncias. Cada item permite Copiar script inteiro ou duas partes consecutivas no MESMO script. (NOVO)/(SUBSTITUIR) são rótulos, não parte do nome. Consulte INSTALL_V53.md. Para roupas 3D, confira Layered Clothing nas configurações de avatar do projeto; não é possível habilitar essa propriedade por script.

## Criar primeiro — 2 NOVOS

| Nome exato no Studio | Tipo | Local | Partes |
|---|---|---|---:|
| `08B4_AVATAR_LOAD` | ModuleScript | ReplicatedStorage | 2 |
| `09B6_CART_RESOLVER` | ModuleScript | ServerScriptService | 2 |

## Substituir — 19 existentes

| Nome exato no Studio | Tipo | Local | Partes |
|---|---|---|---:|
| `08B2_BODY_DESCRIPTION` | ModuleScript | ReplicatedStorage | 2 |
| `08B3_AVATAR_VERIFY` | ModuleScript | ReplicatedStorage | 2 |
| `09B5_AVATAR_RUNTIME` | ModuleScript | ServerScriptService | 2 |
| `09C6_AVATAR_PREVIEW` | ModuleScript | ReplicatedStorage | 2 |
| `07P2_STUDIO_AVATAR` | ModuleScript | ReplicatedStorage | 2 |
| `09B_SHOP_SERVER` | Script | ServerScriptService | 2 |
| `09A1_SHOP_LAYOUT` | ModuleScript | ReplicatedStorage | 2 |
| `09C4_OUTFIT_LIBRARY` | ModuleScript | ReplicatedStorage | 2 |
| `09C2_SHOP_CATALOG` | ModuleScript | ReplicatedStorage | 2 |
| `09C_SHOP_CLIENT` | LocalScript | StarterPlayer > StarterPlayerScripts | 2 |
| `07H1_GAME_LOBBY` | ModuleScript | ReplicatedStorage | 2 |
| `07H_GAME_UI` | LocalScript | StarterPlayer > StarterPlayerScripts | 2 |
| `07K3_TRUCO_DIRECTORY` | ModuleScript | ServerScriptService | 2 |
| `07K2_TRUCO_MATCH` | ModuleScript | ServerScriptService | 2 |
| `07K_TRUCO_SERVER` | Script | ServerScriptService | 2 |
| `07K7_CARD_STYLES` | ModuleScript | ReplicatedStorage | 2 |
| `07K15_TRUCO_TABLE` | ModuleScript | ReplicatedStorage | 2 |
| `07K5_TRUCO_UI` | ModuleScript | ReplicatedStorage | 2 |
| `07K_TRUCO_CLIENT` | LocalScript | StarterPlayer > StarterPlayerScripts | 2 |

Apague a fonte antiga uma vez e cole as duas partes em ordem na mesma instância, ou use Copiar script inteiro. Não crie scripts separados para as partes e não cole versões anteriores por cima. A V53 contém somente alterações; não instale a V44 embutida por cima da V52. O 09A_SHOP_UI e seus quatro trechos permanecem os da versão já instalada. Todos os itens desta entrega têm no máximo 373 linhas.

O HTML mostra nome, tipo, local, última linha e copiar, mantendo a fonte oculta. ONLINE fica verde quando a sincronização termina. Sem conexão, contém o delta V53 e a base histórica V44; a V53 ainda exige a V52 completa.

## O que mudou

- **Avatar e prévias:** catálogo, Meus avatares, comunidade e Photo Mode usam o mesmo carregamento. R15 quando necessário, readback dos IDs/roupas/proporções/cores, corpo completo, acessórios físicos e pré-carregamento das malhas/texturas. Falhas ficam visíveis e as prévias maiores oferecem Tentar novamente; o catálogo tem somente um aviso/botão de falha. A prévia usa fundo neutro claro e câmera 360°. Os itens com X continuam embaixo.
- **Gato abacaxi:** 72779265740934 é uma camisa 3D (ShirtAccessory), não um pacote de corpo. Ela deve ser colocada sobre um R15 que permita camadas. O caminho de teste preserva as roupas e acessórios existentes. Não existe confirmação de renderização desse asset no Roblox nesta sessão.
- **Carrinho:** Outfit atual consulta pacotes de corpo/pares de sapatos em vez de cobrar peças duplicadas. Consultas de pacotes são limitadas e o total é uma estimativa. Itens indisponíveis ou já possuídos são excluídos; preço desconhecido aparece como consultar. Comprar fica bloqueado enquanto o outfit é resolvido; escolhas desmarcadas são mantidas. + CARRINHO nos detalhes adiciona o item sem trocar o avatar. Experimentar também o adiciona sem duplicar.
- **Catálogo:** os cards são reutilizados ao rolar; até 40 instâncias de card, mesmo com mais páginas. Duas linhas visíveis e até cinco itens por linha quando há espaço, miniatura ampla e preço compacto embaixo.
- **Jogos:** abas Truco/Dama/Xadrez e quatro ações do jogo escolhido. Paleta grafite/verde suave, moedas no cabeçalho, bots Nico/Lia/Dante em perfis verticais; os nomes correspondem aos níveis reais das IAs existentes. Xadrez/dama continuam com tabuleiro grande no centro.
- **Salas de Truco:** duas duplas, código, roster e Estou pronto. A partida humana começa somente depois da confirmação dos quatro jogadores. O anfitrião pode reservar o assento oposto para um amigo Roblox por dois minutos e compartilhar o código; não é enviada mensagem automática ao amigo. Códigos de outro servidor utilizam a viagem já existente. Reentrar limpa a confirmação antiga.
- **Mesa:** maior, cartas públicas no centro e três cartas próprias tocáveis; uma única faixa de ações embaixo. TRUCO tem dez segundos para resposta, Aceitar/Correr/aumento legal; o servidor aplica o prazo. Revanche exige todos os votos; não é oferecida nos torneios. As artes ficam mais calmas e distintas, preservando valor e naipe.

## Conferir no Roblox

Habilite roupas em camadas nas propriedades/Avatar Settings do projeto. Teste gato abacaxi, Gumball e corpos realistas no perfil, prévia, Aplicar, Photo Mode e respawn. Confirme notch, controles Roblox, X e arrasto 360° em pé/deitado. Faça uma sala com quatro contas, escolha as duplas, confirme Pronto, teste chamada de 10 segundos, reserva de amigo de outro servidor e revanche.

O carregamento visual usa um prazo para pré-carregamento e uma fila limitada; a criação nativa do Roblox pode demorar além desse prazo. Se falhar, tente novamente. A presença de WrapTarget/WrapLayer, os IDs e o sucesso de downloads não comprovam a deformação/renderização final de todo asset. A leitura de configuração protegida é apenas tentativa; a configuração real deve ser conferida no editor.

Passes, produtos e preços não foram alterados. Compras diretas permanecem, sem novas ofertas de caixas. Não use Éter Visual (3716300364), que continua desativado. Créditos e recibos antigos são preservados.

Testes: [audits/V53/README.md](audits/V53/README.md). Fontes oficiais: [audits/V53/RESEARCH.md](audits/V53/RESEARCH.md).
