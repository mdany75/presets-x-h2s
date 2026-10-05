# Changements

## 1.1 — 2026-10-05

### Ajouté
- Application Mac native « Presets X-H2S » (image disque `Presets-X-H2S.dmg`, macOS 14, Apple Silicon et Intel) : la page dans sa propre fenêtre, mise à jour automatique depuis GitHub à chaque lancement, impression des fiches sélectionnées à quatre par page, ⌘F vers la recherche.
- Application web installable sur PC Windows (Edge ou Chrome), iPhone (Safari) et Android (Chrome ou Samsung Internet) : icône, plein écran, fonctionnement hors ligne, mise à jour automatique. Sur PC, sélection et impression des fiches comme sur Mac.
- Onglets : Bibliothèque, Banques C1–C7, ISO Auto et Référence s'affichent une section à la fois ; en-tête compact sur téléphone.
- Fiches « Street photography sous la pluie » et « Feux d'artifice (main levée) » (104 fiches).

### Modifié
- Le numéro de version de la page ne change plus à chaque fiche : seule la date sous le titre est mise à jour quand une fiche est ajoutée ou retirée.
- Projet mis au standard commun : application Mac à la racine (`Sources/`, `Resources/`, `build.sh`), scripts dans `scripts/`, fichiers produits dans `build/` et publiés en Release. L'export Markdown n'est plus commité ; la copie destinée à l'artifact claude.ai est retirée.

## 1.0 — 2026-10-02

Première version publiée : page de référence `index.html` (banques C1–C7, 102 presets par situation avec recherche et filtre par catégorie, ISO Auto 1–3, glossaire), export Markdown, dépôt GitHub.
