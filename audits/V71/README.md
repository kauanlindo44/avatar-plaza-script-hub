# Auditoria V71 — base V69

Base de instalação: V69, commit `16e26bac39034c899869f61fc641d036e1269721`. Pai da publicação: V70, commit `1425aaae231906c222ce3d0fc2d119a9c76e74fe`. `base_manifest.json` e `published_manifest.json` distinguem esses dois papéis. Fontes da V70 não foram usadas como ponto de partida para o delta.

## Reproduzir

```bash
python3 audits/V71/run_checks.py
python3 audits/V71/build_installer.py
python3 audits/V71/test_package.py
node audits/V71/test_installer_logic.cjs
```

Python 3, `liblua5.4` e Node são necessários. `test_support.py` resolve fontes V71 e usa a V69 como fallback. As fontes de produção são executadas em Lua com doubles explícitos dos serviços Roblox. Não há motor nativo, filtragem real, compra real ou prova de renderização em aparelho físico.

Os 126 cenários anteriores e oito novos totalizam 134. Expectativas visuais foram adaptadas: conversa com largura central máxima e trilho de 56px, formulário por etapas, biblioteca inicialmente recolhida, nova playlist inicial e prévia grafite. Verificações de cancelamento, novas conversas, roupas completas, orçamento, preços, avatares, partidas, isolamento de chat e consentimento continuam.

`test_package.py` confere históricos, hashes, dependências, limite de linhas, rótulos e autoridade das partidas. `test_installer_logic.cjs` executa o JavaScript real de cópia, cache e fallback offline em um DOM mínimo; não renderiza CSS.

## Layouts

`export_layouts.py` constrói as interfaces nos doubles e exporta a geometria. `render_layouts.py` usa Pillow para inspecionar essas coordenadas. Inclui catálogo em mosaico, conversa inicial/ativa, formulário, biblioteca de música e tabuleiros. Texturas, ícones de produtos e avatares ilustrativos podem diferir do motor Roblox. O exportador converte corretamente a origem CoreUISafeInsets para a tela inteira.

As referências foram os 18 anexos do pedido; seus arquivos originais não foram incorporados aos scripts. Detalhes das referências e limitações: [INSTALL_V71.md](../../INSTALL_V71.md).
