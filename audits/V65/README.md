# Auditoria V65

Base publicada: `b1d6048498ad5c7b73b00051b7033f2258cdda02` (V64). Delta explícito: **2 novos módulos em ReplicatedStorage + 18 substituições**, 122 fontes efetivas. Histórico remoto preservado integralmente fora dos cinco arquivos de entrada atualizados; fontes V65 e auditoria entram como arquivos novos.

- `test_delta.py`: 17 cenários focados. Apoio entre corpos diferentes e no ar; descarte de inclinação/momento; rollback real; AnimationConstraint cinemática; emote carregado/reutilizado/recusado/duração zero; fallback com Animate quebrado; orçamento para camisa/calça; destinos XY, duas linhas, arraste e modais; lobby/bots/configurações/HUD em seis geometrias; música com uma/todas sugestões bloqueadas; player flutuante; integração com os patrocínios de itens.
- `test_fixes.py`: 13 regressões de dados pessoais/orçamento/índice global, cancelamento e contexto da IA, preços, captura e permissões/transferência.
- `test_interface.py`: 9 regressões de lifecycle/geometria da IA, salvos, popup de jogador, seis paisagens, catálogo e Truco.
- `test_regressions.py`: 9 regressões de parâmetros readonly, destinos, patrocínio, jogos 2D/sessões, IA/servidor e reaparecimento.
- `test_package.py`: compila as 122 fontes efetivas e verifica nomes/tipos/locais, limite de 400 linhas, hashes, dependências, histórico e ProcessReceipt único.
- `test_installer_logic.cjs`: executa o JavaScript real do HTML com DOM simulado; confere cópia integral/partes, nomes, campos recolhidos, modo offline, status de sincronização e rejeição de hashes incorretos.

Rodar os quatro testes Python acima com Python 3 e Lua 5.4 via `audits/V43/lua_runner.py`; depois `build_installer.py`, `test_package.py` e `node test_installer_logic.cjs`. O suporte estende explicitamente doubles anteriores; os novos contratos têm fixtures para raycast, Animator/tracks, AnimationConstraint, vetores e pivô de modelo.

**Limites:** doubles não reproduzem motor físico, renderização, cages de layered clothing, streaming real de malhas, permissões nativas de áudio/animação ou FPS. As geometrias não são screenshots do Roblox. Os 48 cenários validam decisões/controladores e regressões, sem prometer que um corpo sem ID foi reproduzido. O aviso FoundationProvider/UIBlox visto nas fotos é uma pilha interna; não é tratado como exceção comprovada de um script do jogo.
