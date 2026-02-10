# Inception - Ce qui manque pour valider

## CRITIQUE - Bloquant pour la validation

### 1. Username admin interdit
- **Fichier:** `srcs/.env` ligne `WP_ADMIN=admin`
- **Probleme:** Le sujet dit explicitement que le username admin ne peut PAS contenir "admin/Admin/administrator/Administrator". `admin` est interdit.
- **Fix:** Changer pour un autre nom, ex: `WP_ADMIN=elopin`

### 2. Pas de deuxieme utilisateur WordPress
- **Fichier:** `srcs/requirements/wordpress/tools/entrypoint.sh`
- **Probleme:** Le sujet demande 2 utilisateurs dans la base WordPress (dont 1 admin). Actuellement seul l'admin est cree.
- **Fix:** Ajouter apres `wp core install` :
  ```
  wp user create <user2> user2@example.com --role=author --user_pass=<pass> --allow-root
  ```

### 3. Mots de passe en clair dans le repo Git
- **Fichier:** `srcs/.env` est track par git avec les passwords en clair
- **Probleme:** Le sujet dit : "Any credentials, API keys, or passwords found in your Git repository (outside of properly configured secrets) will result in project failure."
- **Fix:** Creer un `.gitignore` qui ignore `srcs/.env` et le dossier `secrets/`. Le `.env` ne doit pas etre commit.

### 4. Pas de dossier `secrets/`
- **Probleme:** Le sujet montre dans l'arborescence attendue un dossier `secrets/` a la racine contenant :
  - `credentials.txt`
  - `db_password.txt`
  - `db_root_password.txt`
- **Fix:** Creer le dossier et les fichiers, utiliser Docker secrets dans le docker-compose.yml

### 5. Pas de `.gitignore`
- **Probleme:** Aucun `.gitignore` n'existe. Les secrets et le `.env` sont potentiellement pushes.
- **Fix:** Creer un `.gitignore` a la racine :
  ```
  secrets/
  srcs/.env
  en.subject.pdf
  ```

### 6. `restart: always` manquant sur WordPress
- **Fichier:** `srcs/docker-compose.yml`
- **Probleme:** Le sujet dit "Your containers have to restart in case of a crash." Le service `wordpress` n'a pas `restart: always` (nginx et mariadb l'ont).
- **Fix:** Ajouter `restart: always` au service wordpress.

---

## IMPORTANT - Problemes techniques

### 7. Mismatch volume / root nginx
- **Fichier:** `srcs/docker-compose.yml` et `srcs/requirements/nginx/conf/nginx.conf`
- **Probleme:** Le volume monte `wp_data:/var/www/html` dans nginx, mais nginx.conf utilise `root /var/www/wordpress;` et fastcgi_param pointe vers `/var/www/wordpress`. Ca ne matchera pas.
- **Fix:** Soit changer le volume en `wp_data:/var/www/wordpress`, soit changer nginx.conf pour utiliser `/var/www/html`. Verifier aussi que WordPress installe ses fichiers au bon endroit.

### 8. `sleep 40` dans le CMD nginx
- **Fichier:** `srcs/requirements/nginx/Dockerfile` ligne 14
- **Probleme:** `CMD ["sh", "-c", "sleep 40 && nginx -g 'daemon off;'"]` - Le sujet interdit les hacky patches : "tail -f, bash, sleep infinity, while true". Meme si `sleep 40` n'est pas `sleep infinity`, c'est un workaround hack. Utiliser `depends_on` avec healthcheck est la bonne approche.
- **Fix:** Changer le CMD en `CMD ["nginx", "-g", "daemon off;"]` et gerer la dependance via `depends_on` avec condition healthcheck dans docker-compose.yml.

### 9. Credentials affichees dans les logs
- **Fichier:** `srcs/requirements/wordpress/tools/entrypoint.sh` ligne 9
- **Probleme:** `echo $WORDPRESS_DB_HOST $WORDPRESS_DB_USER $WORDPRESS_DB_PASSWORD` affiche les credentials dans les logs.
- **Fix:** Supprimer cette ligne.

### 10. Makefile casse
- **Fichier:** `Makefile`
- **Probleme 1:** `$(home)` n'est pas defini. Doit etre `$(HOME)` (variable d'env) ou un path hardcode `/home/elopin`.
- **Probleme 2:** La regle `fclean` est ecrite `flcnan` (typo). Donc `re: fclean all` ne marchera pas car `fclean` n'existe pas.
- **Fix:** Corriger `$(home)` -> `$(HOME)` et `flcnan` -> `fclean`.

### 11. Image de base Debian - verifier la version
- **Fichier:** Tous les Dockerfiles utilisent `debian:bookworm`
- **Probleme:** Le sujet demande "the penultimate stable version of Alpine or Debian". Bookworm (Debian 12) est le stable actuel. La penultieme version stable serait `bullseye` (Debian 11), sauf si Debian 13 (trixie) est sorti depuis.
- **Fix:** Verifier quelle est la penultieme version stable de Debian au moment de la soutenance et ajuster si necessaire.

---

## DOCUMENTATION MANQUANTE

### 12. Pas de `README.md`
Le sujet exige un `README.md` a la racine contenant :
- [ ] Premiere ligne en italique : *This project has been created as part of the 42 curriculum by elopin.*
- [ ] Section **Description** (but du projet, overview, comparaisons VM vs Docker, Secrets vs Env Vars, Docker Network vs Host Network, Docker Volumes vs Bind Mounts)
- [ ] Section **Instructions** (compilation, installation, execution)
- [ ] Section **Resources** (references, et description de l'utilisation de l'IA)
- [ ] En anglais

### 13. Pas de `USER_DOC.md`
Documentation utilisateur requise a la racine, expliquant :
- [ ] Quels services sont fournis par la stack
- [ ] Comment demarrer et arreter le projet
- [ ] Comment acceder au site et au panel admin
- [ ] Ou trouver et gerer les credentials
- [ ] Comment verifier que les services tournent

### 14. Pas de `DEV_DOC.md`
Documentation developpeur requise a la racine, expliquant :
- [ ] Comment setup l'environnement from scratch (prerequisites, config, secrets)
- [ ] Comment build et lancer via Makefile et Docker Compose
- [ ] Commandes utiles pour gerer containers et volumes
- [ ] Ou sont stockees les donnees et comment elles persistent

---

## MINEUR / Bonnes pratiques

### 15. `version: '3.8'` obsolete dans docker-compose.yml
- Les versions recentes de Docker Compose n'utilisent plus le champ `version`. Peut etre supprime.

### 16. `apt update` au lieu de `apt-get update` dans les Dockerfiles
- Best practice Docker : utiliser `apt-get` au lieu de `apt` dans les Dockerfiles, et ajouter `rm -rf /var/lib/apt/lists/*` pour reduire la taille de l'image (manquant dans nginx Dockerfile).

### 17. Domaine hardcode
- `elopin.42.fr` est hardcode dans nginx.conf et le Dockerfile nginx au lieu d'utiliser des variables d'environnement du `.env`.

### 18. `wp-config.php` dans tools/ inutilise
- Le fichier `srcs/requirements/wordpress/tools/wp-config.php` n'est jamais copie/utilise. L'entrypoint.sh modifie `wp-config-sample.php` a la place. Fichier mort.

---

## Resume rapide

| Categorie | Element | Status |
|-----------|---------|--------|
| Structure | Makefile | Casse (typo + variable) |
| Structure | .gitignore | MANQUANT |
| Structure | secrets/ | MANQUANT |
| Structure | README.md | MANQUANT |
| Structure | USER_DOC.md | MANQUANT |
| Structure | DEV_DOC.md | MANQUANT |
| Docker | nginx Dockerfile (sleep) | A corriger |
| Docker | wordpress restart policy | MANQUANT |
| Docker | volume/root mismatch | A corriger |
| WordPress | Admin username "admin" | INTERDIT |
| WordPress | 2eme utilisateur | MANQUANT |
| Securite | .env avec passwords dans git | BLOQUANT |
| Securite | Docker secrets | MANQUANT |
| Securite | Credentials dans les logs | A corriger |
