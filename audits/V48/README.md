# Auditoria V48

## Base e escopo

Base confirmada no GitHub: `main` em `308f6706902576cb7a6e2f929cdc265f04866654` (V47), árvore `a23c34818f82bf4b23ed3d66c766f4933d1d3743`. Antes de editar, os 60 blobs locais relevantes foram comparados pelo SHA Git: 56 fontes V47, manifest, HTML, README e INSTALL_V47. O handoff inteiro e o histórico visível foram lidos. Fontes V47 não foram alteradas.

V48 contém 57 fontes no snapshot. São **19 alterações desde V47**, **36 substituições cumulativas desde V44** e **zero novas instâncias**. O ModuleScript original `09C5_UGC_STORES` entrou no snapshot para ser substituído; já existia na instalação original. IDs, preços do painel e contratos VERSION V41/V44 não foram modificados. `09A_SHOP_UI` continua com exatamente quatro partes no mesmo ModuleScript; demais fontes têm duas partes e todas ficam abaixo de 400 linhas.

## Correções e evidências

- **Jogos:** painel preto/verde ocupa a altura restante, mantendo Xadrez, Damas e Truco no topo. Partida rápida, sala/código e bots aparecem conforme o modo escolhido. Em telas largas há uma ilustração lateral; em telas menores a área serve aos controles. Busy/Waiting impedem troca de categoria durante operações. Regras e callbacks do servidor permanecem compatíveis.
- **Truco 2D:** mesa opaca com quatro posições públicas e três cartas privadas em proporção 0,70. Retrato coloca mesa acima da mão; paisagem usa mesa à esquerda. Placar, ação de jogar qualquer carta própria, Truco, Correr, cobrir e gritos ficam separados. Cliente não cria mãos 3D, não altera a câmera e restaura controles de toque ao sair. Informações de mãos adversárias continuam exclusivas ao servidor. Bots, variantes, conferência casual e torneios usam o fluxo anterior.
- **Cartas:** nove edições ganharam geometria gráfica própria na frente e verso: facetas, órbitas, circuitos, coroas, art déco, escudo, estrelas, penas e sol. Índices de rank e naipe mantêm contraste; carta coberta não renderiza identidade. Caixa tem embalagem diferente de carta. Escolhas e resultado da caixa também mantêm proporção, inclusive um único resultado.
- **Compra da coleção:** todos os três visuais aparecem antes de pagar, com `100% ao escolher`. Não existe resultado aleatório. Compra nova seleciona um visual e aguarda crédito no inventário pelo servidor antes de consumir a caixa e mostrar o resultado imediato. `PromptProductPurchaseFinished` apenas trata cancelamento do próprio jogador; sucesso do prompt não concede itens. `ProcessReceipt` continua sendo a origem de concessão Robux. Duplicatas de atualizações não abrem duas caixas. Caixa recebida com a tela fechada permanece recuperável no inventário. Caixas já existentes podem ser abertas com escolhas conhecidas.
- **Ateliê:** estados Loading/Ready/Error geram texto neutro, sucesso verde ou falha vermelha. Type/ID inválido e timeout de metadados são identificados. Falha de imagem após tentativas diretas/thumbnail diz que permissão, moderação e conexão são possibilidades, pois o Roblox não fornece causa conclusiva nessa resposta. Salvar continua exigindo metadados correspondentes e imagem efetivamente carregada. Respostas antigas e fechamento não podem mostrar falso sucesso. Servidor resolve textura canônica de Decal sem inserir modelos ou mudar permissões.
- **Corpos e memes:** subcategoria fica destacada; Corpo prioriza preço mínimo 1, com uma opção explícita para gratuitos. MEMES / CRIATURAS pesquisa pacotes nativos. Um pacote BodyParts/DynamicHeadAvatar com UserOutfit carrega proporções e cores via `GetHumanoidDescriptionFromOutfitIdAsync`, mantendo roupas e acessórios existentes. Falha dessa consulta adicional conserva a aplicação das peças disponíveis. Bounds de prévia enquadram geometria muito larga e quatro ângulos; Apply do servidor recebe proporções e mantém partes não editadas.
- **Limiteds:** `09C5_UGC_STORES` agora usa `SalesTypeFilter.Collectibles` e confirma em cada item restrições Limited/Collectible, sinalizadores ou CollectibleItemId válido. Itens comuns são excluídos. Cards horizontais dourados, busca, Popular / Menor preço e paginação diferenciam essa vitrine do catálogo geral. Não se promete resultado quando o serviço não retorna Limiteds.
- **Comunidade:** descrição nativa tenta novamente uma vez apenas em erros transitórios, mantendo limite de quatro consultas simultâneas e cotas existentes. Cliente repete uma página com falha temporária e preserva looks carregados. Até três colunas e duas linhas maiores; pool de 50 slots, janela de 100, sobras reaproveitadas, remoção em grupos de dez e assinaturas limitadas continuam. Itens de um look mostram imagem/nome e X separado; preço/criador/descrição abrem em um pequeno painel seguro ao toque, com Experimentar/Carrinho. Metadados que chegam depois atualizam o item aberto. Não há autoria inventada nem inferência automática universal de cosplay.
- **Photo Mode:** painéis contextuais têm destaque teal/verde e seleção lateral clara. Não há bloco permanente inferior com nome do fundo; notificações são texto temporário no alto. Cinco cenários originais receberam bancos, arco-íris, ondas/pedras, torii e neon/reflexos, respectivamente. Têm 72–159 partes e no máximo 20 elementos móveis, atualizados a 20 Hz. Geometria fica atrás do avatar nos quatro ângulos, exceto o piso abaixo dele. Pausa/saída desconectam animações. Emotes R15 reais e editor de pose continuam no avatar do cenário local.

## Verificação executada

| Suíte | Casos |
|---|---:|
| test_v48.py | 13 |
| test_integration.py | 15 |
| test_changes.py | 6 |
| test_features.py | 7 |
| test_games_commerce.py | 9 |
| test_server_flows.py | 5 |
| test_fixes.py | 12 |
| test_redesign.py | 9 |
| JavaScript real do instalador | 1 |
| **Total** | **77** |

As oito suítes de fontes executam Lua 5.4 com doubles de serviços, UI, geometria e agendamento. Incluem 72 partidas completas, 400 combinações carta/visual, turno/revisão, privacidade, recibos, cancelamento, duplicatas, imagem, native body outfit simulado, HTTP 429/503, 50/100 looks, navegação e geometria em vários tamanhos. Não executam renderização, rede Roblox, física nativa, moderação ou pagamento. O JavaScript extraído do HTML é executado de verdade, com DOM mínimo: fallback V44/V48, hashes, reconstrução exata de partes, 36 SUBSTITUIR/0 CRIAR, quatro partes 09A, cache antigo, corrupção e fechamento durante carga. Não testa CSS.

```sh
python audits/V48/test_v48.py
python audits/V48/test_integration.py
python audits/V48/test_changes.py
python audits/V48/test_features.py
python audits/V48/test_games_commerce.py
python audits/V48/test_server_flows.py
python audits/V48/test_fixes.py
python audits/V48/test_redesign.py
node audits/V48/test_installer_logic.cjs
```

Dependências dos doubles V43 e fixtures de regressão V42/V43 continuam no repositório. `build_installer.py` é reexecutável e gera manifest, HTML e INSTALL_V48 com hashes atualizados. Resultados detalhados estão nos JSON das suítes e em `validation_summary.json`.

## Pesquisa e limites

Fontes primárias, consulta legal de 04/10/2026 e limites da pesquisa visual estão em [RESEARCH.md](RESEARCH.md). Buscas e imagens públicas do Catalog Avatar Creator não forneceram cinco fotografias verificáveis de cada um de cinco fundos. Não foi declarada uma comparação de 25 fotos nem uma reprodução exata. Frames públicos do editor de pose sustentam somente esse fluxo, não a aparência dos cinco ambientes. Nenhum código ou asset do CAC foi incorporado.

Ainda é necessário testar no Roblox/Studio Lite/place publicado: renderização, toque físico, emotes reais, carregamento de assets aprovados, latência e compras. Não foram feitas compras nem publicada uma versão do place. A comunidade consulta perfis reais sob demanda; não é um acervo pronto de um milhão de skins. Segurança de dados e escolhas conhecidas não certificam conformidade integral do jogo.
