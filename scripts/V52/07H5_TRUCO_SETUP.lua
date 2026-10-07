-- 07H5_TRUCO_SETUP | ModuleScript | ReplicatedStorage | V52 (NOVO)
-- Escolha antes da partida; configurações personalizadas só em salas criadas.
local Rep=game:GetService('ReplicatedStorage')
local D=require(Rep:WaitForChild('07UI_DESIGN_SYSTEM'));local C=D.Colors
local Bounds=require(Rep:WaitForChild('07UI_SCREEN_BOUNDS'))
local Deck=require(Rep:WaitForChild('07K14_DECK_OPTIONS'))
local M={}
function M.Build(parent,U)
 local V={};local ranks,suits={},{};local choices={};local suitButtons={};U.Deck={mode='Full'}
 local root=D.New('Frame',{Name='DeckSetup',BackgroundTransparency=1,ZIndex=41},parent)
 V.Full=D.Button(root,'Cheio · 40 cartas',{ZIndex=42,TextSize=13});V.Clean=D.Button(root,'Limpo · 24 cartas',{ZIndex=42,TextSize=13})
 V.Custom=D.Button(root,'Personalizar',{ZIndex=42,TextSize=13})
 V.Note=D.Text(root,'',{TextSize=12,TextColor3=C.muted,ZIndex=42})
 local cards=D.New('Frame',{Name='CustomRanks',BackgroundTransparency=1,ZIndex=42},root)
 local saved=D.New('Frame',{Name='DeckPresets',BackgroundTransparency=1,ZIndex=42},root)
 V.Save=D.Button(saved,'Salvar baralho',{ZIndex=43,TextSize=12});V.Restore=D.Button(saved,'Usar salvo',{ZIndex=43,TextSize=12})
 local function raw()
  local a,b={},{};for _,k in ipairs(Deck.Ranks)do if ranks[k]then a[#a+1]=k end end
  for _,k in ipairs(Deck.Suits)do if suits[k]then b[#b+1]=k end end;return{mode='Custom',ranks=a,suits=b}
 end
 local function paint()
  if U.Deck.mode=='Custom'then U.Deck=raw()end
  local clean,e=Deck.Clean(U.Deck,U.Variant,U.Mode=='Create')
  V.Note.Text=clean and(clean.custom and'Mesa personalizada · '..clean.count..' cartas · fora do ranking'or'Baralho oficial · '..clean.count..' cartas · distribuição automática')or e
  for k,b in pairs(choices)do b.BackgroundColor3=ranks[k]and C.green or C.card;b.TextColor3=ranks[k]and C.bg or C.text end
  for k,b in pairs(suitButtons)do b.BackgroundColor3=suits[k]and C.green or C.card end
  V.Full.BackgroundColor3=U.Deck.mode=='Full'and C.green or C.card;V.Clean.BackgroundColor3=U.Deck.mode=='Clean'and C.green or C.card;V.Custom.BackgroundColor3=U.Deck.mode=='Custom'and C.green or C.card
 end
 for _,k in ipairs(Deck.Ranks)do ranks[k]=true;local b=D.Button(cards,k,{ZIndex=43,TextSize=15});choices[k]=b
  b.Activated:Connect(function()ranks[k]=not ranks[k];U.Deck=raw();paint()end)
 end
 for i,k in ipairs(Deck.Suits)do suits[k]=true;local b=D.Button(cards,({'♦','♠','♥','♣'})[i],{ZIndex=43,TextSize=20});suitButtons[k]=b
  b.Activated:Connect(function()suits[k]=not suits[k];U.Deck=raw();paint()end)
 end
 V.Full.Activated:Connect(function()U.Deck={mode='Full'};U.Layout()end)
 V.Clean.Activated:Connect(function()U.Deck={mode='Clean'};U.Layout()end)
 V.Custom.Activated:Connect(function()U.Deck=raw();U.Layout()end)
 local function call(action,data)
  local kit=Rep:FindFirstChild('PracaKit');local rem=kit and kit:FindFirstChild('Remotes');local rpc=rem and rem:FindFirstChild('TrucoRequest')
  if not rpc then return nil,'Servidor carregando.'end
  local ok,r=pcall(function()return rpc:InvokeServer(action,data or{})end);return ok and r and r.ok and r.data or nil,ok and r and r.error or'Servidor indisponível.'
 end
 V.Save.Activated:Connect(function()
  local clean,e=Deck.Clean(U.Deck,U.Variant,true);if not clean then V.Note.Text=e;return end
  local d,err=call('savedeck',{deck=U.Deck,variant=U.Variant});U.SetStatus(d and'Baralho salvo na sua conta.'or err,not d)
 end)
 V.Restore.Activated:Connect(function()
  local d,e=call('inventory');if d and d.deckPreset then
   local p=d.deckPreset;U.Variant=p.variant;U.Deck=p.deck
   if U.Deck.mode=='Custom'then ranks={};suits={};for _,k in ipairs(U.Deck.ranks)do ranks[k]=true end;for _,k in ipairs(U.Deck.suits)do suits[k]=true end end;U.Layout()
  else U.SetStatus(e or'Salve um baralho primeiro.',true)end
 end)
 function V.Layout(w,h,on)
  root.Visible=on;if not on then return end
  if U.Mode~='Create'and U.Deck.mode=='Custom'then U.Deck={mode='Full'}end
  local compact=U.Mode=='Create'and U.Deck.mode=='Custom'and h<390
  Bounds.Rect(root,12,compact and 54 or 134,w-24,h-(compact and 110 or 196)-(U.Mode=='Practice'and 50 or 0));local rw=w-24
  if compact then U.Intro.Visible=false;Bounds.Rect(U.GameTitle,12,4,w-232,48);Bounds.Rect(U.VariantButton,w-214,4,144,44)end
  local create=U.Mode=='Create';local n=create and 3 or 2
  for i,b in ipairs({V.Full,V.Clean,V.Custom})do b.Visible=i<=n;Bounds.Rect(b,(i-1)*(rw+6)/n,0,(rw-6*(n-1))/n,44);b.TextSize=w<500 and 11 or 13 end
  V.Clean.Text=U.Variant=='Mineiro'and'Limpo · manilhas fixas'or'Limpo · 24 cartas'
  cards.Visible=create and U.Deck.mode=='Custom';saved.Visible=create
  local custom=cards.Visible;local cols=rw>=510 and 9 or 6;local rows=math.ceil(17/cols)
  local step=compact and 46 or 48;Bounds.Rect(cards,0,compact and 44 or 50,rw,rows*step)
  for i,k in ipairs(Deck.Ranks)do Bounds.Rect(choices[k],(i-1)%cols*(rw+4)/cols,math.floor((i-1)/cols)*step,(rw-4*(cols-1))/cols,44)end
  for i,k in ipairs(Deck.Suits)do local j=13+i;Bounds.Rect(suitButtons[k],(j-1)%cols*(rw+4)/cols,math.floor((j-1)/cols)*step,(rw-4*(cols-1))/cols,44)end
  local y=custom and 54+rows*48 or 54;Bounds.Rect(saved,0,y,rw,44);Bounds.Rect(V.Save,0,0,(rw-6)/2,44);Bounds.Rect(V.Restore,(rw+6)/2,0,(rw-6)/2,44)
  Bounds.Rect(V.Note,0,create and y+50 or 52,rw,28);V.Note.Visible=not compact
  if compact then
   local footer=h-108;Bounds.Rect(saved,0,footer,rw,44);Bounds.Rect(V.Save,0,0,(rw-12)/3,44);Bounds.Rect(V.Restore,(rw+6)/3,0,(rw-12)/3,44)
   Bounds.Rect(U.Create,12+2*(rw+6)/3,h-54,(rw-12)/3,44);U.Create.Text="Criar sala"
  end;paint()
 end
 return V
end
return M
