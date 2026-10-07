# Validação V52

Base: GitHub `main`, commit `24dad1296cabb261eb67bf1aed5a449f6cac3cf9` (V51). Os arquivos efetivos da V51 e seu manifesto foram comparados com os blobs remotos antes da edição. O handoff completo foi lido; as duas imagens desta solicitação foram abertas.

## Resultado

| Verificação | Resultado |
|---|---|
| Sintaxe das fontes efetivas | 74 fontes Lua 5.4 válidas |
| Cenários novos da entrega | 11 aprovados em `results.json` |
| Fluxos completos e regressões selecionadas | 14 aprovados em `extended_results.json` |
| Partidas de bots dentro dos cenários | 72 concluídas; 3 variantes × 3 níveis × 8 partidas |
| Instalador HTML | JavaScript real com DOM mínimo; hashes e cópia inteira/em partes conferidos |
| Pacote | 23 substituições + 5 novos; 28 itens, no máximo 357 linhas cada |

Os 72 jogos são parte de um cenário, não 72 verificações independentes adicionais. Os 25 cenários desta entrega não incluem todos os testes históricos da V51.

São usados doubles de serviços, instâncias, relógios e geometria, mais o JavaScript real do instalador. `physical_doubles.lua` simula explicitamente os acessórios físicos; não carrega meshes ou cages reais. As reconstruções de layout em `preview_layouts.py` são diagnósticos, não capturas do Roblox.

## Escopo conferido

- Roupas em camadas em R6 selecionam R15; preservação de corpo/roupas, expressão e metadados nativos; remover um item; salvar e respawn; falha atômica e retry; ausência de Handle/WrapLayer rejeitada em prévia e aplicação.
- Comunidade só com pesquisa e filtro, 3/4 colunas, pool de 50 slots; prévia dos avatares salvos com itens embaixo; coordenadas de área segura preservadas.
- Lobby com três jogos, ações separadas e moedas; mesa 2D com quatro jogadores, cartas próprias/públicas separadas; tabuleiros centrados e ampliados.
- Baralhos cheio/limpo/personalizado validados no servidor; partida rápida combina variante e chave do baralho; configuração personalizada salva e excluída da fila normal. As manilhas avançam corretamente dentro do baralho paulista reduzido.
- Regressões das regras de Truco, decisões distintas dos bots, progressão, torneios e deduplicação de recompensas. A distribuição manual está desativada nos novos fluxos.
- Compra direta, duplicação de recibos, falha de persistência sem débito, preservação e resgate dos créditos antigos; nenhuma nova oferta de caixa.
- Três cartas de amostra; imagem/decal validado, sucesso só após IsLoaded, erro e recarregar; transformações e até 12 presets próprios persistidos; salvar proibido após falha de carga.
- Geometria amostrada em 390×844, 851×392, 1920×1080, 667×375 e, no Ateliê/configuração de cartas, 568×320. Controles do Ateliê e seleção de valores/naipes não cruzam Aplicar/Criar/Salvar nesses tamanhos.

## Reproduzir

Na raiz do repositório, com Python, Node.js e a biblioteca Lua 5.4 disponíveis:

```bash
python audits/V52/test_v52.py
python audits/V52/test_extended.py
python audits/V52/build_installer.py
node audits/V52/test_installer_logic.cjs
```

O teste usa fontes V52 quando presentes e o manifesto para os módulos existentes. Os fixtures antigos são reaproveitados como infraestrutura; as regressões selecionadas são executadas com as fontes efetivas novas.

## Teste necessário no Roblox

Conferir roupas em camadas habilitadas no projeto e testar o gato abacaxi, Gumball/meme e corpos realistas no perfil, prévia, personagem e respawn. Os testes não confirmam disponibilidade ou deformação desses assets específicos. Conferir toque físico, notch, controle nativo, câmera 360°, imagens aprovadas e preço/compra nativos. Não foram feitas compras nem publicação do place.

Consulte [INSTALL_V52.md](../../INSTALL_V52.md) e [RESEARCH.md](RESEARCH.md).
