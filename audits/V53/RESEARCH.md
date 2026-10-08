# Referências V53 — consultas em 8 de outubro de 2026

A V53 usa documentação primária do Roblox para as APIs alteradas. Regras, decks e referências anteriores continuam em [V52/RESEARCH.md](../V52/RESEARCH.md); nenhuma regra de pontuação foi reinventada.

- [Pineapple Cat Suit — Roblox](https://www.roblox.com/pt/catalog/72779265740934/Pineapple-Cat-Suit): exemplo fornecido pelo usuário, camisa 3D (ShirtAccessory), diferente de um bundle de corpo. A classificação foi consultada; o asset não foi carregado no motor.
- [Players](https://create.roblox.com/docs/reference/engine/classes/Players): criação nativa por HumanoidDescription e rig explícito com AssetTypeVerification.Always. O pacote conserva descrição de corpo e roupas, evitando construir um corpo por números isolados.
- [Humanoid](https://create.roblox.com/docs/reference/engine/classes/Humanoid): GetAppliedDescription, ApplyDescriptionResetAsync e GetBodyPartR15. A estrutura aceita funções nativas de partes, inclusive meshes com nomes diferentes.
- [HumanoidDescription](https://create.roblox.com/docs/reference/engine/classes/HumanoidDescription): corpo, cores/proporções, acessórios em camadas e UseAvatarSettings. A conferência compara a descrição solicitada com a aplicada, preservando a mescla existente de roupas.
- [ContentProvider](https://create.roblox.com/docs/reference/engine/classes/ContentProvider): PreloadAsync espera conteúdo e recebe callbacks AssetFetchStatus. Uma falha de asset pode ser relatada no callback, portanto pcall sem erro sozinho não representa sucesso de download.
- [AccessoryDescription](https://create.roblox.com/docs/reference/engine/classes/AccessoryDescription): GetAppliedInstance para verificar o acessório específico associado à descrição aplicada, quando disponível. A conferência usa apenas descrição anexada ao Humanoid, não uma cópia desacoplada.
- [WrapLayer](https://create.roblox.com/docs/reference/engine/classes/WrapLayer) e [WrapTarget](https://create.roblox.com/docs/reference/engine/classes/WrapTarget): camadas e encaixe do corpo. MeshPart/Handle, layer ativa e target presentes são condições verificáveis, sem editar CageMeshId/ReferenceMeshId protegidos. Presença dessas instâncias não prova o ajuste visual final.
- [StarterPlayer](https://create.roblox.com/docs/reference/engine/classes/StarterPlayer): LoadCharacterLayeredClothing é protegida/Not Scriptable e Not Replicated. Não escrevemos a propriedade. A leitura com pcall é somente tentativa; o criador precisa conferir a configuração de avatar no projeto.
- [AvatarEditorService](https://create.roblox.com/docs/reference/engine/classes/AvatarEditorService) e [CatalogPages](https://create.roblox.com/docs/reference/engine/classes/CatalogPages): GetBundlesByAssetIdAsync(assetId, limit) retorna CatalogPages; consultamos GetCurrentPage. A resolução usa limite de dez candidatos por asset e não promete buscar a combinação ótima de todos os bundles.
- [AssetService](https://create.roblox.com/docs/reference/engine/classes/AssetService): GetBundleDetailsAsync retorna os itens do pacote, usados para excluir peças cobertas por um bundle.
- [MarketplaceService](https://create.roblox.com/docs/reference/engine/classes/MarketplaceService): metadados/posse de asset e bundle e PromptBulkPurchase. Posse não é guardada como dado público; preço desconhecido não vira zero e o prompt nativo define o preço final.
- [Player](https://create.roblox.com/docs/reference/engine/classes/Player): IsFriendsWithAsync(userId) confirma amizade para reservar o parceiro. A reserva não envia mensagem ou convite externo.
- [MemoryStoreService](https://create.roblox.com/docs/reference/engine/classes/MemoryStoreService) e [TeleportService](https://create.roblox.com/docs/reference/engine/classes/TeleportService): reserva atômica no diretório existente e transferência ao anfitrião, com validação de convidado/token/universo no fluxo de chegada.

## Conclusões e escopo

Inferência: selecionar R6, substituir a aparência inteira, retornar um modelo genérico ou confirmar apenas IDs podem explicar parte das falhas relatadas. A V53 elimina essas condições verificáveis, compartilha o carregamento entre superfícies e dá retry com erro visível. Não é uma prova da causa de toda falha de corpo e não certifica que todo asset meme tenha cages compatíveis ou esteja disponível.

Não foram incorporados assets, marcas ou código do Catalog Avatar Creator. O layout e as artes são do projeto. A V53 mantém as vendas diretas da V52, sem novas caixas, mudança de preço/IDs, compra de testes, patrocínio ou publicação do place. Não há nova orientação/certificação jurídica.

