# Auditoria V68

Base remota verificada: `1d79070d8dd4f120ac0a92c96398d4e8d6a3c409` (V67). Delta explícito: **37 fontes = 5 criações + 32 substituições**. Metadados e fontes históricas preservados. [Guia](../../INSTALL_V68.md).

## Reproduzir

```sh
python audits/V68/test_fixes.py
python audits/V68/test_interface.py
python audits/V68/test_regressions.py
python audits/V68/test_delta.py
python audits/V68/test_features.py
python audits/V68/test_v67.py
python audits/V68/test_v68.py
python audits/V68/build_installer.py
python audits/V68/test_package.py
node audits/V68/test_installer_logic.cjs
```

Doubles cumulativos V43–V68, Lua 5.4. **106 cenários simulados**: os 84 anteriores adaptados às mudanças intencionais de layout/contrato e 22 adicionais da V68. Os novos cobrem prioridade do texto/edição confirmada; reset do formulário; recolhimento real do menu; teclado; segunda página; alternativas em camadas; cor/exclusões; reserva de roupas; atualização de preço; recusa nativa; novidade entre pedidos/perfil recarregado e escrita agrupada; cinco orçamentos independentes; limites/serialização/confirmação de ajustes rígidos; assinatura neutra compatível; categoria inicial e integração no LocalScript real; desfazer/comparar/altura opcional; cenário/câmera fixos; enquadramento do estúdio; pausa/velocidade de emote; ações e tempo de resposta do Truco; favoritos preservados e geometria das ferramentas em sete tamanhos.

O double V68 modela os filhos AccessoryDescription, posição/rotação/escala, clonagem e limites nativos por tipo. Os testes anteriores de locomoção agora explicitam a prioridade nativa de Movement para o clip do Animate. Fixtures de buscas por cor retornam nomes compatíveis com o pedido; uma fixture adversária separada prova que uma roupa rosa barata não é aceita para preto.

Também são compiladas as **136 fontes efetivas**, verificadas dependências/tipos/locais, hashes, ausência de mudanças históricas, IDs comerciais e o único proprietário de ProcessReceipt. O JavaScript real do HTML é executado em Node com DOM mínimo, testando cópia completa, reconstrução em partes, hashes, labels NOVO/SUBSTITUIR, offline/online e clipboard bloqueado.

## Limites

Sem Roblox Studio/Player, GPU, solver físico, deformação/cages, FPS ou permissões de assets reais. Geometria numérica não é captura renderizada do jogo. A pesquisa visual registrada tem 20 referências de cada jogo, incluindo quadros oficiais de vídeo; não afirma cobrir todos os mapas/botões atuais. Os cenários e a interface usam código próprio. O motor da IA continua sendo um montador/guia do jogo; cor/estilo usam metadados e busca, sem classificador visual ou conversação generativa geral.

O teste de altura 1,1 não é imposto a todos os avatares. A confirmação de um ajuste perdido falha em vez de anunciar sucesso. Recusa de fundo/áudio permanece uma possibilidade real; o fallback e a preservação anterior são verificados. Avisos de CorePackages/UIBlox não são atribuídos ao usuário nem declarados corrigidos por scripts do jogo.
