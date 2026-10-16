"""Explicit V66 delta on published V65; keep historical versions immutable."""
from pathlib import Path
from datetime import datetime, timezone, timedelta
from zoneinfo import ZoneInfo
import hashlib, json, re

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
BASE = 'b07af6cac3395f3f893d4855ce3a3e625a7054b2'
NEW = {'07P11_EMOTE_RESOLVER': ('ModuleScript', 'ServerScriptService'), '07UI_CHOICE_LIST': ('ModuleScript', 'ReplicatedStorage'), '09C14_NEW_AVATAR': ('ModuleScript', 'ReplicatedStorage'), '09I8_AVATAR_STYLES': ('ModuleScript', 'ReplicatedStorage'), '09I9_GAME_GUIDE': ('ModuleScript', 'ReplicatedStorage')}
EXTERNAL = {}

def safe(obj):
    return json.dumps(obj, ensure_ascii=False, separators=(',', ':')).replace('<', '\\u003c').replace('\u2028', '\\u2028').replace('\u2029', '\\u2029')

def build():
    baseline = json.loads((HERE / 'base_manifest.json').read_text())
    assert baseline['latest'] == baseline['versions'][-1]['id'] == 'V65'
    previous = baseline['versions']
    effective = {s['name']: s for v in previous for s in v['scripts']}
    specs = []
    for path in sorted((ROOT / 'scripts/V66').glob('*.lua')):
        name = path.stem
        data = path.read_bytes()
        lines = len(data.decode().splitlines())
        assert lines <= 400, (name, lines)
        if name in NEW:
            assert name not in effective
            kind, location = NEW[name]
            spec = dict(name=name, type=kind, location=location, action='CRIAR')
        else:
            spec = effective[name].copy() if name in effective else dict(name=name,type=EXTERNAL[name][0],location=EXTERNAL[name][1])
            if name in effective: assert data != (ROOT / spec['path']).read_bytes(), name
            spec['action'] = 'SUBSTITUIR'
        spec.update(path=path.relative_to(ROOT).as_posix(), sha256=hashlib.sha256(data).hexdigest(), lines=lines, parts=2)
        for key in ['hide_full', 'install_note']:
            spec.pop(key, None)
        specs.append(spec)
    specs.sort(key=lambda s: (s['action'] != 'CRIAR', s['type'] != 'ModuleScript', s['name']))
    assert len(specs) == 24
    assert sum(s['action'] == 'CRIAR' for s in specs) == 5
    assert sum(s['action'] == 'SUBSTITUIR' for s in specs) == 19
    reports = [json.loads((HERE / p).read_text()) for p in ['fix_results.json', 'interface_results.json', 'regression_results.json','delta_results.json','feature_results.json']]
    cases = sum(map(len, reports))
    assert cases == 65 and all(x['result'] == 'pass' for r in reports for x in r)
    note = 'Requer V65 completa. V66: 5 módulos NOVOS + 19 SUBSTITUIÇÕES. Pare Play. Crie primeiro os cinco ModuleScripts: 07P11_EMOTE_RESOLVER em ServerScriptService; 07UI_CHOICE_LIST, 09C14_NEW_AVATAR, 09I8_AVATAR_STYLES e 09I9_GAME_GUIDE em ReplicatedStorage. Substitua as 19 fontes completas e reinicie. Não use NOVO/SUBSTITUIR no nome. Nenhum passe/produto novo. Guia: INSTALL_V66.md.'
    version = dict(
        id='V66', title='FUNDOS, EMOTES, ESTILOS E AVATAR DO ZERO — 5 NOVOS / 19 SUBSTITUIÇÕES',
        date=datetime.now(ZoneInfo('America/Sao_Paulo')).date().isoformat(),
        summary='Fundos leem AvatarBackground/ImageId.Value e Color.Value via InsertService no servidor, sem confundir o item com a imagem. Emotes resolvem o AnimationId e usam Animator na mesma cópia, corrigindo a restrição LocalPlayer. Música troca a faixa também após erro manual/salvo e aguarda preferências iniciais. Catálogo gira o avatar mantendo câmera/cenário. Mais de 80 estilos, listas com descrição e orçamento, 35 assuntos de ajuda sem gastar busca de look. Meus looks com quatro ações, menu e confirmação de exclusão; criação do zero com R6/R15/cor e prévia. Mundos mais discretos e restauração de nuvens sem duplicação.',
        install_note=note,
        validation='65 cenários simulados em Lua 5.4, incluindo contratos ImageId/Color e restrição LocalPlayer fotografada, animação por clip, troca automática de áudio, perguntas sem quota, estilos/formulário e avatar do zero. 127 fontes efetivas compiladas, hashes/dependências e JavaScript real do instalador. Seis geometrias numéricas. Motor Roblox, aparência visual, FPS e permissões/serviços reais ainda precisam de teste publicado.',
        scripts=specs)
    m = dict(baseline)
    current = json.loads((ROOT / 'manifest.json').read_text())
    prior_date = datetime.fromisoformat(current['updated_at'])
    m.update(latest='V66', updated_at=max(datetime.now(timezone.utc), prior_date + timedelta(seconds=1)).isoformat(timespec='seconds'), versions=previous + [version])
    (ROOT / 'manifest.json').write_text(json.dumps(m, ensure_ascii=False, indent=2) + '\n')
    embedded = [v for v in m['versions'] if v['id'] in {'V44', 'V55', 'V56', 'V57', 'V58', 'V59', 'V60', 'V61', 'V62', 'V63', 'V64', 'V65', 'V66'}]
    sources = {s['path']: (ROOT / s['path']).read_text() for v in embedded for s in v['scripts']}
    runtime = (ROOT / 'audits/V51/installer_runtime.js').read_text()
    constants = 'const REPO_OWNER="kauanlindo44",REPO_NAME="avatar-plaza-script-hub",BRANCH="main";\nconst RAW=`https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${BRANCH}`;\nconst FALLBACK_MANIFEST=' + safe(dict(m, versions=embedded)) + ';\nconst FALLBACK_SCRIPTS=' + safe(sources) + ';\n'
    hp = ROOT / 'AVATAR_PLAZA_SCRIPT_HUB_PERMANENTE.html'
    html = re.sub(r'<script>[\s\S]*?</script>', lambda _: '<script>\n' + constants + runtime + '\n</script>', hp.read_text())
    meta = '<div class="meta">Abra a versão mais recente e siga CRIAR/SUBSTITUIR. Este arquivo inclui V66, V65, V64, V63, V62, V61, V60, V59, V58, V57, V56, V55 e a instalação V44 para uso sem conexão e verifica novas versões no GitHub. V66: 5 NOVOS + 19 SUBSTITUIÇÕES. O 09A_SHOP_UI permanece somente em 4 partes.</div>'
    html = re.sub(r'<div class="meta">Abra a versão mais recente[\s\S]*?</div>', meta, html, count=1)
    hp.write_text(html)
    (ROOT / 'AVATAR_PLAZA_V66.html').write_text(html)
    intro = '# Instalação V66 — 5 novos + 19 substituições\n\n' + note + '\n\n'
    for action, heading in [('CRIAR', 'Criar primeiro — NOVOS'), ('SUBSTITUIR', 'Substituir nas instâncias existentes')]:
        intro += '## ' + heading + '\n\n| Nome exato | Tipo | Local | Linhas |\n|---|---|---|---:|\n'
        for s in specs:
            if s['action'] == action:
                intro += '| `' + s['name'] + '` | ' + s['type'] + ' | ' + s['location'] + ' | ' + str(s['lines']) + ' |\n'
        intro += '\n'
    (ROOT / 'INSTALL_V66.md').write_text(intro + (HERE / 'INSTALL_DETAILS.md').read_text())
    result = dict(version='V66', base_commit=BASE, items=24, replace=19, create=5, effective_sources=len(effective) + len(NEW) + len(EXTERNAL), max_lines=max(s['lines'] for s in specs), simulated_cases=cases, html_bytes=hp.stat().st_size, prerequisite='Complete V65 already installed')
    (HERE / 'package_results.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(result))

if __name__ == '__main__':
    build()
