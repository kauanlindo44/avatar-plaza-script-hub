-- 09I0_ASSISTANT_CONFIG | ModuleScript | ReplicatedStorage | V76 (SUBSTITUIR)
-- Produtos repetíveis: 30 dias corridos, inclusive fora do jogo. Sem senha Roblox.
local C={Seconds=2592000,MaxFriends=3,AdAsset=77359681399843,AdOwner=4129514489,MaxMessages=1000}
C.Plans={Normal={count=1,daily=10},Studio={count=5,daily=30,product=3717699383,suggestedRobux=15},Pro={count=2147483647,daily=60,product=3717699454,suggestedRobux=25}}
C.Disclosure='Assistente de looks por pesquisa no catálogo Roblox. Não é um chat generativo geral. As peças e o preço são verificados antes de entregar.'
C.Styles={'emo','casual','meme','anime','gótico','Halloween','elegante','esportivo'}
C.Tools={{'Criar','Novos looks'},{'Cores','Variar cores'},{'Temas','Variar tema'},{'Lote','Editar em lote'},{'Econômico','Reduzir custo'},{'Inventário','Usar minhas peças'}}
C.ProBenefits={'Quantidade escolhida em lotes de cinco','Variações de cores','Variações de tema','Edição em lote','Alternativas econômicas','Combinar peças possuídas','Orçamento por peça','Coleções organizadas','Versões de looks','Compartilhar coleções'}
C.Labels={Normal='Gratuito',Studio='Plus',Pro='Pro'}
C.BatchSize=5
C.ProductPlans={[3717699383]='Studio',[3717699454]='Pro'} -- Studio é a chave legada do Plus.
C.Version='V76'
return C
