let manifest=null,currentVersion=null,timer=null,isRemote=false,viewToken=0,readyVersion=null;
const $=id=>document.getElementById(id);
const saved=(key)=>{try{return localStorage.getItem(key)}catch(e){return null}};
const save=(key,value)=>{try{localStorage.setItem(key,value)}catch(e){}};
function toast(t){const z=$("toast");z.textContent=t;z.style.display="block";clearTimeout(window.__toast);window.__toast=setTimeout(()=>z.style.display="none",1800)}
function esc(s){return String(s??"").replace(/[&<>"']/g,c=>({"&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;","'":"&#39;"}[c]))}
async function request(url){const controller=new AbortController();const timeout=setTimeout(()=>controller.abort(),3500);try{return await fetch(url,{cache:"no-store",signal:controller.signal})}finally{clearTimeout(timeout)}}
function validManifest(m){return m&&Array.isArray(m.versions)&&m.versions.some(v=>v.id===m.latest&&Array.isArray(v.scripts))}
function recentEnough(m){return validManifest(m)&&Date.parse(m.updated_at)>=Date.parse(FALLBACK_MANIFEST.updated_at)}
async function loadManifest(){
 try{
  const r=await request(`${RAW}/manifest.json?t=${Date.now()}`);if(!r.ok)throw Error(`HTTP ${r.status}`);
  const m=await r.json();if(!validManifest(m))throw Error("Manifesto inválido");
  manifest=recentEnough(m)?m:FALLBACK_MANIFEST;isRemote=recentEnough(m);
  if(isRemote)save("ap_manifest_cache",JSON.stringify(m));
  $("net").textContent=isRemote?"ONLINE • sincronizado":`${manifest.latest} disponível neste arquivo`;
 }catch(e){
  let cached;try{cached=JSON.parse(saved("ap_manifest_cache"))}catch(e){}
  manifest=recentEnough(cached)?cached:FALLBACK_MANIFEST;isRemote=false;
  $("net").textContent=manifest===FALLBACK_MANIFEST?`OFFLINE • pacote ${manifest.latest} disponível`:"OFFLINE • usando versão em cache";
 }
 renderVersions();detectNew();
}
async function verifiedCode(code,s,source){
 let verified=false;
 if(crypto?.subtle&&s.sha256){
  const bytes=await crypto.subtle.digest("SHA-256",new TextEncoder().encode(code));
  const hash=Array.from(new Uint8Array(bytes),b=>b.toString(16).padStart(2,"0")).join("");
  if(hash!==s.sha256)throw Error("O arquivo não corresponde ao SHA-256 do manifesto");verified=true;
 }
 return{code,verified,source};
}
async function getText(s){
 if(!/^scripts\/[A-Za-z0-9_.-]+\/[A-Za-z0-9_]+\.lua$/.test(s.path))throw Error("Caminho de script inválido");
 const embedded=FALLBACK_SCRIPTS[s.path],key="ap_source_"+s.sha256;
 if(!isRemote&&embedded!=null)return verifiedCode(embedded,s,"embutido");
 try{
  const r=await request(`${RAW}/${s.path}?t=${Date.now()}`);if(!r.ok)throw Error(`HTTP ${r.status}`);
  const result=await verifiedCode(await r.text(),s,"GitHub");save(key,result.code);return result;
 }catch(e){
  if(embedded!=null)return verifiedCode(embedded,s,"embutido");
  const cached=saved(key);if(cached!=null)return verifiedCode(cached,s,"cache");
  throw Error("Arquivo indisponível. Conecte-se e tente novamente. "+e.message);
 }
}
function installed(){return saved("ap_installed_version")||""}
function detectNew(){
 if(!manifest)return;
 const latest=manifest.latest||"",seen=saved("ap_seen_latest")||"";
 if(latest&&latest!==installed()&&latest!==seen){
  const v=manifest.versions.find(x=>x.id===latest);$("banner").style.display="block";
  $("bannerTitle").textContent=`NOVA VERSÃO ${latest}`;$("bannerText").textContent=v?`${v.title} — ${v.summary||""}`:"Atualização disponível";
 }else $("banner").style.display="none";
}
function renderVersions(){
 const box=$("versions");box.innerHTML="";
 const arr=[...(manifest?.versions||[])].reverse();if(!arr.length){box.textContent="Nenhuma versão disponível.";return}
 for(const v of arr){
  const c=document.createElement("div");c.className="card";
  c.innerHTML=`<span class="tag ${v.id===manifest.latest?"newtag":""}">${v.id===manifest.latest?"MAIS RECENTE":"VERSÃO ANTERIOR"}</span>${v.id===installed()?'<span class="tag">INSTALADA</span>':""}<h2>${esc(v.id)} — ${esc(v.title)}</h2><div class="meta">${esc(v.date||"")}</div><p>${esc(v.summary||"")}</p><div class="meta">${(v.scripts||[]).length} scripts</div><div style="margin-top:10px"><button class="btn purple">ABRIR VERSÃO</button></div>`;
  c.querySelector("button").onclick=()=>openVersion(v.id);box.appendChild(c);
 }
}
function splitCode(code,count){
 const lines=code.match(/[^\n]*\n|[^\n]+$/g)||[];const parts=[];
 for(let i=0;i<count;i++)parts.push(lines.slice(Math.floor(lines.length*i/count),Math.floor(lines.length*(i+1)/count)).join(""));
 if(parts.join("")!==code)throw Error("Divisão do código incompleta");return{lines,parts};
}
async function openVersion(id){
 const v=manifest?.versions.find(x=>x.id===id);if(!v)return;
 const mine=++viewToken;currentVersion=v;readyVersion=null;$("markButton").disabled=true;
 save("ap_seen_latest",manifest.latest||"");$("versionTitle").textContent=`${v.id} — ${v.title}`;$("versionStatus").textContent="CARREGANDO";
 $("overlay").style.display="block";document.body.style.overflow="hidden";
 const out=$("versionContent");out.innerHTML=`<div class="card"><b>${esc(v.summary||"")}</b><p>${esc(v.install_note||"")}</p>${v.validation?`<p class="meta">${esc(v.validation)}</p>`:""}<div class="meta">Os botões de cópia preservam as quebras de linha. Cole cada parte após a anterior, sem apagar o que já colou.</div></div><div id="scriptsLoad" class="empty">Carregando scripts…</div>`;
 try{
  for(const s of v.scripts||[]){
   const result=await getText(s);if(mine!==viewToken)return;const code=result.code;
   const special=s.name==="09A_SHOP_UI",count=special?4:Math.max(1,Math.min(4,Number(s.parts||2))),hideFull=special||s.hide_full===true;
   const {lines,parts}=splitCode(code,count);const sec=document.createElement("section");sec.className="script";sec.dataset.name=s.name;
   let controls=hideFull?`<p><b>COLE AS 4 PARTES EM ORDEM NO MESMO MODULESCRIPT.</b></p>`:`<div class="copyrow"><button class="btn green all">COPIAR SCRIPT INTEIRO</button><button class="btn manual">SELECIONAR INTEIRO</button></div><textarea class="allcode" readonly aria-label="Código completo de ${esc(s.name)}"></textarea>`;
   for(let i=0;i<count;i++)controls+=`<details><summary>PARTE ${i+1}/${count}</summary><div class="copyrow"><button class="btn purple part" data-i="${i}">COPIAR PARTE ${i+1}</button><button class="btn selectpart" data-i="${i}">SELECIONAR PARTE ${i+1}</button></div><textarea class="partarea" data-i="${i}" readonly aria-label="${esc(s.name)} parte ${i+1}"></textarea></details>`;
   const isNew=s.action==="CRIAR",label=isNew?"(NOVO)":"(SUBSTITUIR)";
   sec.innerHTML=`<h3>${esc(s.name)} <span class="tag ${isNew?"newtag":""}">${label}</span></h3><div class="meta"><b>${esc(s.type||"Script")}</b> • ${esc(s.location||"")} • ${lines.length} linhas • ${isNew?"Crie uma instância com este nome.":"Substitua o código da instância existente."}</div><div class="hash">SHA-256 ${result.verified?"verificado":"esperado"}: ${esc(s.sha256||"")}</div><div class="meta">Disponível: ${esc(result.source)}</div>${controls}`;
   if(!hideFull){sec.querySelector(".allcode").value=code;sec.querySelector(".all").onclick=()=>copyText(code,"SCRIPT INTEIRO COPIADO");sec.querySelector(".manual").onclick=()=>selectArea(sec.querySelector(".allcode"))}
   sec.querySelectorAll(".partarea").forEach((a,i)=>a.value=parts[i]);
   sec.querySelectorAll(".part").forEach((b,i)=>b.onclick=()=>copyText(parts[i],`PARTE ${i+1} COPIADA`));
   sec.querySelectorAll(".selectpart").forEach((b,i)=>b.onclick=()=>selectArea(sec.querySelectorAll(".partarea")[i]));
   out.appendChild(sec);
  }
  if(mine!==viewToken)return;$("scriptsLoad")?.remove();readyVersion=v.id;$("markButton").disabled=false;
  $("versionStatus").textContent=v.id===installed()?"INSTALADA":"PACOTE CARREGADO";
 }catch(e){if(mine===viewToken&&$("scriptsLoad"))$("scriptsLoad").textContent="Falha ao carregar: "+e.message}
 detectNew();renderVersions();
}
function closeVersion(){viewToken++;readyVersion=null;$("overlay").style.display="none";document.body.style.overflow="";currentVersion=null}
function openLatest(){if(manifest?.latest)openVersion(manifest.latest)}
function markInstalled(){
 if(!currentVersion||readyVersion!==currentVersion.id){toast("Aguarde todos os scripts carregarem.");return}
 save("ap_installed_version",currentVersion.id);$("versionStatus").textContent="INSTALADA";toast("VERSÃO MARCADA COMO INSTALADA");renderVersions();detectNew();
}
async function copyText(text,msg){
 let ok=false;try{if(navigator.clipboard&&window.isSecureContext){await navigator.clipboard.writeText(text);ok=true}}catch(e){}
 if(!ok){const t=document.createElement("textarea");t.value=text;t.style.position="fixed";t.style.left="-9999px";document.body.appendChild(t);t.focus();t.select();try{ok=document.execCommand("copy")}catch(e){}t.remove()}
 toast(ok?msg:"Use SELECIONAR PARTE e copie manualmente");
}
function selectArea(a){a.closest("details")?.setAttribute("open","");a.focus();a.select();a.setSelectionRange(0,a.value.length);toast("SELECIONADO PARA CÓPIA MANUAL")}
async function checkNow(){await loadManifest();toast(isRemote?"ATUALIZADO":"PACOTE LOCAL DISPONÍVEL")}
function schedule(){if(timer)clearInterval(timer);if($("auto").checked)timer=setInterval(loadManifest,Math.max(5,manifest?.poll_seconds||5)*1000)}
$("auto").addEventListener("change",schedule);window.addEventListener("keydown",e=>{if(e.key==="Escape")closeVersion()});loadManifest().then(schedule);
