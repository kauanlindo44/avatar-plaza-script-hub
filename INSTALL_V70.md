# Avatar Catalog & Games — Instalação V70

**Atualização exclusivamente visual sobre a V69.** Interface preto/grafite, contraste legível, destaques por categoria e menos superfícies claras.

**Instalador com botão de cópia:** [AVATAR_PLAZA_V70.html](AVATAR_PLAZA_V70.html) (baixe o HTML e abra no navegador conectado à internet). O código também está disponível em `scripts/V70/`.

## O que muda

- Fundos principais pretos/grafite com cartões separados visualmente e texto claro.
- Catálogo: destaque verde para roupas, marrom/laranja para cabelos, roxo para corpos e favoritos, azul/índigo para emotes.
- Assistente: tons violeta; comunidade: azul/roxo; música: violeta; patrocínios: laranja; jogos: verde/azul conforme tabuleiro.
- Preserva cartas, peças, prévias e texturas que precisam manter suas cores próprias.

**Não altera** as regras, bots, pontos, relógios, inventário, preço, compras, recibos, permissões, chat ou sistemas de salvamento. Nenhum novo Script/LocalScript de servidor ou cliente.

## Instalação

1. Garanta que a **V69 completa** esteja instalada. Faça cópia do projeto.
2. Pare o Play no Roblox Studio.
3. Em `ReplicatedStorage`, localize as **20 instâncias ModuleScript existentes** da tabela abaixo. Não crie novas instâncias e não acrescente V70 ao nome.
4. Clique em **Copiar script inteiro** na página V70 e substitua o conteúdo integral do ModuleScript correspondente.
5. Reinicie o Play **somente após atualizar os 20 módulos**. Teste catálogo, botões, assistente, jogos e telas no celular e no computador.

| ModuleScript — substituir em ReplicatedStorage | Linhas | Código |
|---|---:|---|
| `07H1_GAME_LOBBY` | 202 | [Abrir](https://github.com/kauanlindo44/avatar-plaza-script-hub/blob/main/scripts/V70/07H1_GAME_LOBBY.lua) |
| `07H2_GAME_BOARD` | 174 | [Abrir](https://github.com/kauanlindo44/avatar-plaza-script-hub/blob/main/scripts/V70/07H2_GAME_BOARD.lua) |
| `07K5_TRUCO_UI` | 174 | [Abrir](https://github.com/kauanlindo44/avatar-plaza-script-hub/blob/main/scripts/V70/07K5_TRUCO_UI.lua) |
| `07M1_MUSIC_UI` | 65 | [Abrir](https://github.com/kauanlindo44/avatar-plaza-script-hub/blob/main/scripts/V70/07M1_MUSIC_UI.lua) |
| `07UI_DESIGN_SYSTEM` | 167 | [Abrir](https://github.com/kauanlindo44/avatar-plaza-script-hub/blob/main/scripts/V70/07UI_DESIGN_SYSTEM.lua) |
| `07UI_HALLOWEEN_THEME` | 121 | [Abrir](https://github.com/kauanlindo44/avatar-plaza-script-hub/blob/main/scripts/V70/07UI_HALLOWEEN_THEME.lua) |
| `07UI_SURFACE_EFFECTS` | 66 | [Abrir](https://github.com/kauanlindo44/avatar-plaza-script-hub/blob/main/scripts/V70/07UI_SURFACE_EFFECTS.lua) |
| `09A1_SHOP_LAYOUT` | 194 | [Abrir](https://github.com/kauanlindo44/avatar-plaza-script-hub/blob/main/scripts/V70/09A1_SHOP_LAYOUT.lua) |
| `09A4_UTILITY_SKIN` | 71 | [Abrir](https://github.com/kauanlindo44/avatar-plaza-script-hub/blob/main/scripts/V70/09A4_UTILITY_SKIN.lua) |
| `09C12_DESTINATION_BROWSER` | 150 | [Abrir](https://github.com/kauanlindo44/avatar-plaza-script-hub/blob/main/scripts/V70/09C12_DESTINATION_BROWSER.lua) |
| `09C16_CATALOG_HOME` | 49 | [Abrir](https://github.com/kauanlindo44/avatar-plaza-script-hub/blob/main/scripts/V70/09C16_CATALOG_HOME.lua) |
| `09C1_SHOP_LOOKS` | 215 | [Abrir](https://github.com/kauanlindo44/avatar-plaza-script-hub/blob/main/scripts/V70/09C1_SHOP_LOOKS.lua) |
| `09C2_SHOP_CATALOG` | 280 | [Abrir](https://github.com/kauanlindo44/avatar-plaza-script-hub/blob/main/scripts/V70/09C2_SHOP_CATALOG.lua) |
| `09C5_UGC_STORES` | 184 | [Abrir](https://github.com/kauanlindo44/avatar-plaza-script-hub/blob/main/scripts/V70/09C5_UGC_STORES.lua) |
| `09C7_COMMUNITY_FEED` | 154 | [Abrir](https://github.com/kauanlindo44/avatar-plaza-script-hub/blob/main/scripts/V70/09C7_COMMUNITY_FEED.lua) |
| `09C8_COMMUNITY_DETAILS` | 150 | [Abrir](https://github.com/kauanlindo44/avatar-plaza-script-hub/blob/main/scripts/V70/09C8_COMMUNITY_DETAILS.lua) |
| `09C9_PLAYER_INSPECT` | 71 | [Abrir](https://github.com/kauanlindo44/avatar-plaza-script-hub/blob/main/scripts/V70/09C9_PLAYER_INSPECT.lua) |
| `09I4_ASSISTANT_UI` | 141 | [Abrir](https://github.com/kauanlindo44/avatar-plaza-script-hub/blob/main/scripts/V70/09I4_ASSISTANT_UI.lua) |
| `09I5_ASSISTANT_QUESTIONNAIRE` | 93 | [Abrir](https://github.com/kauanlindo44/avatar-plaza-script-hub/blob/main/scripts/V70/09I5_ASSISTANT_QUESTIONNAIRE.lua) |
| `09I6_ASSISTANT_RESULTS` | 133 | [Abrir](https://github.com/kauanlindo44/avatar-plaza-script-hub/blob/main/scripts/V70/09I6_ASSISTANT_RESULTS.lua) |

## Critérios de qualidade

- Arquivos históricos V69 permanecem inalterados. A V70 usa apenas fontes em `scripts/V70/`.
- Os 20 scripts de instalação têm no máximo 280 linhas; hashes SHA-256 estão no `manifest.json`.
- Foi realizada revisão estática das mudanças visuais. **Ainda não foi realizado teste nativo no Roblox Studio/Player nem em celular real**. A aparência final e a legibilidade devem ser verificadas antes da publicação para jogadores.
- Para voltar à V69, reponha as versões correspondentes das mesmas 20 instâncias conforme o manifesto histórico V69.
