## Instalação

1. Pare Play. A base precisa estar na **V72 completa** (oito novos e 37 substituições da V72). Não recrie scripts já existentes.
2. No instalador V73, copie as oito fontes completas para os oito nomes exatos da tabela. A contagem vai de **1/8 (SUBSTITUIR)** até **8/8 (SUBSTITUIR)**.
3. Confira especialmente **09I_ASSISTANT_CLIENT** (conversa/looks) e **09I_ACTIVITIES_CLIENT** (atividades com amigos). São dois LocalScripts distintos em StarterPlayer > StarterPlayerScripts. Não acrescente o contador ou o rótulo ao nome.
4. Deixe uma única instância de cada nome. Reinicie Play depois de terminar as oito substituições. Publique pelo seu editor Roblox.

**09A_SHOP_UI continua nas quatro partes anteriores. Não há script NOVO, produto, passe ou chave novo nesta atualização.**

## Diagnóstico das fotos

- **Erro confirmado no código:** o layout antigo tentava mudar `Parent` de “NewConversation” depois que sua interface era destruída. A reprodução simulada com duas construções da tela confirmou o mesmo erro da foto. A V73 interrompe callbacks de interfaces encerradas e impede duas execuções do cliente da assistente.
- **Possível conflito de instalação:** uma das capturas mostra uma chamada da assistente sob o nome `09I_ACTIVITIES_CLIENT`. A fonte oficial desse script de atividades da V69 tem 43 linhas e não cria a tela da assistente. Isso é compatível com fonte copiada no destino errado/duplicação, mas uma foto não permite conferir o Explorer ou todas as fontes instaladas. Incluímos a fonte correta das atividades nas substituições.
- **Catálogo:** “modo seguro” era uma mensagem genérica; sozinho, esse aviso não informa se faltou módulo ou se houve erro de script. Com a base completa, o cliente do catálogo passou nos testes simulados. A V73 distingue `INSTALAÇÃO` (nome/tipo/duplicata), `REQUIRE`, `EXPORTAÇÃO`, `INIT` e `DADOS`, mostra o diagnóstico e preserva a exceção original no Output. O atributo `ACP_CatalogDiagnostic` em PlayerGui também guarda a última causa.
- **Música:** os avisos mostram conteúdo não carregado. Duração conhecida não prova permissão de reprodução. A V73 aguarda o carregamento, impede clientes duplicados e espaça a troca de faixa, com no máximo seis falhas consecutivas. Não libera assets privados/moderados por script.

Não é possível atribuir todas as falhas à sua instalação ou ao pacote apenas por essas capturas. Há uma falha de ciclo de vida corrigida no nosso código; o motivo exato da antiga falha do catálogo exige seu erro original de inicialização ou o diagnóstico novo.

## Patrocinar

- **6 itens por linha × 4 linhas completas = 24 cards visíveis**, quando houver pelo menos 24 resultados. A grade usa rolagem vertical para os próximos itens.
- Cards menores, preços compactos e cores suaves. Removido o gradiente que alterava a própria miniatura; a imagem mantém a cor original. Em cards pequenos, o título completo fica nos detalhes ao tocar, preservando espaço para a imagem e o preço.
- No celular deitado e no computador, a prévia lateral ocupa menos largura. No celular em pé, **Avatar** abre a prévia em um painel com X; a grade usa toda a largura disponível.
- Favoritos, busca, categorias, publicação gratuita por 24 h, exemplos identificados e substituição um por um continuam funcionando. A atualização de mídia de jogos/grupos a cada 15 minutos permanece no código anterior.

## Verificação no Roblox

Os testes executam código Lua compatível e serviços/layout simulados. A reconstrução visual não é captura nativa. Após instalar: abrir Catálogo e escolher uma categoria; abrir/fechar Assistente e Nova conversa; testar atividades; conferir os 24 cards em pé/deitado, preço, favoritos e X da prévia; testar áudio permitido e fallback. Compras, permissões de assets, moderação, filtros de comunicação e aparelhos reais continuam dependendo de conferência no Roblox publicado.
