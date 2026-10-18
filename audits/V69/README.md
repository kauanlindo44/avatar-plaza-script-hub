# Auditoria V69

Base publicada: `04e8d334850200827fe3a7e64a8db9ae6f6f4e71` (V68). `base_manifest.json` registra o manifesto antes deste delta. Fontes históricas e metadados anteriores permanecem imutáveis.

## Reproduzir

Na raiz do repositório, com Python 3 e biblioteca `liblua5.4` disponível:

```bash
python3 audits/V69/run_checks.py
python3 audits/V69/build_installer.py
python3 audits/V69/test_package.py
node audits/V69/test_installer_logic.cjs
```

O executável Node deve estar no PATH. Neste ambiente foi usado o Node do runtime instalado. Os cenários executam o código Lua de produção com doubles explícitos dos serviços Roblox, não uma tradução em outra linguagem. `v69_doubles.lua` documenta os contratos adicionais de TextChatService; não implementa nem testa o filtro real da plataforma.

São 106 cenários anteriores e vinte novos, totalizando **126**. As expectativas visuais antigas de chão inteiramente plástico, cenário muito escuro e contagem mínima de pedras da aventura foram ajustadas para a nova composição. As regras continuam cobertas pelas verificações funcionais e de preservação do pacote.

`test_package.py` compila as 146 fontes efetivas, confere hashes, nomes/tipos/locais, dependências e proprietário único de recibos; verifica que as alterações de autoridade das partidas consistem somente nos hooks de chat. `test_installer_logic.cjs` executa o JavaScript real do HTML com DOM mínimo, conferindo cópia e operação offline. Ele não renderiza CSS.

## Layout

`export_layouts.py` instancia as interfaces reais em doubles de GuiObject e exporta suas coordenadas. `render_layouts.py` reconstrói essas coordenadas com Pillow e assets ilustrativos. A folha de revisão tem doze telas e há imagens separadas do truco. Não são screenshots nativos do Roblox. Fontes, rotação, layout automático, imagens, glifos e câmera podem diferir do motor real.

Foram conferidos computador, celular em pé e celular deitado com recortes; os testes dos novos controles também incluem tela menor e teclado. As folhas de revisão e os resultados ficam nesta pasta. Não se afirma teste em aparelho físico ou navegador com Roblox.

## Testes nativos pendentes

Conferir filtragem/permissões reais, bloqueios e denúncias com pelo menos duas contas elegíveis; duas mesas simultâneas, saída e revanche. Conferir renderização, toque/teclado, áudio, animações, malhas/collision/cages, moderação e disponibilidade de assets, materiais e FPS em aparelhos reais. Executar o fluxo completo das quatro atividades com contas distintas e autorização/revogação persistente.

Referências e instruções completas: [INSTALL_V69.md](../../INSTALL_V69.md). Direção visual: [DIRETRIZES_VISUAIS.md](../../DIRETRIZES_VISUAIS.md).
