"""Build cumulative V46 replacements from the complete V44 installation."""
from pathlib import Path
from datetime import datetime, timezone, timedelta
import hashlib,json,re
ROOT=Path(__file__).resolve().parents[2]
mp=ROOT/'manifest.json';manifest=json.loads(mp.read_text());base=next(v for v in manifest['versions']if v['id']=='V44')
files={p.stem:p for p in (ROOT/'scripts/V46').glob('*.lua')};assert len(files)==56
changed={s['name']for s in base['scripts']if files[s['name']].read_bytes()!=(ROOT/s['path']).read_bytes()}
changed.add('08B_AVATAR_DATA');assert len(changed)==30
original=next(s for v in manifest['versions']for s in v['scripts']if s['name']=='08B_AVATAR_DATA')
specs=[]
for old in base['scripts']+[original]:
 if old['name']not in changed:continue
 spec=old.copy();p=files[spec['name']];code=p.read_text();spec.update(action='SUBSTITUIR',path=p.relative_to(ROOT).as_posix(),lines=len(code.splitlines()),sha256=hashlib.sha256(code.encode()).hexdigest(),parts=4 if spec['name']=='09A_SHOP_UI'else 2,hide_full=spec['name']=='09A_SHOP_UI')
 assert spec['lines']<=400 and not re.search(r'(?:\+|-|\*|/|\.\.)=',code)
 specs.append(spec)
note=('Requer V44 completa, com seus 55 scripts e a base original já instalados. Pare Play. '
 'SUBSTITUA estes 30 scripts nas instâncias existentes, sem duplicar nomes. A V46 inclui as correções da V45; não precisa instalar a V45 separadamente. '
 'Nenhuma instância nova, passe ou Developer Product adicional. 08B_AVATAR_DATA também SUBSTITUI o ModuleScript original em ReplicatedStorage. '
 'Se ainda estiver instalando a V44, termine os 55 itens primeiro. '
 '09A_SHOP_UI: apague a fonte antiga uma vez e cole as 4 partes V46, em ordem, no MESMO ModuleScript. '
 'Os demais têm 2 partes consecutivas. Não misture versões. IDs e preços atuais do Roblox permanecem. Consulte INSTALL_V46.md.')
version=dict(id='V46',title='TRUCO LEGÍVEL + ATELIÊ + PHOTO MODE + CATÁLOGO',date='2026-10-04',
 summary=('Truco ajusta a mesa ao espaço livre da tela, permite olhar por arraste, centralizar e escolher qualquer uma das três cartas por toque, teclado ou botão abaixo dela. '
 'Placar acima, ações embaixo, bots mais pausados e gritos TRUCO/SEIS/NOVE/DEZ/DOZE conforme o perfil. '
 'Jogos usam Contra bots; loja inicia em Loja com abas e ações explícitas. Visuais recebem gravuras, coroas, constelações e figuras nos dois lados. '
 'Ateliê tem Carregar/Recarregar, pré-carregamento, fallback nativo e prazo de falha; zoom/arraste não recriam a imagem. '
 'Catálogo mantém cinco colunas e duas linhas em paisagem, abre detalhes compactos e aplica roupas/proporções automaticamente no personagem. '
 'Corpo busca pacotes reais, incluindo gratuitos. Comunidade busca avatares atuais, até 50 no lote inicial, Carregar mais e janela máxima de 100 looks, com descarte dos antigos em grupos de dez. '
 'Photo Mode inclui seleção direta de partes, alças de pose, animação real no cenário, congelar animação, cinco fundos melhorados e luz ajustável.'),
 install_note=note,
 validation=('56 fontes verificadas, 30 substituições, nenhuma criação; fontes até 400 linhas, sem atribuições compostas. '
 '55 casos em Lua 5.4 com serviços simulados e um no JavaScript real do instalador. '
 'Incluem 72 partidas completas, 400 combinações carta/visual, geometria e projeção das cartas em cinco telas e quatro lugares, toque, câmera, preços, persistência, avatar e Photo Mode. '
 'Renderização, toque físico, imagens moderadas, compras e limites de serviços ainda precisam de QA no Roblox/Studio Lite. '
 'Foi analisada a foto enviada e dez quadros de um vídeo público de poses; não foram obtidas dez fotos atuais distintas. '
 'A comunidade consulta perfis reais sob demanda; não é uma coleção pronta nem reconhecimento visual universal de personagens.'),scripts=specs)
manifest['latest']='V46';manifest['updated_at']=max(datetime.now(timezone.utc),datetime.fromisoformat(manifest['updated_at'])+timedelta(seconds=1)).isoformat(timespec='seconds')
manifest['versions']=[v for v in manifest['versions']if v['id']!='V46']+[version];mp.write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+'\n')
def safe(v):return json.dumps(v,ensure_ascii=False,separators=(',',':')).replace('<','\\u003c').replace('\u2028','\\u2028').replace('\u2029','\\u2029')
sources={s['path']:(ROOT/s['path']).read_text()for v in [base,version]for s in v['scripts']}
runtime=(ROOT/'audits/V46/installer_runtime.js').read_text()
constants=('const REPO_OWNER="kauanlindo44",REPO_NAME="avatar-plaza-script-hub",BRANCH="main";\n'
 'const RAW=`https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${BRANCH}`;\n'
 'const FALLBACK_MANIFEST='+safe(dict(manifest,versions=[base,version]))+';\n'
 'const FALLBACK_SCRIPTS='+safe(sources)+';\n')
hp=ROOT/'AVATAR_PLAZA_SCRIPT_HUB_PERMANENTE.html';html=re.sub(r'<script>[\s\S]*?</script>',lambda _:'<script>\n'+constants+runtime+'\n</script>',hp.read_text())
html=re.sub(r'inclui a V\d+(?:\.\d+)?(?: e a instalação V44)?','inclui a V46 e a instalação V44',html);hp.write_text(html)
install='# Instalação V46 — Studio Lite\n\n'+note+'\n\n'
install+='Os títulos exibem **(SUBSTITUIR)**; esse aviso não pertence ao nome da instância. A V46 atualiza a V44 ou a V45 instalada. O HTML contém V44 e V46 offline. Preserve as dependências da [V44](INSTALL_V44.md), substituindo também o `08B_AVATAR_DATA` original pela V46. Os identificadores VERSION V41/V44 internos são contratos de compatibilidade, não sinais de código antigo.\n\n'
install+='| Nome | Ação | Tipo | Local | Linhas | Partes |\n|---|---|---|---|---:|---:|\n'
for s in specs:install+=f'| `{s["name"]}` | SUBSTITUIR | {s["type"]} | {s["location"]} | {s["lines"]} | {s["parts"]} |\n'
install+='\nApós instalar, inicie Play e confira Output. Teste Contra bots no Truco em paisagem: mesa visível, três cartas acima dos botões, câmera por arraste, centralizar, qualquer carta e pausas entre bots. No Ateliê, cole ID/link de imagem pública aprovada, pressione Carregar/Recarregar, ajuste e Salvar e equipar. No catálogo, experimentar, remover item e proporções aplicam no personagem; Restaurar pede confirmação. Em Corpo, verifique os pacotes reais. No Photo Mode, abra Animações em R15, congele e ajuste tocando uma parte ou pelo manequim. Na comunidade, teste Carregar mais, erro/retry, gratuito/pago, X e quatro ângulos. Faça a conferência em place publicado: serviços, compras e renderização nativos não foram executados nesta auditoria.\n'
(ROOT/'INSTALL_V46.md').write_text(install)
print(json.dumps(dict(latest='V46',scripts=len(specs),create=0,replace=len(specs),snapshot=len(files),max_lines=max(s['lines']for s in specs),html_bytes=hp.stat().st_size),ensure_ascii=False))
