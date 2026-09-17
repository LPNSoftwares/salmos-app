# Salmo do Dia — Bíblia offline

A edição VFL em `resources/VFL.json` é embarcada integralmente no aplicativo.
O arquivo fornecido contém 66 livros, organizados por capítulos e versículos.
O conteúdo é preservado, incluindo sua numeração. Não há chamadas à Bíblia API
no fluxo do aplicativo e nenhuma chave é necessária para executar ou compilar.

## Recursos
- Início com palavra do dia determinística pela data local.
- Biblioteca de livros, capítulos e busca por palavras sem distinção de acentos.
- Área de Salmos com os 150 capítulos.
- Sorteio de versículos da Bíblia inteira ou somente dos Salmos.
- Sorteio com baralho embaralhado: sem repetição dentro de cada ciclo da sessão.
- Leitor com capítulo anterior/próximo, fonte ajustável, favoritos e compartilhamento.
- Favoritos, histórico e preferências existentes preservados no aparelho.
- Fontes do sistema: nenhuma fonte é baixada na primeira abertura.
- Notificações locais com textos salvos, sujeitas à permissão do Android.
- Voz apenas com mecanismo/voz offline instalada no aparelho. Na ausência de voz,
  o app informa a indisponibilidade; o texto permanece acessível.
- Compartilhar abre o seletor do sistema; o envio depende do aplicativo escolhido.

## Executar e validar
```sh
flutter pub get
flutter run
flutter analyze
flutter test
flutter build appbundle --release
```

O bundle sai em `build/app/outputs/bundle/release/app-release.aab`.
Para publicar, use um versionCode maior que o já enviado à loja.
A assinatura continua usando os arquivos locais `android/key.properties`
e `android/app/upload-keystore.jks`.

A identificação da tradução é VFL, conforme o nome do arquivo fornecido.
O JSON não contém metadados de autoria/licença; não foram inventados créditos.
