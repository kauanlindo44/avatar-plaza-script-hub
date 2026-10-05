# V51 — corpos nativos e tela do celular

Base confirmada no GitHub: `3a46d5547042db04a47268d29900bbc13bb073a8` (V50 compacta). Entrega delta: **11 substituições e 1 novo ModuleScript**, `08B2_BODY_DESCRIPTION` em ReplicatedStorage. `scripts/V51` contém somente estes 12 arquivos; os demais são reutilizados das versões anteriores. O manifesto mantém o histórico. [INSTALL_V51.md](../../INSTALL_V51.md) contém os tipos, locais e ordem de instalação.

A entrega corrige a origem dos Rects da tela, ocupa o topo desocupado quando cabe, remove a margem inferior falsa e amplia a prévia. Botões da prévia ficam fora do avatar; cards usam imagem com preço embaixo, em cinco colunas e duas linhas nas telas deitadas com espaço suficiente. X, popups, gesto inferior e notch ficam nos limites calculados. Abrir janela respeita movimento reduzido. Miniaturas/X dos itens equipados permanecem abaixo da prévia.

O novo módulo preserva metadados de BodyPartDescription e expressão estática. Pacote usa o outfit nativo antes dos extras; metadados de cartão/extra offline não bloqueiam um corpo resolvido. Roupas anteriores são preservadas, incluindo emotes nomeados no servidor. Criação nativa tem uma nova tentativa e AssetTypeVerification.Always. Modelos com peças divergentes não são confirmados como carregados; o cliente exibe Tentar novamente. Fonte de falhas de criação vai ao Output; não se afirma moderação sem evidência. Confirmações sem mudança visual não cancelam nem recriam a prévia pendente/pronta; o catálogo fechado não inicia novos pedidos de prévia.

## Testes

**106 verificações Lua 5.4 com doubles + 1 verificação do JavaScript real do instalador.** `validation_summary.json` e arquivos `*_results.json` contêm os resultados. O teste de sintaxe inclui as 62 fontes efetivas (reutilizadas + delta), não somente as doze entregues.

- 15 casos novos de metadados nativos, pacote completo, perda/retirada de peça, schema antigo, alterações recentes no avatar, novo head shape com mesmo ID, respawn, erro/transiente/IDs incorretos, retry pelo controlador real e confirmação sem pedido duplicado durante/depois da criação.
- Geometria com a origem documentada -59/-58, mudança de orientação, topo que deixa de ter largura suficiente, notch e barra inferior; 44px para controles, 48px para X de popup, miniaturas separadas e dez cards completamente visíveis.
- Enquadramento dos oito cantos do corpo em 24 ângulos e quatro aspectos de viewport, incluindo formas de meme largas.
- Regressões existentes: roupa preservada, privacidade, carrinho, comunidade, Photo Mode/pose, jogos/Truco, imagens, inventário, recibos e torneios.
- Instalador: V51 offline, cache antigo recusado, hashes, uma criação/onze substituições, nomes reais sem rótulos, cópia exata, quatro partes de 09A, código oculto e fallback manual, indicador ONLINE verde, fonte adulterada recusada e cancelamento de carregamento.

Reproduzir:

```bash
python audits/V51/build_installer.py
python audits/V51/test_v49.py
python audits/V51/test_bodies.py
python audits/V51/test_native_mobile.py
python audits/V51/test_changes.py
python audits/V51/test_features.py
python audits/V51/test_fixes.py
python audits/V51/test_games_commerce.py
python audits/V51/test_integration.py
python audits/V51/test_redesign.py
python audits/V51/test_server_flows.py
node audits/V51/test_installer_logic.cjs
```

As asserções antigas sobre a origem física da tela e a prévia obrigatoriamente quadrada foram adaptadas às coordenadas nativas e ao layout aprovado. A exigência de manter emotes nomeados detectou um defeito na primeira implementação e foi mantida após a correção.

`preview_layouts.py` gera esquemas de geometria para revisão local, com fontes genéricas e sem malhas/miniaturas reais; não são screenshots do Roblox nem prova de nitidez. A inspeção mostrou os dez cards, preços abaixo e ausência de rolagem para os controles principais. O instalador foi verificado com DOM mínimo; não houve renderização real de seu CSS neste ambiente.

## Limites

Não há Roblox/Studio acessível neste ambiente. Não foram carregados os assets reais do Funky Ehh Kid Meme (Gumball), gato abacaxi ou corpos realistas; o ID exato do Gumball não foi confirmado. Toque físico, latência e meshes devem ser verificados na experiência. Nenhuma compra foi feita nem o place foi publicado. A V51 atualiza as fontes/HTML no GitHub e não modifica preços, produtos, jogos ou políticas de comércio. Referências oficiais: [RESEARCH.md](RESEARCH.md).
