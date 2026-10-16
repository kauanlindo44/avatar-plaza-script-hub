# Auditoria V66

Base remota conferida: `b07af6cac3395f3f893d4855ce3a3e625a7054b2` (V65). Delta explícito: 24 fontes, 5 criações/19 substituições; histórico preservado. As oito imagens novas foram inspecionadas. [Mudanças e fontes de pesquisa](../../INSTALL_V66.md).

## Reprodução

```sh
python audits/V66/test_fixes.py
python audits/V66/test_interface.py
python audits/V66/test_regressions.py
python audits/V66/test_delta.py
python audits/V66/test_features.py
python audits/V66/build_installer.py
python audits/V66/test_package.py
node audits/V66/test_installer_logic.cjs
```

Os testes usam o runner Lua 5.4 e doubles cumulativos V43–V66 já versionados. `base_manifest.json` registra o manifesto V65 publicado; o builder acrescenta somente V66. `test_package.py` compila as 127 fontes efetivas e confere os hashes da base, dependências, nomes/tipos/locais, máximo de 400 linhas e proprietário único dos recibos. O teste Node executa o JavaScript real com DOM mínimo: cópia integral, reconstrução por partes, rótulos, fallback offline, hashes e estado online. Não renderiza CSS.

## Cobertura

- 13 verificações funcionais de armazenamento, catálogo, patrocínio, IA, avatar e permissões.
- 9 verificações de interface/controladores em seis geometrias.
- 9 regressões de dados, jogos, persistência e reaparecimento.
- 17 verificações herdadas do delta V65, adaptadas ao contrato novo quando necessário.
- 17 verificações novas: ImageId.Value/Color.Value, recusas e limpeza; par servidor/cliente do fundo; clip real de emote; restrição LocalPlayer reproduzida; animação na mesma cópia; giro do modelo sem câmera/chão; 90 estilos; guia de 35 assuntos; ajuda sem quota; listas estilo/preço; exclusão confirmada; base limpa/cores/cancelar/Undo; área segura do painel; ordem de remoção/restauração de Clouds; fallback de música manual e salva; roteamento de perguntas no LocalScript real.

Total: **65 cenários simulados**. As verificações de sintaxe/pacote/instalador são adicionais, sem inflar a contagem de cenários.

O double V65 permitia PlayEmoteAsync em uma cópia e não reproduzia a restrição mostrada nas fotos. V66 lança esse erro para a cópia; o novo código passa por Animator/AnimationId e não chama esse caminho restrito. Este ajuste corrige uma lacuna do teste anterior, mas não transforma o double em motor Roblox. A destruição de uma pasta é verificada; o double antigo não implementa a destruição recursiva nativa de descendentes.

## Limites

Sem Roblox Studio/Player nativo, sem teste de renderização, FPS, deformação/cages, física ou serviços privados. Fixtures de permissão não provam acesso a assets publicados. A imagem, o áudio e o emote continuam sujeitos à permissão/moderação nativa. A interface foi verificada por medidas e eventos simulados, sem captura visual do jogo.

Avisos FoundationProvider/UIBlox das fotos não são tratados como corrigidos. Preços, recibos, produtos, regras e DataStores existentes não foram recriados. Não foi adicionado endpoint externo de IA nem promessa de reconhecer qualquer personagem. A curadoria de estilos usa descrições próprias, com referências comunitárias; o guia usa funções presentes nos scripts.
