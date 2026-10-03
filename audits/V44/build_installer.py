"""Build the V44 upgrade, source hashes and offline Studio Lite installer."""
from pathlib import Path
from datetime import datetime, timezone, timedelta
import hashlib
import json
import re

ROOT = Path(__file__).resolve().parents[2]
MP = ROOT / 'manifest.json'
manifest = json.loads(MP.read_text())
legacy = {'07A_CHESS', '07B_CHECKERS', '07C_POISON_POTATO', '07W_WINS_SERVICE'}
existing = {s['name'] for v in manifest['versions'] if v['id'] != 'V44' for s in v['scripts']} | legacy
locals_ = {'07G_HUB_UI', '07H_GAME_UI', '07P_PHOTO_MODE', '09C_SHOP_CLIENT', '07K_TRUCO_CLIENT'}
servers = {'01C_HUB_CHALLENGES', '07A_CHESS', '07B_CHECKERS', '07C_POISON_POTATO',
           '07G_SETTINGS_SERVER', '07K_TRUCO_SERVER', '09B_SHOP_SERVER'}
server_modules = {'07W_WINS_SERVICE', '09B1_AVATAR_DISCOVERY', '09B2_COSPLAY_METADATA',
                  '09B3_PLAYER_INSPECT', '09B4_CURATED_LOOKS', '07K2_TRUCO_MATCH',
                  '07K3_TRUCO_DIRECTORY', '07K4_TRUCO_TABLES', '07K8_CARD_INVENTORY',
                  '07K10_CARD_COMMERCE', '07K11_GAMES_PROGRESS', '07K13_TOURNAMENT_SERVICE'}
files = {p.stem: p for p in (ROOT / 'scripts/V44').glob('*.lua')}
assert len(files) == 55
def category(name):
    return 2 if name in locals_ or name in servers else 1 if name in server_modules else 0
order = sorted(files, key=lambda name: (category(name), name))
specs, sources = [], {}
for name in order:
    path = files[name].relative_to(ROOT).as_posix()
    code = files[name].read_text()
    assert len(code.splitlines()) <= 400
    assert not re.search(r'(?:\+|-|\*|/|\.\.)=', code)
    spec = dict(name=name, type='LocalScript' if name in locals_ else 'Script' if name in servers else 'ModuleScript',
                location='StarterPlayer > StarterPlayerScripts' if name in locals_ else
                'ServerScriptService' if name in servers or name in server_modules else 'ReplicatedStorage',
                action='SUBSTITUIR' if name in existing else 'CRIAR', lines=len(code.splitlines()),
                sha256=hashlib.sha256(code.encode()).hexdigest(), path=path,
                parts=4 if name == '09A_SHOP_UI' else 2, hide_full=name == '09A_SHOP_UI')
    specs.append(spec)
    sources[path] = code
assert sum(s['action'] == 'CRIAR' for s in specs) == 22
note = ('Requer V43 completa e os scripts originais do handoff já instalados. Pare Play. '
        'CRIE 22 instâncias e SUBSTITUA 33 nos locais indicados, sem duplicar nomes. '
        '07A_CHESS, 07B_CHECKERS, 07C_POISON_POTATO e 07W_WINS_SERVICE SUBSTITUEM os originais '
        'que já existem no jogo, embora apareçam pela primeira vez neste repositório. '
        '07C_POISON_POTATO agora desativa o jogo antigo; não mantenha sua cópia ativa. '
        'Mantenha as regras 07A0/07B0 originais no ServerScriptService e as cópias em ReplicatedStorage. '
        '09A_SHOP_UI: apague o código antigo uma vez e cole exatamente as 4 partes, em ordem, '
        'no MESMO ModuleScript. Instale os 55 itens antes de Play. Passes usam os IDs informados '
        'e o preço atual do Roblox, inclusive 2 Robux durante seu teste. Produtos repetíveis '
        'continuam desativados até receber IDs de Developer Product. Caixas oferecem escolha '
        'garantida, sem sorteios. Consulte INSTALL_V44.md e audits/V44/README.md.')
version = dict(id='V44', title='TRUCO + CATÁLOGO + ESTÚDIO + VISUAIS GARANTIDOS', date='2026-10-03',
    summary=('Truco Paulista, Mineiro e Goiano no lugar da batata, com mesas para quatro, '
        'cartas privadas, bots em três níveis, salas entre servidores e torneios semanais gratuitos. '
        'Inventário, nove visuais originais e Ateliê com prévia e ajuste por arraste no celular. '
        'Compras consultam o preço atual; caixas de escolha garantida, sem aleatoriedade paga. '
        'Catálogo com 5 colunas × 2 linhas visíveis em telas horizontais, detalhe sem rolar ações, '
        'carrinho selecionados/outfit, restauração confirmada e prévias 360° maiores e claras. '
        'Photo Mode com manequim direto R6/R15, desfazer/refazer e ambiente sem rolagem. '
        'Configurações, comandos pessoais e permissão de copiar avatar desativada por padrão. '
        'Comunidade com composições consultadas no Roblox, filtros internos de orçamento, '
        '50 cards reciclados e nomes conservadores de seis personagens conhecidos.'),
    install_note=note,
    validation=('55 fontes verificadas: até 400 linhas e sem atribuição composta. '
        '41 casos de lógica/sintaxe em Lua 5.4 com serviços simulados, incluindo 72 partidas '
        'completas de bots; testes de geometria, avatar, compras, privacidade, torneios e recuperação. '
        'Mais 1 caso do JavaScript real do instalador, hashes, cache, fechamento e quatro partes exatas. '
        'Não executado no Studio Lite/Roblox: faltam renderização 3D, toque, compras/assinatura reais, '
        'rate limits e viagem entre servidores. Não existe base pronta de 1 milhão de skins nem '
        'reconhecimento universal de personagens. Revisão técnica não equivale a parecer jurídico.'),
    scripts=specs)
manifest['latest'] = 'V44'
manifest['updated_at'] = max(datetime.now(timezone.utc), datetime.fromisoformat(manifest['updated_at']) + timedelta(seconds=1)).isoformat(timespec='seconds')
manifest['versions'] = [v for v in manifest['versions'] if v['id'] != 'V44'] + [version]
MP.write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + '\n')
def safe(value):
    return json.dumps(value, ensure_ascii=False, separators=(',', ':')).replace('<', '\\u003c').replace('\u2028', '\\u2028').replace('\u2029', '\\u2029')
runtime = (ROOT / 'audits/V43/installer_runtime.js').read_text()
constants = ('const REPO_OWNER="kauanlindo44",REPO_NAME="avatar-plaza-script-hub",BRANCH="main";\n'
    'const RAW=`https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${BRANCH}`;\n'
    'const FALLBACK_MANIFEST=' + safe(dict(manifest, versions=[version])) + ';\n'
    'const FALLBACK_SCRIPTS=' + safe(sources) + ';\n')
hp = ROOT / 'AVATAR_PLAZA_SCRIPT_HUB_PERMANENTE.html'
html = re.sub(r'<script>[\s\S]*?</script>', lambda _: '<script>\n' + constants + runtime + '\n</script>', hp.read_text())
html = re.sub(r'inclui a V\d+(?:\.\d+)?', 'inclui a V44', html)
hp.write_text(html)
install = '# Instalação V44 — Studio Lite\n\n' + note + '\n\n'
install += ('## Antes de instalar\n\n'
    'Faça uma cópia do seu place e pare Play. Esta é uma atualização da V43, não um projeto vazio. '
    'A V43 depende da V42 e dos scripts originais do handoff. Preserve `08B_AVATAR_DATA` e '
    '`08D_SKIN_STATE` V41, `08L_COMMUNITY`, `07P1_CAPTURE_ENGINE`, `07H2_BOT_CLIENT`, '
    '`07H3_CROSS_SERVER_ROOMS`, `07Z_BOARD_VISUALS`, as regras 07A0/07B0 nos dois locais '
    'indicados na V37 e a base que cria `PracaKit`.\n\n'
    'No instalador, abra V44 e copie cada parte no tipo e local da tabela. Para SUBSTITUIR, '
    'use a instância existente e apague sua fonte antiga antes de colar. Para CRIAR, crie '
    'uma única instância com o nome exato. Partes consecutivas pertencem à mesma instância.\n\n'
    'Os sete módulos mantidos com a mesma fonte da V43 também estão no pacote para facilitar '
    'uma instalação coerente. O carrinho e Plus não precisam de passe adicional.\n\n'
    '## Os 55 scripts\n\n| Ação | Nome | Tipo | Local | Linhas |\n|---|---|---|---|---:|\n')
for s in specs:
    install += f'| {s["action"]} | `{s["name"]}` | {s["type"]} | {s["location"]} | {s["lines"]} |\n'
install += ('\n## Compras e primeiro teste\n\n'
    'Os passes 1951234105/1962433436/1966813498 estão associados a Ateliê/Regent/Zenith. '
    'O código não muda preços no painel Roblox. Mantenha os 2 Robux durante o teste. '
    'Caixas e os outros visuais por Robux precisam de Developer Products: seus IDs ficam em '
    '`07K6_CARD_CATALOG.Products`, por enquanto todos zero. Não coloque IDs de Game Pass nesse registro.\n\n'
    'Publique em um place de teste e use duas contas para verificar os itens de QA em '
    '`audits/V44/README.md`. O proprietário pode já possuir seus passes; a compra real '
    'deve ser conferida por uma conta que ainda não tenha o benefício. Não use os testes '
    'simulados como prova de compra real.\n')
(ROOT / 'INSTALL_V44.md').write_text(install)
print(json.dumps(dict(latest='V44', scripts=len(specs), create=22, replace=33,
    max_lines=max(s['lines'] for s in specs), html_bytes=hp.stat().st_size), ensure_ascii=False))
