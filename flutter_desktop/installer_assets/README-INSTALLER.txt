
== Fazenda São Petrônio - Pacote de Ícones + Instalador (Windows) ==

1) Ícones
   - Windows: copie "app_icon.ico" para o seu projeto em:
       windows/runner/resources/app_icon.ico
     (substitua o existente). Recompile o app:
       flutter build windows --release

   - macOS: substitua toda a pasta:
       macos/Runner/Assets.xcassets/AppIcon.appiconset
     pela pasta "AppIcon.appiconset" fornecida aqui e faça o build:
       flutter build macos --release

   - Linux: use os PNGs da pasta "png_icons" (16..1024 px).
     O Flutter instala ícones em
       linux/icons/hicolor/<size>x<size>/apps
     com o nome do seu app. Ex:
       linux/icons/hicolor/256x256/apps/fazenda-sao-petronio.png

2) Instalador Windows (Inno Setup)
   Pré-requisitos: Inno Setup instalado (ISCC no PATH).

   - Coloque "installer.iss" e "app_icon.ico" dentro de uma pasta
     "installer" na raiz do projeto.
   - Compile o app:
       flutter build windows --release
   - Compile o instalador (no prompt dentro da pasta "installer"):
       ISCC installer.iss

   Notas:
   - O script assume que o binário está em:
       ..\build\windows\x64\runner\Release
     Se seu caminho for outro, ajuste #define BuildOutput no .iss.
   - O nome do executável padrão no seu projeto é "flutter_desktop.exe".
     Se mudar o BINARY_NAME em windows/CMakeLists.txt, ajuste MyAppExeName.

3) Dicas de Assinatura
   - Para distribuição profissional, assine o executável/instalador
     com um certificado Code Signing (EV recomendado).

4) Suporte
   - Qualquer dúvida me chame aqui que ajusto os arquivos.
