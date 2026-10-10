-- 07B0_CHECKERS_RULES | ModuleScript | ReplicatedStorage E ServerScriptService | V54 (SUBSTITUIR)
-- Damas brasileiras 64 casas: maioria, tema turco, coroação ao final e empates.
local R={};local dirs={{1,1},{1,-1},{-1,1},{-1,-1}}
local function inside(r,c)return r>=1 and r<=8 and c>=1 and c<=8 end
local function other(c)return c=='W'and'B'or'W'end
local function key(r,c)return r..':'..c end
local function copy(v)if type(v)~='table'then return v end;local out={};for k,x in pairs(v)do out[k]=copy(x)end;return out end
local function captures(board,r,c,taken)
 local p=board[r]and board[r][c];local out={};if not p then return out end;taken=taken or{}
 for _,d in ipairs(dirs)do
  local rr,cc=r+d[1],c+d[2]
  if not p.k then
   local tr,tc=r+d[1]*2,c+d[2]*2;local e=inside(rr,cc)and board[rr][cc]
   if inside(tr,tc)and e and e.c~=p.c and not taken[key(rr,cc)]and not board[tr][tc]then out[#out+1]={fr=r,fc=c,tr=tr,tc=tc,cr=rr,cc=cc,capture=true}end
  else
   local enemy
   while inside(rr,cc)do
    local cell=board[rr][cc]
    if cell then
     if enemy or cell.c==p.c or taken[key(rr,cc)]then break end;enemy={r=rr,c=cc}
    elseif enemy then out[#out+1]={fr=r,fc=c,tr=rr,tc=cc,cr=enemy.r,cc=enemy.c,capture=true}end
    rr,cc=rr+d[1],cc+d[2]
   end
  end
 end
 return out
end
local function captureCopy(board,move,taken)
 local b=copy(board);local seen=copy(taken or{});b[move.tr][move.tc]=b[move.fr][move.fc];b[move.fr][move.fc]=nil
 seen[key(move.cr,move.cc)]=true;return b,seen
end
local function depth(board,r,c,taken)
 local best=0
 for _,m in ipairs(captures(board,r,c,taken))do local b,seen=captureCopy(board,m,taken);best=math.max(best,1+depth(b,m.tr,m.tc,seen))end
 return best
end
local function annotated(board,r,c,taken)
 local list=captures(board,r,c,taken)
 for _,m in ipairs(list)do local b,seen=captureCopy(board,m,taken);m.depth=1+depth(b,m.tr,m.tc,seen)end
 return list
end
local function hash(s)
 local out={s.turn};for r=1,8 do for c=1,8 do local p=s.board[r][c];out[#out+1]=p and(p.c..(p.k and'K'or'P'))or'.'end end;return table.concat(out)
end
function R.New()
 local b={};for r=1,8 do b[r]={};for c=1,8 do if(r+c)%2==1 and(r<=3 or r>=6)then b[r][c]={c=r<=3 and'B'or'W',k=false}end end end
 local s={board=b,turn='W',quiet=0,repetition={},endgame=0};s.repetition[hash(s)]=1;return s
end
function R.Legal(s,r,c)
 local b=s.board;local p=b[r]and b[r][c];if not p or p.c~=s.turn then return{}end
 if s.forced and(s.forced.r~=r or s.forced.c~=c)then return{}end
 local all={};local best=0
 for rr=1,8 do for cc=1,8 do local q=b[rr][cc]
  if q and q.c==s.turn and(not s.forced or rr==r and cc==c)then
   for _,m in ipairs(annotated(b,rr,cc,s.taken))do all[#all+1]=m;best=math.max(best,m.depth)end
  end
 end end
 if best>0 then local out={};for _,m in ipairs(all)do if m.fr==r and m.fc==c and m.depth==best then out[#out+1]=m end end;return out end
 if s.forced then return{}end
 local out={}
 for _,d in ipairs(dirs)do if p.k or d[1]==(p.c=='W'and-1 or 1)then
  local rr,cc=r+d[1],c+d[2];while inside(rr,cc)and not b[rr][cc]do
   out[#out+1]={fr=r,fc=c,tr=rr,tc=cc};if not p.k then break end;rr,cc=rr+d[1],cc+d[2]
  end
 end end;return out
end
local function counts(s)
 local n={W={k=0,p=0},B={k=0,p=0}};local lone
 for r=1,8 do for c=1,8 do local p=s.board[r][c];if p then local a=n[p.c];a[p.k and'k'or'p']=a[p.k and'k'or'p']+1;if p.k then lone=lone or{};lone[p.c]={r=r,c=c}end end end end
 return n,lone or{}
end
local function shortEndgame(s)
 local n,l=counts(s)
 for _,color in ipairs({'W','B'})do local a,b=n[color],n[other(color)]
  if a.k==2 and a.p==0 and(b.k==2 and b.p==0 or b.k==1 and b.p==1)then return true end
  if a.k==1 and a.p==0 then
   if b.k+b.p==1 and b.k==1 or b.k==2 and b.p==0 or b.k==1 and b.p==1 then return true end
   local v=l[color];if b.k+b.p==3 and b.k>=1 and v and v.r+v.c==9 then return true end
  end
 end;return false
end
function R.Apply(s,m)
 local beforeShort=shortEndgame(s)
 local chosen
 for _,v in ipairs(R.Legal(s,m.fr,m.fc))do if v.tr==m.tr and v.tc==m.tc then chosen=v;break end end
 if not chosen then return false,'Lance inválido.'end;m=chosen
 s.endgameActive=s.endgameActive or beforeShort
 local p=s.board[m.fr][m.fc];s.board[m.fr][m.fc]=nil;s.board[m.tr][m.tc]=p
 if m.capture then
  s.taken=s.taken or{};s.taken[key(m.cr,m.cc)]=true;s.quiet=0
  if #captures(s.board,m.tr,m.tc,s.taken)>0 then s.forced={r=m.tr,c=m.tc};return true,'continue'end
  for square in pairs(s.taken)do local r,c=square:match('^(%d+):(%d+)$');s.board[tonumber(r)][tonumber(c)]=nil end
 else s.quiet=p.k and(s.quiet or 0)+1 or 0 end
 if not p.k and(p.c=='W'and m.tr==1 or p.c=='B'and m.tr==8)then p.k=true end
 s.taken=nil;s.forced=nil;s.turn=other(s.turn)
 s.repetition=s.repetition or{};local h=hash(s);s.repetition[h]=(s.repetition[h]or 0)+1
 -- Nestes finais, movimento de pedra ou captura não reinicia a contagem (CBJD).
 if s.endgameActive then s.endgame=(s.endgame or 0)+1
 elseif shortEndgame(s)then s.endgameActive=true;s.endgame=0 end
 return true,'turn'
end
function R.Result(s)
 if s.forced then return nil end
 local has=false
 for r=1,8 do for c=1,8 do if #R.Legal(s,r,c)>0 then has=true;break end end;if has then break end end
 if not has then return other(s.turn),'Sem peças ou movimentos legais'end
 if(s.quiet or 0)>=40 then return'draw','20 lances de damas sem captura nem movimento de pedra'end
 if(s.repetition and s.repetition[hash(s)]or 0)>=3 then return'draw','Tripla repetição'end
 if(s.endgame or 0)>=10 then return'draw','Final reduzido: cinco lances de cada jogador'end
 return nil
end
return R
