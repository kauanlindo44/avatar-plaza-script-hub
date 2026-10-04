"""Build cumulative V48 replacements from the complete V44 installation."""
from pathlib import Path
from datetime import datetime, timezone, timedelta
import hashlib,json,re
ROOT=Path(__file__).resolve().parents[2]
mp=ROOT/'manifest.json';manifest=json.loads(mp.read_text());base=next(v for v in manifest['versions']if v['id']=='V44')
files={p.stem:p for p in (ROOT/'scripts/V48').glob('*.lua')};assert len(files)==57
changed={s['name']for s in base['scripts']if files[s['name']].read_bytes()!=(ROOT/s['path']).read_bytes()}
changed.update(['08B_AVATAR_DATA','09C5_UGC_STORES']);assert len(changed)==36
originals=[next(s for v in manifest['versions']for s in v['scripts']if s['name']==name)for name in ['08B_AVATAR_DATA','09C5_UGC_STORES']]
specs=[]
for old in base['scripts']+originals:
 if old['name']not in changed:continue
 spec=old.copy();p=files[spec['name']];code=p.read_text();spec.update(action='SUBSTITUIR',path=p.relative_to(ROOT).as_posix(),lines=len(code.splitlines()),sha256=hashlib.sha256(code.encode()).hexdigest(),parts=4 if spec['name']=='09A_SHOP_UI'else 2,hide_full=spec['name']=='09A_SHOP_UI')
 assert spec['lines']<=400 and not re.search(r'(?:\+|-|\*|/|\.\.)=',code)
 specs.append(spec)
old_paths={s['name']:s['path']for v in manifest['versions']if v['id']!='V48'for s in v['scripts']}
delta=sorted(n for n,p in files.items() if p.read_bytes()!=(ROOT/old_paths[n]).read_bytes())
assert len(delta)==19
note=('Requer V44 completa, com seus 55 scripts e a base original já instalados. Pare Play. '
 'SUBSTITUA estes 36 scripts nas instâncias existentes, sem duplicar nomes. A V48 inclui V45, V46 e V47; não precisa instalá-las separadamente. '
 'Nenhuma instância nova, passe ou Developer Product adicional. 08B_AVATAR_DATA também SUBSTITUI o ModuleScript original em ReplicatedStorage. '
 'Se ainda estiver instalando a V44, termine os 55 itens primeiro. '
 '09A_SHOP_UI: apague a fonte antiga uma vez e cole as 4 partes V48, em ordem, no MESMO ModuleScript. '
 'Os demais têm 2 partes consecutivas. Não misture partes de versões diferentes. Quem já terminou a V47 pode substituir apenas os 19 nomes da lista de diferenças em INSTALL_V48.md. '
 'IDs e preços atuais do Roblox permanecem. Consulte INSTALL_V48.md.')
version=dict(id='V48',title='JOGOS PRETO/VERDE + TRUCO 2D + LIMITEDS + AVATARES',date='2026-10-04',
 summary=('Jogos refeitos em preto/verde ocupam a área disponível: categorias no topo, partida rápida, sala/código, bots e torneios. '
 'Truco agora é 2D, com as quatro posições da mesa, três cartas próprias legíveis, placar e ações fixas; regras/mãos privadas continuam validadas pelo servidor. '
 'Todos os visuais de carta ganharam arte frontal/verso própria. Cada coleção mostra seus visuais antes de pagar; a escolha conhecida é entregue assim que a compra é confirmada no servidor, sem sorteio. '
 'Ateliê tem sucesso verde ou falha vermelha; permissões, moderação e conexão são possibilidades, sem diagnóstico inventado. '
 'Catálogo destaca SUBCATEGORIA, prioriza corpos pagos, mantém corpos grátis e inclui busca por memes/criaturas. Pacotes de corpo carregam proporções nativas sem apagar roupas/acessórios existentes. '
 'Lojas UGC vira vitrine Limiteds com filtro nativo e verificação por item. Comunidade tem até três colunas, duas linhas maiores e recuperação de falhas; detalhes do look mostram miniatura/nome dos itens e abrem metadados ao toque. '
 'Photo Mode mantém cinco ambientes originais mais detalhados, painéis organizados e nenhum bloco inferior com o nome do fundo.'),
 install_note=note,
 validation=('57 fontes verificadas, 36 substituições cumulativas, 19 alterações desde V47 e nenhuma criação; fontes até 400 linhas, sem atribuições compostas. '
 '76 casos em Lua 5.4 com serviços simulados e um no JavaScript real do instalador. '
 'Incluem falhas HTTP/serviços, tipo e textura de imagens, cancelamento/timeout, lotes de looks, retomada, cotas, 72 partidas completas e 400 combinações carta/visual. '
 'Geometria, controles e câmera foram verificados em várias telas. Os cinco cenários têm 72 a 159 partes e no máximo 20 elementos móveis. '
 'Pesquisa visual pública feita nesta versão; não foram localizadas cinco fotos verificáveis de cada fundo do CAC. Renderização, toque físico, emotes, imagens moderadas e compras ainda exigem QA no Roblox/Studio Lite. '
 'A comunidade consulta perfis reais sob demanda; não é uma coleção pronta nem reconhecimento visual universal de personagens.'),scripts=specs)
manifest['latest']='V48';manifest['updated_at']=max(datetime.now(timezone.utc),datetime.fromisoformat(manifest['updated_at'])+timedelta(seconds=1)).isoformat(timespec='seconds')
manifest['versions']=[v for v in manifest['versions']if v['id']!='V48']+[version];mp.write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+'\n')
def safe(v):return json.dumps(v,ensure_ascii=False,separators=(',',':')).replace('<','\\u003c').replace('\u2028','\\u2028').replace('\u2029','\\u2029')
sources={s['path']:(ROOT/s['path']).read_text()for v in [base,version]for s in v['scripts']}
runtime=(ROOT/'audits/V48/installer_runtime.js').read_text()
constants=('const REPO_OWNER="kauanlindo44",REPO_NAME="avatar-plaza-script-hub",BRANCH="main";\n'
 'const RAW=`https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${BRANCH}`;\n'
 'const FALLBACK_MANIFEST='+safe(dict(manifest,versions=[base,version]))+';\n'
 'const FALLBACK_SCRIPTS='+safe(sources)+';\n')
hp=ROOT/'AVATAR_PLAZA_SCRIPT_HUB_PERMANENTE.html';html=re.sub(r'<script>[\s\S]*?</script>',lambda _:'<script>\n'+constants+runtime+'\n</script>',hp.read_text())
html=re.sub(r'inclui a V\d+(?:\.\d+)?(?: e a instalação V44)?','inclui a V48 e a instalação V44',html);hp.write_text(html)
install='# Instalação V48 — Studio Lite\n\n'+note+'\n\n'
install+='Os títulos exibem **(SUBSTITUIR)**; esse aviso não pertence ao nome da instância. **0 scripts NOVOS**. O HTML contém V44 e V48 offline e preserva o histórico online. Preserve as dependências da [V44](INSTALL_V44.md). Os identificadores VERSION V41/V44 internos são contratos de compatibilidade.\n\n'
install+='## Se já terminou a V47\n\nSubstitua somente estes **19 scripts** pela fonte V48. Pare Play antes. Use as mesmas instâncias, tipos e locais da tabela abaixo; apague a fonte antiga uma vez e cole todas as partes do script.\n\n'
for n in delta: install+='- `'+n+'` — **SUBSTITUIR**\n'
install+='\n## Pacote completo de substituições desde V44\n\nSe está na V44/V45 ou não sabe quais correções já instalou, substitua os **36** nomes desta tabela. A V48 contém as correções anteriores.\n\n'
install+='| Nome | Ação | Tipo | Local | Linhas | Partes |\n|---|---|---|---|---:|---:|\n'
for s in specs:install+=f'| `{s["name"]}` | SUBSTITUIR | {s["type"]} | {s["location"]} | {s["lines"]} | {s["parts"]} |\n'
install+='\n## Conferência no jogo\n\n'
install+='1. Jogos: escolha Xadrez, Damas e Truco no topo. Confira Partida rápida, Criar / entrar, Contra bots, três dificuldades, código e Cancelar espera em retrato/paisagem. O painel preto/verde deve ocupar a altura disponível sem sobrepor controles nativos.\n'
install+='2. Truco 2D: veja as quatro posições públicas da mesa, suas três cartas, placar e ações inferiores. Jogue qualquer carta própria na sua vez; teste Truco, Correr, carta coberta, variantes e gritos. Nenhuma carta privada adversária pode aparecer. Não deve existir câmera dentro do rosto ou mão 3D na tela.\n'
install+='3. Baralhos: caixas Nox/Reign/Eclipse têm embalagem própria. Antes de pagar, veja os três visuais e escolha um; cada opção mostra 100% ao escolher, sem sorteio. Após a confirmação efetiva do servidor, o visual escolhido deve aparecer recebido; cancelar a compra não entrega nada. Veja todas as frentes/versos e Meus visuais. Uma caixa já existente pode ser aberta pelo inventário.\n'
install+='4. Ateliê: cole um ID/link de Image ou Decal publicado, pressione Carregar e confira sucesso verde ou falha vermelha. Uma falha genérica pode ser permissão, moderação ou conexão; o aviso não deve afirmar uma causa que o Roblox não informou. Teste Recarregar, zoom, arraste, frente/verso e Salvar e equipar. Cliente e servidor devem estar ambos atualizados. Carregamento de Decal respeita permissões nativas e não habilita importação de modelos de terceiros.\n'
install+='5. Catálogo: confira SUBCATEGORIA destacado, corpos pagos primeiro, CORPOS GRÁTIS e MEMES / CRIATURAS. Teste um corpo de proporções incomuns na prévia 360 graus e no personagem do jogo. Roupa aplicada não deve apagar acessórios não editados. Confira também as duas linhas, faixa inferior, carrinho e X de remoção.\n'
install+='6. Limiteds: o botão antigo de Lojas UGC agora abre Limiteds, com aparência dourada e cards horizontais. Busca, Popular / Menor preço e Carregar mais só devem mostrar itens comprovadamente Limited/Collectible. Uma consulta sem resultados pode ficar vazia, sem inserir itens comuns.\n'
install+='7. Comunidade: confira Todos, Robux, Grátis e Publicados, até três colunas e duas linhas maiores e Carregar mais. Após falha temporária, deve haver nova tentativa sem apagar looks já carregados. Ao abrir um look, veja itens com imagem e nome; toque no item para preço, descrição, Experimentar e Carrinho. Teste X de fechar/remover e rotação da prévia.\n'
install+='8. Photo Mode: abra cada ferramenta lateral. Em R15, escolha um emote e veja o avatar no cenário se mover; pare/congele e edite a pose. Teste Galeria Aurora, Ilhas Celestes, Costa Dourada, Jardim Sakura e Cidade Prisma, rotação, luz, pausar cenário, ocultar UI e sair. Ao fechar ferramentas, não deve permanecer um bloco inferior com o nome do fundo. Estes cinco cenários são originais; a pesquisa pública não encontrou cinco fotos verificáveis de cada fundo do CAC.\n'
install+='\nOs 77 testes são simulados, exceto a execução real do JavaScript do instalador. Renderização, toque físico, imagens aprovadas, emotes e compras exigem teste no Roblox/Studio Lite/place publicado. Esta atualização não faz compras nem muda preços do painel.\n'
(ROOT/'INSTALL_V48.md').write_text(install)
print(json.dumps(dict(latest='V48',scripts=len(specs),create=0,replace=len(specs),delta_from_V47=len(delta),snapshot=len(files),max_lines=max(s['lines']for s in specs),html_bytes=hp.stat().st_size),ensure_ascii=False))
