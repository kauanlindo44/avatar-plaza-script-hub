# Avatar Plaza V40.1 — fundo de tela inteira

Base: V40 publicada no commit `e5771fab449ce25dbcedef95549f6dae6132a96f`. Esta atualização substitui somente `07UI_DESIGN_SYSTEM`, um ModuleScript de ReplicatedStorage. Não há scripts novos.

A V40 construía o catálogo e os jogos dentro de ScreenGuis com `IgnoreGuiInset=false`. Os controles respeitam a área da barra superior do Roblox, mas o fundo também ficava limitado à área útil. Um Frame com Size 1×1 nessa área não é, por si só, garantia de cobertura da tela física.

A V40.1 acrescenta uma camada de fundo para `AvatarShop08Gui` e `GameClubGui`. Essa camada usa `ScreenInsets=None`, `IgnoreGuiInset=true`, `ClipToDeviceSafeArea=false` e Frame de tamanho 1×1. Os controles continuam na área útil para evitar sobreposição com ícones do Roblox e recortes do aparelho.

A camada acompanha o menu visível, sua cor, transparência, estado Enabled, ordem e ciclo de vida. Ela some quando todos os menus fecham ou a partida é minimizada. Também fica desligada quando a Batata online usa o mundo 3D com fundo transparente. A camada não recebe seleção nem captura entradas.

## Instalação

1. Aplique a V40 completa antes desta atualização.
2. Pare o teste. Abra a versão **V40.1** no instalador permanente.
3. Substitua o código de `07UI_DESIGN_SYSTEM` em ReplicatedStorage pelas duas partes, em ordem, no mesmo ModuleScript.
4. Inicie um teste novo para recarregar o módulo. Confira Catálogo, Comunidade, Looks, Lojas, Carregar avatar e Jogos.

O pacote V40.1 contém somente esse módulo alterado. O histórico continua acessível no instalador; o Shop UI da V40 mantém suas quatro partes.

## Verificação

- Sintaxe Lua 5.4, até 400 linhas e ausência de atribuições compostas.
- Os nove casos da V40 foram executados com os controladores/editor originais e o módulo atualizado.
- Cobertura calculada com barras de 36, 58, 64 e 88 pixels, recortes laterais, margem inferior e diferentes áreas de tela. O fundo começa em 0,0 e ocupa o viewport completo; fechar/entrar permanecem dentro da área dos controles.
- Estado de abertura, carregador de avatar, Enabled, alteração de cor/ordem, fechamento, minimização, fundo transparente, recriação e remoção do GUI.
- JavaScript do instalador com DOM mínimo, pacote offline, hash, reconstrução exata e cache antigo.

Execute:

```sh
python audits/V40_1/test_fullscreen.py
node audits/V40_1/test_installer_logic.cjs
```

Os resultados são de serviços e geometria simulados. Não houve renderização no Roblox Studio/Studio Lite. A conferência visual no aparelho continua necessária.

Referências oficiais consultadas: [ScreenGui](https://create.roblox.com/docs/reference/engine/classes/ScreenGui), [ScreenInsets](https://create.roblox.com/docs/reference/engine/enums/ScreenInsets) e [Instance.Destroying](https://create.roblox.com/docs/reference/engine/classes/Instance/Destroying).
