# Instalação V57 — apenas 7 substituições, nenhum NOVO

Requer V56 completa. V57: somente 7 SUBSTITUIÇÕES e nenhum NOVO. Pare Play, substitua as fontes completas nos locais indicados e reinicie Play. Não duplique scripts. Mantenha 09C4_OUTFIT_LIBRARY da V55 já instalada; não existe substituição V56/V57 desse módulo. Guia: INSTALL_V57.md.

## Substituir estes 7 scripts

| Nome exato | Tipo | Local | Linhas |
|---|---|---|---:|
| `08B2_BODY_DESCRIPTION` | ModuleScript | ReplicatedStorage | 91 |
| `08B3_AVATAR_VERIFY` | ModuleScript | ReplicatedStorage | 67 |
| `08B4_AVATAR_LOAD` | ModuleScript | ReplicatedStorage | 113 |
| `08B5_AVATAR_DIAGNOSTICS` | ModuleScript | ReplicatedStorage | 68 |
| `09B_SHOP_SERVER` | Script | ServerScriptService | 214 |
| `09C12_AVATAR_FEEDBACK` | LocalScript | StarterPlayer > StarterPlayerScripts | 105 |
| `09C_SHOP_CLIENT` | LocalScript | StarterPlayer > StarterPlayerScripts | 380 |

## Instalar

Use o HTML V57 novo ou sincronize o instalador permanente pelo GitHub. A tela inicial mostra somente as sete substituições da V57; fontes inteiras/partes continuam escondidas até copiar. Copie o script inteiro para a instância existente, sem acrescentar NOVO/SUBSTITUIR ao nome. Não crie duplicatas. Cada fonte tem até 400 linhas.

Requer **V56 completa**, incluindo os quatro novos scripts dela. Pare Play antes das sete substituições e reinicie para limpar o cache de require. A V57 não pede passes, produtos ou scripts novos.

**09C4_OUTFIT_LIBRARY continua V55.** O aviso pedindo esse módulo na V56 era um erro do cliente V56, que rejeitava a versão fornecida. A V57 aceita e inicializa V55; não substitua esse módulo por um módulo inventado V56/V57. O 09A_SHOP_UI e suas quatro partes continuam instalados.

## O que mudou no avatar

O verificador usa `AccessoryDescription.IsLayered` da descrição efetivamente aplicada, associada ao Humanoid. O Roblox pode corrigir essa classificação ao aplicar o acessório. Se um cabelo foi solicitado como camada mas aplicado como rígido, não é obrigado a ter WrapLayer ou Handle MeshPart: Handle Part com SpecialMesh válido também é aceito.

A instância precisa corresponder ao ID solicitado pelo `GetAppliedInstance` da descrição aplicada. Outro acessório com o mesmo tipo não serve como confirmação. Cabelo que continua realmente em camadas mantém a exigência de camada/corpo. Tipos de roupa 3D, como ShirtAccessory do gato abacaxi 72779265740934, continuam exigindo R15, malha preenchida, WrapLayer ativo e WrapTarget no corpo. Esta correção não remove itens da skin para disfarçar uma falha.

O servidor continua aplicando pela descrição nativa completa, preservando roupas/corpo e usando o fluxo existente de restauração em falha e aparência lembrada. O aparelho continua conferindo seus próprios conteúdos separadamente. Layered Clothing protegido não é forçado por script.

A comparação de aparência agora ignora a ordem de leitura dos mesmos IDs de emote. Isso evita recriar a prévia no Photo Mode somente porque o Roblox devolveu o dicionário de emotes em outra ordem; mudar os IDs continua invalidando a comparação.

## Ler o diagnóstico

A janela mostra **item com falha, tipo e requisito**, quando a verificação consegue localizar o acessório. Também mostra etapa, origem, lado Client/Server, esperado/encontrado, causa e código. Erros gerais de criação/conteúdo que não identificam um acessório não recebem um ID inventado.

- **Validação do jogo:** uma verificação do nosso código falhou.
- **Erro retornado pelo Roblox:** uma chamada nativa lançou um erro; o texto original fica preservado.
- **Erro do script:** uma exceção interna ocorreu durante a verificação.
- **Carregamento de conteúdo / tempo de carregamento:** falha ou timeout de malha/textura.
- **Configuração do projeto:** roupa em camadas desativada.

Requisitos incluem APPLIED_DESCRIPTION, APPLIED_INSTANCE, GET_APPLIED_INSTANCE, HANDLE, MESH, VISIBILITY, WRAP_LAYER, WRAP_ENABLED, BODY_CAGE e RIG. Não são todos apresentados como “Erro do Roblox”.

Procure **`[Avatar V57] FALHA`** e o código exibido no Output. Falha local aparece em Client e também é enviada ao Server com o mesmo item/requisito. O servidor confirma que o ID informado pertence ao avatar dele e usa o tipo real, sem confiar no tipo enviado pelo cliente. O texto completo da causa fica no Output; a janela usa texto limitado.

## Conferir no Roblox

1. Instale os sete scripts, com tipos/locais da tabela, e reinicie Play.
2. Abra o carrinho: o aviso pedindo 09C4 V56 deve desaparecer, com a versão V55 instalada.
3. Teste o look que mostrou “Hair: esperado 1, encontrado 0” e o gato abacaxi, feche catálogo e confira a roupa no mapa.
4. Teste respawn/reentrada, prévia e Photo Mode. Se falhar, o relatório deve identificar ID/requisito quando houver evidência por item.
5. Confira o mesmo código nos filtros Client e Server do console. Roupas válidas não devem ser removidas para completar a aplicação.

Validação automatizada: Lua 5.4 com serviços simulados e JavaScript real do HTML com DOM mínimo. Os IDs usados nos testes são metadados; não carregam os assets reais. **Não houve execução no motor Roblox, cobrança ou comprovação visual do gato no mapa publicado.**
