# WORDPDF

Déposez un ou plusieurs fichiers Word `.doc` ou `.docx` sur l’icône bleue de WORDPDF dans le Dock. Chaque PDF apparaît à côté du fichier source. Par exemple, `Séquence.v2.DOCX` devient `Séquence.v2.pdf`. Si le nom existe déjà, l’app essaie `Séquence.v2 (2).pdf`, puis les numéros suivants.

1. Ouvrez le DMG et glissez **WORDPDF** vers **Applications**.
2. Depuis Applications, ajoutez **WORDPDF** au Dock.
3. Déposez les documents sur l’icône. Au premier export, autorisez WORDPDF à piloter Microsoft Word si macOS vous le demande. Un clic simple permet aussi de choisir des fichiers.

WORDPDF utilise le moteur d’export PDF de Microsoft Word pour Mac. Une version installée et activée de Word doit pouvoir ouvrir le fichier et l’exporter. L’app traite la version enregistrée du document en ouvrant une copie temporaire. Enregistrez les modifications en cours avant de lancer la conversion. Les ressources externes référencées par un chemin relatif peuvent demander une vérification dans Word.

Le binaire universel cible macOS 10.14.4 sur Intel et macOS 11 sur Apple Silicon. Les versions de Word utilisables dépendent du système. Les deux formats ont été testés sous macOS 26.6.2 avec Word 16.114.4 sur Apple Silicon. Les anciennes versions restent à valider sur machine. L’automatisation utilise le dictionnaire AppleScript de la version de Word installée. [Compatibilité de Microsoft Office pour Mac](https://support.microsoft.com/en-us/office/lifecycle/officeinstall/upgrade-macos-to-continue-receiving-microsoft-365-and-office-for-mac-updates)

## Compilation

```sh
./script/build_and_run.sh --build-only
./script/package_dmg.sh
```

L’app et le DMG sont créés dans `dist/`. Le DMG local contient une app signée ad hoc. Pour distribuer avec Gatekeeper, compiler avec `WORDPDF_SIGN_IDENTITY='Developer ID Application: …'`, puis soumettre le DMG à la notarisation Apple. [Notarisation Apple](https://developer.apple.com/documentation/security/notarizing-macos-software-before-distribution)
