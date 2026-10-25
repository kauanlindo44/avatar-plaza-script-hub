# Auditoria V77

Base publicada: V76, commit `9594b931ae57a7ec1cc3ca4ee3bce31340bfdd46`. O manifesto resolve as fontes efetivas; não foi escolhida uma pasta pelo maior número de versão. A V77 acrescenta cinco ModuleScripts e substitui 24 fontes, todas com até 399 linhas.

## Verificações executadas

- **198 cenários em 17 suítes**, executando os módulos/controladores com serviços Roblox simulados em Lua 5.4. [Resultados](suite_results.json).
- **180 fontes compiladas**, 179 hashes declarados conferidos; uma fonte legada não tem hash declarado. Todos os 1.017 caminhos históricos mantêm seus bytes. Onze declarações da V37 já divergiam na base e não foram reescritas. [Verificação do pacote](syntax_results.json).
- Rede e execução de comandos efetivamente bloqueadas por seccomp no processo dos testes; I/O e acesso ao ambiente também limitados dentro do Lua. [Resultado da sandbox](sandbox_results.json).
- RPCs de IA/catálogo: dados cíclicos, profundidade/tamanho excessivo, NaN/infinito, mil ações repetidas, falsificação de plano/proprietário, concorrência e recibos duplicados. [Segurança](security_results.json).
- Tabuleiro: só lances aceitos entram no histórico, revisões antigas e espectadores não forjam entradas; 500 inserções continuam limitadas a 120 registros. Regras/bots permanecem nas mesmas fontes; o relógio do servidor e suas chamadas ao motor são preservados. [Tabuleiro](board_ui_results.json).
- HUD: 14 combinações de geometria/toque, 44 px mínimos e reserva do pulo. IA acessível pelo menu Mais, repetição de toque limitada; seis categorias de configurações. Catálogo experimenta sem comprar e compra apenas na ação explícita. [Interface](reference_ui_results.json).
- Controlador do modo foto: 50 trocas de painel sem deslocar câmera/modelo; 100 toques iniciam uma solicitação de captura; timeout recupera a interface. [Controlador](photo_controller_results.json).
- 13 composições dos mapas, 268 peças somadas, orçamento individual de 96, centro livre de 92 studs e cancelamento de geração. IA limitada lateralmente e 1.800 conceitos editoriais locais sem IDs fabricados. [Mapas/IA](worlds_ai_results.json).
- Instalador: código JavaScript real com DOM simulado; reconstrução das duas partes, cópia integral, fallback sem rede, rejeição de cache antigo, hashes e contadores separados. [Lógica](installer_logic_results.json), [812 cards verificados](counter_results.json).

## O que estes testes não comprovam

Não são testes nativos do Roblox/Luau, física, streaming, FPS, aparelho físico, áudio ouvido, renderização de avatars, compra/recibo real ou multiplayer publicado. Chromium local não está instalado, portanto o teste visual do instalador em Chromium não executou. [Registro](installer_browser_results.json).

As reconstruções JPG usam posições exportadas dos scripts e imagens ilustrativas. Não são screenshots do jogo. [Revisão visual](visual_review.jpg). A cobertura da pesquisa e da análise dos vídeos é descrita sem alegar inspeção integral em [RESEARCH.md](RESEARCH.md). A correspondência com o pedido está em [PROMPT_REVIEW.md](PROMPT_REVIEW.md).

## Reprodução

Na raiz do repositório, execute `python audits/V77/run_checks.py`, `python audits/V77/test_sandbox.py`, `python audits/V77/build_installer.py`, `python audits/V77/test_package.py`, `node audits/V77/test_installer_logic.cjs` e `node audits/V77/test_counters.cjs`. O build usa a base congelada da V76 e recusa fontes sem alteração além do cabeçalho. Testes de versões anteriores foram atualizados somente para expectativas visuais substituídas pelo pedido atual e para dependências novas; verificações de comportamento/autoridade continuam presentes.
