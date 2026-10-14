# Auditoria V64

Base publicada: `232164b3de7987a1036d65dff020fc3700062418` (V63).

Delta explícito: 2 módulos novos, 24 substituições. `07P1_CAPTURE_ENGINE` é uma dependência anterior que passa a integrar o instalador; criar somente se estiver ausente. Históricos e armazenamento preservados.

- `test_fixes.py`: 13 cenários de orçamento, dados pessoais, comunidade, contexto/cancelamento da IA, seleção de peças, captura e permissões/transferência.
- `test_interface.py`: 9 cenários de geometria/lifecycle, incluindo LocalScript real da IA e coleta de cartas sem reiniciar animação a cada snapshot.
- `test_regressions.py`: 9 cenários do construtor readonly, destinos, patrocínio, salas virtuais, metas, IA/servidor e respawn.
- `test_package.py`: sintaxe, histórico, nomes/tipos/locais, limites de linhas, hashes/dependências e recibo único.
- `test_installer_logic.cjs`: JavaScript real do instalador com DOM simulado.

Rodar com Python 3 e Lua 5.4 via `audits/V43/lua_runner.py`; não há Roblox Studio/motor neste ambiente. Geometria numérica não é screenshot do jogo nem medição de FPS. Serviços são doubles e não validam acesso real aos assets.
