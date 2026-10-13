# Auditoria V61

Base publicada: `d55939d9b0885a4b60ec5fe2c336676d28a42842` (V60). Delta: **45 instâncias, 37 substituições + oito módulos novos**. O manifesto base fica íntegro; metadados históricos/hashes das 101 fontes efetivas anteriores são comparados. Publicação parte da árvore Git remota preservando demais blobs.

**31 cenários simulados** em Lua 5.4/doubles determinísticos, executando módulos e controladores reais do projeto. Não usam motor Roblox, compras nem serviços online.

`test_features.py`: 19 casos de patrocínio/prazo/deduplicação/favoritos/recuperação/compra/páginas, áudio/cache, união persistente de 200 + 500 contas, arquivo/código/falha/checkpoint e fila além dos primeiros 50 contribuidores, fundos sem posse, planejador limitado e preço/aparência, comandos pessoais/bloqueio, ShopRPC/publicações, IA gratuita/quota, consentimento de revanche e chão físico móvel.

`test_interface.py`: 12 casos de HUD/configurações, música lista + ID, múltiplas linhas de patrocínio/exemplos, pesquisa inicial, comunidade Todos/Grátis, filtros, cenas distintas/25 partes, avatar centralizado/fundo inválido, resumo/revisão, MusicClient com autoplay 40%/fila/avanço, GameClient mantendo tabuleiro após roomClosed e catálogo lateral de emotes/compra. Geometria em seis resoluções/áreas seguras; sem renderização visual nativa.

`v61_doubles.lua` simula os contratos de áudio/paginação/índice/chat/eventos/sons e falhas. Importa doubles históricos V43/V48–V60. Não comprova disponibilidade real, renderização de AvatarBackground ou perfeição estética dos looks.

Reprodução:

```sh
python audits/V61/test_features.py
python audits/V61/test_interface.py
python audits/V61/build_installer.py
python audits/V61/test_package.py
node audits/V61/test_installer_logic.cjs
```

Pacote compila 109 fontes efetivas e verifica dependências, nomes/tipos/locais, 400 linhas e único ProcessReceipt; mantém IDs antigos para reconhecer recibos. JavaScript testa runtime real do instalador: offline/cache antigo/hashes, fontes recolhidas, clipboard inteiro/partes/bloqueado, online/offline e cancelamento, sem renderização CSS.

[Guia V61](../../INSTALL_V61.md) contém requisitos/limites e testes nativos. IA é pesquisa, não chatbot geral; contas registradas não significam snapshots instantaneamente verificados; 16+ depende do Creator Dashboard. Nenhum produto/passe novo ou cobrança para patrocinar.
