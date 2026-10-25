# Diretrizes — Avatar Creator Plaza

**BUSCAR O EQUILÍBRIO ENTRE EXCESSO E FALTA.**

- **Legal:** visual bem feito, divertido, com personalidade e agradável de observar.
- **Lindo:** composição cuidadosa, que não seja repetitiva nem pareça feita apenas para preencher espaço.

Essas definições foram dadas pelo responsável pelo projeto e devem orientar as próximas alterações.

## Aplicação

1. O avatar e a partida recebem o destaque. Decoração, mapa e animações os acompanham.
2. Usar contraste legível, uma cor principal e poucos destaques por tela. A referência atual pede catálogo/HUD em grafite com categorias coloridas e assistente claro com conversa ampla. Preto, branco e cores têm função; nenhum deve predominar sem propósito.
3. Títulos, espaçamentos, ícones e estados seguem o mesmo sistema. Estado selecionado deve ser reconhecível por mais do que a cor.
4. O fundo pode cobrir a tela; controles respeitam recortes, barra do Roblox e teclado. Verificar computador, celular em pé e deitado. Alvos de toque: pelo menos 44 × 44 quando forem controles isolados.
5. Preferir interações curtas e pontuais. Respeitar movimento reduzido. Animações não atrasam relógios, turnos, envio de jogadas ou atualizações.
6. Vegetação usa composição planejada: agrupamentos assimétricos, clareiras e vistas abertas. Variar silhuetas e escala de modo coerente, sem espalhamento puramente aleatório.
7. Texturas devem combinar com o mundo estilizado e com o orçamento do celular. Materiais nativos e detalhes reutilizados têm prioridade sobre arquivos grandes.
8. Halloween é opcional e tem prazo automático. Deve ser uma camada sazonal, sem prejudicar preços, peças, avatar ou leitura.
9. Preservar itens equipados com X abaixo da prévia e as funções existentes do catálogo. Nunca confundir experimentar, favoritar e adicionar ao carrinho.
10. Regras, dificuldades, pontuação e tempos dos jogos são preservados. Conversas entre participantes passam por TextChatService, respeitam permissões oficiais e ficam isoladas por partida.
11. Atividades assistidas não podem aplicar, comprar ou publicar um look sem ação explícita do jogador. Remix exige consentimento verificável e mantém a autoria original.
12. Não ativar serviços pagos, assinaturas ou cobranças novas sem apresentar custos e obter autorização.

## Verificação e entrega

Separar verificações simuladas de testes no motor Roblox. Não afirmar teste no aparelho, filtragem real, FPS ou permissões reais quando isso não foi executado. Entregar a lista exata de novos scripts e substituições, mantendo fontes históricas imutáveis e cada fonte de instalação com até 400 linhas.

## Referências V71

Partir da V69 por pedido explícito do responsável. V70 fica preservada no histórico. Seguir as imagens fornecidas: catálogo com mosaico de categorias e prévia à esquerda; xadrez verde/creme; damas clássicas vermelhas/escuras; assistente com menu lateral estreito, mensagem central e campo de envio amplo. Atualizar mídia das vitrines a cada quinze minutos sem alterar o prazo de 24 horas das publicações.

## Continuidade V72

- Partir da V71 publicada no GitHub (`798f63e5327c831cca02e664a00f75f852e25633`); manter o histórico e as regras dos jogos.
- Usar a referência de patrocinar fornecida em 20/10: prévia à esquerda, pesquisa e prateleiras à direita. Adaptar as fileiras à altura e manter os itens equipados com remoção abaixo da prévia.
- Assistente em branco suave, histórico recolhível e acesso a conta/planos no rodapé. Corpo confirmado por ID é obrigatório; tipos exatos, orçamento e exclusões não podem ser trocados para preencher resultados.
- Esforço significa profundidade de pesquisa/validação nativa, sem alegar um modelo generativo externo. Não conceder planos por conclusão do prompt de compra; manter o recibo oficial.
- Recursos e imagens nativas podem depender de permissões/moderação do Roblox. Uma simulação de layout não comprova execução no aparelho.

## Continuidade V73

- Patrocinar usa seis itens por linha e quatro linhas completas, com cards menores, miniaturas sem filtro escuro e cores suaves. Priorizar imagem/preço; título completo nos detalhes em células compactas.
- Usar prévia lateral menor em modo deitado/computador e prévia opcional com X em pé. Respeitar barra nativa/recortes, mantendo alvos de 44 px nas geometrias suportadas.
- Ao investigar falhas, separar o que foi reproduzido no código dos indícios de instalação. Não atribuir culpa ao usuário sem conferir a fonte instalada. Evitar mensagens genéricas que afirmam abrir uma função que falhou.
- Callbacks não devem reutilizar instâncias destruídas. Clientes duplicados ou fontes copiadas no nome errado precisam de diagnóstico explícito.

## Continuidade V74

- Partir da V73 publicada (`144dcc4d8168536b87d8e046b117a965714c5312`). A biblioteca se chama **Nossos jogos** e identifica as implementações do Avatar Catalog & Games, com cards e caminhos claros para jogar. Truco/Xadrez/Damas mantêm regras, bots, relógios, pontuação e conversas; novas travas apenas impedem salas simultâneas.
- HUD maior e legível com grafite suave, poucos acentos e nomes visíveis. Agrupar os atalhos de avatar sem eliminar funções. Patrocinar conserva 6 × 4 e usa cards neutros; imagem e preço recebem o destaque.
- Botão do Caos V1 segue o GDD aprovado: uma arena isolada da praça; mesmo avatar; 2–8 pessoas; fila FIFO; 12/5/150/10 segundos de preparação/contagem/disputa/resultados; treino separado de 90 segundos; 12 efeitos gratuitos e autoridade do servidor. Não implementar Rodovia 061 nesta versão.
- Nunca alterar o inventário do catálogo para criar poderes. Ferramentas antigas são guardadas e devolvidas; a espera pela mochila nativa não autoriza apagá-las. Limpar câmera, foco de streaming, efeitos e ferramentas temporárias na saída.
- O desenvolvimento da V1 permanece **PENDENTE DE TESTE NATIVO** até a validação com usuários reais, celulares, corpos personalizados e desempenho medido. Simulações não aprovam FPS ou o lançamento no Roblox.

## Continuidade V75

- Base V74 publicada (`d1518e49cfb6962a7ed854d659cbe0fe3816cf2f`). Pedido atual autoriza HUD compacto nas bordas, acesso direto à IA, janela de comandos, emotes em cinco colunas e até quatro linhas e câmera sem deslocamento ao abrir menus.
- Carregar, Vestindo agora e Restaurar recebem superfícies coloridas; assistente usa azul/lilás suaves e prévias pequenas, até cinco por coluna. Nenhuma compra ou aplicação automática é adicionada.
- Vale da aventura inicia por padrão; cenários recebem menos peças. Não alegar FPS sem medição física.
- Mudanças de regras autorizadas no Botão do Caos: plataforma verde finita 128×88 sem paredes/retorno invisível; queda eliminatória; empurrão próximo com intervalo e validação no servidor. A onda usa impulso limitado. A bomba continua com uma única vítima e recebe descida/som de explosão.
- Regras, bots, relógios e recibos de Truco/Xadrez/Damas permanecem intactos. Áudio/visual não comandam a partida. Som da explosão não deve ser interrompido pela transição imediata ao resultado; sair encerra o áudio restante.
- Testes locais são simulados, ainda que o processo tenha bloqueios reais de rede/comandos. Chromium não foi executado neste ambiente; multiplayer, áudio, controles físicos e desempenho continuam pendentes no Roblox. A pesquisa registra o bloqueio de vídeos sem inventar análise audiovisual.

## Continuidade V76

- Base V75 publicada (`b7bfbea37b52765f608e4384c2699193c4e53daf`). Adaptar a foto: catálogo/lojas no alto, pares laterais, utilidades nos cantos e +. Preservar IA/patrocinar/funções; toque com pouca altura recolhe atalhos no + e reserva controles nativos.
- Fundos: 3 colunas × até 3 cards por coluna; emotes: 5×4. Câmera/cópia não mudam ao abrir menus. Captura direta com trava contra repetição.
- Plus: Developer Product `3717699383`, chave interna `Studio`; Pro: `3717699454`. Confirmar listagem de produtos da experiência antes do prompt. Benefícios somente pelo recibo oficial idempotente.
- Validar payload, números finitos, frequência conjunta e concorrência antes dos handlers da IA/catálogo. Ataques simulados localmente contra nossas fontes; não alegar segurança absoluta.
- Vinte referências de vídeos selecionadas, revisão audiovisual integral pendente. Não afirmar que os vídeos foram assistidos ou que todas as telas do Photo Studio foram copiadas exatamente sem evidência acessível.
- Separar simulação, reconstrução de layout, navegador e Roblox nativo. `08L_COMMUNITY`, legado das bases anteriores fora do manifesto, permanece no place existente.

## V77 — referência fornecida e mesas clássicas

A orientação mais recente de seguir a gravação prevalece sobre a grade antiga de emotes 5×4: o modo foto usa três colunas e até três linhas, com barra primária de cinco ações e ferramentas adicionais em menu separado. Nenhum reflow de painel muda as margens da câmera. HUD preserva o centro; no toque, acessos que colidiriam com controles nativos recolhem para o menu.

Configurações usam seis categorias coloridas. Remoção tem prévia e confirmação; salvar/restaurar/vestindo conservam cores. Compras são ações explícitas e dependem do fluxo oficial existente. A IA usa janela lateral no computador e resultados pequenos; sua biblioteca editorial não equivale a pesquisa de looks reais nem a treinamento de um modelo.

Xadrez e damas usam tabuleiro clássico de duas cores, jogadores/relógios acima e abaixo e lances separados das casas. O histórico não muda regras, relógio ou autoridade do servidor. As composições novas dos mapas usam primitivas simples e orçamento explícito; Vale da aventura continua inicial.

Pesquisa pública desta etapa restrita ao Chess.com. Documentação/interface atual observadas; gameplay integral quadro a quadro e fidelidade pixel a pixel não certificadas. Reconstruções de layout são ilustrativas. Testes nativos de Roblox permanecem pendentes.
