# V50 — entrega reduzida

Base GitHub: V49, commit `43a2e678427e3d5e03540ba3589b106a4437f6b9`.

Esta versão reorganiza a instalação solicitada: somente **8 substituições e 3 NOVOS** para uma V48 completa. As 11 fontes em `scripts/V50` são idênticas, byte a byte, às fontes correspondentes da V49. O histórico do manifesto permanece disponível; nenhum script das versões anteriores é removido do repositório.

Os três novos são `08B1_BODY_PACKAGES`, `09B5_AVATAR_RUNTIME` e `09C11_AVATAR_CHARACTER`. As oito substituições são `08B_AVATAR_DATA`, `08D_SKIN_STATE`, `09A_SHOP_UI`, `09A1_SHOP_LAYOUT`, `09B_SHOP_SERVER`, `09C_SHOP_CLIENT`, `09C2_SHOP_CATALOG` e `09C4_OUTFIT_LIBRARY`.

O instalador conserva os tipos/locais, rótulos (NOVO)/(SUBSTITUIR), SHA-256 e a cópia em partes. 09A_SHOP_UI continua com quatro partes no mesmo ModuleScript; os demais têm duas. O HTML inclui V50 e a base V44 sem conexão. A aba V50 contém apenas os 11 itens.

Correção do indicador: sincronização online aplica a classe CSS verde `online`; modo local/cache aplica `offline`. Antes, o texto mudava sem atualizar a classe, mantendo a cor cinza. `AVATAR_PLAZA_V50.html` é uma cópia do instalador atual com nome explícito. A lógica dos 11 scripts Roblox não mudou.

Cartões compactos: nome e ação, tipo, local no Studio, última linha e botão de copiar. O código inteiro fica oculto. Os demais scripts oferecem a divisão em partes numa seção recolhida; 09A_SHOP_UI mostra seus quatro botões com a última linha de cada parte. Somente se as duas tentativas de cópia automática falharem, o código correspondente é aberto e selecionado para permitir cópia manual.

Reproduzir o pacote:

```bash
python audits/V50/build_installer.py
node audits/V50/test_installer_logic.cjs
```

O caso do JavaScript real verifica carregamento offline da V50, rejeição de cache antigo, exatamente 11 seções, 8 substituições/3 criações, hashes, fontes iguais à V49, reconstrução das partes, cópia/seleção, rótulos, fechamento e fallback de fonte adulterada. O DOM é simulado e não valida CSS. Os resultados estão em `installer_logic_results.json`.

A lógica e a validação do jogo permanecem as da [V49](../V49/README.md). Não foi realizado teste no Roblox real nem qualquer compra; esta entrega não executa alterações na experiência publicada.
