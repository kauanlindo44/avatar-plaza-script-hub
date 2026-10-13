# Auditoria V62

Base publicada: `dd885215d58637d426142d912560214c0d07cfe0` (V61). Delta: **28 instâncias, três novas + 25 substituições**. Manifesto/hashes históricos preservados; publicação usa árvore Git remota e confere os demais blobs.

**20 cenários simulados**, Lua 5.4/doubles: 11 de regras/serviços e nove de UI/controladores. Áudio assíncrono/cache/paginação/falha/canal manual; patrocínio pago/free rejeitado/categorias/migração de publicação grátis; tabuleiro denso e turnos reais de xadrez/damas/lance antigo/desistência; sala/revanche sem avatar movido; IA antiga identificada antes de quota; planejador sem HTTP; loja de fundos/versionamento. Interface verifica rolagem vertical/pagos/substituição de exemplos, arrays nativos somente leitura, prioridade paga/continuação grátis, cenários/céus/partes limitadas/restauração, nove movimentos/pausa/reset, catálogo de fundos/emotes sem inventário, MusicClient real, estilo/área segura da IA e GameClient desenhando todas as 32 peças após um lance.

`v62_doubles.lua` acrescenta o contrato de listas somente leitura, ausente das auditorias antigas. Serviços/motores nativos e renderização/FPS não são executados; resposta simulada não prova autorização de áudio/imagem nem perfeição estética.

```sh
python audits/V62/test_features.py
python audits/V62/test_interface.py
python audits/V62/build_installer.py
python audits/V62/test_package.py
node audits/V62/test_installer_logic.cjs
```

O pacote compila 112 fontes efetivas, resolve dependências, confirma tipos/locais, máximo de 400 linhas, único ProcessReceipt e hashes anteriores. O JavaScript real do instalador testa offline/cache/hashes/fontes recolhidas/clipboard/online/cancelamento, sem CSS renderizado. O [guia V62](../../INSTALL_V62.md) traz diagnóstico das fotos e teste nativo. Requer V61 completa; IA é pesquisa, patrocínio aceita itens pagos com envio grátis, xadrez/damas são locais sem transferência.
