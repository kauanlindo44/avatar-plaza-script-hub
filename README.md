# Avatar Plaza — V44

Atualização da V43 para Roblox Studio Lite: Truco, catálogo, Photo Mode, configurações, comunidade e inventário de baralhos. A implementação continua os scripts originais do handoff; este repositório não é um place vazio pronto para publicar.

Abra [AVATAR_PLAZA_SCRIPT_HUB_PERMANENTE.html](AVATAR_PLAZA_SCRIPT_HUB_PERMANENTE.html) e selecione **V44**. O instalador funciona com as fontes embutidas e consulta as versões publicadas no GitHub. As fontes e suas partes têm SHA-256 verificado.

São **55 scripts: 22 criações e 33 substituições**, até 393 linhas cada. `09A_SHOP_UI` tem exatamente quatro partes no mesmo ModuleScript. Os locais e dependências estão em [INSTALL_V44.md](INSTALL_V44.md).

## O que mudou

- Truco Paulista, Mineiro e Goiano substituem Batata Envenenada. Quatro jogadores, duplas opostas, mão privada, mesa pública, treino em três dificuldades e salas entre servidores.
- Torneios semanais gratuitos de xadrez, damas e Truco. Convites, aceite, check-in, reservas e prêmio somente em título. Nenhuma aposta.
- Inventário com nove visuais originais, caixas de escolha garantida e Ateliê com imagem, zoom e ajuste por arraste, inclusive no celular. Cosméticos não mudam as cartas ou o resultado.
- Catálogo com cinco colunas e duas linhas completas em telas horizontais. Ações de detalhe fixas, carrinho de itens escolhidos/outfit e restauração confirmada.
- Prévias maiores, fundo adaptado ao avatar, giro 360° e preservação da skin ao aplicar uma peça. Photo Mode com pose direta R6/R15, desfazer/refazer e controles de ambiente sem rolagem.
- Configurações coloridas, cinco mundos locais e comandos pessoais limitados. Inspeção de jogadores, curtidas e uso de look bloqueado por padrão até o dono permitir.
- Comunidade com até cinco composições por referência conhecida, consulta ao catálogo Roblox, categorias internas de orçamento e 50 cards reciclados.

## Passes e preços

Os preços de teste informados pelo criador são **2 Robux**. A interface consulta o preço atual da Roblox; scripts não alteram o painel de preços.

| ID de Game Pass | Benefício permanente | Sugestão após os testes |
|---|---|---:|
| 1951234105 | Ateliê: imagem no baralho, zoom e ajuste | 249 Robux |
| 1962433436 | Regent | 35 Robux |
| 1966813498 | Zenith | 65 Robux |

| Coleção | Conteúdo conhecido | Moedas por escolha ou visual direto | Sugestão por escolha ou visual direto |
|---|---|---:|---:|
| Nox | Onyx, Vesper, Hex | 500 | 15 Robux |
| Reign | Regent, Aurum, Valor | 1.200 | 35 Robux |
| Eclipse | Zenith, Aether, Nova | 2.500 | 65 Robux |

Caixas e outros visuais vendidos por Robux precisam de **Developer Product IDs**, ainda não fornecidos. Estão em `07K6_CARD_CATALOG.Products`, todos com zero, e a compra correspondente fica desativada. Compras por moedas e os três passes já têm seus caminhos implementados. Moedas são ganhas em partidas PvP validadas; não existe venda de moedas.

## Decisão sobre ECA Digital

Caixas aleatórias estão desativadas para todas as contas. O jogador escolhe um visual permanente conhecido, sem sorteio. `PolicyService` e `AccountAge` não são tratados como prova de maioridade. Não se coletam documento, data de nascimento ou declaração de idade no jogo.

A análise técnica usa a Lei 15.211/2025 e o Decreto 12.880/2026, além de três documentos distintos de monetização da Roblox. Fontes, regras regionais e limites estão em [audits/V44/LEGAL_AND_RULES.md](audits/V44/LEGAL_AND_RULES.md). Essa decisão não é uma certificação de conformidade integral.

## Validação e limites

**42 casos passaram**: 41 de lógica/sintaxe em Lua 5.4 com serviços simulados e um do JavaScript real do instalador. Incluem 72 partidas completas de bots, geometria em diversas telas, preservação do avatar, recibos, privacidade e recuperação de salas/torneios.

Ainda é necessário testar no Roblox/Studio Lite a renderização 3D, o toque real, compras, assinatura, serviços publicados e viagem entre servidores. A comunidade tem capacidade paginada de um milhão de registros, não uma coleção pronta desse tamanho. Identificação de personagens usa nomes de roupas e referências verificadas, com seis personagens iniciais; não há reconhecimento visual universal.

Resultados, comandos de teste e roteiro de QA: [audits/V44/README.md](audits/V44/README.md).
