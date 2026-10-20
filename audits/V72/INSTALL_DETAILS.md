## Ordem e confirmação

Se ainda estiver na **V69**, termine a **V71** antes desta atualização; a V70 não é necessária. As versões anteriores continuam disponíveis no HTML.

1. Abra a V72 no HTML atualizado e marque **somente os oito novos**, nos tipos e locais indicados. Os três módulos de servidor ficam em **ServerScriptService**; os outros cinco em **ReplicatedStorage**.
2. Substitua as **37 fontes** nas instâncias existentes. `09I9_GAME_GUIDE` também faz parte das substituições: as instruções da assistente precisam acompanhar os menus novos.
3. Copie a fonte inteira pelo botão. Não acrescente `(NOVO)`, `(SUBSTITUIR)` ou a contagem ao nome da instância. Cada fonte tem até 400 linhas. `09A_SHOP_UI` permanece como estava na V71.
4. Termine todas as fontes antes de iniciar Play e publicar pelo seu editor Roblox. Instalar só a interface e deixar o servidor antigo pode manter falhas de protocolo/recursos.

O HTML tem `1/8 (NOVO)` a `8/8 (NOVO)` e `1/37 (SUBSTITUIR)` a `37/37 (SUBSTITUIR)`, com nome, tipo, local, última linha e cópia integral. A conexão online compara o manifesto publicado no GitHub; a cópia offline também contém a V72.

## Produtos e custos

- **Plus da assistente:** Developer Product **3717699383**, antes chamado Studio. Até 5 looks por pedido, 30 pedidos/dia.
- **Pro da assistente:** Developer Product **3717699454**. Quantidade escolhida por pedido, processada em lotes de cinco; 60 pedidos/dia.
- **Gratuito:** 1 look por pedido, 10 pedidos/dia.
- Os dois produtos pagos concedem **30 dias corridos (2.592.000 segundos)**, incluindo o período fora do jogo. Compra avulsa; sem renovação automática. Até três amigos podem compartilhar o benefício e a cota, sem compartilhar a conta Roblox, senha ou conversas.
- O preço é consultado no Roblox e mostrado antes do prompt oficial. Os preços de teste existentes não são alterados por script. A configuração mantém as sugestões anteriores de **15 e 25 Robux**, mas a cobrança é a do produto configurado no Roblox.
- **Nenhum Developer Product, passe, upload ou chave novo.** Nenhum serviço externo pago foi ativado. O sistema pesquisa, combina e valida itens nativos; não usa OpenAI nem é um chat generativo geral.
- A concessão segue exclusivamente o recibo existente em `07K10_CARD_COMMERCE` → `09I1_ASSISTANT_ACCOUNTS.Receipt`. Nunca conceder por fechar/concluir a janela de compra.

## O que mudou

Pedido em quatro etapas, confirmação visual do corpo, tipos oficiais, IDs/pesquisa por peça, esforços, etapas reais e botão de parar. Corpo obrigatório ou peça específica indisponível gera erro; não deve ser trocado por um resultado diferente. Pro entrega lotes progressivos, limita a tela a 50 resultados recentes e permite guardar os escolhidos. A proteção de repetição por pedido tem memória limitada; pode recusar combinações por coincidência do filtro, mas não deve repetir uma combinação marcada.

Patrocinar mantém busca, filtros, favoritos, publicações grátis de 24 h, substituição de exemplos um por um e renovação de mídia de jogos/comunidades a cada 15 minutos. O painel usa a prévia à esquerda e prateleiras à direita. Em altura muito pequena, o número de fileiras se adapta; não comprime os controles abaixo de 44 px para forçar uma grade impossível.

O editor ganhou criação em quatro etapas, atualmente vestindo, três destinos de salvamento, restauração com confirmação, ferramentas de zoom/rotação, câmera livre, ocultar interface e histórico de compras de catálogo **confirmadas nesta experiência desde a V72**. Esse histórico não consulta todas as compras da conta Roblox.

Photo Mode mantém o fundo Roblox escolhido, usa grade lateral de fundos/emotes/pacotes, executa animação na cópia, permite luz direcional, cópias de cena e ocultar cabeça/corpo apenas na foto. As interfaces de música e jogos foram refinadas. As regras, dificuldades, turnos, pontuação e tempos continuam nos mesmos scripts anteriores.

## Verificação no Roblox publicado

As verificações do pacote executam Lua compatível e serviços simulados; **não substituem teste no motor Roblox ou em aparelhos reais**.

Conferir: compra de teste dos produtos e recibo; salvar/cancelar roupa e avatar da conta; corpo e roupa em camadas no mapa; emotes/pacotes/imagens permitidos; áudio e fallback; toque, recorte e teclado em pé/deitado; mensagens entre participantes de mesas distintas e bloqueios nativos de comunicação. O fundo anterior e a cópia devem continuar disponíveis se um asset for recusado.

O aviso de `FoundationProvider`/`CorePackages` das fotos pertence à interface interna do Roblox. Este pacote não modifica esses módulos internos. Os testes de armazenamento verificam que descoberta de comunidade respeita orçamento e que falha de leitura não apaga looks.

Atalhos de voz dependem das configurações e da elegibilidade nativas do Roblox; esta atualização não habilita voz nem promete encontrar um servidor exclusivo de voz. A reprodução literal de toda interface privada de outro produto não é verificável pelas capturas; foram adaptados os fluxos identificados, com arte e código do projeto.
