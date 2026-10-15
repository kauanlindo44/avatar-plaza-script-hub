"""Explicit V65 delta on published V64; keep historical versions immutable."""
from pathlib import Path
from datetime import datetime, timezone, timedelta
from zoneinfo import ZoneInfo
import hashlib, json, re

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
BASE = 'b1d6048498ad5c7b73b00051b7033f2258cdda02'
NEW = {'07UI_PAN_GRID': ('ModuleScript', 'ReplicatedStorage'), '08B6_AVATAR_MOVEMENT': ('ModuleScript', 'ReplicatedStorage')}
EXTERNAL = {}

def safe(obj):
    return json.dumps(obj, ensure_ascii=False, separators=(',', ':')).replace('<', '\\u003c').replace('\u2028', '\\u2028').replace('\u2029', '\\u2029')

def build():
    baseline = json.loads((HERE / 'base_manifest.json').read_text())
    assert baseline['latest'] == baseline['versions'][-1]['id'] == 'V64'
    previous = baseline['versions']
    effective = {s['name']: s for v in previous for s in v['scripts']}
    specs = []
    for path in sorted((ROOT / 'scripts/V65').glob('*.lua')):
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
    assert len(specs) == 20
    assert sum(s['action'] == 'CRIAR' for s in specs) == 2
    assert sum(s['action'] == 'SUBSTITUIR' for s in specs) == 18
    reports = [json.loads((HERE / p).read_text()) for p in ['fix_results.json', 'interface_results.json', 'regression_results.json','delta_results.json']]
    cases = sum(map(len, reports))
    assert cases == 48 and all(x['result'] == 'pass' for r in reports for x in r)
    note = 'Requer V64 completa. V65: 2 módulos NOVOS em ReplicatedStorage + 18 SUBSTITUIÇÕES. Pare Play, crie primeiro 07UI_PAN_GRID e 08B6_AVATAR_MOVEMENT como ModuleScript em ReplicatedStorage, substitua as fontes completas e reinicie. Não use NOVO/SUBSTITUIR no nome. Nenhum passe/produto novo. Guia: INSTALL_V65.md.'
    version = dict(
        id='V65', title='CORPOS, PHOTO MODE E PRAÇA TRANQUILA — 2 NOVOS / 18 SUBSTITUIÇÕES',
        date=datetime.now(ZoneInfo('America/Sao_Paulo')).date().isoformat(),
        summary='Apoio nativo dos corpos ao trocar altura/rig, sem transferir inclinação ou velocidade; fallback de movimento que cede ao Animate. Emotes mantêm AnimationConstraints cinemáticas, têm confirmação real e reutilizam a cópia ao repetir. Seis cenários próprios, planos e tranquilos, com vegetação nas bordas e sem construções/relevo. Jogos e comunidades patrocinados usam espaço de cabeçalho, duas linhas e navegação XY real com arraste seguro. Música espera conteúdo carregado e tenta outra sugestão se falhar. Looks priorizam camisa/calça antes dos opcionais. Salão de jogos ilustrado, perfis de bots, configurações compactas, HUD sem atalho ambíguo de restaurar e comunidade com maior área para as skins.',
        install_note=note,
        validation='48 cenários simulados em Lua 5.4: troca de altura/momento/apoio e rollback, juntas modernas/pose/emotes, fallback de locomoção, orçamento/peças, destinos XY e gestos, música/conteúdo/falhas, armazenamento/IA e interfaces em seis geometrias. 122 fontes efetivas compiladas, hashes/dependências e JavaScript real do instalador. Motor Roblox, aparência visual, FPS e permissões/serviços reais precisam de teste publicado.',
        scripts=specs)
    m = dict(baseline)
    current = json.loads((ROOT / 'manifest.json').read_text())
    prior_date = datetime.fromisoformat(current['updated_at'])
    m.update(latest='V65', updated_at=max(datetime.now(timezone.utc), prior_date + timedelta(seconds=1)).isoformat(timespec='seconds'), versions=previous + [version])
    (ROOT / 'manifest.json').write_text(json.dumps(m, ensure_ascii=False, indent=2) + '\n')
    embedded = [v for v in m['versions'] if v['id'] in {'V44', 'V55', 'V56', 'V57', 'V58', 'V59', 'V60', 'V61', 'V62', 'V63', 'V64', 'V65'}]
    sources = {s['path']: (ROOT / s['path']).read_text() for v in embedded for s in v['scripts']}
    runtime = (ROOT / 'audits/V51/installer_runtime.js').read_text()
    constants = 'const REPO_OWNER="kauanlindo44",REPO_NAME="avatar-plaza-script-hub",BRANCH="main";\nconst RAW=`https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${BRANCH}`;\nconst FALLBACK_MANIFEST=' + safe(dict(m, versions=embedded)) + ';\nconst FALLBACK_SCRIPTS=' + safe(sources) + ';\n'
    hp = ROOT / 'AVATAR_PLAZA_SCRIPT_HUB_PERMANENTE.html'
    html = re.sub(r'<script>[\s\S]*?</script>', lambda _: '<script>\n' + constants + runtime + '\n</script>', hp.read_text())
    meta = '<div class="meta">Abra a versão mais recente e siga CRIAR/SUBSTITUIR. Este arquivo inclui V65, V64, V63, V62, V61, V60, V59, V58, V57, V56, V55 e a instalação V44 para uso sem conexão e verifica novas versões no GitHub. V65: 2 NOVOS + 18 SUBSTITUIÇÕES. O 09A_SHOP_UI permanece somente em 4 partes.</div>'
    html = re.sub(r'<div class="meta">Abra a versão mais recente[\s\S]*?</div>', meta, html, count=1)
    hp.write_text(html)
    (ROOT / 'AVATAR_PLAZA_V65.html').write_text(html)
    intro = '# Instalação V65 — 2 novos + 18 substituições\n\n' + note + '\n\n'
    for action, heading in [('CRIAR', 'Criar primeiro — NOVOS'), ('SUBSTITUIR', 'Substituir nas instâncias existentes')]:
        intro += '## ' + heading + '\n\n| Nome exato | Tipo | Local | Linhas |\n|---|---|---|---:|\n'
        for s in specs:
            if s['action'] == action:
                intro += '| `' + s['name'] + '` | ' + s['type'] + ' | ' + s['location'] + ' | ' + str(s['lines']) + ' |\n'
        intro += '\n'
    (ROOT / 'INSTALL_V65.md').write_text(intro + (HERE / 'INSTALL_DETAILS.md').read_text())
    result = dict(version='V65', base_commit=BASE, items=20, replace=18, create=2, effective_sources=len(effective) + len(NEW) + len(EXTERNAL), max_lines=max(s['lines'] for s in specs), simulated_cases=cases, html_bytes=hp.stat().st_size, prerequisite='Complete V64 already installed')
    (HERE / 'package_results.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(result))

if __name__ == '__main__':
    build()
