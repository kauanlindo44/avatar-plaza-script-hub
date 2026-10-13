"""Explicit V61 delta on published V60; keep historical versions immutable."""
from pathlib import Path
from datetime import datetime, timezone, timedelta
from zoneinfo import ZoneInfo
import hashlib, json, re

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
BASE = 'd55939d9b0885a4b60ec5fe2c336676d28a42842'
NEW = {
    '07M2_AUDIO_LIBRARY': ('ModuleScript', 'ServerScriptService'),
    '09C9_SPONSOR_PICKER': ('ModuleScript', 'ReplicatedStorage'),
    '07P9_STUDIO_CATALOG': ('ModuleScript', 'ReplicatedStorage'),
    '09C3_CATALOG_FILTERS': ('ModuleScript', 'ReplicatedStorage'),
    '09B9_GLOBAL_LOOKS': ('ModuleScript', 'ServerScriptService'),
    '07G5_CHAT_COMMANDS': ('ModuleScript', 'ReplicatedStorage'),
    '07G4_WORLD_SCENERY': ('ModuleScript', 'ReplicatedStorage'),
    '07H6_GAME_MOMENTS': ('ModuleScript', 'ReplicatedStorage'),
}

def safe(obj):
    return json.dumps(obj, ensure_ascii=False, separators=(',', ':')).replace('<', '\\u003c').replace('\u2028', '\\u2028').replace('\u2029', '\\u2029')

def build():
    baseline = json.loads((HERE / 'base_manifest.json').read_text())
    assert baseline['latest'] == baseline['versions'][-1]['id'] == 'V60'
    previous = baseline['versions']
    effective = {s['name']: s for v in previous for s in v['scripts']}
    specs = []
    for path in sorted((ROOT / 'scripts/V61').glob('*.lua')):
        name = path.stem
        data = path.read_bytes()
        lines = len(data.decode().splitlines())
        assert lines <= 400, (name, lines)
        if name in NEW:
            assert name not in effective
            kind, location = NEW[name]
            spec = dict(name=name, type=kind, location=location, action='CRIAR')
        else:
            spec = effective[name].copy()
            assert data != (ROOT / spec['path']).read_bytes(), name
            spec['action'] = 'SUBSTITUIR'
        spec.update(path=path.relative_to(ROOT).as_posix(), sha256=hashlib.sha256(data).hexdigest(), lines=lines, parts=2)
        for key in ['hide_full', 'install_note']:
            spec.pop(key, None)
        specs.append(spec)
    specs.sort(key=lambda s: (s['action'] != 'CRIAR', s['type'] != 'ModuleScript', s['name']))
    assert len(specs) == 45
    assert sum(s['action'] == 'CRIAR' for s in specs) == 8
    assert sum(s['action'] == 'SUBSTITUIR' for s in specs) == 37
    reports = [json.loads((HERE / p).read_text()) for p in ['feature_results.json', 'interface_results.json']]
    cases = sum(map(len, reports))
    assert cases == 31 and all(x['result'] == 'pass' for r in reports for x in r)
    note = ('Requer V60 completa. V61: 8 scripts NOVOS + 37 SUBSTITUIÇÕES. Pare Play, crie primeiro os oito módulos novos nos locais indicados, substitua as 37 fontes completas e reinicie Play. Não inclua NOVO/SUBSTITUIR no nome da instância. Nenhum passe ou produto novo. Guia: INSTALL_V61.md.')
    version = dict(
        id='V61', title='PATROCINAR + IA DE LOOKS, MÚSICA E COMUNIDADE GLOBAL — 8 NOVOS / 37 SUBSTITUIÇÕES',
        date=datetime.now(ZoneInfo('America/Sao_Paulo')).date().isoformat(),
        summary='Música inicia com biblioteca nativa, fila e volume de 40%. Patrocinar grátis tem exemplos temporários, busca por nome e acesso ao assistente de looks por pesquisa. Comunidade Todos/Grátis reúne publicações e descoberta global persistente, com códigos/preços e arquivo progressivo. Photo Mode testa fundos da loja e emotes na cópia centralizada. Comandos pessoais no chat, mundos locais distintos e chão contínuo em partes reutilizadas. Jogos mantêm resultado, revisão e revanche por consentimento.',
        install_note=note,
        validation='31 cenários simulados; 109 fontes efetivas com sintaxe válida; geometria em seis resoluções; JavaScript real do instalador. Serviços, permissões e renderização reais exigem teste no Roblox. IA é pesquisa de looks com validação, não chat generativo geral. Registro de contas descobertas é persistente; snapshots são verificados e arquivados progressivamente.',
        scripts=specs)
    m = dict(baseline)
    current = json.loads((ROOT / 'manifest.json').read_text())
    prior_date = datetime.fromisoformat(current['updated_at'])
    m.update(latest='V61', updated_at=max(datetime.now(timezone.utc), prior_date + timedelta(seconds=1)).isoformat(timespec='seconds'), versions=previous + [version])
    (ROOT / 'manifest.json').write_text(json.dumps(m, ensure_ascii=False, indent=2) + '\n')
    embedded = [v for v in m['versions'] if v['id'] in {'V44', 'V55', 'V56', 'V57', 'V58', 'V59', 'V60', 'V61'}]
    sources = {s['path']: (ROOT / s['path']).read_text() for v in embedded for s in v['scripts']}
    runtime = (ROOT / 'audits/V51/installer_runtime.js').read_text()
    constants = 'const REPO_OWNER="kauanlindo44",REPO_NAME="avatar-plaza-script-hub",BRANCH="main";\nconst RAW=`https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${BRANCH}`;\nconst FALLBACK_MANIFEST=' + safe(dict(m, versions=embedded)) + ';\nconst FALLBACK_SCRIPTS=' + safe(sources) + ';\n'
    hp = ROOT / 'AVATAR_PLAZA_SCRIPT_HUB_PERMANENTE.html'
    html = re.sub(r'<script>[\s\S]*?</script>', lambda _: '<script>\n' + constants + runtime + '\n</script>', hp.read_text())
    meta = '<div class="meta">Abra a versão mais recente e siga CRIAR/SUBSTITUIR. Este arquivo inclui V61, V60, V59, V58, V57, V56, V55 e a instalação V44 para uso sem conexão e verifica novas versões no GitHub. V61: 8 NOVOS + 37 SUBSTITUIÇÕES. O 09A_SHOP_UI permanece somente em 4 partes.</div>'
    html = re.sub(r'<div class="meta">Abra a versão mais recente[\s\S]*?</div>', meta, html, count=1)
    hp.write_text(html)
    (ROOT / 'AVATAR_PLAZA_V61.html').write_text(html)
    intro = '# Instalação V61 — 8 novos + 37 substituições\n\n' + note + '\n\n'
    for action, heading in [('CRIAR', 'Criar primeiro — NOVOS'), ('SUBSTITUIR', 'Substituir nas instâncias existentes')]:
        intro += '## ' + heading + '\n\n| Nome exato | Tipo | Local | Linhas |\n|---|---|---|---:|\n'
        for s in specs:
            if s['action'] == action:
                intro += '| `' + s['name'] + '` | ' + s['type'] + ' | ' + s['location'] + ' | ' + str(s['lines']) + ' |\n'
        intro += '\n'
    (ROOT / 'INSTALL_V61.md').write_text(intro + (HERE / 'INSTALL_DETAILS.md').read_text())
    result = dict(version='V61', base_commit=BASE, items=45, replace=37, create=8, effective_sources=len(effective) + len(NEW), max_lines=max(s['lines'] for s in specs), simulated_cases=cases, html_bytes=hp.stat().st_size, prerequisite='Complete V60 already installed')
    (HERE / 'package_results.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(result))

if __name__ == '__main__':
    build()
