# Referências V52 — consulta em 7 de outubro de 2026

## Corpos e roupas em camadas

- [Roblox — Layered accessories](https://create.roblox.com/docs/avatar/layered-accessories): cages, WrapLayer e o ajuste de roupas em camadas ao corpo. Uma roupa 3D que muda a silhueta não é necessariamente um novo tipo de rig; a implementação precisa distinguir o pacote de corpo do acessório em camadas.
- [Roblox — StarterPlayer](https://create.roblox.com/docs/reference/engine/classes/StarterPlayer): `LoadCharacterLayeredClothing` é **Not Scriptable** e **Not Replicated**. A configuração do projeto deve permitir roupas em camadas; scripts não podem habilitar essa propriedade. `LoadCharacterAppearance` também participa do carregamento da aparência.
- [Roblox — HumanoidDescription](https://create.roblox.com/docs/reference/engine/classes/HumanoidDescription): acessórios, `SetAccessories`, ordem/camadas e `UseAvatarSettings`. A V52 preserva as descrições nativas e identifica os nove tipos de roupas em camadas para selecionar R15.
- [Roblox — Humanoid](https://create.roblox.com/docs/reference/engine/classes/Humanoid): aplicação da descrição e `ApplyDescriptionResetAsync`. A atualização confere a aparência efetiva e os acessórios físicos após a criação/aplicação; não trata o retorno da API ou a presença de IDs como prova de que um mesh foi renderizado.

O exemplo gato abacaxi usado na regressão corresponde a um ShirtAccessory, com ID `72779265740934`. Sua classificação foi usada no fixture; não houve carregamento desse asset no motor Roblox nesta sessão. O Gumball e corpos realistas precisam de teste real. A inferência que motivou a correção é que a seleção de R6 para uma roupa em camadas pode impedir a silhueta esperada; isso não prova a causa de todas as falhas de assets.

## Truco

- [AABB-SP — Regulamento de Truco (PDF)](https://aabbsp.com.br/storage/0%202022/07.%20JULHO/Regulamento%20Truco.pdf): baralho cheio de 40 cartas e limpo de 24, ordem das cartas, manilhas, vaza e regras competitivas. O paulista limpo remove 4–7; depois do 3, a manilha volta à Q dentro do conjunto reduzido.
- [Copag — Truco mineiro](https://wap.copag.com.br/blog/detalhes/truco-mineiro-tambem-tem-treta-barulho-e-diversao): referência do fabricante sobre a variante mineira, baralho e manilhas fixas. A página teve resposta incompleta no navegador de pesquisa; não foi usada como comprovação de todo o regulamento.
- [APCEF-GO — Regulamento técnico de Truco](https://apcefgo.org.br/portal/apcef-go-portal/informacoes/noticias-de-esportes/regulamento-geral-e-tecnico-dos-jogos-regionais-centro-oeste-2017.htm): referência primária regional com 40 cartas, três por jogador, vira na 13ª, mão de 11, cartas cobertas, comunicação e decisão da dupla. Não existe uma promessa de contemplar todos os regulamentos regionais do Brasil.

A V52 mantém os três perfis de pontuação/regras já usados na V51, com regressões, e acrescenta escolha de baralho. O reduzido mineiro conserva as manilhas fixas que sairiam ao remover 4–7: são 27 cartas, explicitadas como “Limpo · manilhas fixas”; não é apresentado como regra universal de torneios mineiros. A opção limpo no Goiano é uma seleção de mesa, não uma alegação de que o regulamento APCEF citado exija esse conjunto.

Mesas com valores/naipes personalizados são identificadas como personalizadas, separadas da partida rápida normal e excluídas das recompensas competitivas. Não se misturam jogadores de baralhos diferentes na mesma fila. A distribuição é automática. A mesa 2D mostra somente cartas públicas e a mão autorizada de quem recebe o payload.

## Referências visuais e limites

As duas imagens anexadas nesta solicitação orientaram o lobby com três jogos e a mesa verde com jogadores ao redor. Foram usadas como composição; os desenhos de cartas, ícones e interfaces foram construídos no código do projeto. Nenhum código, marca ou asset do Catalog Avatar Creator foi incorporado.

A loja passou a compras diretas, retirando caixas das novas ofertas. IDs e créditos antigos são preservados para processar recibos pendentes. Não foi alterado preço no painel, criado produto, solicitado documento de idade ou feita compra. As decisões legais históricas permanecem documentadas nos relatórios anteriores; esta entrega não faz certificação legal do jogo.
