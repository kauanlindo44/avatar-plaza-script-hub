# Validação V55

Base remota: `71ecc10926b71518f8786fb13491a2daadcaf3d7` (V54). Há 32 fontes alteradas: 18 substituições e 14 criações; 93 fontes efetivas. Scripts com até 380 linhas, sem mudança de regras/passes antigos. Instalador apresenta apenas esse delta e marca NOVO/SUBSTITUIR com tipo/local.

72 cenários executados em Lua 5.4 com serviços Roblox simulados: catálogo/carrinho, corpo e camadas, persistência, partidas, regras, recibos e prazos dos novos produtos, consentimento/revogação de convites, limites da IA, metadados de áudio, tema e seis tamanhos de tela. O caso novo do gato fecha o catálogo antes do debounce e exige o ID no personagem nativo simulado, sem apagar roupa/corpo anterior. Há testes que interrompem a inicialização do carrinho e exigem que os itens/X continuem funcionando.

`test_package.py` faz parsing de todas as fontes efetivas, verifica hashes, dependências, locais, tamanho e um único dono de ProcessReceipt. O teste Node executa o JavaScript real do instalador, cópia integral/partes, deduplicação de locais, marcas, fallback, sincronização e hashes.

`preview_layouts.py` gera reconstruções diagnósticas de geometria em 851×392, 390×844 e 568×320. Foram inspecionados o painel de música, enquete e loja de cartas, e o layout da prévia de três cartas em tela baixa foi ampliado após a inspeção. Esses PNGs **não são capturas do Roblox**. O renderizador de diagnóstico não reproduz Placeholders, TextScaled, thumbnails/ViewportFrames nativos nem o motor de roupas 3D.

Essas verificações não provam acesso real a TextGenerator, carregamento de malhas/cages no aparelho, autorização de áudio, DataStores reais, preços regionais ou cobranças. O roteiro de conferência está em INSTALL_V55.md. Nenhuma experiência Roblox foi publicada automaticamente. Veja RESEARCH.md para fontes e decisões sobre políticas, contas e anúncios.

Executar da raiz:

```bash
python3 audits/V55/test_features.py
python3 audits/V55/test_layout.py
python3 audits/V55/test_ui_actions.py
python3 audits/V55/test_catalog.py
python3 audits/V55/test_avatars.py
python3 audits/V55/test_utilities.py
python3 audits/V55/test_persistence.py
python3 audits/V55/test_game_ui.py
python3 audits/V55/test_servers.py
python3 audits/V55/test_rules.py
python3 audits/V55/test_regressions.py
python3 audits/V55/build_installer.py
python3 audits/V55/test_package.py
node audits/V55/test_installer_logic.cjs
```
