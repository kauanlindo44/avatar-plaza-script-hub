# Instalação V76 — 2 novos + 12 substituições

Base: V75 completa. V76: 2 NOVOS + 12 SUBSTITUIÇÕES. Pare Play. Crie primeiro 07G10_HUD_LAYOUT (ModuleScript em ReplicatedStorage) e 09I26_REQUEST_GUARD (ModuleScript em ServerScriptService). Depois substitua as 12 fontes existentes por inteiro, nos nomes/tipos/locais indicados. Não acrescente V76, números ou contadores aos nomes. Use Copiar script inteiro. As duas partes são alternativa para a mesma instância. Reinicie Play após instalar os dois grupos. Guia: INSTALL_V76.md.

## Criar os 2 módulos novos

| Número | Nome exato | Tipo | Local | Linhas |
|---:|---|---|---|---:|
| 1/2 | `07G10_HUD_LAYOUT` | ModuleScript | ReplicatedStorage | 54 |
| 2/2 | `09I26_REQUEST_GUARD` | ModuleScript | ServerScriptService | 54 |

## Substituir as 12 fontes existentes

| Número | Nome exato | Tipo | Local | Linhas |
|---:|---|---|---|---:|
| 1/12 | `07K15_TRUCO_TABLE` | ModuleScript | ReplicatedStorage | 118 |
| 2/12 | `07P4_STUDIO_UI` | ModuleScript | ReplicatedStorage | 125 |
| 3/12 | `07P9_STUDIO_CATALOG` | ModuleScript | ReplicatedStorage | 95 |
| 4/12 | `09C4_OUTFIT_LIBRARY` | ModuleScript | ReplicatedStorage | 210 |
| 5/12 | `09I0_ASSISTANT_CONFIG` | ModuleScript | ReplicatedStorage | 13 |
| 6/12 | `09I1_ASSISTANT_ACCOUNTS` | ModuleScript | ServerScriptService | 142 |
| 7/12 | `09I25_PLAN_PRODUCTS` | ModuleScript | ReplicatedStorage | 69 |
| 8/12 | `09B_SHOP_SERVER` | Script | ServerScriptService | 269 |
| 9/12 | `09I_ASSISTANT_SERVER` | Script | ServerScriptService | 160 |
| 10/12 | `07G_HUB_UI` | LocalScript | StarterPlayer > StarterPlayerScripts | 121 |
| 11/12 | `07P_PHOTO_MODE` | LocalScript | StarterPlayer > StarterPlayerScripts | 182 |
| 12/12 | `09C_SHOP_CLIENT` | LocalScript | StarterPlayer > StarterPlayerScripts | 397 |

## Conferir no Studio Lite

Os dois módulos novos ficam em locais diferentes. `09I26_REQUEST_GUARD` pertence ao servidor; `07G10_HUD_LAYOUT` pertence ao ReplicatedStorage. Instale tudo com Play parado. A substituição é da fonte inteira, sem manter o código antigo no final. Mantenha `08L_COMMUNITY` no ServerScriptService: é uma dependência legada da base, já documentada antes da V43, cuja fonte não está no manifesto do repositório. A V76 preserva os códigos e dados antigos sem recriar esse módulo.

`09C_SHOP_CLIENT` tem 397 linhas e continua abaixo do teto de 400. Se usar as partes do instalador, cole a parte 2 imediatamente depois da parte 1 na mesma instância, na ordem indicada.

O botão + abre IA de looks, corpo, carregamento, looks, carrinho, música e demais utilidades. Em celular deitado com pouca altura, os atalhos secundários ficam nesse menu para liberar os controles nativos. Catálogo e Patrocinar permanecem no alto. A IA não mudou de produto ou de provedor.

Fundos usam 3 colunas e no máximo 3 linhas (9 por página). Emotes usam 5 colunas e no máximo 4 linhas. Telas muito baixas exibem menos linhas; os botões de página dão acesso aos outros itens. A seleção só experimenta; comprar exige o botão separado e o prompt oficial.

## Produtos conferidos

| Plano exibido | Chave interna preservada | Developer Product |
|---|---|---:|
| IA Plus | `Studio` | 3717699383 |
| IA Pro | `Pro` | 3717699454 |

A chave `Studio` preserva perfis e recibos anteriores do Plus. O servidor consulta a lista oficial de produtos desta experiência antes de abrir uma compra. O preço final é o do prompt Roblox. As consultas públicas externas dos dois IDs responderam 503; a associação real à sua experiência ainda precisa ser confirmada no jogo publicado. Nenhuma compra real foi realizada nesta revisão.

## Validação nativa pendente

1. Abrir Catálogo, Patrocinar, Comunidade, Emotes, Looks e Carregar; fechar e abrir 20 vezes.
2. Testar os 15 atalhos e o menu + no Motorola Moto 5G, em pé e deitado, com joystick/pulo nativos ativos.
3. Abrir IA, enviar pedido, cancelar, continuar lote e reabrir a conversa. Conferir Plus/Pro e preço, sem confirmar uma compra de teste inadvertidamente.
4. No Photo Mode, alternar fundos/emotes/pose, trocar páginas e fechar os painéis. Comparar o enquadramento antes/depois; testar R6/R15 e corpos personalizados.
5. Tirar foto pelo botão de câmera; salvar/compartilhar pelo serviço nativo. Fechar o estúdio e confirmar câmera, luz e interface restauradas.
6. Conferir Truco com quatro cartas públicas em tela deitada; jogar Xadrez, Damas e Botão do Caos. Medir FPS/memória no aparelho e verificar áudio/streaming com outras pessoas.

Os testes publicados são simulações de serviços/layout. O processo bloqueou sockets e execução de comandos de verdade, mas isso não representa física, filtragem, pagamentos ou multiplayer executados no Roblox.

## Alcance da referência visual

O HUD segue a organização da foto fornecida, com adaptação dos nossos destinos e controles de toque. A reprodução integral do Photo Studio do Catalog Avatar Creator não pôde ser confirmada: foram identificados vídeos e datas, mas a mídia audiovisual não ficou acessível. Consulte `audits/V76/RESEARCH.md` e `PROMPT_REVIEW.md` para a cobertura e as pendências exatas.
