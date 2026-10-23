# Auditoria V75

Base: V74 publicada, commit `d1518e49cfb6962a7ed854d659cbe0fe3816cf2f`. Delta: **2 novos + 35 substituições**, cada fonte com até **197 linhas**; teto do projeto: 400. O manifesto resolve **173 fontes efetivas** após a atualização.

## Resultado

- **178 cenários de comportamento passaram em 12 suítes.** As fontes reais são executadas em Lua 5.4 compatível com este código, usando contratos simulados de serviços Roblox.
- **Restrição real do processo de testes:** seccomp bloqueia criação de sockets e execução de comandos; a verificação tentou ambas as operações e recebeu `EPERM`. Lua não tem acesso ao ambiente do host, comandos de shell ou arquivos arbitrários. Memória limitada a 1 GiB e CPU a 60 segundos por processo. Isso não é uma instância do motor Roblox.
- **173 fontes efetivas compiladas**, hashes declarados conferidos, tipos/locais do delta e dependências verificados. Os 966 caminhos históricos tiveram seus bytes preservados. A V37 já tinha 11 hashes declarados divergentes e fora das fontes atuais; uma fonte antiga efetiva não tinha hash declarado. O inventário registra esses fatos, sem reescrever a história.
- **JavaScript real do instalador executado com DOM simulado:** cópia exata das 37 fontes, fallback manual, reconstrução das partes, hashes, versão offline/online e contadores independentes. A suíte de contadores conferiu 793 cards de versões e casos sintéticos.
- **42 reconstruções de layout** em computador, celular em pé e celular deitado, com mídia ilustrativa. Testes geométricos cobrem sete tamanhos, incluindo 320×568 e recortes laterais. As reconstruções não são screenshots Roblox.
- **Navegador Chromium: não executado.** O pacote JavaScript estava disponível, mas o executável não estava instalado. O relatório `installer_browser_results.json` registra a limitação; os testes de DOM não são apresentados como validação de CSS no navegador.

## Cobertura da mudança

| Área | Evidência |
|---|---|
| HUD | Onze ações não se sobrepõem e preservam o corredor central em sete geometrias; todas têm alvos de pelo menos 44 px |
| Comandos | Menu Avatar e resposta do comando de ajuda abrem a mesma janela; lista e fechamento continuam utilizáveis |
| IA sem módulo de planos | A ausência exata de `09I25_PLAN_PRODUCTS` não bloqueia construção do perfil/conversa; só a consulta/compra fica indisponível |
| Ciclo da assistente | Pedidos, cancelamento, novos chats e restauração de formulários mantêm os testes anteriores |
| Busca | Negação de cor, palavras completas, tipos exatos, orçamento, corpo, verificação de preço e modelo, repetições e lotes |
| Looks | Casos de 1 a 50 resultados, cards de 148×192, até cinco por coluna, descarte e montagem de prévias |
| Photo Mode | Cinco colunas, quatro linhas no recorte 851×392, paginação de 30 resultados, compra separada e margens estáveis |
| Avatar | Salvamento e restauração conservam confirmação, histórico e resultado oficial; telas auxiliares coloridas |
| Cenários | Oito mundos mantidos, Vale inicial, orçamento reduzido e restauração de ambiente |
| Truco | Ações/decisões legais, tempo de resposta, carta própria, vaza, privacidade anterior e geometria; placar em linha única |
| Xadrez/Damas | Tabuleiro, ações e relógios; fonte dos motores, bots e sessões permanece idêntica à base |
| Arena aberta | Apenas piso verde e duas peças do botão; nenhuma parede; ausência de teleporte de correção nas bordas; queda elimina |
| Empurrão | Alvo e força forjados ignorados; membro externo, spam, distância, orientação, obstáculo, ator congelado e escudo |
| Bomba | Atraso de quatro segundos, posição no chão e uma única vítima; escudo/cancelamento anteriores preservados |
| Áudio | Limite local, identificação de evento, não interromper a explosão na transição de resultado e limpeza na saída |
| Música | O LocalScript real reduz 0,4 para 0,128, respeita alteração para 0,6 durante a partida e restaura 0,6 ao sair |
| Integração | Fila/tempos/FIFO/treino, inventário, saída, câmera, espectador, exclusão entre jogos e recibo continuam cobertos |

## Reproduzir

Execute na raiz do repositório, em Linux com Python, `liblua5.4`, Node e Pillow:

```bash
python3 audits/V75/test_sandbox.py
python3 audits/V75/run_checks.py
python3 audits/V75/build_installer.py
python3 audits/V75/test_package.py
node audits/V75/test_installer_logic.cjs
node audits/V75/test_counters.cjs
python3 audits/V75/export_layouts.py
python3 audits/V75/render_layouts.py
```

O teste opcional `node audits/V75/test_installer_browser.cjs` requer Playwright e um Chromium instalado. Se o binário estiver ausente, registra `not_run`.

Resultados: `suite_results.json`, `sandbox_results.json`, `syntax_results.json`, `package_results.json`, `installer_logic_results.json`, `counter_results.json` e `installer_browser_results.json`. `history_inventory.json` ancora a integridade dos bytes anteriores. Fontes e avaliação do acesso aos vídeos: [RESEARCH.md](RESEARCH.md). Inventário das 44 versões: [HISTORY.md](HISTORY.md).

## Pendente no Roblox

Não houve execução no Studio Lite, servidor multiplayer publicado ou aparelho físico. Ainda precisam de teste: duas rodadas com 2–8 pessoas, impulso sob latência, streaming, R6/R15/corpos personalizados, áudio e permissões de assets, controles de toque, captura, FPS e memória no Motorola Moto 5G. A implementação não é uma certificação de ausência de bugs ou de segurança absoluta. O assistente continua sendo o planejador nativo do catálogo, sem um novo modelo externo.

O acesso ao player do YouTube falhou mesmo após novas buscas e tentativa dos feeds. Há quinze referências identificadas no relatório, algumas somente pelos índices de canal/playlist; elas não foram assistidas integralmente. As decisões de implementação se apoiam nas fotos fornecidas, na documentação acessível e no código do projeto.
