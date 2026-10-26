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
