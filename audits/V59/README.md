# Auditoria V59

Base remota confirmada: `eee3fb7a7114b8cdb6828436c78556817938ecf5` (V58).

Quatro substituições: motor, servidor, controlador do cliente e interface da IA. Nenhuma instância nova. A V59 responde em inglês durante o teste de compatibilidade e identifica esse idioma. Não depende de chave externa.

`test_native.py` cobre dez cenários: sonda com a instrução real, comparação independente com o exemplo oficial, falha em ambos os caminhos, falha apenas na referência, transporte depois do filtro, texto/JSON legado, saída inválida, timeout, reembolso e compra condicionada à saúde completa. `test_interface.py` cobre quatro cenários: geometria em seis resoluções/quatro abas/dois estados, alinhamento das mensagens, teclado e fluxo real do LocalScript.

Os serviços são **doubles determinísticos**, com casos de falha conhecidos. Eles verificam comportamento do código, não disponibilidade ou saída do TextGenerator real. `native_results.json` e `interface_results.json` registram os 14 cenários. `test_package.py` verifica sintaxe, dependências, hashes e preservação do manifesto histórico. `test_installer_logic.cjs` executa o JavaScript do HTML com DOM mínimo; não renderiza CSS.

Reprodução local:

```sh
python audits/V59/test_native.py
python audits/V59/test_interface.py
python audits/V59/build_installer.py
python audits/V59/test_package.py
node audits/V59/test_installer_logic.cjs
```

O exemplo oficial e o relato original consultados estão vinculados no guia de instalação. A confirmação nativa requer Play no Roblox, Recarregar IA, pedido real e comparação dos registros HEALTH/REFERENCE/ASK. Não houve cobrança nem execução no motor Roblox nesta auditoria.
