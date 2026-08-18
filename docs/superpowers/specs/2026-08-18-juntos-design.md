# Juntos — Design v1

**Data:** 2026-08-18
**Status:** aprovado em brainstorming, aguardando plano de implementação

## O que é

App de desafios em grupo, estilo GymRats. Alguém cria uma sala com um desafio de prazo definido ("dormir cedo por 21 dias", "novena de 40 dias às 3:30"), manda o link pros amigos, e cada um faz check-in diário. O valor central é **companhia**: ver que os outros também estão fazendo. Sem ranking, sem pontos, sem punição.

Projeto novo, independente do Evolva. Rails 8, SQLite, Hotwire, padrão 37signals em tudo (controllers pequenos e RESTful, mínimo de estado, HTML no servidor, Minitest).

## Decisões de produto

- **Sala = 1 desafio.** Criar o desafio cria a sala. Outro desafio com o mesmo grupo = outra sala, outro link.
- **Entrar é fricção zero:** clicou no link, digitou o nome, está dentro. Sem conta, sem senha, sem email. Identidade por cookie assinado permanente.
- **Criar exige conta**, para a sala nunca ficar órfã (criador trocar de aparelho não pode perder a sala). Login estilo 37signals/HEY: email → código de 6 dígitos por email → sessão. Sem senha.
- **Check-in de um toque:** "Fiz hoje ✓". Tocar de novo desmarca. Sem foto, sem nota, sem quantidade na v1.
- **Retroativo só até ontem**, e só se ontem estiver dentro do período do desafio. Mantém a grade honesta sem punir esquecimento.
- **Criador escolhe a data de início** (padrão: amanhã). Todo mundo compartilha o mesmo dia 1 — o "estamos todos no dia 8" é parte da companhia.
- **Sem edição nem exclusão de sala na v1.** Criou errado, cria outra.

## Modelos

### User (só quem cria salas)
- `email` (único). Sem senha.
- Login: formulário de email → código de 6 dígitos enviado por email → verificação → sessão.

### Challenge (a sala)
- `user_id` (criador), `name`, `starts_on` (date), `days` (integer), `token` (código curto aleatório, único — o link de convite `/c/:token`).
- Derivados (métodos, não colunas): `ends_on`, `current_day`, `upcoming?`, `running?`, `finished?`, `today` (data atual no fuso do app).

### Participant (pessoa dentro de uma sala)
- `challenge_id`, `name`, `person_token` (identifica o cookie do navegador), `user_id` opcional.
- Não existe pessoa global: quem está em 3 salas tem 3 participants ligados ao mesmo `person_token`. O participant do criador aponta pro `user_id` dele — é o que dá "minhas salas" multi-dispositivo e histórico pra quem tem conta.
- Único por `(challenge_id, person_token)`.

### Checkin
- `participant_id`, `date`.
- Índice único em `(participant_id, date)` — clique duplo não duplica.
- Validação: `date` é hoje ou ontem (no fuso do app) e está entre `starts_on` e `ends_on` do desafio.

Sem contadores denormalizados: grade, "quem fez hoje" e progresso são queries sobre `checkins`.

## Fuso e virada do dia

"Hoje" é sempre calculado em `America/Sao_Paulo`, fixo na config do app na v1. Regra num lugar só (`Challenge#today`); validação, grade, linha do HOJE e "dia 8/21" derivam dela. Nenhum job ou cron: à meia-noite de Brasília o dia vira naturalmente na leitura.

## Rotas e controllers

```ruby
root "challenges#index"                  # minhas salas (ou landing se vazio)

resources :challenges, only: [:index, :new, :create, :show]

get  "c/:token" => "joins#new", as: :join   # link de convite
post "c/:token" => "joins#create"

resources :checkins, only: [:create, :destroy]

resource :session, only: [:new, :create, :destroy]   # pede o email
resource :verification, only: [:new, :create]        # pede o código
```

Controllers: `ChallengesController`, `JoinsController`, `CheckinsController`, `SessionsController`, `VerificationsController` — 2–3 actions curtas cada. Concern `Authentication` no `ApplicationController` com `current_user` e `current_participant_for(challenge)`.

## Fluxos

1. **Criar sala** — `challenges/new` exige login (sem sessão → fluxo email/código → volta). Formulário: nome, data de início (padrão amanhã), duração em dias. Ao criar, cria também o `Participant` do criador e cai na sala com o link de convite em destaque pra copiar.
2. **Entrar pelo link** — `/c/:token` mostra nome do desafio, quem já está dentro, e o campo "como você quer ser chamado?". Enviou → cria `Participant`, grava `person_token` em cookie assinado permanente, cai na sala. Quem já é participante e reabre o link vai direto pra sala.
3. **Check-in** — `POST /checkins` marca hoje; `DELETE` desmarca. Link discreto "marcar ontem" aparece só quando ontem está vazio e dentro do período.
4. **Minhas salas** — raiz. Une salas do cookie com salas do user logado, ativas primeiro, encerradas depois (histórico).

## Tela da sala (o coração do app)

```
Dormir cedo — 21 dias      dia 8/21

HOJE
 ● Gui  ✓    ● Ana  ✓    ○ Bia  —

      1 2 3 4 5 6 7 8
Gui   ■ ■ ■ □ ■ ■ ■ ■
Ana   ■ ■ ■ ■ ■ □ ■ ■
Bia   ■ □ ■ ■ ■ ■ ■ □

      [ Fiz hoje ✓ ]
```

Topo: quem já fez check-in hoje. Meio: grade de consistência por participante, do dia 1 até o dia atual. Embaixo: o botão. Mobile-first — todo mundo abre pelo link do WhatsApp no celular.

## Tempo real

`Checkin` faz `broadcasts_to :challenge` ao ser criado/destruído. Quem estiver com a sala aberta vê a linha do HOJE e a grade da pessoa atualizarem na hora, via Turbo Streams sobre Solid Cable (SQLite, zero infra extra). O broadcast re-renderiza a partial do participante, nunca a página inteira.

## Email

Action Mailer com um provedor transacional (Resend ou Postmark) para o código de login. Único email do app na v1.

## Testes (Minitest)

- **Model:** validações de `Checkin` (hoje/ontem, dentro do período, sem duplicata); derivados de `Challenge`; `travel_to` para virada do dia e fuso.
- **Integração:** os 4 fluxos — criar sala exige login; entrar pelo link cria participant e cookie; check-in e desmarcar; minhas salas unindo cookie + user.
- **System test** do caminho feliz: cria sala → abre link em outra sessão → entra → os dois fazem check-in → grade mostra os dois.

## Fora da v1 (registrado, não esquecido)

- Push/lembrete diário (PWA)
- Foto ou nota no check-in
- Participante comum linkar email (o `user_id` opcional em `Participant` já deixa o caminho pronto)
- Editar/excluir sala
- Comentários/conversa na sala
