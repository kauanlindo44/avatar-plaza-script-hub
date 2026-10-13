"""Explicit V62 delta on published V61; keep historical versions immutable."""
from pathlib import Path
from datetime import datetime, timezone, timedelta
from zoneinfo import ZoneInfo
import hashlib, json, re

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
BASE = 'dd885215d58637d426142d912560214c0d07cfe0'
NEW = {'07H7_BOARD_SESSIONS': ('ModuleScript', 'ServerScriptService'), '07P10_VIDEO_MOTION': ('ModuleScript', 'ReplicatedStorage'), '09C10_SPONSOR_DESIGN': ('ModuleScript', 'ReplicatedStorage')}

def safe(obj):
    return json.dumps(obj, ensure_ascii=False, separators=(',', ':')).replace('<', '\\u003c').replace('\u2028', '\\u2028').replace('\u2029', '\\u2029')

def build():
    baseline = json.loads((HERE / 'base_manifest.json').read_text())
    assert baseline['latest'] == baseline['versions'][-1]['id'] == 'V61'
    previous = baseline['versions']
    effective = {s['name']: s for v in previous for s in v['scripts']}
    specs = []
    for path in sorted((ROOT / 'scripts/V62').glob('*.lua')):
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
    assert len(specs) == 28
    assert sum(s['action'] == 'CRIAR' for s in specs) == 3
    assert sum(s['action'] == 'SUBSTITUIR' for s in specs) == 25
    reports = [json.loads((HERE / p).read_text()) for p in ['feature_results.json', 'interface_results.json']]
    cases = sum(map(len, reports))
    assert cases == 20 and all(x['result'] == 'pass' for r in reports for x in r)
    note = ('Requer V61 completa. V62: 3 scripts NOVOS + 25 SUBSTITUIÇÕES. Pare Play, crie primeiro os três módulos novos nos locais indicados, substitua as 25 fontes completas e reinicie Play. Não inclua NOVO/SUBSTITUIR no nome da instância. Nenhum passe ou produto novo. Guia: INSTALL_V62.md.')
    version = dict(
        id='V62', title='CORREÇÕES DE LOJA, MÚSICA E PARTIDAS 2D — 3 NOVOS / 25 SUBSTITUIÇÕES',
        date=datetime.now(ZoneInfo('America/Sao_Paulo')).date().isoformat(),
        summary='Música consulta em segundo plano e usa cache compartilhado, sem bloquear ID/link. Patrocinar tem itens pagos, categorias 2D/3D e rolagem vertical; envio continua grátis. Corrige arrays nativos somente leitura e prioriza pagos no catálogo. Detecta o gerador antigo da IA. Estúdio abre loja de fundos, emotes na cópia e nove movimentos suaves. Xadrez/damas têm sessões 2D com tabuleiro completo, sem assentos ou teleporte. Mundos originais detalhados, com céus/atmosferas e partes limitadas.',
        install_note=note,
        validation='20 cenários simulados; 112 fontes efetivas com sintaxe válida; geometria em seis resoluções; JavaScript real do instalador. Inclui contrato nativo de arrays somente leitura, transmissão de 64 casas, desenho das 32 peças e módulos antigos. Serviços, permissões e renderização reais ainda precisam de teste Roblox.',
        scripts=specs)
    m = dict(baseline)
    current = json.loads((ROOT / 'manifest.json').read_text())
    prior_date = datetime.fromisoformat(current['updated_at'])
    m.update(latest='V62', updated_at=max(datetime.now(timezone.utc), prior_date + timedelta(seconds=1)).isoformat(timespec='seconds'), versions=previous + [version])
    (ROOT / 'manifest.json').write_text(json.dumps(m, ensure_ascii=False, indent=2) + '\n')
    embedded = [v for v in m['versions'] if v['id'] in {'V44', 'V55', 'V56', 'V57', 'V58', 'V59', 'V60', 'V61', 'V62'}]
    sources = {s['path']: (ROOT / s['path']).read_text() for v in embedded for s in v['scripts']}
    runtime = (ROOT / 'audits/V51/installer_runtime.js').read_text()
    constants = 'const REPO_OWNER="kauanlindo44",REPO_NAME="avatar-plaza-script-hub",BRANCH="main";\nconst RAW=`https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${BRANCH}`;\nconst FALLBACK_MANIFEST=' + safe(dict(m, versions=embedded)) + ';\nconst FALLBACK_SCRIPTS=' + safe(sources) + ';\n'
    hp = ROOT / 'AVATAR_PLAZA_SCRIPT_HUB_PERMANENTE.html'
    html = re.sub(r'<script>[\s\S]*?</script>', lambda _: '<script>\n' + constants + runtime + '\n</script>', hp.read_text())
    meta = '<div class="meta">Abra a versão mais recente e siga CRIAR/SUBSTITUIR. Este arquivo inclui V62, V61, V60, V59, V58, V57, V56, V55 e a instalação V44 para uso sem conexão e verifica novas versões no GitHub. V62: 3 NOVOS + 25 SUBSTITUIÇÕES. O 09A_SHOP_UI permanece somente em 4 partes.</div>'
    html = re.sub(r'<div class="meta">Abra a versão mais recente[\s\S]*?</div>', meta, html, count=1)
    hp.write_text(html)
    (ROOT / 'AVATAR_PLAZA_V62.html').write_text(html)
    intro = '# Instalação V62 — 3 novos + 25 substituições\n\n' + note + '\n\n'
    for action, heading in [('CRIAR', 'Criar primeiro — NOVOS'), ('SUBSTITUIR', 'Substituir nas instâncias existentes')]:
        intro += '## ' + heading + '\n\n| Nome exato | Tipo | Local | Linhas |\n|---|---|---|---:|\n'
        for s in specs:
            if s['action'] == action:
                intro += '| `' + s['name'] + '` | ' + s['type'] + ' | ' + s['location'] + ' | ' + str(s['lines']) + ' |\n'
        intro += '\n'
    (ROOT / 'INSTALL_V62.md').write_text(intro + (HERE / 'INSTALL_DETAILS.md').read_text())
    result = dict(version='V62', base_commit=BASE, items=28, replace=25, create=3, effective_sources=len(effective) + len(NEW), max_lines=max(s['lines'] for s in specs), simulated_cases=cases, html_bytes=hp.stat().st_size, prerequisite='Complete V61 already installed')
    (HERE / 'package_results.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(result))

if __name__ == '__main__':
    build()
