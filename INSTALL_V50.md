# Instalação V50 — somente 11 itens

Requer a **V48 completa já instalada**. São **8 substituições + 3 scripts NOVOS**. A V50 contém exatamente o mesmo código destes 11 itens da V49; apenas retira da aba os outros 30 itens cumulativos.

**Se já colocou o código da V49 em algum destes itens, pule esse item.** Se terminou todos os 11 da V49, não há código adicional para instalar.

Pare Play. Crie os três novos primeiro, apenas se ainda não existem. Em seguida substitua a fonte dos oito existentes. Os rótulos (NOVO)/(SUBSTITUIR) não fazem parte do nome no Studio.

## Criar — 3 NOVOS

| Nome | Tipo | Local | Partes |
|---|---|---|---:|
| `08B1_BODY_PACKAGES` | ModuleScript | ReplicatedStorage | 2 |
| `09B5_AVATAR_RUNTIME` | ModuleScript | ServerScriptService | 2 |
| `09C11_AVATAR_CHARACTER` | LocalScript | StarterPlayer > StarterPlayerScripts | 2 |

## Substituir — 8 existentes

| Nome | Tipo | Local | Partes |
|---|---|---|---:|
| `08B_AVATAR_DATA` | ModuleScript | ReplicatedStorage | 2 |
| `08D_SKIN_STATE` | ModuleScript | ReplicatedStorage | 2 |
| `09A_SHOP_UI` | ModuleScript | ReplicatedStorage | 4 |
| `09A1_SHOP_LAYOUT` | ModuleScript | ReplicatedStorage | 2 |
| `09B_SHOP_SERVER` | Script | ServerScriptService | 2 |
| `09C_SHOP_CLIENT` | LocalScript | StarterPlayer > StarterPlayerScripts | 2 |
| `09C2_SHOP_CATALOG` | ModuleScript | ReplicatedStorage | 2 |
| `09C4_OUTFIT_LIBRARY` | ModuleScript | ReplicatedStorage | 2 |

**09A_SHOP_UI:** apague a fonte antiga uma vez e cole as quatro partes em ordem no mesmo ModuleScript. Nos demais, cole as duas partes em ordem na mesma instância. Preserve nomes, tipos e locais.

Abra V50 no HTML atualizado. O arquivo tem V50 e a base V44 disponíveis sem conexão; o histórico completo continua no GitHub. Para instalações anteriores à V48, use o pacote cumulativo V49 e [INSTALL_V49.md](INSTALL_V49.md).

As correções de corpos e catálogo, seus testes simulados e os testes visuais pendentes estão em [audits/V49/README.md](audits/V49/README.md). Esta entrega não muda a lógica do jogo, IDs, passes, produtos nem preços. VERSION V41/V44 internos continuam como contratos de compatibilidade.
