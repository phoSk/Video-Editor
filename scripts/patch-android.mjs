// Ajusta el proyecto Android que genera Capacitor: número de versión y firma.
import fs from 'node:fs';

const gradlePath = 'android/app/build.gradle';
let g = fs.readFileSync(gradlePath, 'utf8');
const build = parseInt(process.env.BUILD_NUMBER || '1', 10);

g = g.replace(/versionCode\s+\d+/, `versionCode ${build}`)
     .replace(/versionName\s+"[^"]*"/, `versionName "1.0.${build}"`);

if (process.env.KEYSTORE_PATH) {
  const signing = `
    signingConfigs {
        release {
            storeFile file(System.getenv("KEYSTORE_PATH"))
            storePassword System.getenv("KEYSTORE_PASSWORD")
            keyAlias System.getenv("KEY_ALIAS")
            keyPassword System.getenv("KEY_PASSWORD")
        }
    }
    buildTypes {`;
  if (!g.includes('signingConfigs {')) g = g.replace(/\n\s*buildTypes\s*\{/, signing);
  g = g.replace(/(release\s*\{\s*\n\s*minifyEnabled[^\n]*)/, `$1\n            signingConfig signingConfigs.release`);
  if (!g.includes('signingConfig signingConfigs.release')) throw new Error('No se pudo añadir la firma a build.gradle');
}
fs.writeFileSync(gradlePath, g);

// Versión visible para la app (para avisar de actualizaciones)
fs.writeFileSync('android/app/src/main/assets/public/version.json', JSON.stringify({ build }));
console.log('Android parcheado: build', build, process.env.KEYSTORE_PATH ? '(firmado)' : '(sin firma propia)');
