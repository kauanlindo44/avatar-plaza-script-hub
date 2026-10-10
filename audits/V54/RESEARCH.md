# Referências da V54 — consulta em 10/10/2026

Referências primárias usadas na revisão; não constituem certificação de cumprimento de todas as políticas, leis ou regras de competição.

| Fonte | Aplicação |
|---|---|
| [Roblox — Data stores](https://create.roblox.com/docs/cloud-services/data-stores) | UpdateAsync, callback sem yield, cancelamento por retorno nil, operações protegidas e tratamento de falhas. |
| [Roblox — Player data and purchasing systems](https://create.roblox.com/docs/cloud-services/data-stores/player-data-purchasing) | Evitar gravar valores padrão após falha de leitura; revisar sessão, orçamento e salvamento de saída. |
| [Roblox — BindToClose](https://create.roblox.com/docs/reference/engine/classes/DataModel#BindToClose) | Tentar finalizar gravações pendentes ao desligar o servidor. |
| [Roblox — ScreenInsets](https://create.roblox.com/docs/reference/engine/enums/ScreenInsets) | Preservar a distinção entre tela completa, área do dispositivo e controles nativos. |
| [Roblox — UI appearance modifiers](https://create.roblox.com/docs/ui/appearance-modifiers) | Gradientes, contornos e cantos; efeitos decorativos separados do conteúdo. |
| [Roblox — UIGradient LIVE](https://devforum.roblox.com/t/uigradient-live/404831) | Anúncio técnico da Roblox: gradiente multiplica a cor e também afeta texto. Consulta do conteúdo indexado; abertura direta mostrou verificação de JavaScript. |
| [FIDE — Laws of Chess, vigente desde 01/01/2023](https://handbook.fide.com/chapter/e012023) | Artigos 3.7/9.2/9.6: promoção, repetição conforme movimentos possíveis e prioridade do mate sobre o empate de 75 lances. |
| [CBJD — Regras oficiais de damas](https://midiasstoragesec.blob.core.windows.net/001/2019/04/cbjd-regras-damas-010113.pdf) | Maioria, coroação ao fim da captura, tema turco e finais reduzidos; movimento de pedra/captura não reinicia esta contagem. |

A implementação de sessão usa **nova sessão assumindo um token**, e não todo o exemplo de bloqueio de sessão da referência Roblox. A limitação de transferência antes do flush está documentada. Nenhuma chamada cliente grava diretamente no DataStore; só a aparência confirmada pelo servidor entra na fila.

Os perfis de Truco e os aumentos legais continuam sendo os da V53. Nesta versão, a apresentação usa o estado público já sanitizado pelo servidor; não há novas regras de jogo, apostas ou caixas. As fontes e diferenças de regulamentos de Truco permanecem em [V53/RESEARCH.md](../V53/RESEARCH.md).
