"""Explicit V63 delta on published V62; keep historical versions immutable."""
from pathlib import Path
from datetime import datetime, timezone, timedelta
from zoneinfo import ZoneInfo
import hashlib, json, re

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
BASE = '6ee0a6afb665a1a806388b6a6706cd04604af93f'
NEW = {'07G6_WORLD_DETAILS': ('ModuleScript', 'ReplicatedStorage'), '07H8_PLAY_SESSION': ('ModuleScript', 'ReplicatedStorage'), '09B10_SPONSORED_DESTINATIONS': ('ModuleScript', 'ServerScriptService'), '09C11_SPONSOR_FEED': ('ModuleScript', 'ReplicatedStorage'), '09C12_DESTINATION_BROWSER': ('ModuleScript', 'ReplicatedStorage')}

def safe(obj):
    return json.dumps(obj, ensure_ascii=False, separators=(',', ':')).replace('<', '\\u003c').replace('\u2028', '\\u2028').replace('\u2029', '\\u2029')

def build():
    baseline = json.loads((HERE / 'base_manifest.json').read_text())
    assert baseline['latest'] == baseline['versions'][-1]['id'] == 'V62'
    previous = baseline['versions']
    effective = {s['name']: s for v in previous for s in v['scripts']}
    specs = []
    for path in sorted((ROOT / 'scripts/V63').glob('*.lua')):
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
    assert len(specs) == 25
    assert sum(s['action'] == 'CRIAR' for s in specs) == 5
    assert sum(s['action'] == 'SUBSTITUIR' for s in specs) == 20
    reports = [json.loads((HERE / p).read_text()) for p in ['feature_results.json', 'interface_results.json', 'new_feature_results.json', 'new_interface_results.json']]
    cases = sum(map(len, reports))
    assert cases == 32 and all(x['result'] == 'pass' for r in reports for x in r)
    note = ('Requer V62 completa. V63: 5 scripts NOVOS + 20 SUBSTITUIÇÕES. Pare Play, crie primeiro os cinco módulos novos nos locais indicados, substitua as 20 fontes completas e reinicie Play. Não inclua NOVO/SUBSTITUIR no nome da instância. Nenhum passe ou produto novo. Guia: INSTALL_V63.md.')
    version = dict(
        id='V63', title='CORREÇÕES DE LOJA, MÚSICA E PARTIDAS 2D — 5 NOVOS / 20 SUBSTITUIÇÕES',
        date=datetime.now(ZoneInfo('America/Sao_Paulo')).date().isoformat(),
        summary='IA e música com novos layouts. Corrige mutação de filtro readonly no construtor de looks e bloqueio por rótulo de versão no Photo Mode. Patrocínio substitui exemplos um a um, rola em duas direções e acrescenta Jogos/Comunidades apenas com seus IDs iniciais. Mundos ao ar livre com materiais/detalhes/água/luz e limites de partes. Respawn central seguro, Truco virtual sem distrito removido e metas/resumos de sessão nos três jogos.',
        install_note=note,
        validation='32 cenários simulados, 117 fontes efetivas com sintaxe válida, seis geometrias e JavaScript real do instalador. Inclui IA/resposta com catálogo readonly, substituição exata de cards, validação/paginação dos destinos, controles de música/IA, tabuleiro 2D, spawn e cenários ao ar livre. Renderização, FPS, permissões e serviços nativos precisam de teste Roblox.',
        scripts=specs)
    m = dict(baseline)
    current = json.loads((ROOT / 'manifest.json').read_text())
    prior_date = datetime.fromisoformat(current['updated_at'])
    m.update(latest='V63', updated_at=max(datetime.now(timezone.utc), prior_date + timedelta(seconds=1)).isoformat(timespec='seconds'), versions=previous + [version])
    (ROOT / 'manifest.json').write_text(json.dumps(m, ensure_ascii=False, indent=2) + '\n')
    embedded = [v for v in m['versions'] if v['id'] in {'V44', 'V55', 'V56', 'V57', 'V58', 'V59', 'V60', 'V61', 'V62', 'V63'}]
    sources = {s['path']: (ROOT / s['path']).read_text() for v in embedded for s in v['scripts']}
    runtime = (ROOT / 'audits/V51/installer_runtime.js').read_text()
    constants = 'const REPO_OWNER="kauanlindo44",REPO_NAME="avatar-plaza-script-hub",BRANCH="main";\nconst RAW=`https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${BRANCH}`;\nconst FALLBACK_MANIFEST=' + safe(dict(m, versions=embedded)) + ';\nconst FALLBACK_SCRIPTS=' + safe(sources) + ';\n'
    hp = ROOT / 'AVATAR_PLAZA_SCRIPT_HUB_PERMANENTE.html'
    html = re.sub(r'<script>[\s\S]*?</script>', lambda _: '<script>\n' + constants + runtime + '\n</script>', hp.read_text())
    meta = '<div class="meta">Abra a versão mais recente e siga CRIAR/SUBSTITUIR. Este arquivo inclui V63, V62, V61, V60, V59, V58, V57, V56, V55 e a instalação V44 para uso sem conexão e verifica novas versões no GitHub. V63: 5 NOVOS + 20 SUBSTITUIÇÕES. O 09A_SHOP_UI permanece somente em 4 partes.</div>'
    html = re.sub(r'<div class="meta">Abra a versão mais recente[\s\S]*?</div>', meta, html, count=1)
    hp.write_text(html)
    (ROOT / 'AVATAR_PLAZA_V63.html').write_text(html)
    intro = '# Instalação V63 — 5 novos + 20 substituições\n\n' + note + '\n\n'
    for action, heading in [('CRIAR', 'Criar primeiro — NOVOS'), ('SUBSTITUIR', 'Substituir nas instâncias existentes')]:
        intro += '## ' + heading + '\n\n| Nome exato | Tipo | Local | Linhas |\n|---|---|---|---:|\n'
        for s in specs:
            if s['action'] == action:
                intro += '| `' + s['name'] + '` | ' + s['type'] + ' | ' + s['location'] + ' | ' + str(s['lines']) + ' |\n'
        intro += '\n'
    (ROOT / 'INSTALL_V63.md').write_text(intro + (HERE / 'INSTALL_DETAILS.md').read_text())
    result = dict(version='V63', base_commit=BASE, items=25, replace=20, create=5, effective_sources=len(effective) + len(NEW), max_lines=max(s['lines'] for s in specs), simulated_cases=cases, html_bytes=hp.stat().st_size, prerequisite='Complete V62 already installed')
    (HERE / 'package_results.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(result))

if __name__ == '__main__':
    build()
