"""Explicit V67 delta on published V66; keep historical versions immutable."""
from pathlib import Path
from datetime import datetime, timezone, timedelta
from zoneinfo import ZoneInfo
import hashlib, json, re

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
BASE = 'f67f6ff374677908967b3e1408485d6ab595c433'
NEW = {'07G7_ADVENTURE_WORLD': ('ModuleScript', 'ReplicatedStorage'), '08B7_AVATAR_ANIMATIONS': ('ModuleScript', 'ServerScriptService'), '09I10_CHAT_NAV': ('ModuleScript', 'ReplicatedStorage'), '09I11_CONVERSATIONS': ('ModuleScript', 'ServerScriptService')}
EXTERNAL = {}

def safe(obj):
    return json.dumps(obj, ensure_ascii=False, separators=(',', ':')).replace('<', '\\u003c').replace('\u2028', '\\u2028').replace('\u2029', '\\u2029')

def build():
    baseline = json.loads((HERE / 'base_manifest.json').read_text())
    assert baseline['latest'] == baseline['versions'][-1]['id'] == 'V66'
    previous = baseline['versions']
    effective = {s['name']: s for v in previous for s in v['scripts']}
    specs = []
    for path in sorted((ROOT / 'scripts/V67').glob('*.lua')):
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
    assert len(specs) == 36
    assert sum(s['action'] == 'CRIAR' for s in specs) == 4
    assert sum(s['action'] == 'SUBSTITUIR' for s in specs) == 32
    reports = [json.loads((HERE / p).read_text()) for p in ['fix_results.json', 'interface_results.json', 'regression_results.json','delta_results.json','feature_results.json','v67_results.json']]
    cases = sum(map(len, reports))
    assert cases == 84 and all(x['result'] == 'pass' for r in reports for x in r)
    note = 'Requer V66 completa. V67: 4 módulos NOVOS + 32 SUBSTITUIÇÕES. Pare Play. Crie 07G7_ADVENTURE_WORLD e 09I10_CHAT_NAV como ModuleScript em ReplicatedStorage; 08B7_AVATAR_ANIMATIONS e 09I11_CONVERSATIONS como ModuleScript em ServerScriptService. Depois substitua as 32 fontes completas e reinicie. Não acrescente NOVO/SUBSTITUIR aos nomes. Nenhum passe, produto ou chave externa novo. Guia: INSTALL_V67.md.'
    version = dict(
        id='V67', title='FUNDOS, CONVERSAS, AVATARES E TRUCO — 4 NOVOS / 32 SUBSTITUIÇÕES',
        date='2026-10-16',
        summary='Corrige a prova de imagem fora da tela/transparente que rejeitava fundos válidos. Apoio medido pelos pés do rig e protegido contra recálculo tardio; resolve clips equipados, atualiza Animate e repete consultas quando Apply está ocupado. Emotes testáveis na prévia do catálogo pelo Animator. IA com barra lateral, histórico privado, busca, renomear/arquivar/excluir, configurações e cópia textual compartilhável filtrada. Conversa contextual, saudações e ajuda sem gastar busca de look. Truco recomposto a partir da foto 4: mesa oval, jogadores nas bordas, mão em leque e cartas públicas menores. Mapas simples e um vale detalhado separado; spawn com emblema clássico. Halloween opcional até 31/10 no modo automático. Música inicial de piano e fallback; patrocínio de destinos mantém 24 horas; atualizações repetidas do feed usam cache.',
        install_note=note,
        validation='84 cenários simulados em Lua 5.4, incluindo reprodução da falha V66 no carregamento invisível, apoio dos pés, animações equipadas/retry, histórico privado e cópia pública filtrada, sete mundos, tema/data e geometria do novo truco. 131 fontes efetivas, hashes/dependências e JavaScript real do instalador. Motor Roblox, imagens, áudio/animações, física, renderização e FPS reais continuam exigindo teste publicado.',
        scripts=specs)
    m = dict(baseline)
    current = json.loads((ROOT / 'manifest.json').read_text())
    prior_date = datetime.fromisoformat(current['updated_at'])
    m.update(latest='V67', updated_at=max(datetime.now(timezone.utc), datetime(2026,10,17,tzinfo=timezone.utc), prior_date + timedelta(seconds=1)).isoformat(timespec='seconds'), versions=previous + [version])
    (ROOT / 'manifest.json').write_text(json.dumps(m, ensure_ascii=False, indent=2) + '\n')
    embedded = [v for v in m['versions'] if v['id'] in {'V44', 'V55', 'V56', 'V57', 'V58', 'V59', 'V60', 'V61', 'V62', 'V63', 'V64', 'V65', 'V66', 'V67'}]
    sources = {s['path']: (ROOT / s['path']).read_text() for v in embedded for s in v['scripts']}
    runtime = (ROOT / 'audits/V51/installer_runtime.js').read_text()
    constants = 'const REPO_OWNER="kauanlindo44",REPO_NAME="avatar-plaza-script-hub",BRANCH="main";\nconst RAW=`https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${BRANCH}`;\nconst FALLBACK_MANIFEST=' + safe(dict(m, versions=embedded)) + ';\nconst FALLBACK_SCRIPTS=' + safe(sources) + ';\n'
    hp = ROOT / 'AVATAR_PLAZA_SCRIPT_HUB_PERMANENTE.html'
    html = re.sub(r'<script>[\s\S]*?</script>', lambda _: '<script>\n' + constants + runtime + '\n</script>', hp.read_text())
    meta = '<div class="meta">Abra a versão mais recente e siga CRIAR/SUBSTITUIR. Este arquivo inclui V67, V66, V65, V64, V63, V62, V61, V60, V59, V58, V57, V56, V55 e a instalação V44 para uso sem conexão e verifica novas versões no GitHub. V67: 4 NOVOS + 32 SUBSTITUIÇÕES. O 09A_SHOP_UI permanece somente em 4 partes.</div>'
    html = re.sub(r'<div class="meta">Abra a versão mais recente[\s\S]*?</div>', meta, html, count=1)
    hp.write_text(html)
    (ROOT / 'AVATAR_PLAZA_V67.html').write_text(html)
    intro = '# Instalação V67 — 4 novos + 32 substituições\n\n' + note + '\n\n'
    for action, heading in [('CRIAR', 'Criar primeiro — NOVOS'), ('SUBSTITUIR', 'Substituir nas instâncias existentes')]:
        intro += '## ' + heading + '\n\n| Nome exato | Tipo | Local | Linhas |\n|---|---|---|---:|\n'
        for s in specs:
            if s['action'] == action:
                intro += '| `' + s['name'] + '` | ' + s['type'] + ' | ' + s['location'] + ' | ' + str(s['lines']) + ' |\n'
        intro += '\n'
    (ROOT / 'INSTALL_V67.md').write_text(intro + (HERE / 'INSTALL_DETAILS.md').read_text())
    result = dict(version='V67', base_commit=BASE, items=36, replace=32, create=4, effective_sources=len(effective) + len(NEW) + len(EXTERNAL), max_lines=max(s['lines'] for s in specs), simulated_cases=cases, html_bytes=hp.stat().st_size, prerequisite='Complete V66 already installed')
    (HERE / 'package_results.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(result))

if __name__ == '__main__':
    build()
