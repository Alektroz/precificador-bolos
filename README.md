# Precificador de Bolos de Pote

Aplicativo desenvolvido em Flutter para auxiliar no cálculo de custo, precificação e margem de lucro na produção de bolos de pote.

O projeto foi criado com base em um escopo real de necessidade para pequenos empreendedores da área de confeitaria, com foco em facilitar o cálculo do preço de venda considerando ingredientes, receitas-base, insumos, custos extras e margem de lucro desejada.

## Objetivo do Projeto

O objetivo do app é permitir que o usuário monte um bolo de pote por camadas e obtenha automaticamente:

- custo dos ingredientes;
- custo dos insumos;
- custo total por unidade;
- preço sugerido de venda;
- lucro por unidade;
- validação do peso total do pote.

## Funcionalidades

- Cadastro de receitas-base, como massas, recheios e coberturas;
- Cálculo automático do custo por grama de cada receita;
- Cadastro de insumos, como pote, tampa, colher e etiqueta;
- Montagem do bolo por camadas;
- Cálculo do custo total por unidade;
- Sugestão de preço de venda com base na margem de lucro;
- Persistência local dos dados usando SharedPreferences;
- Interface simples e objetiva para uso prático.

## Exemplo de Uso

O usuário pode montar um bolo de pote com a seguinte estrutura:

```text
Camada 1: Massa de chocolate - 80g
Camada 2: Recheio de brigadeiro - 90g
Camada 3: Massa de chocolate - 80g
