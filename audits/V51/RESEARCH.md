# Pesquisa V51 — Roblox, corpos e tela

Consultada em 4/5 de outubro de 2026. Fontes técnicas primárias do Roblox Creator Hub e seu repositório oficial `Roblox/creator-docs`.

## Áreas seguras

- [GuiBase2d.AbsolutePosition](https://create.roblox.com/docs/reference/engine/classes/GuiBase2d): a posição é relativa à origem de CoreUISafeInsets, não à borda física do display. A documentação YAML foi lida no [repositório oficial](https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/GuiBase2d.yaml).
- [GuiService.GetInsetArea / TopbarInset](https://create.roblox.com/docs/reference/engine/classes/GuiService): os Rects de insets também são relativos a CoreUISafeInsets. O exemplo oficial retorna None=(-59,-58,792,334), Device=(0,-58,733,313), Core=(0,0,733,313), Topbar=(164,-58,733,0). A V51 transforma todos para a origem de None. O bottom real nesse exemplo é 21; o cálculo antigo podia produzir 79. Topbar representa o espaço desocupado e pode mudar quando a UI nativa muda.
- [ScreenInsets](https://create.roblox.com/docs/reference/engine/enums/ScreenInsets): DeviceSafeInsets protege recortes físicos; CoreUISafeInsets inclui o espaço reservado à UI Roblox; TopbarSafeInsets delimita a parte disponível do topo. None sozinho não garante segurança de controles. A V51 usa fundo até a borda e calcula limites interativos explícitos.
- [ScreenGui](https://create.roblox.com/docs/reference/engine/classes/ScreenGui): SafeAreaCompatibility.None evita extensão automática. ClipToDeviceSafeArea não protege um ScreenGui com None; portanto as posições são limitadas pelos Rects nativos. GuiService.ReducedMotionEnabled é respeitado nas novas animações.

**Achado reproduzível no código:** 07UI_SCREEN_BOUNDS usava AbsolutePosition de uma origem junto com o tamanho total, sem descontar a origem. 09A1 reservava o topo inteiro do catálogo, mesmo com espaço disponível à direita, e restringia a prévia a um quadrado. 09C2 dividia cards baixos entre imagem e preço lateral. Esses problemas foram corrigidos; os recortes de segurança são mantidos.

## Corpos Marketplace

- [Character body specifications](https://create.roblox.com/docs/avatar/character-bodies/specifications): corpos realistas e estilizados também usam a estrutura R15. São quinze objetos de malha agrupados em seis assets. Não é preciso inventar um terceiro rig para um corpo meme. As formas e proporções são próprias dos assets.
- [Players](https://create.roblox.com/docs/reference/engine/classes/Players): GetHumanoidDescriptionFromOutfitIdAsync devolve as peças, cores e animações do outfit; CreateHumanoidModelFromDescriptionAsync cria o modelo no rig indicado. GetHumanoidDescriptionFromUserIdAsync consulta a aparência equipada, não todo o inventário comprado.
- [BodyPartDescription](https://create.roblox.com/docs/reference/engine/classes/BodyPartDescription): filhos de HumanoidDescription podem representar os assets do corpo, cor e HeadShape. A V51 serializa os metadados publicados e os preserva em preview/Apply/save/respawn. Não aceita Instances arbitrárias enviadas pelo cliente. Referências Instance já confiáveis na descrição do servidor são preservadas quando compatíveis; geração/transporte de corpos não publicados não faz parte desta entrega.
- [HumanoidDescription](https://create.roblox.com/docs/reference/engine/classes/HumanoidDescription): UseAvatarSettings pode aplicar as regras da experiência; permanece false no gerador. StaticFacialAnimation e MoodAnimation influenciam a expressão de cabeças dinâmicas e agora sobrevivem ao caminho de dados.
- [Humanoid](https://create.roblox.com/docs/reference/engine/classes/Humanoid): GetAppliedDescription permite ler a aparência efetiva; GetBodyPartR15 identifica papéis sem depender exclusivamente do nome da Instance. ApplyDescriptionResetAsync continua no caminho de edição de um rig já compatível.
- [AssetTypeVerification](https://create.roblox.com/docs/reference/engine/enums/AssetTypeVerification): a documentação recomenda Always para assets do catálogo. A V51 usa esse modo tanto no cliente quanto no servidor, sem inserir modelos arbitrários.

**Achados reproduzíveis no código:** a conversão antiga descartava metadados nativos de corpo/expressão; S.Try exigia que o serviço de metadados respondesse antes de resolver um bundle; um asset extra indisponível podia abortar um outfit válido. A prévia não conferia os IDs efetivos do modelo gerado. A V51 preserva os dados publicados, resolve primeiro o outfit e verifica a confirmação. Falhas transitórias têm uma nova tentativa limitada.

## Corpo específico e limites

A busca pública pelo nome Funky Ehh Kid Meme (Gumball) não forneceu uma página oficial verificável do bundle exato usado pelo jogador. O nome pode corresponder a mais de uma publicação. Não foi usado um ID suposto para alterar a lógica, e não se inferiu moderação de um componente que não está à venda individualmente.

A causa específica nesse asset não foi confirmada em um cliente Roblox. A correção foi validada em casos simulados que reproduzem os defeitos do código. É necessário conferir renderização e disponibilidade de meshes no Roblox real. Erro de rede, permissão ou moderação da plataforma não pode ser resolvido fabricando um avatar nem ignorando a verificação de assets.
