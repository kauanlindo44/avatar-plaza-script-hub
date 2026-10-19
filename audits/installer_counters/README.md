# Contadores do instalador

Atualização somente do HTML da V71 e do instalador permanente. Cada nome tem sua posição e o total de scripts da mesma ação, dentro da versão aberta: `1/1 (NOVO)` e `1/31 (SUBSTITUIR)` na V71. A sequência reinicia ao trocar ou reabrir uma versão. Partes de cópia não contam como scripts adicionais.

O manifesto, os códigos Lua, as versões e as instruções de instalação permanecem iguais. Cabeçalhos usam quebra de linha flexível para acomodar nomes longos e manter o contador legível.

Ao regenerar o pacote usando um construtor histórico, execute depois `python3 audits/installer_counters/update_installer.py`. A atualização é idempotente e verifica que metadados e fontes embutidas não mudaram.

Verificações: `node audits/installer_counters/test_counters.cjs` e `node audits/V71/test_installer_logic.cjs`. Executam o JavaScript real com objetos de DOM simulados. Não constituem teste de renderização em navegador ou Roblox.
