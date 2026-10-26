# Instalação V78 — 3 novos + 26 substituições

Base: V77 completa. V78: 3 NOVOS + 26 SUBSTITUIÇÕES. Pare Play. Crie primeiro os três ModuleScripts novos em ReplicatedStorage, exatamente com os nomes indicados. Depois substitua as 26 fontes existentes por inteiro, nos tipos/locais indicados. Não acrescente V78 ou contadores aos nomes. Use Copiar script inteiro; partes são alternativa para a mesma instância. Reinicie Play depois dos dois grupos. Guia: INSTALL_V78.md.

## Criar os 3 módulos novos

| Número | Nome exato | Tipo | Local | Linhas |
|---:|---|---|---|---:|
| 1/3 | `07G12_WORLD_FINISHES` | ModuleScript | ReplicatedStorage | 70 |
| 2/3 | `07G13_FREE_CAMERA` | ModuleScript | ReplicatedStorage | 101 |
| 3/3 | `09C21_EDITOR_CONNECTION` | ModuleScript | ReplicatedStorage | 29 |

## Substituir as 26 fontes existentes

| Número | Nome exato | Tipo | Local | Linhas |
|---:|---|---|---|---:|
| 1/26 | `07G10_HUD_LAYOUT` | ModuleScript | ReplicatedStorage | 75 |
| 2/26 | `07G11_REFERENCE_WORLDS` | ModuleScript | ReplicatedStorage | 164 |
| 3/26 | `07G2_LOCAL_WORLDS` | ModuleScript | ReplicatedStorage | 88 |
| 4/26 | `07G4_WORLD_SCENERY` | ModuleScript | ReplicatedStorage | 64 |
| 5/26 | `07G7_ADVENTURE_WORLD` | ModuleScript | ReplicatedStorage | 49 |
| 6/26 | `07P4_STUDIO_UI` | ModuleScript | ReplicatedStorage | 121 |
| 7/26 | `07UI_DESIGN_SYSTEM` | ModuleScript | ReplicatedStorage | 176 |
| 8/26 | `07UI_REFERENCE_LAYOUT` | ModuleScript | ReplicatedStorage | 75 |
| 9/26 | `09C16_CATALOG_HOME` | ModuleScript | ReplicatedStorage | 74 |
| 10/26 | `09C19_EDITOR_UTILITIES` | ModuleScript | ReplicatedStorage | 38 |
| 11/26 | `09C2_SHOP_CATALOG` | ModuleScript | ReplicatedStorage | 300 |
| 12/26 | `09C4_OUTFIT_LIBRARY` | ModuleScript | ReplicatedStorage | 210 |
| 13/26 | `09I10_CHAT_NAV` | ModuleScript | ReplicatedStorage | 89 |
| 14/26 | `09I16_ACTIVITY_UI` | ModuleScript | ReplicatedStorage | 211 |
| 15/26 | `09I20_ASSISTANT_APPEARANCE` | ModuleScript | ReplicatedStorage | 41 |
| 16/26 | `09I26_REQUEST_GUARD` | ModuleScript | ServerScriptService | 55 |
| 17/26 | `09I4_ASSISTANT_UI` | ModuleScript | ReplicatedStorage | 150 |
| 18/26 | `09I6_ASSISTANT_RESULTS` | ModuleScript | ReplicatedStorage | 142 |
| 19/26 | `BC_HUD` | ModuleScript | ReplicatedStorage | 140 |
| 20/26 | `09B_SHOP_SERVER` | Script | ServerScriptService | 279 |
| 21/26 | `09I_ASSISTANT_SERVER` | Script | ServerScriptService | 169 |
| 22/26 | `07G_HUB_UI` | LocalScript | StarterPlayer > StarterPlayerScripts | 154 |
| 23/26 | `07H_GAME_UI` | LocalScript | StarterPlayer > StarterPlayerScripts | 259 |
| 24/26 | `07P_PHOTO_MODE` | LocalScript | StarterPlayer > StarterPlayerScripts | 185 |
| 25/26 | `09C_SHOP_CLIENT` | LocalScript | StarterPlayer > StarterPlayerScripts | 394 |
| 26/26 | `09I_ASSISTANT_CLIENT` | LocalScript | StarterPlayer > StarterPlayerScripts | 131 |

## Correções que precisam ser instaladas juntas

`09I26_REQUEST_GUARD` é **ModuleScript em ServerScriptService**. Substitua sua fonte completa e também `09B_SHOP_SERVER` e `09I_ASSISTANT_SERVER`, ambos Scripts no mesmo serviço. As duas chamadas inválidas vistas no Output apontam para a inicialização dessa dependência; a imagem não permite determinar o conteúdo exato instalado. A V78 inclui a fábrica `New()` correta e testes de inicialização real das nossas fontes. Se uma exportação incompatível for encontrada, a resposta identifica o módulo e bloqueia os pedidos, sem executar ações desprotegidas.

Substitua também `09C4_OUTFIT_LIBRARY` e `09C_SHOP_CLIENT`. A V77 continha uma comparação rígida com `V58` que rejeitava a biblioteca V76. A V78 verifica as funções exportadas e restaura carrinho/corpo. O novo `09C21_EDITOR_CONNECTION` deve existir antes de iniciar Play.

Não apague o place nem o histórico. Esta entrega é um delta sobre a V77 completa. Preserve o módulo legado `08L_COMMUNITY` já existente no place; sua fonte continua fora deste repositório. Mantenha uma única instância ativa de cada nome indicado, com o tipo e local da tabela. O instalador oferece cópia integral e duas partes alternativas para a mesma instância, com hashes e última linha para conferência.

Os estados opcionais de catálogo/atividades/Caos foram normalizados para booleanos explícitos. Isso evita atribuir `nil` a `Visible`, que o Roblox rejeita.

## Uso no PC e no celular

- HUD: alvos principais de 56 px no PC e 52 px no toque; 48 px em paisagem baixa. “IA de looks” e “Nossos jogos” têm entrada lateral quando cabem. O menu Mais mantém todas as rotas nas telas curtas e reserva o espaço dos controles nativos.
- Catálogo: cards proporcionais, título e preço separados, duas a oito colunas conforme a largura. Em espaço compacto, “Categorias” reúne subcategorias, filtros e ordenação. Ações da prévia usam 48 px; os itens equipados permanecem abaixo.
- IA: navegação e histórico ocupam áreas diferentes; a lista rola e o acesso aos planos fica em um rodapé separado. Prévia de looks com cards de 176 × 224, botões com largura mínima de 48 px e até cinco looks por coluna. “?” abre o guia. Reconectar redescobre os remotos atuais.
- Câmera livre: Mais → Câmera livre. PC: WASD, arraste para olhar, Q/E para descer/subir; Shift acelera. Celular: joystick à esquerda, arraste à direita e setas de altura. “Sair da câmera” restaura câmera e controles. O personagem não é teleportado, ancorado ou movido pelos comandos da câmera.
- Mapas: a troca de tema preserva a posição. O cenário e seu piso têm origem fixa. Materiais nativos acrescentam relevo visual leve; trilhas continuam além da tomada do vídeo. A continuação é uma composição nova, pois a gravação não mostra a planta completa.

## Conferência no Roblox

Os testes automatizados executam nossas fontes com serviços nativos simulados e um processo local restrito. Eles não substituem abrir o place no Roblox Studio/Lite e jogar em aparelhos reais. Conferir Output do cliente/servidor; abrir os atalhos; arrastar a prévia; experimentar/remover/desfazer; alternar a IA; jogar e fechar partidas; testar teclado/joystick e rotação da tela; trocar mapas longe do spawn; medir desempenho e verificar captura/áudio.

Plus `3717699383` e Pro `3717699454` permanecem os mesmos. Nenhum plano é concedido pelo fechamento do prompt; os recibos oficiais e a validação de produto da experiência são preservados. Publicar este pacote no GitHub não instala nem publica o place Roblox.
