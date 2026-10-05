"""Package only the eleven V49 changes needed after a complete V48 install."""
from datetime import datetime, timedelta, timezone
from pathlib import Path
import hashlib
import json
import re

ROOT = Path(__file__).resolve().parents[2]
REPLACEMENTS = [
    '08B_AVATAR_DATA', '08D_SKIN_STATE', '09A_SHOP_UI', '09A1_SHOP_LAYOUT',
    '09B_SHOP_SERVER', '09C_SHOP_CLIENT', '09C2_SHOP_CATALOG',
    '09C4_OUTFIT_LIBRARY',
]
CREATIONS = ['08B1_BODY_PACKAGES', '09B5_AVATAR_RUNTIME', '09C11_AVATAR_CHARACTER']


def safe(value):
    return json.dumps(value, ensure_ascii=False, separators=(',', ':')).replace(
        '<', '\\u003c').replace('\u2028', '\\u2028').replace('\u2029', '\\u2029')


def build():
    manifest_path = ROOT / 'manifest.json'
    manifest = json.loads(manifest_path.read_text())
    source_version = next(v for v in manifest['versions'] if v['id'] == 'V49')
    base = next(v for v in manifest['versions'] if v['id'] == 'V44')
    available = {s['name']: s for s in source_version['scripts']}
    target = ROOT / 'scripts/V50'
    target.mkdir(exist_ok=True)
    specs = []
    for name in CREATIONS + REPLACEMENTS:
        spec = available[name].copy()
        data = (ROOT / spec['path']).read_bytes()
        assert hashlib.sha256(data).hexdigest() == spec['sha256'], name
        assert len(data.decode().splitlines()) <= 400, name
        assert spec['action'] == ('CRIAR' if name in CREATIONS else 'SUBSTITUIR')
        path = target / (name + '.lua')
        path.write_bytes(data)
        spec['path'] = path.relative_to(ROOT).as_posix()
        specs.append(spec)
    assert {p.stem for p in target.glob('*.lua')} == set(CREATIONS + REPLACEMENTS)
    note = (
        'Para quem terminou a V48: são somente 11 itens, 8 substituições e 3 NOVOS. '
        'Pare Play. Crie primeiro os três novos nos locais indicados, somente se ainda não existem. '
        'Depois substitua o código dos oito existentes, sem duplicar instâncias. '
        'Se algum destes itens já recebeu o código da V49, pule esse item: a fonte da V50 é idêntica. '
        '09A_SHOP_UI tem 4 partes consecutivas no MESMO ModuleScript; os demais têm 2 partes. '
        'Use apenas o nome do script no Studio, sem (NOVO) ou (SUBSTITUIR). '
        'Consulte INSTALL_V50.md.'
    )
    version = dict(
        id='V50', title='8 SUBSTITUIÇÕES + 3 NOVOS — CORPOS E CATÁLOGO',
        date='2026-10-04',
        summary=(
            'Pacote reduzido para quem terminou a V48: apenas as 8 substituições e os 3 scripts novos '
            'da correção de corpos e do catálogo. O código é o mesmo da V49. '
            'Se já aplicou os 11 itens da V49, esta versão não exige outra instalação.'
        ),
        install_note=note,
        validation=(
            '11 fontes idênticas à V49, todas com até 400 linhas. '
            'Conferência de quantidade, tipos, locais, hashes, cópia e reconstrução das partes no instalador. '
            'A V50 reorganiza a entrega; a validação do jogo permanece a da V49, '
            'com testes simulados e confirmação visual pendente no Roblox real.'
        ), scripts=specs,
    )
    manifest['latest'] = 'V50'
    manifest['updated_at'] = max(
        datetime.now(timezone.utc),
        datetime.fromisoformat(manifest['updated_at']) + timedelta(seconds=1),
    ).isoformat(timespec='seconds')
    manifest['versions'] = [v for v in manifest['versions'] if v['id'] != 'V50'] + [version]
    manifest_path.write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + '\n')
    sources = {s['path']: (ROOT / s['path']).read_text() for v in [base, version] for s in v['scripts']}
    runtime = (ROOT / 'audits/V50/installer_runtime.js').read_text()
    constants = (
        'const REPO_OWNER="kauanlindo44",REPO_NAME="avatar-plaza-script-hub",BRANCH="main";\n'
        'const RAW=`https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${BRANCH}`;\n'
        'const FALLBACK_MANIFEST=' + safe(dict(manifest, versions=[base, version])) + ';\n'
        'const FALLBACK_SCRIPTS=' + safe(sources) + ';\n'
    )
    html_path = ROOT / 'AVATAR_PLAZA_SCRIPT_HUB_PERMANENTE.html'
    html = re.sub(r'<script>[\s\S]*?</script>', lambda _: '<script>\n' + constants + runtime + '\n</script>', html_path.read_text())
    html = re.sub(r'inclui a V\d+(?:\.\d+)?(?: e a instalação V44)?', 'inclui a V50 e a instalação V44', html)
    if '/* COMPACT_INSTALLER */' not in html:
        html = html.replace('</style>', '''/* COMPACT_INSTALLER */
.scriptplace{display:flex;gap:12px;flex-wrap:wrap;margin:10px 0}.scriptplace>span{background:#122437;border:1px solid #315371;border-radius:9px;padding:8px 11px}.scriptplace small{display:block;color:#94b3cc;font-size:10px;font-weight:800;letter-spacing:.7px}.scriptplace b{display:block;font-size:14px;color:#edf8ff}.copyblock{margin-top:10px}.lastline{background:#081320;border:1px solid #24415b;border-radius:8px;padding:8px 10px;margin-bottom:8px}.lastline span{display:block;font-size:10px;font-weight:800;color:#85a7bd;letter-spacing:.7px}.lastline code{display:block;margin-top:3px;font:12px/1.5 Consolas,monospace;color:#c9efff;white-space:pre-wrap;overflow-wrap:anywhere}.copyblock>.btn{min-height:44px;min-width:180px}.partsgrid{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:10px}.partblock{background:#101c2a;border:1px solid #28435d;border-radius:10px;padding:10px;min-width:0}.partblock>b{font-size:12px;color:#e2e9ff}.optionalparts{margin-top:12px}.optionalparts summary{font-size:12px;color:#98b8ce}.partnote{color:#b8ccd9;font-size:12px}textarea[hidden]{display:none}.status.online{font-weight:800}
@media(max-width:620px){.partsgrid{grid-template-columns:1fr}.copyblock>.btn{width:100%}.scriptplace{gap:7px}.scriptplace>span{max-width:100%;overflow-wrap:anywhere}}
</style>''')
    html_path.write_text(html)
    (ROOT / 'AVATAR_PLAZA_V50.html').write_text(html)
    install = '# Instalação V50 — somente 11 itens\n\n'
    install += 'Requer a **V48 completa já instalada**. São **8 substituições + 3 scripts NOVOS**. A V50 contém exatamente o mesmo código destes 11 itens da V49; apenas retira da aba os outros 30 itens cumulativos.\n\n'
    install += '**Se já colocou o código da V49 em algum destes itens, pule esse item.** Se terminou todos os 11 da V49, não há código adicional para instalar.\n\n'
    install += 'Pare Play. Crie os três novos primeiro, apenas se ainda não existem. Em seguida substitua a fonte dos oito existentes. Os rótulos (NOVO)/(SUBSTITUIR) não fazem parte do nome no Studio.\n\n'
    for title, names in [('Criar — 3 NOVOS', CREATIONS), ('Substituir — 8 existentes', REPLACEMENTS)]:
        install += f'## {title}\n\n| Nome | Tipo | Local | Partes |\n|---|---|---|---:|\n'
        for name in names:
            s = next(s for s in specs if s['name'] == name)
            install += f'| `{name}` | {s["type"]} | {s["location"]} | {s["parts"]} |\n'
        install += '\n'
    install += '**09A_SHOP_UI:** apague a fonte antiga uma vez e cole as quatro partes em ordem no mesmo ModuleScript. Nos demais, cole as duas partes em ordem na mesma instância. Preserve nomes, tipos e locais.\n\n'
    install += 'Abra V50 no HTML atualizado. O arquivo tem V50 e a base V44 disponíveis sem conexão; o histórico completo continua no GitHub. Para instalações anteriores à V48, use o pacote cumulativo V49 e [INSTALL_V49.md](INSTALL_V49.md).\n\n'
    install += 'As correções de corpos e catálogo, seus testes simulados e os testes visuais pendentes estão em [audits/V49/README.md](audits/V49/README.md). Esta entrega não muda a lógica do jogo, IDs, passes, produtos nem preços. VERSION V41/V44 internos continuam como contratos de compatibilidade.\n'
    (ROOT / 'INSTALL_V50.md').write_text(install)
    print(json.dumps(dict(latest='V50', scripts=len(specs), replace=8, create=3, max_lines=max(s['lines'] for s in specs), html_bytes=html_path.stat().st_size)))


if __name__ == '__main__':
    build()
