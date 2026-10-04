"""Build cumulative V47 replacements from the complete V44 installation."""
from pathlib import Path
from datetime import datetime, timezone, timedelta
import hashlib,json,re
ROOT=Path(__file__).resolve().parents[2]
mp=ROOT/'manifest.json';manifest=json.loads(mp.read_text());base=next(v for v in manifest['versions']if v['id']=='V44')
files={p.stem:p for p in (ROOT/'scripts/V47').glob('*.lua')};assert len(files)==56
changed={s['name']for s in base['scripts']if files[s['name']].read_bytes()!=(ROOT/s['path']).read_bytes()}
changed.add('08B_AVATAR_DATA');assert len(changed)==32
original=next(s for v in manifest['versions']for s in v['scripts']if s['name']=='08B_AVATAR_DATA')
specs=[]
for old in base['scripts']+[original]:
 if old['name']not in changed:continue
 spec=old.copy();p=files[spec['name']];code=p.read_text();spec.update(action='SUBSTITUIR',path=p.relative_to(ROOT).as_posix(),lines=len(code.splitlines()),sha256=hashlib.sha256(code.encode()).hexdigest(),parts=4 if spec['name']=='09A_SHOP_UI'else 2,hide_full=spec['name']=='09A_SHOP_UI')
 assert spec['lines']<=400 and not re.search(r'(?:\+|-|\*|/|\.\.)=',code)
 specs.append(spec)
delta=sorted(n for n,p in files.items() if p.read_bytes()!=(ROOT/'scripts/V46'/p.name).read_bytes())
assert len(delta)==18
note=('Requer V44 completa, com seus 55 scripts e a base original já instalados. Pare Play. '
 'SUBSTITUA estes 32 scripts nas instâncias existentes, sem duplicar nomes. A V47 inclui V45 e V46; não precisa instalá-las separadamente. '
 'Nenhuma instância nova, passe ou Developer Product adicional. 08B_AVATAR_DATA também SUBSTITUI o ModuleScript original em ReplicatedStorage. '
 'Se ainda estiver instalando a V44, termine os 55 itens primeiro. '
 '09A_SHOP_UI: apague a fonte antiga uma vez e cole as 4 partes V47, em ordem, no MESMO ModuleScript. '
 'Os demais têm 2 partes consecutivas. Não misture partes de versões diferentes. Quem já terminou a V46 pode substituir apenas os 18 nomes da lista de diferenças em INSTALL_V47.md. '
 'IDs e preços atuais do Roblox permanecem. Consulte INSTALL_V47.md.')
version=dict(id='V47',title='JOGOS NO TOPO + ATELIÊ + COMUNIDADE + ESTÚDIO VIVO',date='2026-10-04',
 summary=('Xadrez, Damas e Truco ficam no topo em retrato e paisagem, com opções compactas para criar/entrar em sala, jogar online ou contra bots e fundo carvão. '
 'Caixas têm embalagem própria com tampa, selo e volume; os visuais preservam rank e naipe. '
 'Ateliê verifica Image/Decal no servidor, resolve a textura quando permitido, exibe a imagem nos dois lados da carta e só libera salvar depois do carregamento. '
 'Comunidade continua carregando avatares reais mesmo se a consulta de nomes falhar; cache, cota global conservadora e recuperação evitam consultas repetidas. '
 'O primeiro lote mantém até 50 looks, Carregar mais reaproveita os recebidos, a janela de 100 recicla os antigos em grupos de dez, com até três linhas visíveis quando há altura suficiente. '
 'Catálogo aproveita a faixa inferior mantendo o recorte físico do dispositivo, duas linhas de itens e mais espaço de prévia. '
 'Photo Mode tem ferramentas laterais, emotes no avatar do cenário, luz e pose sem rolagem e cinco ambientes originais com camadas, detalhes e movimento.'),
 install_note=note,
 validation=('56 fontes verificadas, 32 substituições cumulativas, 18 alterações desde V46 e nenhuma criação; fontes até 400 linhas, sem atribuições compostas. '
 '67 casos em Lua 5.4 com serviços simulados e um no JavaScript real do instalador. '
 'Incluem falhas HTTP/serviços, tipo e textura de imagens, cancelamento/timeout, lotes de looks, retomada, cotas, 72 partidas completas e 400 combinações carta/visual. '
 'Geometria, controles e câmera foram verificados em várias telas. Os cinco cenários têm 58 a 144 partes e no máximo 20 elementos móveis. '
 'As três fotos enviadas foram analisadas. Renderização, toque físico, emotes, imagens moderadas e compras ainda exigem QA no Roblox/Studio Lite. '
 'A comunidade consulta perfis reais sob demanda; não é uma coleção pronta nem reconhecimento visual universal de personagens.'),scripts=specs)
manifest['latest']='V47';manifest['updated_at']=max(datetime.now(timezone.utc),datetime.fromisoformat(manifest['updated_at'])+timedelta(seconds=1)).isoformat(timespec='seconds')
manifest['versions']=[v for v in manifest['versions']if v['id']!='V47']+[version];mp.write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+'\n')
def safe(v):return json.dumps(v,ensure_ascii=False,separators=(',',':')).replace('<','\\u003c').replace('\u2028','\\u2028').replace('\u2029','\\u2029')
sources={s['path']:(ROOT/s['path']).read_text()for v in [base,version]for s in v['scripts']}
runtime=(ROOT/'audits/V47/installer_runtime.js').read_text()
constants=('const REPO_OWNER="kauanlindo44",REPO_NAME="avatar-plaza-script-hub",BRANCH="main";\n'
 'const RAW=`https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${BRANCH}`;\n'
 'const FALLBACK_MANIFEST='+safe(dict(manifest,versions=[base,version]))+';\n'
 'const FALLBACK_SCRIPTS='+safe(sources)+';\n')
hp=ROOT/'AVATAR_PLAZA_SCRIPT_HUB_PERMANENTE.html';html=re.sub(r'<script>[\s\S]*?</script>',lambda _:'<script>\n'+constants+runtime+'\n</script>',hp.read_text())
html=re.sub(r'inclui a V\d+(?:\.\d+)?(?: e a instalação V44)?','inclui a V47 e a instalação V44',html);hp.write_text(html)
install='# Instalação V47 — Studio Lite\n\n'+note+'\n\n'
install+='Os títulos exibem **(SUBSTITUIR)**; esse aviso não pertence ao nome da instância. **0 scripts NOVOS**. O HTML contém V44 e V47 offline e preserva o histórico online. Preserve as dependências da [V44](INSTALL_V44.md). Os identificadores VERSION V41/V44 internos são contratos de compatibilidade.\n\n'
install+='## Se já terminou a V46\n\nSubstitua somente estes **18 scripts** pela fonte V47. Pare Play antes. Use as mesmas instâncias, tipos e locais da tabela abaixo; apague a fonte antiga uma vez e cole todas as partes do script.\n\n'
for n in delta: install+='- `'+n+'` — **SUBSTITUIR**\n'
install+='\n## Pacote completo de substituições desde V44\n\nSe está na V44/V45 ou não sabe quais correções já instalou, substitua os **32** nomes desta tabela. A V47 contém as correções anteriores.\n\n'
install+='| Nome | Ação | Tipo | Local | Linhas | Partes |\n|---|---|---|---|---:|---:|\n'
for s in specs:install+=f'| `{s["name"]}` | SUBSTITUIR | {s["type"]} | {s["location"]} | {s["lines"]} | {s["parts"]} |\n'
install+='\n## Conferência no jogo\n\n'
install+='1. Jogos: escolha Xadrez, Damas e Truco no topo; veja Criar / entrar e Contra bots. Confira o código e Cancelar espera em paisagem.\n'
install+='2. Baralhos: Caixa Nox/Reign/Eclipse deve ter embalagem, diferente da carta. Em Ateliê, cole um ID/link de Image ou Decal publicado, pressione Carregar e espere a imagem aparecer. Ajuste recorte, veja frente/verso e pressione Salvar e equipar. Cliente e servidor devem estar ambos na V47. O carregamento de Decal respeita as permissões atuais da Roblox; nenhuma configuração para importar modelos de terceiros é habilitada.\n'
install+='3. Catálogo: confira a faixa inferior, duas linhas legíveis, prévia ampliada, itens removíveis por X e aplicação sem apagar acessórios não editados.\n'
install+='4. Comunidade: confira os quatro filtros visíveis, até três linhas conforme altura e Carregar mais. Os lotes restantes devem ser reaproveitados; erros devem mostrar uma tentativa, sem nomes de scripts. Somente descrições reais e distintas são exibidas.\n'
install+='5. Photo Mode: abra cada ferramenta lateral. Em R15, escolha um emote e veja o avatar no cenário se mover; pare/congele e edite a pose. Teste Galeria Aurora, Ilhas Celestes, Costa Dourada, Jardim Sakura e Cidade Prisma, rotação, luz, pausar cenário, ocultar UI e sair.\n'
install+='\nOs 68 testes são simulados, exceto a execução real do JavaScript do instalador. Renderização, toque físico, imagens aprovadas, emotes e compras exigem teste no Roblox/Studio Lite/place publicado. Esta atualização não faz compras nem muda preços do painel.\n'
(ROOT/'INSTALL_V47.md').write_text(install)
print(json.dumps(dict(latest='V47',scripts=len(specs),create=0,replace=len(specs),delta_from_V46=len(delta),snapshot=len(files),max_lines=max(s['lines']for s in specs),html_bytes=hp.stat().st_size),ensure_ascii=False))
