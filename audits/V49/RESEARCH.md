# Referências V49

Documentação primária Roblox consultada em 04/10/2026 via repositório oficial creator-docs e páginas de referência. Foram lidas as entradas completas relevantes antes de escolher as APIs.

- [Players](https://create.roblox.com/docs/reference/engine/classes/Players): CreateHumanoidModelFromDescriptionAsync recebe rig explícito; GetHumanoidDescriptionFromUserIdAsync recupera a aparência equipada; GetCharacterAppearanceInfoAsync contém playerAvatarType; GetHumanoidDescriptionFromOutfitIdAsync recupera o outfit nativo do pacote.
- [HumanoidDescription](https://create.roblox.com/docs/reference/engine/classes/HumanoidDescription): UseAvatarSettings=false evita aplicar as Avatar Settings da experiência à construção. A V48 clonava o HumanoidDescription aplicado sem normalizar esse campo; não foi observada a configuração real do place.
- [Humanoid](https://create.roblox.com/docs/reference/engine/classes/Humanoid): ResetAsync garante aparência conforme a descrição, mas não recebe parâmetro de rig. RigType tem escrita, porém mudar apenas esse enum sem corrigir a estrutura quebra o personagem. A V49 reconstrói as partes/articulações.
- [Player](https://create.roblox.com/docs/reference/engine/classes/Player): CharacterAdded vincula o personagem; CharacterAppearanceLoaded dispara no servidor para aparência nativa e não substitui inicialização própria de personagens customizados. LoadCharacterWithHumanoidDescriptionAsync não oferece argumento de rig; não foi usado como conversor R6/R15.
- [Especificações de corpos](https://create.roblox.com/docs/avatar/character-bodies/specifications): corpos do marketplace com formas realistas ou memes continuam usando nomes/hierarquia internos compatíveis, geralmente R15. A aparência externa não constitui um terceiro rig arbitrário.
- [BodyPartDescription](https://create.roblox.com/docs/reference/engine/classes/BodyPartDescription): a descrição nativa pode conter metadados adicionais de corpo/cabeça. A entrada e o cache de respawn mantêm o HumanoidDescription completo. O schema legado do editor continua baseado em IDs/propriedades/acessórios; suporte integral a campos futuros não foi certificado.

Fontes YAML equivalentes: `Roblox/creator-docs/content/en-us/reference/engine/classes/{Players,Player,Humanoid,HumanoidDescription,StarterPlayer,BodyPartDescription}.yaml` no branch principal. A decisão usa as assinaturas e documentação atuais; o sucesso visual de um asset específico depende de QA nativo.

Esta versão não altera monetização nem retoma pesquisa legal/visual do CAC. A pesquisa e as decisões da V48 permanecem em `audits/V48/RESEARCH.md`. Não há novos assets ou código copiados de outros jogos.
