# Salmo do Dia

Aplicativo Flutter offline-friendly para ler, ouvir, favoritar, receber notificações e compartilhar Salmos usando a Bíblia API.

## Como Rodar

```bash
flutter pub get
flutter run
```

Para usar a API autenticada, informe as credenciais fora do código-fonte:

```bash
flutter run --dart-define=BIBLIA_API_KEY=sua_chave_bapi
```

Validações usadas durante o desenvolvimento:

```bash
dart format .
flutter analyze
flutter test
```

## Packages Usadas

- `dio`: cliente HTTP para a Bíblia API.
- `flutter_riverpod`: estado da aplicação.
- `shared_preferences`: cache, favoritos, histórico, configurações e controle de requisições.
- `flutter_local_notifications`: notificações locais.
- `flutter_tts`: leitura do Salmo em voz alta usando TTS nativo do aparelho.
- `timezone`: cálculo dos horários diários das notificações.
- `share_plus`: compartilhamento com WhatsApp, Instagram, Telegram, SMS e apps disponíveis no aparelho.
- `go_router`: navegação.
- `google_fonts`: tipografia.
- `intl`: formatação de data/hora quando necessário.

## API

Base URL:

```text
https://bibliaapi.com.br/api/v2
```

Endpoint principal:

```text
GET /versions/{version}/books/sl/random
```

Busca de Salmo completo:

```text
GET /versions/{version}/books/sl/chapters/{chapter}
```

Informe a chave criada no painel da Bíblia API por `--dart-define=BIBLIA_API_KEY=...`. O app envia a chave no header `X-API-Key`; ela não fica salva no repositório.

> Atenção: `--dart-define` impede o segredo de entrar no Git, mas a chave ainda pode ser extraída do binário de um aplicativo público. Para proteção forte em produção, encaminhe as chamadas por um backend próprio e mantenha a chave apenas no servidor.

O app usa `nvi` como versão padrão e mantém cache local para continuar funcionando quando a API estiver indisponível. Também oferece `acf` e `ara`, disponíveis no catálogo v2.

## Notificações

As notificações locais são agendadas por padrão para:

- 08:00
- 12:00
- 19:00

Como apps Flutter não devem depender de chamadas HTTP confiáveis em background para esse caso, o fluxo é:

1. Ao abrir o app, ele carrega o Salmo atual e tenta pré-carregar alguns Salmos.
2. Os Salmos pré-carregados são salvos localmente.
3. As notificações usam os Salmos já salvos em cache.
4. Ao tocar em uma notificação, o app abre exibindo o Salmo enviado no payload.
5. Se ainda não existir cache, a notificação orienta abrir o app.

No Android 13+, o app solicita permissão de notificações. O `AndroidManifest.xml` também está configurado com permissões e receivers necessários para notificações agendadas e reagendamento após reinicialização.

## Dados Locais

Tudo é persistido no aparelho com `shared_preferences`:

- Último Salmo carregado.
- Favoritos.
- Histórico dos últimos Salmos recebidos ou gerados.
- Cache usado pelas notificações.
- Configurações de versão bíblica, tema e horários.
- Preferências de voz: voz escolhida, velocidade, tom, volume e leitura automática.
- Log local de requisições para evitar excesso de chamadas à API.

Não há login de usuário no app, Firebase, backend próprio, banco remoto ou autenticação do usuário final.

## Voz e Text-to-Speech

O app usa `flutter_tts` para ler o Salmo atual em voz alta com o TTS nativo do aparelho.

Formato da leitura:

```text
Salmos capítulo {chapter}, versículo {number}. {text}
```

A tela de voz permite iniciar/parar a leitura e ajustar:

- Voz disponível no aparelho.
- Velocidade.
- Tom.
- Volume.
- Opção `Ouvir automaticamente ao abrir um Salmo`.
- Tamanho da letra do Salmo.

O idioma padrão é `pt-BR`. Quando existirem vozes `pt-BR`, o app lista apenas essas vozes. Se o aparelho não tiver voz `pt-BR`, o app mostra um aviso e permite usar uma voz disponível.

## Build Release Android

Nome exibido do app:

```text
Salmo do Dia
```

Application ID de produção:

```text
br.com.lpnsoftwares.salmos
```

A assinatura release usa:

- `android/app/upload-keystore.jks`
- `android/key.properties`

Esses arquivos são locais e ignorados pelo Git. Guarde uma cópia segura deles, pois serão necessários para publicar futuras atualizações do app na Play Console.

Build App Bundle:

```bash
flutter build appbundle --release --build-name=1.0.1 --build-number=2 --dart-define=BIBLIA_API_KEY=sua_chave_bapi
```

Artefato gerado:

```text
build/app/outputs/bundle/release/app-release.aab
```
