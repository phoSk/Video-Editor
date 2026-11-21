# Editor de vídeo

Editor de vídeo sencillo para Android y PC: cortar en clips, unir varios vídeos, cambiar la velocidad, pista de audio separada (enlazada o no), música y guardar el resultado. Los proyectos se guardan solos y se pueden exportar como `.zip`.

- **PC / navegador:** la app web se publica en GitHub Pages. Desde Chrome o Edge se puede instalar con el botón de instalar de la barra de direcciones.
- **Android:** cada cambio genera una APK nueva en *Releases*. Enlace directo a la última:
  https://github.com/phoSk/Video-Editor/releases/latest/download/editor-video.apk
- **Web:** https://phosk.github.io/Video-Editor/

## Cómo se publica

Cada `push` a `main` lanza `.github/workflows/build.yml`, que:
1. publica la carpeta `www/` en GitHub Pages;
2. crea el proyecto Android con Capacitor, lo firma y sube la APK como nueva versión.

La APK se firma con `android-release.keystore` (un almacén PKCS12 protegido por contraseña). La contraseña va en el secreto del repositorio `KEYSTORE_PASSWORD`; sin él la compilación de Android se detiene. **No pierdas esa contraseña:** sin ella no se pueden publicar actualizaciones que se instalen encima de la app.

## Estructura

- `www/` — la app (un único `index.html`, manifiesto, service worker e iconos)
- `assets/` — iconos y pantalla de inicio para Android
- `scripts/patch-android.mjs` — versión y firma del proyecto Android
