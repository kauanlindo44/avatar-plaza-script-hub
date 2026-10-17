# Auditoria V67

Base: V66 publicada, commit `f67f6ff374677908967b3e1408485d6ab595c433`. Delta explícito: **36 fontes = 4 criações + 32 substituições**. Histórico anterior preservado. [Mudanças, instalação e fontes](../../INSTALL_V67.md).

## Reproduzir

```sh
python audits/V67/test_fixes.py
python audits/V67/test_interface.py
python audits/V67/test_regressions.py
python audits/V67/test_delta.py
python audits/V67/test_features.py
python audits/V67/test_v67.py
python audits/V67/build_installer.py
python audits/V67/test_package.py
node audits/V67/test_installer_logic.cjs
```

Runner Lua 5.4 e doubles cumulativos V43–V67. Total: **84 cenários simulados**: 13 funcionais + 9 interfaces + 9 regressões + 17 delta anterior + 17 recursos V66 + 19 verificações V67. Adicionais: 131 fontes efetivas compiladas, hashes/dependências, preservação de recibos/produtos e execução do JavaScript real do instalador com DOM mínimo, sem renderizar CSS.

O double V67 reproduz o descarte de uma ImageLabel fora da tela ou 100% transparente. O teste executa o leitor real V66 e o real V67 contra a mesma referência: o anterior rejeita e o novo aceita sob esse contrato. Isso corrige uma lacuna do teste V66, que permitia IsLoaded em uma prova não renderizável. Não comprova acesso a qualquer imagem privada/moderada do Roblox.

Os testes novos também cobrem apoio pelos pés sem acessórios, recálculo tardio, clips diretos/recipientes, retentativa após Apply ocupado, teste real da função de emote do catálogo, sete mundos, calendário/override de Halloween, histórico privado com escritas agrupadas, cópia pública filtrada/confirmada, arquivo/renomear/excluir, nova navegação em seis telas e cartas/avatares/controles do truco. O retorno repetido do HighlightFeed é cacheado; uma mudança real invalida o cache.

## Limites

Sem motor Roblox Studio/Player, renderização, solver físico, deformação/cages, FPS ou permissões reais. Geometrias numéricas não são capturas visuais do jogo. Os mundos são composições próprias por código; o Vale da aventura tem relevo cenográfico não colidível e preserva o centro plano. Não foi copiada a arte da foto 4, nem afirmada reprodução exata da interface atual do CAC/ChatGPT.

A navegação da IA é inspirada no desktop, mas o motor é um planejador/guia do jogo sem serviço generativo externo. Histórico guarda texto limitado, não modelos 3D antigos. Os registros anteriores do avatar mantêm identificadores compatíveis; a versão do runtime também é exposta nas remotes. A música escolhida é uma candidata consultada na Creator Store e ainda passa pelo verificador nativo. Nenhuma regra de jogo, recibo ou produto comercial foi recriada.
