# Avatar Plaza V40

Continuação da V39, commit-base `ed233b7685b37f0e6f9d1e862cd9a646d85a8b67`, conferido novamente antes da publicação. O handoff e as cinco imagens do projeto foram lidos antes das alterações.

## Interface entregue

A HUD segue a disposição clássica do Catalog Avatar Creator: Catálogo e Lojas no topo, Comunidade/Carregar avatar à esquerda, Looks/Emotes à direita, música/carrinho/limpeza no canto superior e ações com ícones na parte inferior. Os botões usam fundo escuro, contorno discreto e texto branco. No celular, os atalhos inferiores se adaptam ao espaço; as outras ações continuam disponíveis dentro do editor.

O catálogo usa a mesma paleta e componentes. Filtros têm controles maiores e rolagem; salvar, publicar e testar emotes têm títulos e instruções claras. O carregador de avatar se ajusta à altura, oferece R6/R15 e mantém a prévia separada do avatar vestido. Os detalhes de looks permitem rolagem em telas pequenas.

Jogos têm navegação por Xadrez, Damas e Batata, modos separados para partida rápida, amigo e treino, uma tela de espera com código selecionável e cancelamento acessível. A contagem de salas vem do servidor. Código de sala e busca rápida conectam jogadores do mesmo servidor, conforme o contrato existente.

O tabuleiro tem peças vetoriais, coordenadas fora das casas, indicação de turno, relógios e confirmação para desistência. No treino, o painel exibe dificuldade em vez de um relógio fictício. A Batata online continua usando a mesa física e a câmera existente, com status e saída de sala na nova interface.

Referência consultada: [jogo oficial de Muneeb](https://www.roblox.com/games/7041939546/Catalog-Avatar-Creator), captura publicada por Muneeb em 2021 e captura de interface de abril de 2024. O trabalho reproduz a organização dessa referência e adapta textos, funções e telas pequenas; não é uma comparação de pixels da versão atual do jogo.

## Instalação sobre a V39

Pare o teste, abra `AVATAR_PLAZA_SCRIPT_HUB_PERMANENTE.html` e selecione **V40**. Se a base ainda for V38.1, aplique primeiro a V39 disponível no histórico.

| Ação | Tipo e local | Script |
|---|---|---|
| CRIAR | ModuleScript — ReplicatedStorage | 07UI_DESIGN_SYSTEM |
| CRIAR | ModuleScript — ReplicatedStorage | 07H1_GAME_LOBBY |
| CRIAR | ModuleScript — ReplicatedStorage | 07H2_GAME_BOARD |
| SUBSTITUIR | ModuleScript — ReplicatedStorage | 09A_SHOP_UI |
| SUBSTITUIR | LocalScript — StarterPlayer > StarterPlayerScripts | 07G_HUB_UI |
| SUBSTITUIR | LocalScript — StarterPlayer > StarterPlayerScripts | 07H_GAME_UI |
| SUBSTITUIR | LocalScript — StarterPlayer > StarterPlayerScripts | 09C_SHOP_CLIENT |

Crie os três módulos novos primeiro. Não acrescente cópias dos scripts que devem ser substituídos. No **09A_SHOP_UI**, apague o código antigo uma vez e cole **Parte 1, 2, 3 e 4, nessa ordem, no mesmo ModuleScript**. O instalador mostra somente essas quatro partes para o Shop UI. Depois de instalar todos os sete scripts, inicie um teste novo.

O mapa, regras, salas no servidor e serviços do catálogo mantêm a base já instalada. Os campos exportados pelo 09A anterior continuam disponíveis. `TopMusic`, nomes de ScreenGui, `OpenRequest`, `HudAction` e os remotes de partidas seguem os contratos existentes. O instalador inclui os sete arquivos V40 offline, mantém o histórico online e verifica hashes quando Web Crypto está disponível.

## Verificação realizada

- Sete scripts compilados com o parser Lua 5.4, todos com até 400 linhas e sem atribuições compostas.
- Campos exportados pelo Shop UI comparados com a V39; nenhum campo anterior foi removido.
- Geometria de HUD, editor, diálogos, menu de jogos e tabuleiro calculada em cinco áreas úteis: 320×604, 360×604, 800×324, 1460×785 e 1920×1040. Foram verificados limites, áreas de ações e sobreposições relevantes.
- Integração real dos controladores com serviços simulados: atalhos do HUD, carrinho, salvamento no Roblox, carregador de avatar, parâmetros de criar/entrar/cancelar sala, erros de cancelamento, ordem de respostas e restauração do HUD.
- Regras reais de xadrez usadas no treino; bloqueio de segundo toque e cancelamento de callbacks antigos na Batata; fluxo da Batata online e saída pelo contrato `leave`.
- JavaScript real do instalador executado em Node.js com DOM mínimo: pacote offline, hashes, reconstrução exata, quatro partes exclusivas do 09A, cópia/seleção, cache antigo, fonte divergente e fechamento durante carregamento.

Os resultados estão em `results.json` e `installer_logic_results.json`. Para reproduzir:

```sh
python audits/V40/test_redesign.py
node audits/V40/test_installer_logic.cjs
```

Os doubles de serviços e GUI não simulam renderização, física ou rede real do Roblox. Foi feita uma revisão aproximada de layout com os retângulos dos componentes e fonte substituta; ela não é uma captura do jogo. Não houve execução no Studio/Studio Lite nem teste visual do HTML em navegador: o Chromium deste ambiente não pôde ser instalado.

## Conferência no Studio Lite

1. Abrir a V40 em celular na vertical e horizontal e no computador. Conferir a área dos controles nativos do Roblox, textos e ícones.
2. Testar Catálogo, Lojas, Comunidade, Looks, Carregar avatar, Emotes e cada atalho inferior. Salvar um look, publicar, girar/zoomar e aplicar a prévia.
3. Em dois jogadores do mesmo servidor, criar sala, selecionar código, entrar, cancelar fila, iniciar partida, ocultar/reabrir e desistir. Conferir os relógios do servidor.
4. Jogar Xadrez, Damas e Batata contra o bot; sair durante o turno do bot e iniciar outro treino.
5. Confirmar renderização de avatares, reprodução de emotes, prompts de compra/salvamento e persistência usando os serviços reais.
