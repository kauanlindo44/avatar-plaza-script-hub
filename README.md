# Avatar Creator Plaza — V67

Delta sobre a V66 publicada (`f67f6ff374677908967b3e1408485d6ab595c433`): **4 ModuleScripts novos + 32 substituições**, todas as fontes até 400 linhas. [Guia com nomes, tipos e locais](INSTALL_V67.md).

Abra [AVATAR_PLAZA_V67.html](AVATAR_PLAZA_V67.html) ou o [instalador permanente](AVATAR_PLAZA_SCRIPT_HUB_PERMANENTE.html). Código recolhido, botão de copiar fonte inteira, última linha e duas partes opcionais. `09A_SHOP_UI` permanece nas quatro partes anteriores. Requer a **V66 completa**; o HTML também inclui as versões anteriores necessárias.

Crie primeiro `07G7_ADVENTURE_WORLD` e `09I10_CHAT_NAV` como **ModuleScript em ReplicatedStorage**; `08B7_AVATAR_ANIMATIONS` e `09I11_CONVERSATIONS` como **ModuleScript em ServerScriptService**. Depois substitua as 32 fontes indicadas e reinicie Play. Nenhum passe/produto/chave externa novo.

A V67 corrige a prova de fundos invisível e fora da tela que rejeitava imagens válidas na V66. Usa uma prova renderizável temporária, preservando a seleção anterior em recusas reais. Apoio dos corpos é comparado aos pés do rig, sem medir acessórios; animações equipadas são resolvidas e atualizam Animate/fallback. Emotes do catálogo usam o clip confirmado no Animator da prévia.

IA com navegação desktop, busca/histórico privado, renomear/arquivar/excluir, configurações e compartilhamento confirmado de uma cópia textual filtrada. Há saudações, contexto de ajuda e refinamentos de cor/peça, além dos 90 estilos. Até 20 conversas/16 mensagens por conversa; gravações agrupadas. A IA é um planejador/guia específico, sem chave OpenAI nem promessa de conversação generativa geral.

Truco recomposto pela foto 4: mesa oval verde com borda escura, avatares circulares, identificação das duplas, mão em leque, cartas públicas menores e controles compactos. Regras e comércio existentes preservados. HUD/painel de jogador menores, catálogo com contraste maior para emotes.

Seis mundos mais simples e um Vale da aventura detalhado separado, com árvores variadas, lago, caminhos e morros decorativos. Spawn com emblema clássico. Música inicial Pastel Afternoon Piano para entradas sem última faixa salva, sujeita à permissão e com fallback. Patrocínio de jogos/comunidades dura 24 h. Halloween opcional: o modo automático termina em **01/11/2026, 00h de Brasília**; é possível desligar antes ou manter ligado manualmente.

**84 cenários simulados**, **131 fontes efetivas**, seis geometrias e JavaScript real do instalador. [Auditoria](audits/V67/README.md). Sem motor Roblox nativo: renderização, física, FPS e permissões reais ainda exigem teste publicado. As mudanças não afirmam corrigir módulos internos de CorePackages/UIBlox.
