"""Build cumulative V49 replacements from the complete V44 installation."""
from pathlib import Path
from datetime import datetime, timezone, timedelta
import hashlib,json,re
ROOT=Path(__file__).resolve().parents[2]
mp=ROOT/'manifest.json';manifest=json.loads(mp.read_text());base=next(v for v in manifest['versions']if v['id']=='V44')
files={p.stem:p for p in (ROOT/'scripts/V49').glob('*.lua')};assert len(files)==61
changed={s['name']for s in base['scripts']if files[s['name']].read_bytes()!=(ROOT/s['path']).read_bytes()}
changed.update(['08B_AVATAR_DATA','09C5_UGC_STORES','08D_SKIN_STATE']);assert len(changed)==38
originals=[next(s for v in manifest['versions']for s in v['scripts']if s['name']==name)for name in ['08B_AVATAR_DATA','09C5_UGC_STORES','08D_SKIN_STATE']]
specs=[]
for old in base['scripts']+originals:
 if old['name']not in changed:continue
 spec=old.copy();p=files[spec['name']];code=p.read_text();spec.update(action='SUBSTITUIR',path=p.relative_to(ROOT).as_posix(),lines=len(code.splitlines()),sha256=hashlib.sha256(code.encode()).hexdigest(),parts=4 if spec['name']=='09A_SHOP_UI'else 2,hide_full=spec['name']=='09A_SHOP_UI')
 assert spec['lines']<=400 and not re.search(r'(?:\+|-|\*|/|\.\.)=',code)
 specs.append(spec)
new_specs=[dict(name='08B1_BODY_PACKAGES',type='ModuleScript',location='ReplicatedStorage'),dict(name='09B5_AVATAR_RUNTIME',type='ModuleScript',location='ServerScriptService'),dict(name='09C11_AVATAR_CHARACTER',type='LocalScript',location='StarterPlayer > StarterPlayerScripts')]
for spec in new_specs:
 p=files[spec['name']];code=p.read_text();spec.update(action='CRIAR',path=p.relative_to(ROOT).as_posix(),lines=len(code.splitlines()),sha256=hashlib.sha256(code.encode()).hexdigest(),parts=2,hide_full=False);specs.append(spec)
specs.sort(key=lambda s:(s['action']!='CRIAR',s['name']))
old_paths={s['name']:s['path']for v in manifest['versions']if v['id']!='V49'for s in v['scripts']}
delta=sorted(n for n,p in files.items() if n not in old_paths or p.read_bytes()!=(ROOT/old_paths[n]).read_bytes())
assert len(delta)==11
note=('Requer V44 completa e a base original já instaladas. Pare Play. '
 'A V49 tem 3 scripts NOVOS e 38 substituições cumulativas desde V44, incluindo V45 a V48. '
 'Crie primeiro 08B1_BODY_PACKAGES (ModuleScript/ReplicatedStorage), 09B5_AVATAR_RUNTIME (ModuleScript/ServerScriptService) '
 'e 09C11_AVATAR_CHARACTER (LocalScript/StarterPlayer > StarterPlayerScripts). '
 'Depois substitua as fontes indicadas nas instâncias existentes, sem duplicar nomes. '
 '08B_AVATAR_DATA e 08D_SKIN_STATE substituem seus ModuleScripts originais em ReplicatedStorage. '
 'Se já terminou a V48, faça somente os 11 itens da lista de diferenças: 3 criações e 8 substituições. '
 'Se ainda está instalando a V44, termine seus 55 itens primeiro. '
 '09A_SHOP_UI: apague a fonte antiga uma vez e cole as 4 partes V49 em ordem no MESMO ModuleScript. '
 'Os demais têm 2 partes consecutivas. Não misture partes de versões diferentes. '
 'Nenhum passe ou produto adicional; IDs e preços do Roblox mantidos. Consulte INSTALL_V49.md.')
version=dict(id='V49',title='CORPOS COMPLETOS + AVATAR AO ENTRAR + CATÁLOGO',date='2026-10-04',
 summary=('Ao entrar, consulta a aparência equipada da conta no Roblox, sem impor corpo padrão da experiência. '
 'Corpos com meshes próprios recebem estrutura R15 completa; trocar corpo ou rig reconstrói o personagem com posição, movimento, roupas e acessórios preservados. '
 'O servidor confirma peças, proporções e rig efetivos antes de responder sucesso. Falha mantém o avatar anterior; o último look confirmado volta ao reaparecer nesta sessão. '
 'Pacotes usam todas as peças e proporções do outfit nativo, mantendo roupas e acessórios anteriores. '
 'Catálogo tem prévia quadrada, Aplicar verde e ações compactas, itens equipados abaixo com X separado da imagem, duas linhas e quatro/cinco colunas conforme espaço.'),
 install_note=note,
 validation=('61 fontes com até 400 linhas e sem atribuições compostas; 3 criações e 38 substituições cumulativas, 11 itens desde V48. '
 '91 casos Lua 5.4 com serviços simulados e 1 caso do JavaScript real do instalador. '
 '17 casos novos cobrem corpo equipado ao entrar, R6/R15, partes nativas, falhas/readback, corrida de personagem, respawn, câmera/animações e geometria do catálogo. '
 'Não houve teste de meshes, toque ou compras no Roblox real. O corpo específico gato abacaxi ainda precisa de QA equipado na conta, junto a corpos realistas/memes. '
 'IDs e preços não mudam; as coleções continuam sem sorteio.'),scripts=specs)
manifest['latest']='V49';manifest['updated_at']=max(datetime.now(timezone.utc),datetime.fromisoformat(manifest['updated_at'])+timedelta(seconds=1)).isoformat(timespec='seconds')
manifest['versions']=[v for v in manifest['versions']if v['id']!='V49']+[version];mp.write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+'\n')
def safe(v):return json.dumps(v,ensure_ascii=False,separators=(',',':')).replace('<','\\u003c').replace('\u2028','\\u2028').replace('\u2029','\\u2029')
sources={s['path']:(ROOT/s['path']).read_text()for v in [base,version]for s in v['scripts']}
runtime=(ROOT/'audits/V49/installer_runtime.js').read_text()
constants=('const REPO_OWNER="kauanlindo44",REPO_NAME="avatar-plaza-script-hub",BRANCH="main";\n'
 'const RAW=`https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${BRANCH}`;\n'
 'const FALLBACK_MANIFEST='+safe(dict(manifest,versions=[base,version]))+';\n'
 'const FALLBACK_SCRIPTS='+safe(sources)+';\n')
hp=ROOT/'AVATAR_PLAZA_SCRIPT_HUB_PERMANENTE.html';html=re.sub(r'<script>[\s\S]*?</script>',lambda _:'<script>\n'+constants+runtime+'\n</script>',hp.read_text())
html=re.sub(r'inclui a V\d+(?:\.\d+)?(?: e a instalação V44)?','inclui a V49 e a instalação V44',html);hp.write_text(html)
install='# Instalação V49 — Studio Lite\n\n'+note+'\n\n'
install+='Os avisos **(NOVO)** e **(SUBSTITUIR)** pertencem ao instalador, nunca ao nome da instância. O HTML contém V44 e V49 offline e preserva o histórico online. VERSION V41/V44 internos continuam como contratos de compatibilidade.\n\n'
install+='## Se já terminou a V48\n\nSão **11 itens**: **3 NOVOS + 8 substituições**. Pare Play; crie os três novos nas localizações abaixo antes de substituir as fontes restantes. Não reinstale os outros scripts da V48.\n\n'
install+='| Nome | Ação | Tipo | Local | Partes |\n|---|---|---|---|---:|\n'
for n in delta:
 spec=next(s for s in specs if s['name']==n);install+=f'| `{n}` | {"**NOVO**" if spec["action"]=="CRIAR" else "SUBSTITUIR"} | {spec["type"]} | {spec["location"]} | {spec["parts"]} |\n'
install+='\n## Pacote cumulativo desde V44\n\nSe está em V44/V45/V46/V47 ou não sabe quais correções instalou, use os **41 itens** desta tabela: **3 NOVOS + 38 substituições**. A base completa V44 ainda é necessária. Para 09A, cole as quatro partes juntas no mesmo ModuleScript. Nos demais, cole ambas as partes na mesma instância.\n\n'
install+='| Nome | Ação | Tipo | Local | Linhas | Partes |\n|---|---|---|---|---:|---:|\n'
for spec in specs:install+=f'| `{spec["name"]}` | {"**NOVO**" if spec["action"]=="CRIAR" else "SUBSTITUIR"} | {spec["type"]} | {spec["location"]} | {spec["lines"]} | {spec["parts"]} |\n'
install+='\n## O que foi corrigido\n\n'
install+='- Entrada: consulta o HumanoidDescription equipado no perfil Roblox e desliga UseAvatarSettings para a construção desse avatar. Um corpo comprado precisa estar equipado na conta para aparecer automaticamente; possuir o pacote sem equipá-lo não muda o avatar. A correção não faz nenhuma compra.\n'
install+='- Corpo/pacote: usa IDs das seis partes, proporções e animações do outfit nativo. Corpos diferentes continuam usando articulações internas R15. Roupas e acessórios existentes são mantidos ao experimentar um corpo. Pacote incompleto ou indisponível mostra erro em vez de sucesso parcial.\n'
install+='- Aplicar: ao trocar corpo ou rig, cria um personagem nativo completo com o rig escolhido. Mantém posição, vida, velocidade e ferramentas; retoma assento e liga câmera/animações. Confere os IDs, rig, partes e proporções efetivos antes de responder. Se o Roblox não carregar o novo modelo, mantém o anterior.\n'
install+='- Reaparecimento: recupera o último look confirmado durante a mesma sessão. A V49 não salva automaticamente o outfit no perfil Roblox nem entre servidores; use Salvar para guardar seus looks.\n'
install+='- Catálogo: prévia quadrada, duas linhas, cinco colunas em telas largas e quatro quando necessário; miniaturas e Robux legíveis. Aplicar continua em texto verde, com Salvar/Restaurar/Carrinho/Corpo em ícones. Os itens equipados permanecem abaixo com X ao lado da imagem; espaço maior permite mais itens visíveis.\n'
install+='\n## Teste obrigatório no Roblox\n\n'
install+='1. Equipe o gato abacaxi na personalização do Roblox. Entre num servidor novo com todos os 11 itens atualizados. Confira o corpo inteiro, não só o R15 padrão, e o catálogo mostrando o mesmo avatar. Não é necessário comprar novamente para este teste.\n'
install+='2. Experimente um corpo realista e um meme/criatura. Confira frente, costas e lados, camisa/calça/acessórios, proporções e Aplicar. Em seguida remova só um item pelo X.\n'
install+='3. Teste R6 → R15, restaurar e reaparecer após morrer. Confirme câmera, andar, correr/pular, emotes, Photo Mode e retorno à sala de jogos.\n'
install+='4. Em celular retrato/paisagem e desktop, confira duas linhas do catálogo, miniaturas dos itens, X, ações e popup de corpo. Uma falha temporária do Roblox deve mostrar aviso e permitir tentar de novo.\n'
install+='\n**Validação:** 91 casos em Lua 5.4 com serviços simulados + 1 caso do JavaScript real do instalador. Os doubles não carregam meshes reais; não foi possível validar o pacote específico do gato abacaxi no Roblox/Studio Lite daqui. IDs, preços, passes e Developer Products são os mesmos da V48.\n'
(ROOT/'INSTALL_V49.md').write_text(install)
print(json.dumps(dict(latest='V49',scripts=len(specs),create=3,replace=38,delta_from_V48=len(delta),snapshot=len(files),max_lines=max(s['lines']for s in specs),html_bytes=hp.stat().st_size),ensure_ascii=False))
