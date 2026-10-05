# Instalação V51 — 11 substituições + 1 NOVO

Requer a V50 completa (ou os mesmos 11 itens da V49 sobre a V48 completa). São 12 itens: 11 SUBSTITUIÇÕES e 1 NOVO. Pare Play e crie primeiro 08B2_BODY_DESCRIPTION em ReplicatedStorage, como ModuleScript. Depois substitua os 11 existentes, sem duplicar instâncias. Os três NOVOS da V50 são existentes nesta versão. 09A_SHOP_UI continua com 4 partes consecutivas no MESMO ModuleScript; os demais têm 2 partes. (NOVO)/(SUBSTITUIR) são rótulos, não parte do nome. Consulte INSTALL_V51.md.

## Criar primeiro — 1 NOVO

| Nome no Studio | Tipo | Local | Partes |
|---|---|---|---:|
| `08B2_BODY_DESCRIPTION` | ModuleScript | ReplicatedStorage | 2 |

## Substituir — 11 existentes

| Nome no Studio | Tipo | Local | Partes |
|---|---|---|---:|
| `07UI_SCREEN_BOUNDS` | ModuleScript | ReplicatedStorage | 2 |
| `08B_AVATAR_DATA` | ModuleScript | ReplicatedStorage | 2 |
| `08B1_BODY_PACKAGES` | ModuleScript | ReplicatedStorage | 2 |
| `08D_SKIN_STATE` | ModuleScript | ReplicatedStorage | 2 |
| `09A_SHOP_UI` | ModuleScript | ReplicatedStorage | 4 |
| `09A1_SHOP_LAYOUT` | ModuleScript | ReplicatedStorage | 2 |
| `09B_SHOP_SERVER` | Script | ServerScriptService | 2 |
| `09B5_AVATAR_RUNTIME` | ModuleScript | ServerScriptService | 2 |
| `09C_SHOP_CLIENT` | LocalScript | StarterPlayer > StarterPlayerScripts | 2 |
| `09C2_SHOP_CATALOG` | ModuleScript | ReplicatedStorage | 2 |
| `09C6_AVATAR_PREVIEW` | ModuleScript | ReplicatedStorage | 2 |

Apague a fonte antiga uma vez e cole as partes em ordem na mesma instância. Não crie quatro scripts para 09A_SHOP_UI. Não reinstale V50/V49 por cima destes itens depois.

O HTML mantém o código oculto e mostra nome, tipo, local, última linha e copiar. ONLINE fica verde quando sincronizado. Sem conexão, o arquivo contém V51 e V44; a V51 depende de uma V50 completa já instalada.

A V51 modifica apenas estes 12 itens. Jogos, passes, produtos, preços e dados salvos continuam compatíveis. As VERSION V41/V44 internas são contratos de compatibilidade.

## Conferir no Roblox

Abra o catálogo com um corpo meme/realista equipado no perfil. Experimente outro corpo e depois uma camisa; o restante do look deve permanecer. Confira as peças na prévia e no personagem, os quatro lados, morte/respawn e os X dos itens. Em caso de erro, use Tentar novamente.

Teste o celular deitado e em pé, incluindo notch/barra de gestos: no deitado, veja 5 cards por linha e 2 linhas nas telas com espaço suficiente, Robux embaixo e prévia maior. Os controles da Roblox devem continuar livres.

Os testes executados são simulados. Não comprovam a disponibilidade de cada asset nem a renderização do Funky Ehh Kid Meme (Gumball) no Roblox real. Detalhes e referências em [audits/V51/README.md](audits/V51/README.md) e [audits/V51/RESEARCH.md](audits/V51/RESEARCH.md).
