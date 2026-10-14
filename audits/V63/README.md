# Auditoria V63

Base: V62 `6ee0a6afb665a1a806388b6a6706cd04604af93f`. Delta: **25 instâncias — cinco novas e vinte substituições**. Fontes/hashes/manifestos históricos são preservados pela árvore remota de base.

32 cenários em Lua 5.4/doubles: 11 de serviços/regras herdados, nove de UI/controladores e 12 novos. Novos casos exercitam construtor com filtros readonly, substituição exata de exemplos, seeds/metadados/slots/índice/paginação/favoritos de destinos, pool virtual do Truco, metas com jogadas legais, solicitação completa de IA, script de spawn, controles de música em seis geometrias, browser nativo de destinos e recuperação/menu/compositor da IA. Cenários também conferem seis mundos ao ar livre, materiais/céus, limite de partes/restauração e movimentos de vídeo. Os doubles não executam renderização, física/colisões/FPS ou serviços nativos Roblox.

```sh
python audits/V63/test_features.py
python audits/V63/test_interface.py
python audits/V63/test_new_features.py
python audits/V63/test_new_interface.py
python audits/V63/build_installer.py
python audits/V63/test_package.py
node audits/V63/test_installer_logic.cjs
```

O pacote compila 117 fontes efetivas, confere dependências, tipo/local/ação, máximo de 400 linhas, único ProcessReceipt e hashes anteriores. O JavaScript real confere clipboard, partes recolhidas, última linha, online/offline/cache e cancelamento, com DOM doubles; não renderiza CSS. Native tests e limites práticos estão no [guia de instalação](../../INSTALL_V63.md).
