# Auditoria V49 — corpo nativo e catálogo

Base conferida: GitHub main V48 `0f66b71e205282905a5b778e2545a9eeb8f7e980`. Antes de editar, 62 fontes/arquivos locais foram comparados por SHA Git com a árvore publicada. A entrega V49 tem 61 fontes, três instâncias novas e 38 substituições cumulativas desde V44; a diferença para V48 é três criações e oito substituições.

## Causa e alteração

O Apply V48 executava `ApplyDescriptionResetAsync` no Humanoid existente e devolvia o corpo solicitado, sem confirmar o resultado ou converter a estrutura. Uma simulação do handler original mostrou `applied=true`, `liveRig=R6`, `wantedRig=R15`. Isso confirma a falha lógica, não a renderização do pacote específico. O cliente ignorava a divergência. A inicialização também usava a aparência já aplicada pela experiência; não recuperava o corpo equipado do perfil quando as Avatar Settings/StarterCharacter o substituíam. Não foi possível inspecionar a configuração nativa do place do usuário; essa causa adicional é tratada pelo novo fluxo, sem afirmar que ela foi observada no place.

`09B5_AVATAR_RUNTIME` consulta o HumanoidDescription nativo ao entrar e desliga UseAvatarSettings na construção. Um corpo com IDs próprios recebe hierarquia R15 na entrada. Troca de corpo/rig cria um modelo nativo completo, verifica descrição efetiva e presença das partes, mantém root/posição, vida, movimento, ferramentas e assento. A câmera normal e animações de movimento têm suporte em `09C11_AVATAR_CHARACTER`; câmera Scriptable permanece sob seu controlador. A alteração não escreve Humanoid.RigType. Para alterações de roupa/escala no mesmo corpo, ainda usa ResetAsync; readback incorreto aciona reconstrução. Falha não devolve sucesso. Verificação ocorre antes de destruir o personagem anterior. Revisão/identidade impedem uma resposta antiga de substituir um personagem mais recente. O último HumanoidDescription confirmado é usado no respawn da sessão.

`08B1_BODY_PACKAGES` usa todas as partes, proporções e animações do UserOutfit do pacote, mantendo as roupas/acessórios atuais. Falha do outfit nativo impede aplicação parcial. Peças avulsas de corpo promovem R15; pacotes de animação preservam rig. `08D_SKIN_STATE` e cliente aceitam o rig efetivo retornado e mantêm proteção contra respostas antigas. AvatarSnapshot de personagem reconstruído não depende de CharacterAppearanceLoaded, evento que não é garantido em caracteres customizados.

O catálogo preserva itens reais abaixo da prévia, com X de pelo menos 40×44 separado da miniatura. Prévia quadrada, Aplicar em texto verde, ícones desenhados de Salvar/Restaurar/Carrinho/Corpo na mesma área, duas linhas e cinco/quatro colunas conforme espaço; telefone retrato adapta. Área maior permite uma grade de itens equipados. Preços e nomes continuam legíveis. Restauro mantém confirmação.

## Resultados

| Suíte | Casos |
|---|---:|
| test_bodies.py | 17 |
| test_v49.py | 13 |
| test_integration.py | 13 |
| test_changes.py | 6 |
| test_features.py | 7 |
| test_games_commerce.py | 9 |
| test_server_flows.py | 5 |
| test_fixes.py | 12 |
| test_redesign.py | 9 |
| JavaScript do instalador | 1 |
| **Total** | **92** |

Execute as nove suítes Python e `node audits/V49/test_installer_logic.cjs`. Lua 5.4 usa doubles V43/V48 e extensões V49 de ciclo do personagem. Os resultados JSON acompanham as fontes. Os casos antigos de pacote sem outfit completo e snapshot bloqueado apenas por HasAppearanceLoaded foram substituídos pelos casos de corpo completo/falha e snapshot de rig reconstruído. As regressões de aplicação usam o Humanoid vivo após a troca, não uma referência destruída. A suíte de sintaxe verifica todas as 61 fontes, limite de 400 linhas e ausência de atribuições compostas.

Inclui as 72 partidas completas de Truco e recibos da V48. Não houve alteração de preços, IDs ou política de compras. O instalador verifica 41 hashes, rótulos três NOVOS/38 SUBSTITUIR, reconstrução exata de partes, quatro partes 09A, fallback offline V44/V49, cache antigo e fechamento durante carga. Foi executado o JavaScript real com DOM mínimo; CSS não é emulado.

`preview_layouts.py` extrai as instâncias das fontes atuais e gera diagramas aproximados de layout em quatro telas, usando PIL e imagens substitutas. Foram revisados desktop, retrato e paisagem; não são screenshots do Roblox. O renderer não carrega avatar/miniaturas reais e não reproduz todas as regras nativas de texto/gradiente/rotação. As figuras intermediárias não integram a entrega.

## Limites

Não há execução Roblox/Studio Lite neste ambiente. Os testes não certificam meshes, aparência física do gato abacaxi, moderação, latência ou compras reais. Conferir IDs/rig/estrutura/descrição detecta erros lógicos, mas não prova a imagem final de cada asset. O gato abacaxi precisa estar equipado no perfil e ser testado em um servidor novo; não foi necessário nem realizado comprar novamente. A V49 não publica o place e não grava automaticamente aparência no perfil ou entre servidores. O roteiro nativo está em INSTALL_V49.md.
