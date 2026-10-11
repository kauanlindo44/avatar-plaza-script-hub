# Auditoria V60

Base publicada confirmada: `7b315b632e27d221632ab30a589216af50d00326` (V59). O pacote altera somente **18 instâncias: 15 substituições e três novos módulos**. `base_manifest.json` mantém o manifesto completo dessa base; a auditoria compara todos os metadados históricos e os hashes das 98 fontes efetivas da V59. As fontes antigas são preservadas pela árvore Git base, sem regravá-las; a publicação confere seus SHAs na nova árvore remota.

`test_features.py` executa dez casos de regra/serviço: prazo e reenvio, deduplicação e retirada, falhas de armazenamento/recuperação, favoritos após expiração, validação/compra nativa, paginação global circular, inventário paginado sem perda, permissão/decodificação/cancelamento, aposentadoria da IA gratuita e rotas reais de ShopRPC/código AV.

`test_interface.py` executa nove casos: HUD sem sobreposição em seis resoluções, configurações compactas, mundos locais distintos/restauração, linhas horizontais, composição de destaque/favoritar/comprar, comunidade código + Look de jogador, plano de imagem/clone/pose, foco real do ShopClient/música/carrinho e Halloween laranja. Mede a geometria de controles com doubles; não renderiza CSS nem o motor gráfico Roblox.

São **19 cenários simulados**. `v60_doubles.lua` emula contratos de DataStore, MemoryStoreSortedMap, inventário, propriedade e imagens, com falhas determinísticas. Os testes importam `test_support.py` e doubles das auditorias históricas V43/V48–V59 presentes no repositório. Não comprovam disponibilidade real de serviços, compras ou renderização de AvatarBackground.

Reprodução local, com Lua 5.4 compartilhada e Node.js disponíveis:

```sh
python audits/V60/test_features.py
python audits/V60/test_interface.py
python audits/V60/build_installer.py
python audits/V60/test_package.py
node audits/V60/test_installer_logic.cjs
```

O build recompõe somente a V60 e mantém intactas todas as versões anteriores. A verificação do pacote compila as 101 fontes efetivas, resolve dependências declaradas, checa os 18 deltas, tipos/locais, limite de 400 linhas e o único ProcessReceipt. O teste JavaScript executa o runtime real do instalador, incluindo modo offline, cache antigo, hashes, clipboard, status de sincronização e cancelamento.

Os testes nativos e as referências primárias estão no [guia](../../INSTALL_V60.md). Fundos são assets 2D de perfil possuídos; a imagem deve ser confirmada antes de aplicar. Falhas não são anunciadas como sucesso. Códigos AV consultam aparência atual, sem arquivo permanente de todas as skins de quem entra.
