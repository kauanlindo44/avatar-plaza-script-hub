# Instalação V55 — 18 substituições + 14 NOVOS

Requer V54 completa. V55: 32 instalações = 18 SUBSTITUIÇÕES + 14 NOVOS. Pare Play. Crie primeiro os novos ModuleScripts nos locais indicados, depois os novos Scripts/LocalScripts e substitua os existentes. Não duplique nomes. (NOVO)/(SUBSTITUIR) não faz parte do nome. Cada fonte tem até 400 linhas. Não substitua 09A_SHOP_UI nem regras de jogos nesta versão. Guia: INSTALL_V55.md.

## Criar — 14 NOVOS

| Nome exato | Tipo | Local | Linhas |
|---|---|---|---:|
| `07M0_MUSIC_PREFS` | ModuleScript | ServerScriptService | 29 |
| `07M1_MUSIC_UI` | ModuleScript | ReplicatedStorage | 43 |
| `09I0_ASSISTANT_CONFIG` | ModuleScript | ReplicatedStorage | 10 |
| `09I1_ASSISTANT_ACCOUNTS` | ModuleScript | ServerScriptService | 113 |
| `09I2_ASSISTANT_ENGINE` | ModuleScript | ServerScriptService | 33 |
| `09I3_OUTFIT_BUILDER` | ModuleScript | ServerScriptService | 76 |
| `09I4_ASSISTANT_UI` | ModuleScript | ReplicatedStorage | 69 |
| `09I5_ASSISTANT_QUESTIONNAIRE` | ModuleScript | ReplicatedStorage | 50 |
| `09I6_ASSISTANT_RESULTS` | ModuleScript | ReplicatedStorage | 91 |
| `09I7_ASSISTANT_PROFILE` | ModuleScript | ReplicatedStorage | 47 |
| `07M_MUSIC_CLIENT` | LocalScript | StarterPlayer > StarterPlayerScripts | 69 |
| `07M_MUSIC_SERVER` | Script | ServerScriptService | 19 |
| `09I_ASSISTANT_CLIENT` | LocalScript | StarterPlayer > StarterPlayerScripts | 73 |
| `09I_ASSISTANT_SERVER` | Script | ServerScriptService | 111 |

## Substituir — 18 existentes

| Nome exato | Tipo | Local | Linhas |
|---|---|---|---:|
| `07K10_CARD_COMMERCE` | ModuleScript | ServerScriptService | 82 |
| `07K6_CARD_CATALOG` | ModuleScript | ReplicatedStorage | 42 |
| `07K7_CARD_STYLES` | ModuleScript | ReplicatedStorage | 155 |
| `07K8_CARD_INVENTORY` | ModuleScript | ServerScriptService | 169 |
| `07K9_CARD_INVENTORY_UI` | ModuleScript | ReplicatedStorage | 157 |
| `07P0_STUDIO_PRESETS` | ModuleScript | ReplicatedStorage | 20 |
| `07P4_STUDIO_UI` | ModuleScript | ReplicatedStorage | 115 |
| `07P5_POSE_CANVAS` | ModuleScript | ReplicatedStorage | 164 |
| `07P6_STUDIO_SETS` | ModuleScript | ReplicatedStorage | 49 |
| `07UI_DESIGN_SYSTEM` | ModuleScript | ReplicatedStorage | 171 |
| `07UI_SURFACE_EFFECTS` | ModuleScript | ReplicatedStorage | 65 |
| `09A1_SHOP_LAYOUT` | ModuleScript | ReplicatedStorage | 174 |
| `09B5_AVATAR_RUNTIME` | ModuleScript | ServerScriptService | 192 |
| `09C4_OUTFIT_LIBRARY` | ModuleScript | ReplicatedStorage | 206 |
| `09C7_COMMUNITY_FEED` | ModuleScript | ReplicatedStorage | 142 |
| `07G_HUB_UI` | LocalScript | StarterPlayer > StarterPlayerScripts | 105 |
| `07P_PHOTO_MODE` | LocalScript | StarterPlayer > StarterPlayerScripts | 175 |
| `09C_SHOP_CLIENT` | LocalScript | StarterPlayer > StarterPlayerScripts | 380 |

## Copiar sem duplicar

Pare Play antes de instalar. Use o nome exato da tabela; NOVO/SUBSTITUIR são apenas marcações. ModuleScript, Script e LocalScript são tipos diferentes. Copie inteiro ou parte 1 e parte 2 no mesmo script. O instalador esconde o código, mostra a última linha e oferece os botões de copiar. ONLINE verde confirma consulta e sincronização com o GitHub. Sem rede, o pacote contém a base histórica V44 e o delta V55; V55 ainda requer todos os módulos efetivos da V54.

Não altere os quatro trechos do 09A_SHOP_UI nesta instalação. 09C5_UGC_STORES deixa de ser aberto pelo HUD; pode permanecer instalado para compatibilidade. O botão antigo Limiteds passa a abrir Avatar IA. Passes e produtos anteriores continuam reconhecidos. Éter Visual 3716300364 permanece desativado.

## Produtos e preços

| Benefício | Tipo | ID | Valor final sugerido |
|---|---|---:|---:|
| IA Studio — até 2 variações do mesmo pedido, 30 dias | Developer Product | 3717699383 | 15 Robux |
| IA Pro — até 5 variações do mesmo pedido, 30 dias | Developer Product | 3717699454 | 25 Robux |
| Salem — cosmético permanente de Halloween | Developer Product | 3717699522 | 10 Robux |

Não é preciso criar outro produto ou passe para esses três benefícios. Os preços do painel não foram alterados. A interface consulta o preço efetivo no Roblox: se está 1 Robux para teste, ela apresenta 1. Mude para os valores finais depois de testar. Planos de IA não são assinaturas automáticas: cada compra adiciona 30 dias de calendário, equivalentes a 720 horas ou 2.592.000 segundos. Tempo offline conta. Compras Studio feitas durante Pro ficam após o período Pro. As duas expirações são preservadas; Pro prevalece enquanto ativo. Comprar Pro não converte nem reembolsa o prazo Studio que já estava ativo.

07K10_CARD_COMMERCE continua sendo o único proprietário de MarketplaceService.ProcessReceipt. Ele concede cards antigos, Salem e planos. Recibos repetidos não duplicam o benefício. Falha no DataStore retorna NotProcessedYet; fechar o prompt não concede compra.

Salem também custa 900 moedas, adquiridas pelo sistema atual de jogos. Venda disponível até 02/11/2026 23:59 UTC, definida em 07K6_CARD_CATALOG. Quem adquiriu mantém a carta após o evento e pode equipá-la normalmente. É uma edição limitada ao período deste jogo, sem negociação no marketplace, sorteio ou vantagem de jogo.

## Catálogo, corpo e comunidade

A faixa de itens equipados é inicializada antes das outras utilidades e mostra miniaturas com X individual de 44px. Uma falha no carrinho não pode impedir sua atualização. O layout reserva essa faixa e reduz a prévia somente quando necessário para manter os controles dentro do espaço seguro.

Fechar o catálogo ou trocar de página não cancela a alteração pendente da aparência. Mudar roupas em camadas reconstrói o avatar pelo mesmo gerador nativo usado na prévia; o servidor verifica o resultado antes de informar aplicação e lembrar a skin. O gato abacaxi 72779265740934 é ShirtAccessory 3D sobre R15. A descrição inteira e as outras peças continuam preservadas. Se Layered Clothing estiver desabilitado nas configurações do projeto, ative-o no Roblox; o script não pode alterar essa propriedade protegida.

Comunidade: cinco skins lado a lado e duas filas visíveis no celular deitado; duas colunas no retrato. Busca e filtro continuam; 50 slots são reciclados e até 100 registros ficam no buffer. Após os 100, a janela antiga é liberada e Carregar mais traz novos looks. Não há um milhão de avatares inventados nem garantia de disponibilidade da API de descoberta. Dados e códigos reais do backend V54 são preservados.

## Avatar IA

Assistente real usando TextGenerator do Roblox. Uma verificação real de saúde deve funcionar para liberar planos pagos. Se o projeto não tem acesso ao serviço ou ele falha, a interface informa indisponibilidade e bloqueia os prompts desses planos. Não há fallback que simula conversa humana nem chave externa configurada. Publicar estes scripts no GitHub não comprova que TextGenerator esteja habilitado na sua experiência.

Interface com conversa, enquete e Confirmar, orçamento, peças clássicas 2D/camadas 3D, manter peças ou trocar, quantidade e busca opcional de corpo. A IA interpreta o estilo; o catálogo fornece IDs, preços e tipos reais. Prévia 3D gira e permite aplicar, remover itens com X, guardar e abrir o carrinho. Porcentagem segue etapas concluídas de geração, busca e validação. A prévia carrega separadamente e mostra erro/repetição se a malha não responde. Preço exibido é a estimativa das peças novas, com confirmação oficial no carrinho/compra; peças já mantidas no avatar não são cobradas pelo assistente.

Normal: 1 look por solicitação e 10 solicitações/dia. Studio: até 2 e 30/dia. Pro: até 5 e 60/dia. Esses limites são compartilhados pelo titular e convidados, e até oito interações independentes cabem em cada sessão. A quantidade é de variações do mesmo pedido. Se não há peças suficientes ou combinações distintas, o resultado explica a quantidade menor. Falhas tentam devolver o limite reservado; se o armazenamento não confirma, isso é informado.

Pro tem comparar cinco, cores, temas, edição em lote a partir do look escolhido, alternativas econômicas, combinar peças possuídas, orçamento por peça, coleções nomeadas, encadeamento de versões salvas e compartilhamento de coleções. Studio compara até dois. Aplicar e guardar looks também continuam disponíveis gratuitamente. Chat ajuda com estilo e funções do jogo; não promete pesquisa geral na internet. Sem histórico conversacional entre sessões. Looks e preferências persistem como dados de jogo, sem serem enviados automaticamente ao modelo como memória de chat.

O perfil usa seu próprio UserId Roblox. Não existe senha nem login extra. Titular de plano ativo pode convidar até três amigos; cada um aceita com sua própria conta Roblox. O grupo compartilha plano e limite, sem compartilhar conversa privada, avatar ou Robux. Revogar retira o acesso; convites expiram em sete dias. Coleções são privadas por padrão; o titular Pro precisa escolher compartilhar. Convidados podem ver/aplicar/importar cópias das coleções compartilhadas, sem excluir as do titular.

Publicidade do item 77359681399843 aparece fora do texto da IA em Normal/Studio, identificada como "Publicidade — minha coleção". Não há segmentação por prompts. O servidor valida o criador configurado 4129514489 e disponibilidade do ativo. Se não confirmar, oculta a publicidade; ativos de grupo exigem validação e configuração própria. Pro não exibe publicidade. O botão Ver abre os detalhes desse item no catálogo, sem compra automática.

## Photo Mode e música

Cinco fundos discretos: Estúdio Creme, Céu Suave, Luz de Fim de Tarde, Jardim Calmo e Outono Salem. O centro fica livre para o avatar, sem neon e letreiros dominantes. Movimento de cenário começa desligado. Luz, emotes, pose, enquadramento e captura usam os controles reais existentes, com menus contextuais menores. Os botões de pose foram ampliados; arraste o manequim ou a parte do avatar da cena e confirme/cancele. Sair restaura câmera e iluminação do jogador. O avatar do estúdio é um modelo animado na cena local; não modifica poses de outros jogadores.

Música abre um popup compacto, com ID/link, Carregar, Recarregar, tocar/pausar, salvar/remover e volume de 0–100%. Primeira configuração começa em 40%; sua escolha e até 24 favoritos persistem. Som é individual. Se há um Sound Music/BackgroundMusic em SoundService, ele é adotado; sem áudio configurado, escolha um ID autorizado. Scripts não inventam músicas nem contornam permissões. ID não áudio, moderação, falta de acesso e timeout têm mensagens. Preferências que não carregam ficam apenas na sessão até Recarregar.

## Conferência no jogo publicado

1. Instale sobre V54, confirme tipos/locais e ausência de scripts duplicados. Verifique Output.
2. Com Layered Clothing permitido, experimente o gato, feche o catálogo rapidamente, confira o personagem no mapa, dê respawn e entre novamente.
3. No celular em pé/deitado, confira faixa de itens, comunidade 5×2, X, carrinho, enquete e três cartas da loja. Compare poses e emotes no estúdio; saia e confira câmera/luz originais.
4. Abra a IA e aguarde disponibilidade real. Gere 1/2/5 looks conforme o plano. Se TextGenerator indisponível, comprar Studio/Pro deve continuar bloqueado.
5. Com os produtos de teste, compre Studio/Pro, confirme o prazo no perfil, aceite/revogue um convite e teste com outra conta própria. Confirme Salem em Meus visuais.
6. Carregue áudio autorizado para a experiência, salve, ajuste volume e reentre. Teste também um ID de imagem e um áudio privado.

DataStores reais dependem da experiência publicada e, para testar no Studio, Enable Studio Access to API Services. Os 72 cenários automatizados desta entrega usam serviços simulados em Lua 5.4 e seis tamanhos de tela. Não houve publicação da experiência Roblox nem teste de cobrança/renderização no motor Roblox. Fontes e limites: [audits/V55/RESEARCH.md](audits/V55/RESEARCH.md).
