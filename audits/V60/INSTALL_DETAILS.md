## Instalação e compras anteriores

Use **AVATAR_PLAZA_V60.html** ou sincronize o instalador permanente. A V59 completa precisa estar instalada; este pacote contém somente o que mudou. Pare Play, crie os três ModuleScripts novos, substitua as quinze fontes completas e reinicie Play para limpar o cache de módulos. Os nomes das instâncias são os da tabela, sem “NOVO” ou “SUBSTITUIR”. O instalador mostra nome, tipo, local, última linha e botões de copiar; as fontes ficam recolhidas.

**Nenhum Game Pass ou Developer Product novo é necessário.** A vitrine não cobra Robux, moedas, recompensas ou outra contrapartida para publicar. Comprar um item usa o diálogo oficial do catálogo Roblox, com o preço confirmado pelo Roblox naquele momento.

Desative a venda dos planos antigos **IA Studio `3717699383` e IA Pro `3717699454`** no Creator Dashboard. Não apague registros, módulos de conta nem o processador de recibos: acesso previamente comprado continua reconhecido até vencer, com um atalho opcional em Configurações. O produto Salem `3717699522` permanece. A V60 bloqueia novas solicitações de compra de plano pelo jogo e não inicia a IA para jogadores gratuitos. Ela não anuncia o erro do gerador antigo como corrigido.

## Destaques gratuitos

O antigo acesso de IA/lojas abre **Destaques**. A pessoa cola o ID ou link de um item/pacote do catálogo, toca **Conferir** e depois **Publicar grátis**. O servidor consulta tipo, existência e disponibilidade; IDs de imagem, passe ou produto não viram anúncios de roupa.

- Um destaque ativo por pessoa, durante **24 horas**. Repetir o envio não estende o prazo; retirar também não permite publicar outro antes do prazo original.
- Um mesmo item não aparece duas vezes simultaneamente. Não é obrigatório ser seu criador: a vitrine aceita recomendações de itens de outras pessoas.
- Não há prioridade paga, por moedas, favoritos ou gastos. A posição inicial varia entre jogadores e períodos; isso distribui a exposição, sem prometer o mesmo número de visualizações ou vendas.
- A página mantém até **45 cards**, em linhas com rolagem horizontal. Em área suficiente, são 15 por linha, até sete visíveis de uma vez e no máximo três linhas. No celular estreito/baixo a quantidade visível diminui para preservar leitura e botões.
- Busca por nome/ID e filtros **Todos, Roupas, Acessórios, Corpo, Emotes, Favoritos**, em um menu compacto. **Mais itens** troca a página; não acumula milhares de instâncias na tela.
- Tocar no card abre os detalhes; **Comprar** abre a compra oficial; **♡** salva o favorito sem colocar no carrinho. Favoritos persistem como marcadores mesmo quando o destaque expira. Um item retirado de venda fica identificado como indisponível.
- Falhas de armazenamento/listagem têm mensagem de recuperação. Um envio salvo que ainda não entrou na vitrine pode ser concluído reenviando o mesmo ID, sem reiniciar as 24 horas.

Os envios e favoritos usam DataStore. A listagem entre servidores usa MemoryStore com expiração automática; não é um banco permanente de todas as publicações antigas. A validação de compra consulta novamente o item, pois preço/disponibilidade podem mudar.

## HUD, configurações e mundos

Música e carrinho têm uma área separada de Meus looks. Ao abrir catálogo/destaques/carrinho, o popup de música fecha sem parar o áudio. Os controles principais ficam dentro da área segura e se reorganizam em telas curtas. Os X têm espaço próprio; ações de toque preservam pelo menos 44 pixels nos tamanhos testados.

Configurações usa um painel compacto, limitado a 620 × 382 pixels quando cabe, com seis categorias e acentos coloridos. **Mudar mundo** permite Original, Nuvens, Anime, Neon, Costa e Halloween. Os temas têm cenários, chão e iluminação diferentes. São alterações locais, sem colisão, sem mudar a posição dos jogadores e sem modificar o mapa para os outros. Anime usa uma vila temática original, sem personagens ou imagens de franquias. Original restaura a aparência do mapa.

A categoria **Halloween** do catálogo fica laranja antes e depois da seleção. As peças/X abaixo da prévia e o diagnóstico de aplicação do avatar permanecem na base anterior.

## Comunidade e o que realmente fica salvo

Cada card mostra **Look de jogador + código**, sem username ou preço no card. O layout de cinco cards por linha e duas linhas em celular deitado continua adaptativo; busca e prévia/itens permanecem.

| Código/dado | Significado e persistência |
|---|---|
| `AV-<UserId>` | Consulta a aparência atual dessa conta no Roblox. Usa cache temporário; não representa uma cópia imutável daquele look e não acompanha cada mudança feita dentro deste jogo. |
| Código `AP` já publicado | Look salvo e publicado manualmente pelo jogador, conforme o sistema existente. |
| Último avatar aplicado e confirmado | O sistema anterior guarda a última aparência confirmada para restaurar ao voltar, quando o DataStore está disponível. |
| Meus looks | Looks salvos manualmente continuam no armazenamento privado, respeitando o limite existente e avisando quando a gravação não persistiu. |

**Não: o jogo não registra permanentemente todas as skins de cada pessoa que entra, nem todas as skins dos amigos.** Entrar também não publica automaticamente um look. A V60 não apresenta descoberta temporária como um arquivo global de avatares.

## Photo Mode — fundos de perfil Roblox

Os antigos cenários construídos por scripts saem da seleção de fundos. **Fundos** solicita a permissão nativa de leitura do inventário e consulta apenas itens `AvatarBackground` realmente possuídos. Há seis opções por página, Mais fundos e Recarregar. Não instala IDs inventados, screenshots de fundos pagos ou imagens sem confirmação de propriedade.

Selecionar um fundo verifica tipo e propriedade no servidor, busca sua referência de imagem e confirma carregamento/decodificação no cliente **antes** de trocar o fundo. A cópia exata do avatar, poses, emotes e giro permanecem. A imagem fica atrás do avatar, sem transformar o giro do personagem em giro de um cenário criado. Sem fundo selecionado, a prévia fica neutra.

**Limite real:** fundo de perfil é um recurso 2D do Roblox. A existência no inventário não prova que aquele asset disponibiliza uma imagem carregável dentro de uma experiência. Se permissão, inventário, propriedade ou imagem falhar, o fundo anterior é mantido e a interface informa a etapa. A renderização desses assets não foi confirmada no motor Roblox nesta auditoria. Se o inventário não contiver fundos, a interface informa isso; não finge disponibilizar um catálogo gratuito completo.

## Verificação no Roblox

1. Instale os três novos e as quinze substituições; reinicie Play. Em uma experiência publicada, permita uso de APIs de DataStore para o teste de Studio conforme sua configuração.
2. No celular em pé e deitado, confira HUD, Meus looks, música, carrinho, todos os X e Configurações. Abra Destaques e deslize as linhas para os lados.
3. Use um ID de roupa/acessório à venda. Confira, publique, favorite e abra Comprar; cancelar a compra deve apenas fechar o diálogo Roblox. Reenviar não aumenta o prazo. Um segundo jogador não deve publicar o mesmo item enquanto estiver ativo.
4. Confira a vitrine em outro servidor. Retire/reabra o seu destaque e confirme o prazo original. Falha real de MemoryStore deve mostrar recuperação, sem dizer que houve publicação completa.
5. Busque um código `AV` de um card e confira a aparência nativa. Salve um look e aplique outro; saia/volte para verificar a restauração da última aparência confirmada, sem esperar que todos os looks usados tenham virado publicações.
6. Teste cada mundo; outra pessoa deve continuar vendo seu próprio mapa. Original deve restaurar o chão/iluminação.
7. No Photo Mode, autorize inventário, selecione um fundo que possui, gire/pose o avatar e volte. Negue permissão em outro teste e confira o aviso. Se a imagem falhar, confira no Output `[V60 PhotoBackground]` com `etapa=IMAGE_DECODE`; o cenário anterior deve continuar.
8. Se houve compra antiga de IA, confira o atalho de acesso remanescente e a data de expiração. Não exclua o único ProcessReceipt.

## Validação e referências

**19 cenários simulados**, geometria em seis resoluções, sintaxe das **101 fontes efetivas**, dependências, hashes históricos e JavaScript real do instalador verificados. As simulações não acessam serviços reais, não compram itens e não renderizam a UI no Roblox. O teste nativo de celular, DataStore/MemoryStore e fundos ainda é necessário.

Referências primárias consultadas: [AvatarEditorService e consentimento para inventário](https://create.roblox.com/docs/reference/engine/classes/AvatarEditorService), [AvatarAssetType e fundo 2D de perfil](https://create.roblox.com/docs/reference/engine/enums/AvatarAssetType), [AssetService](https://create.roblox.com/docs/reference/engine/classes/AssetService), [MemoryStoreSortedMap](https://create.roblox.com/docs/reference/engine/classes/MemoryStoreSortedMap), [InfoType](https://create.roblox.com/docs/reference/engine/enums/InfoType) e [anúncio oficial de fundos de perfil](https://devforum.roblox.com/t/expanding-roblox-plus-new-ways-for-players-to-personalize-their-profiles-and-app-themes/4751465/1).

A vitrine foi implementada como recomendação voluntária de itens do catálogo Roblox, sem contrapartida nem chamada para sites externos. Gratuidade, por si só, não garante isenção das regras de publicidade. Essa distinção é uma interpretação das [Community Standards](https://about.roblox.com/community-standards) e [Advertising Standards](https://en.help.roblox.com/hc/en-us/articles/13722260778260-Advertising-Standards); a V60 não certifica aprovação da Roblox nem introduz integração de anúncio pago.
