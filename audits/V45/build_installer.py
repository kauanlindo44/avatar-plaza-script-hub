"""Build a 14-script V45 patch, with V44 installation available offline."""
from pathlib import Path
from datetime import datetime, timezone, timedelta
import hashlib,json,re
ROOT=Path(__file__).resolve().parents[2]
mp=ROOT/'manifest.json';manifest=json.loads(mp.read_text());base=next(v for v in manifest['versions']if v['id']=='V44')
files={p.stem:p for p in (ROOT/'scripts/V45').glob('*.lua')}
assert len(files)==55
changed={name for name,p in files.items()if p.read_bytes()!=(ROOT/'scripts/V44'/p.name).read_bytes()}
assert len(changed)==14
specs=[]
for old in base['scripts']:
 if old['name']not in changed:continue
 spec=old.copy();p=files[spec['name']];code=p.read_text();spec.update(action='SUBSTITUIR',path=p.relative_to(ROOT).as_posix(),lines=len(code.splitlines()),sha256=hashlib.sha256(code.encode()).hexdigest())
 assert spec['lines']<=400 and not re.search(r'(?:\+|-|\*|/|\.\.)=',code)
 specs.append(spec)
note=('Requer V44 completa, com os 55 scripts e a base original já instalados. Pare Play. '
 'SUBSTITUA apenas estes 14 scripts nas instâncias existentes; não crie nomes duplicados. '
 'Nenhum script novo, passe ou Developer Product adicional é necessário. '
 'Se ainda estiver instalando a V44, termine os 55 itens antes desta atualização. '
 '09A_SHOP_UI: apague a fonte antiga uma vez e cole as 4 partes da V45, em ordem, no MESMO ModuleScript. '
 'Os outros scripts têm 2 partes consecutivas. Não misture partes de versões diferentes. '
 'Os IDs e preços atuais das compras são mantidos. Consulte INSTALL_V45.md.')
version=dict(id='V45',title='CARTAS COMPLETAS + CÂMERA + ATELIÊ + COMUNIDADE DE JOGADORES',date='2026-10-03',
 summary=('Correção da câmera em primeira pessoa, rosto oculto apenas localmente, mão 3D privada '
 'com três cartas clicáveis e controles de movimento ocultos durante a partida. '
 'Visuais mudam frente, verso e acabamento; rank e naipe permanecem legíveis. '
 'Loja, caixas e visuais usam páginas laterais sem rolagem vertical. '
 'Ateliê aceita ID/link, verifica carregamento da imagem, permite zoom/arraste e salva/equipa. '
 'Escolha dos jogos com cartões de categoria e ações fixas. '
 'Comunidade usa avatares reais de jogadores, deduplica looks, separa itens pagos/gratuitos, '
 'consulta peças/pacotes e mantém duas linhas visíveis. '
 'Catálogo conserva cinco colunas e duas linhas em paisagem, com miniaturas maiores.'),
 install_note=note,
 validation=('55 fontes conferidas; 14 substituições de até 280 linhas, sem atribuição composta. '
 '49 casos de lógica/sintaxe em Lua 5.4 com serviços simulados e 1 do JavaScript real do instalador. '
 'Incluem 72 partidas completas de bots, 400 combinações carta/visual, toque/raycast, '
 'restauração da câmera, geometria em celular/paisagem/desktop, imagem indisponível, '
 'preços nativos, pacotes gratuitos, privacidade e persistência. '
 'Ainda exige QA de renderização, toque real, compras e limites de API no Roblox. '
 'Não há coleção pronta de um milhão de skins, reconhecimento visual universal ou garantia '
 'de que um personagem específico esteja entre os perfis encontrados.'),scripts=specs)
manifest['latest']='V45'
manifest['updated_at']=max(datetime.now(timezone.utc),datetime.fromisoformat(manifest['updated_at'])+timedelta(seconds=1)).isoformat(timespec='seconds')
manifest['versions']=[v for v in manifest['versions']if v['id']!='V45']+[version]
mp.write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+'\n')
def safe(v):return json.dumps(v,ensure_ascii=False,separators=(',',':')).replace('<','\\u003c').replace('\u2028','\\u2028').replace('\u2029','\\u2029')
sources={s['path']:(ROOT/s['path']).read_text()for v in [base,version]for s in v['scripts']}
runtime=(ROOT/'audits/V45/installer_runtime.js').read_text()
constants=('const REPO_OWNER="kauanlindo44",REPO_NAME="avatar-plaza-script-hub",BRANCH="main";\n'
 'const RAW=`https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${BRANCH}`;\n'
 'const FALLBACK_MANIFEST='+safe(dict(manifest,versions=[base,version]))+';\n'
 'const FALLBACK_SCRIPTS='+safe(sources)+';\n')
hp=ROOT/'AVATAR_PLAZA_SCRIPT_HUB_PERMANENTE.html'
html=re.sub(r'<script>[\s\S]*?</script>',lambda _:'<script>\n'+constants+runtime+'\n</script>',hp.read_text())
html=re.sub(r'inclui a V\d+(?:\.\d+)?(?: e a instalação V44)?','inclui a V45 e a instalação V44',html)
hp.write_text(html)
install='# Instalação V45 — Studio Lite\n\n'+note+'\n\n'
install+='Os títulos do HTML exibem **(SUBSTITUIR)**; esse aviso não pertence ao nome da instância. Preserve as dependências da [V44](INSTALL_V44.md). O HTML contém V44 e V45 para instalação offline.\n\n'
install+='| Nome | Ação | Tipo | Local | Linhas | Partes |\n|---|---|---|---|---:|---:|\n'
for s in specs:install+=f'| `{s["name"]}` | SUBSTITUIR | {s["type"]} | {s["location"]} | {s["lines"]} | {s["parts"]} |\n'
install+='\nAo terminar, inicie Play e confira Output. Para verificar a câmera/mão do Truco, entre em Treino; para o Ateliê, use uma imagem pública aprovada e o passe existente. Faça a conferência final em um place publicado, porque DataStore, compras e serviços do Roblox não são reproduzidos integralmente pelo Play do Studio Lite.\n'
(ROOT/'INSTALL_V45.md').write_text(install)
print(json.dumps(dict(latest='V45',scripts=len(specs),create=0,replace=14,snapshot=55,max_lines=max(s['lines']for s in specs),html_bytes=hp.stat().st_size),ensure_ascii=False))
