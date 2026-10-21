# V73 — correções das fotos e Patrocinar 6 × 4

Base publicada: V72, commit `85194b93107388bdf7bd4334f066424839fe6b06`. **Oito substituições; nenhum script novo.** Fontes históricas, servidores, jogos, recibos e persistência permanecem inalterados.

## Conferência do pedido

| Pedido | Implementação | Evidência / limite |
|---|---|---|
| Corrigir o erro das fotos | A tela da assistente encerra seu ciclo ao ser destruída. Layout/Select antigos não reparentam botões mortos. Clientes duplicados e fontes com nome de destino incorreto são recusados. | O teste reproduz exatamente `Parent property of NewConversation is locked` com a fonte V72 e a semântica documentada de Destroy; a V73 passa. Não comprova todas as fontes instaladas no aparelho. |
| Investigar se faltou script | Catálogo distingue módulo ausente, tipo errado, duplicado, exportação errada e exceção de inicialização. Preserva a causa/traceback e a mostra no Output e no atributo ACP_CatalogDiagnostic. | Cliente completo abre as categorias. Ausência e falha de código produzem diagnósticos distintos. As fotos não contêm a exceção original do catálogo, portanto sua causa anterior continua indeterminada. |
| Conferir possível cópia errada | Incluída fonte própria de 09I_ACTIVITIES_CLIENT, distinta de 09I_ASSISTANT_CLIENT. | A chamada sob o nome das atividades na captura é incompatível com a fonte oficial V69 de 43 linhas, que não cria a assistente. Indício de instalação divergente, sem confirmação do Explorer. |
| Retirar tom preto dos itens | Removido UIGradient da miniatura; ImageColor3 branco e fundo transparente. Cards em quatro cores suaves, texto escuro e preço compacto. | Teste confere a imagem sem gradiente e seus canais RGB originais, sem recoloração sazonal. |
| Usar melhor o espaço / 6 retos e 4 visíveis | Grade de seis colunas e quatro linhas, total de 24 cards completos, rolando verticalmente para os seguintes. | Sete geometrias: 320×568, 390×844, 568×320, 667×375, 851×392 com recorte, 1280×720, 1920×1080. Alvos de card/favorito >=44 px. Exige resultados suficientes. |
| Aproximar da referência enviada | Navegação colorida, busca compacta, imagens maiores dentro de cards menores; prévia à esquerda mais estreita no modo deitado/computador. | Em pé, Avatar abre um painel de prévia com X para permitir seis colunas usando toda a largura. Em cards pequenos, nome completo nos detalhes. |
| Preservar Patrocinar | Busca, categorias, favoritos, exemplos identificados e substituição um por um preservados. Backend de 24h e refresh de mídia 900s inalterado. | Testes do feed e controles mantidos. A grade agora tem seis colunas fixas e rolagem vertical, evitando prateleiras largas vazias. |
| Falhas de música nas fotos | Uma execução do cliente, carregamento tokenizado, pré-carga de URI imutável, fallback espaçado 1,5s, máximo de seis falhas seguidas. | Simulações de faixa recusada, preferida recusada e todas recusadas; sem falso “tocando”. Não concede permissão a áudio que o Roblox recusa. |

## Resultado das verificações

- **150 cenários simulados em dez suítes.** `python audits/V73/run_checks.py`.
- Compilação das **155 fontes efetivas**, hashes, dependências, máximo de **396 linhas** por fonte V73; histórico V72 preservado. `python audits/V73/test_package.py`.
- JavaScript real do instalador, cópia integral, hashes, offline/online e contador separado **1/8 a 8/8 (SUBSTITUIR)**. `node audits/V73/test_installer_logic.cjs` e `node audits/V73/test_counters.cjs`.
- Reconstruções geométricas em [computador](patrocinar_desktop.jpg), [celular em pé](patrocinar_phone.jpg) e [celular deitado](patrocinar_landscape.jpg). Mídia ilustrativa; **não são capturas do motor Roblox**. Gerar com export_layouts.py e render_layouts.py.

O teste de ciclo de vida usa Destroy recursivo e trava de Parent, pois os simuladores antigos não reproduziam essa regra nativa. Esse limite dos testes anteriores permitia que a falha passasse despercebida.

## Conferência ainda nativa

Instalar as oito substituições sobre V72 completa, parar/reiniciar Play, abrir catálogo e uma categoria; conferir Nova conversa, atividades e ausência de scripts duplicados; testar quatro fileiras, favoritos, detalhes, preço e X da prévia no aparelho; confirmar áudios permitidos e o fallback. Sem Studio/motor nativo nesta execução, não afirmamos teste físico, permissões reais, compras ou FPS.

## Referências técnicas

- [Instance.Destroy — Roblox](https://create.roblox.com/docs/reference/engine/classes/Instance): destruição recursiva, trava de Parent e descarte dos eventos.
- [ContentProvider — Roblox](https://create.roblox.com/docs/reference/engine/classes/ContentProvider): pré-carga e status de assets.
- [Sound — Roblox](https://create.roblox.com/docs/reference/engine/classes/Sound): IsLoaded, SoundId e TimeLength.
- [Audio — Roblox](https://create.roblox.com/docs/audio): uso de áudio disponível e permissões. Nenhum serviço pago foi contratado ou ativado.
