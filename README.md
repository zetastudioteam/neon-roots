# Neon Roots

**Neon Roots** é um RPG narrativo 2D top-down ambientado em um futuro cyberpunk em colapso, onde tecnologia, desigualdade e degradação ambiental moldaram uma cidade dividida entre privilégio e abandono.

O jogador controla **Echo-7**, uma unidade sintética descartada na Undercity, que desperta com pouca energia e encontra um fragmento capaz de iniciar a restauração de um mundo quebrado.

Este repositório contém a versão inicial do projeto, desenvolvida como uma **demo jogável / prova de conceito** para o evento acadêmico associado ao Dia do Meio Ambiente.

---

## Sobre o Projeto

O jogo completo de **Neon Roots** é planejado em torno da coleta de **17 fragmentos**, inspirados nos **17 Objetivos de Desenvolvimento Sustentável (ODS) da ONU**.

A proposta não é explicar os ODS de forma expositiva, mas fazer o jogador sentir suas ausências através de:

- narrativa ambiental;
- exploração;
- puzzles;
- restauração gradual do cenário;
- contraste entre tecnologia e natureza;
- desigualdade social e abandono urbano.

A demo atual foca no **Arco 0 — O Despertar da Dignidade**, apresentando o início da jornada de Echo-7, a descoberta do primeiro fragmento e o despertar de Neo.

---

## Demo — Arco 0

A demo representa o prólogo jogável do projeto completo.

### Fluxo principal esperado

```text
Menu
↓
Echo-7 desperta
↓
Jogador aprende a se mover
↓
Explora a Undercity
↓
Interage com terminais e objetos
↓
Resolve um puzzle simples
↓
Abre uma passagem
↓
Encontra o primeiro fragmento
↓
Neo desperta
````

### Objetivo da demo

Demonstrar os pilares principais do jogo:

* movimentação top-down;
* câmera fixa/seguindo o personagem;
* exploração ambiental;
* interação contextual;
* puzzle simples;
* HUD inicial;
* atmosfera cyberpunk melancólica;
* primeiro contato com o sistema de fragmentos;
* introdução de Echo-7 e Neo.

---

## Gênero e Perspectiva

* **Gênero:** RPG narrativo atmosférico
* **Perspectiva:** 2D top-down tile-based
* **Movimentação:** 4 direções
* **Câmera:** `Camera2D` seguindo Echo-7, sem rotação e sem controle manual do jogador

A referência de câmera e movimentação segue a lógica de RPGs clássicos top-down, como jogos antigos de exploração em tiles.

---

## Tecnologias Utilizadas

* [Godot Engine 4.x](https://godotengine.org/)
* GDScript
* Git + GitHub
* Aseprite
* Blender
* Krita
* Audacity / Reaper

---

## Estrutura de Pastas

Todos os membros devem seguir a estrutura definida para o projeto:

```text
game/
├── assets/
│   ├── art/
│   ├── audio/
│   ├── fonts/
│   └── localization/
│
├── scenes/
│   ├── core/
│   ├── echo7/
│   ├── neo/
│   ├── environments/
│   ├── props/
│   ├── systems/
│   └── menus/
│
├── scripts/
│   ├── core/
│   ├── echo7/
│   ├── systems/
│   ├── neo/
│   ├── ui/
│   └── tools/
│
├── resources/
│   ├── dialogue/
│   ├── configs/
│   └── tilemaps/
│
└── builds/
```

---

## Controles

| Ação                | Tecla |
| ------------------- | ----- |
| Mover para cima     | W     |
| Mover para baixo    | S     |
| Mover para esquerda | A     |
| Mover para direita  | D     |
| Interagir           | E     |

---

## Escopo Atual

Esta versão está focada no desenvolvimento do **primeiro loop jogável**.

### Implementar agora

* movimentação de Echo-7;
* câmera seguindo o jogador;
* mapa inicial da Undercity;
* sistema de interação;
* HUD base;
* puzzle simples de porta/fusível;
* primeiro fragmento;
* despertar de Neo;
* atmosfera inicial.

### Não implementar nesta fase

* inventário completo;
* crafting;
* multiplayer;
* mundo aberto;
* skill tree;
* IA complexa;
* combate avançado;
* 17 fragmentos jogáveis;
* múltiplos arcos completos.

---

## Organização de Branches

O projeto utiliza a seguinte organização:

```text
main
develop
feature/*
```

### Regras

* Nunca desenvolver diretamente na `main`.
* A branch `main` deve conter apenas versões estáveis.
* O desenvolvimento diário deve acontecer na `develop`.
* Novas funcionalidades devem ser feitas em branches `feature/*`.

Exemplos:

```text
feature/player-movement
feature/map-transition
feature/interaction-system
feature/hud-base
```

---

## Convenção de Commits

Utilizar commits curtos e descritivos.

Prefixos recomendados:

```text
feat: nova funcionalidade
fix: correção de bug
art: assets visuais
audio: sons e músicas
docs: documentação
refactor: refatoração de código
```

Exemplos:

```text
feat: adiciona movimentação da Echo
fix: corrige colisão da porta inicial
art: adiciona tileset temporário da Undercity
audio: adiciona ambiência industrial
docs: atualiza README com estrutura do projeto
```

---

## Definition of Done

Uma tarefa só deve ser considerada concluída quando:

* funciona corretamente;
* foi testada;
* não quebra outra funcionalidade;
* está commitada;
* foi integrada na branch `develop`;
* possui feedback visual mínimo quando necessário.

---

## Equipe

| Nome    | Papel               |
| ------- | ------------------- |
| Bruna   | Product Owner       |
| Bruno   | Gameplay Programmer |
| Nicolas | Systems Programmer  |
| Pedro   | Environment Artist  |
| Suelen  | Character/UI Artist |
| Ryan    | Sound Designer      |

---

## Status do Projeto

Projeto em desenvolvimento inicial.

Versão atual: **Demo / Prova de Conceito — Arco 0**

O objetivo desta fase é criar uma experiência curta, funcional e apresentável para demonstrar o conceito central de **Neon Roots**.

---

## Créditos e Licença

Este projeto está em desenvolvimento acadêmico.

Todos os assets, códigos, músicas, roteiros e demais materiais finais do jogo completo serão produzidos pela equipe do projeto.

A licença definitiva do projeto ainda será definida antes de qualquer lançamento público ou comercial.

