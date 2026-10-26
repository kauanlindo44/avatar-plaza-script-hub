# Auditoria V78 — correções funcionais

Base publicada: `f88837441d91560b593c78a26676a736c86b8bcf` (V77). Entrega: **3 módulos novos + 26 substituições**, cada fonte com até **394 linhas**.

**212 cenários passaram em 18 suítes.** Foram executadas nossas fontes Lua com serviços/instâncias do Roblox simulados, dentro de um processo com bloqueios reais de sockets/execução, limites de CPU/memória e I/O Lua restrito. Isso não é uma execução do motor Roblox. A V78 exige propriedades booleanas estritas nos doubles; `Visible=nil` já não passa silenciosamente. Essa revisão encontrou e corrigiu estados inválidos nos cards do catálogo, nas atividades da IA e no HUD do Caos.

Os testes adicionais executam a fábrica real de proteção de pedidos, snapshot e montagem de prévia, rejeição de fábrica incompatível sem liberar handlers, biblioteca real de carrinho/corpo, 19 mudanças de tema sem teleporte, materiais/continuação dos cenários e câmera com teclado/joystick. Também compõem os módulos reais de navegação e histórico da IA para verificar sobreposições. Os testes anteriores de partidas, recibos, spam, dados malformados e captura continuam passando.

As **183 fontes efetivas** compilam em Lua 5.4; todos os **182 hashes declarados** conferem. Uma fonte legada não declara hash. Os **1.048 caminhos históricos**, em 47 versões anteriores, mantêm os mesmos bytes. Onze divergências de declaração de hash em V37 já existiam; não se alteraram essas fontes. Motores, bots, relógios e dono de recibos permanecem iguais.

O JavaScript real do instalador verifica cópia integral/partes, hashes, fallback offline, cache antigo, fonte adulterada e nomes/tipos/locais. A execução usa DOM simulado, não um navegador renderizando CSS. Chromium não está disponível neste workspace. Os 39 layouts são exportações de geometria das fontes e reconstruções com arte ilustrativa; não são screenshots do Roblox e não comprovam a aparência das texturas ou o funcionamento de um aparelho real.

A contagem das 13 composições novas atinge no máximo **133 peças no PC e 121 no toque** na simulação atual. Orçamentos explícitos: 176/144. Piso único fixo; sem sombras, luzes adicionais ou arquivos de textura externos. Vale da aventura tem orçamento separado de 180 peças. Esses números não equivalem a medição de FPS.

## Reproduzir

```bash
python audits/V78/run_checks.py
python audits/V78/test_sandbox.py
python audits/V78/build_installer.py
python audits/V78/test_package.py
node audits/V78/test_installer_logic.cjs
node audits/V78/test_counters.cjs
python audits/V78/build_zip.py
```

O instalador recusa fontes alteradas depois do checkpoint de regressão. O ZIP confere os hashes de todos os scripts e a igualdade dos bytes do HTML antes de substituir o pacote final.

**Pendências:** instalar no place e executar no Roblox Studio/Lite, testar teclado/toque/rotação em aparelhos reais, renderização/materiais, áudio, captura, FPS e multiplayer. Compras reais e permissões de assets dependem do Roblox. Nenhuma afirmação de funcionamento 100%, ausência de toda vulnerabilidade ou cópia pixel a pixel é feita. A gravação dos mapas foi revista por amostragem explicitada em RESEARCH.md; extensões fora da câmera são composição própria.
