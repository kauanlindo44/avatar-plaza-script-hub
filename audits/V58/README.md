# Validação V58

Base GitHub V57: **b918b7d1baf28448855f97fdc00868e01e4704b2**, árvore **1787b7691a26bac7f25bae24de9d0ee9b6292da3**. Delta: 26 substituições + um novo ModuleScript `07UI_SLIDER`. As fontes anteriores são preservadas; a base efetiva está em `base_sources.json`.

**76 casos funcionais** em onze suítes usam Lua 5.4 com serviços Roblox simulados. Os arquivos `*_results.json` registram cada caso e sua evidência. Sintaxe/package e execução real do JavaScript do instalador são verificações separadas.

- IA: chamada mínima sem Unicode/JSON obrigatório/contexto, resposta textual nativa aceita, HTTP 400 e recuperação curta, estado desatualizado, separação entre conexão/armazenamento, ajuda temporária, limite de sessão, recibo não confirmado e compra bloqueada sem armazenamento.
- Avatar: descrição completa, roupa em camadas e cabelo rígido corrigido, instância exata, identidade confirmada pelo servidor e replicada ao aparelho, malha/cage/WrapLayer, conteúdo, falha real, rollback, snapshot e diagnóstico por item. Os IDs são fixtures: não carregam assets Roblox reais.
- Interfaces: cliente real de música/carrinho/catálogo/Photo Mode, fila e fim da música, busca e mute, carrinho explícito e prévia recolhível, filtros/preços reais, cenário fixo durante movimentos, limpeza, X e configurações locais. Layout usa 320×568, 390×844, 568×320, 667×375, 851×392 com recorte e 1920×1080. Alvos de fechar/controle têm 44 px onde testados.
- Jogos: nomes/dono/equipes das cartas, mesa e três cartas privadas; regras existentes de truco; regressões significativas de xadrez/damas (promoção, captura majoritária, empate e en passant). Nenhuma mudança nas regras foi necessária.

O novo mock `v58_doubles.lua` só acrescenta propriedades/sinais de áudio e resposta/erro explicitamente configurados da IA. Não simula renderização nem afirma equivalência com Roblox. Os mocks de corpo/roupa continuam exigindo provas físicas nos testes. `test_package.py` compila 98 fontes, confere hashes anteriores, dependências e o único dono de ProcessReceipt. `test_installer_logic.cjs` executa o JavaScript real com DOM mínimo e confere os 27 nomes, 26 substituições/1 novo, fontes e partes, clipboard, fallback, cache e status ONLINE verde. Não testa CSS de navegador.

Documentação primária consultada durante a implementação:

- [TextGenerator](https://create.roblox.com/docs/reference/engine/classes/TextGenerator).
- [Relato original sobre caracteres e HTTP 400](https://devforum.roblox.com/t/textgenerators-can-only-return-english-characters/4018138): evidência histórica, sem presumir que a restrição seja permanente.
- [Relato sobre JsonSchema e HTTP 400](https://devforum.roblox.com/t/json-schema-leads-to-error-for-beta-text-generation/4320302).
- [Relato sobre resposta JSON Schema](https://devforum.roblox.com/t/text-generation-jsonschema-response-type-fails-to-force-json-compliance/4592233).
- [AccessoryDescription](https://create.roblox.com/docs/reference/engine/classes/AccessoryDescription), [HumanoidDescription](https://create.roblox.com/docs/reference/engine/classes/HumanoidDescription) e [WrapLayer](https://create.roblox.com/docs/reference/engine/classes/WrapLayer).
- [Data stores](https://create.roblox.com/docs/cloud-services/data-stores), [políticas de IA generativa](https://create.roblox.com/docs/production/publishing/generative-ai-guidance) e [permissões dos assets](https://create.roblox.com/docs/projects/assets/privacy).

Não houve execução no Roblox, cobrança, alteração de preço, publicação da experiência ou acesso ao Studio do usuário. A redução da chamada nativa é uma correção testável de contrato/recuperação; a causa interna do HTTP 400 do serviço e o sucesso real do gato no mapa só podem ser confirmados na experiência. Veja `INSTALL_V58.md`.
