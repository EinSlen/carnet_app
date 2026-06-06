# Audit — App de suivi santé animal (chien/chat)

> Recherche web vérifiée (juin 2026) : concurrence réelle, monétisation, faille, distribution, angle France.
> Verdict honnête go/no-go pour un dev solo qui vise des revenus.

---

## 0. Verdict en une phrase

**C'est la meilleure piste qu'on ait trouvée — la porte concurrentielle est VRAIMENT ouverte (pas de leader
aimé, le "leader" 11pets s'est auto-détruit) — MAIS oublie l'abonnement classique : les gens ne paient pas
pour un tracker animal. La monétisation réaliste = soit un ACHAT UNIQUE sur une sous-niche (animal
malade chronique / âgé), soit une app GRATUITE monétisée par AFFILIATION ASSURANCE. Revenus modestes,
et le vrai travail sera la distribution par VIDÉO, pas le code.**

---

## 1. La place est-elle prenable ? → OUI (enfin !)

Contrairement à la méditation (Petit Bambou), **aucun leader dominant et aimé** ne verrouille le carnet de
santé animal. Le marché est **fragmenté et médiocre** :

- **11pets** (le "leader" mondial) : **3,3/5** (77 avis App Store US), **effondré à 2,12/5** (~5 300 avis
  Google Play) après une refonte buguée (2024-2025) + un **paywall punitif** : multi-animaux passé payant,
  utilisateurs **bloqués de leurs propres données** sans prévenir, avis parlant de « vol ». 👉 **Cas d'école
  de ce qu'il NE faut PAS faire.**
- **France, encore plus ouvert** : le plus "gros" est **Mon Compagnon** (assureur Solly Azar, **gratuit**,
  4,1/5, 606 avis) — un outil de lead-gen d'assureur, **pas** un vendeur d'abonnement. Les vrais carnets
  indépendants sont minuscules/bugués : **Zoovet** (3,2/5, 18 avis, recommandée par Virbac), **Animoo**
  (3,7/5, 3 avis, sortie 23/12/2025, freemium **2,99 €/mois ou 29,99 €/an**, déjà un bug de date).
- Les apps à "millions d'utilisateurs" (**PetDesk** = B2B vétos, **Rover/Wag** = services, **Tractive** =
  GPS ; Whistle arrêté août 2025) sont dans **d'autres catégories**. Le segment exact (carnet santé
  consommateur) **n'a pas de géant.**

➡️ Tu n'affrontes pas un Petit Bambou — juste une poignée de petites apps moyennes, dont la "leader" déteste.

---

## 2. Est-ce qu'on peut monétiser ? → PAS par abonnement (honnêteté brutale)

**Les propriétaires ne paient quasiment pas pour un tracker de santé animal.**
- En France, le créneau est déjà couvert par **6+ apps GRATUITES** subventionnées par des labos/assureurs
  (Zoovet/Virbac, Animoo, SOS Pets, OOpet Fit, VetoVeto, Mon Compagnon).
- La seule qui a **forcé l'abonnement** (11pets) **s'est effondrée à 2,12/5**.
- Chiffres durs (RevenueCat 2026, 115 000+ apps) : l'app à abonnement **médiane gagne ~72 $/mois** après 1 an ;
  **4,6 %** seulement atteignent 10 000 $/mois ; 17,3 % atteignent 1 000 $/mois ; conversion ~2 %.
- ⚠️ Piège mental : les Français dépensent **~1 224 €/an/animal** (Harris/Cetelem) — mais ça va à la
  **nourriture (611 €), l'hygiène (356 €), le véto (148 €)**, *pas aux apps*. **Grosse dépense ≠ payer pour une app.**

➡️ **Un abonnement 3-7 €/mois sur un tracker basique = irréaliste pour un solo débutant.**

### Les 2 voies de monétisation qui marchent vraiment

**Voie 1 — Achat unique sur une sous-niche (le plus simple en solo).**
App **privacy-first, 100 % locale, sans compte**, ciblée **animal malade chronique / âgé**. Pas de cloud =
**zéro coût d'infra** → un **achat unique ~9,99-14,99 €** est rentable seul, et c'est un **argument anti-paywall**
direct contre le trauma 11pets. Revenus **modestes mais réels**, pas de churn à gérer.

**Voie 2 — App GRATUITE + affiliation assurance (plafond plus haut).**
Le marché FR de l'**assurance animale explose** : **600 M€** en 2025 (vs 400 M en 2020), **+8 %/an**, et
**seulement ~5 %** des animaux assurés (vs 91 % en Suède) = énorme marge. Dalma (37 M€ levés, 60k+ animaux,
**rentable**, app gratuite) prouve le modèle. Les assureurs paient pour des leads (SanteVet ~6 €/lead ; aux US
25-125 $/vente). ⚠️ **MAIS** : l'affiliation assurance en France peut exiger un **statut d'intermédiaire ORIAS**
(réglementé) — **à vérifier avant de te lancer**. Et il faut du **volume**.

---

## 3. L'angle de différenciation recommandé

**Une app francophone "privacy-first" dédiée à l'animal MALADE CHRONIQUE et ÂGÉ** (diabète, insuffisance
rénale, épilepsie, arthrose, polymédication senior), avec **3 promesses tenues parfaitement** :
1. **Rappels de médicaments ultra-fiables** à l'heure exacte (le point faible de TOUS les concurrents).
2. **Log dose / symptôme / glycémie en 1 tap.**
3. **Export PDF "prêt pour le véto".**

Pourquoi cet angle :
- Tu **évites la guerre frontale** du carnet généraliste (saturé de gratuits) en visant un propriétaire
  **anxieux, engagé et solvable**, mal servi par les apps gratuites d'assureurs/labos.
- Ton positionnement **"sans IA, sans cloud, données locales, sans paywall-otage"** a enfin un **vrai ennemi**
  contre qui se définir : 11pets (haï pour son paywall). C'est la première fois de tout le projet que cet angle
  trouve une cible nette.
- Niche **validée aux US** (PillPaw, Petfetti, neufs) mais **quasi vide en français** : ta fenêtre avant qu'ils
  se localisent.

⚠️ **L'angle France ne protège PAS par la réglementation** : ICAD/passeport sont régaliens (app officielle
Filalapat, passeport réservé aux vétos) → non appropriable. Le fossé est **commercial** (assurance) et
**produit** (qualité/fiabilité), pas réglementaire.

---

## 4. La distribution (la vraie difficulté) — sois prévenu

Dans l'univers animal, le moteur de croissance **n'est PAS l'ASO** (mots-clés génériques saturés) ni Reddit
(hostile à la promo). **C'est la VIDÉO** : TikTok / Instagram dans la niche animale est ultra-viral (un cas
documenté : **0 → 370 000 utilisateurs sans budget**). Groupes Facebook FR + Wamiz = canaux secondaires **si**
tu apportes de la valeur gratuite.

➡️ **Conséquence honnête** : ici, le **travail principal sera de créer du contenu vidéo régulier**, pas de coder.
C'est exactement le type de distribution que tu disais ne pas vouloir faire. **À toi de décider si tu es prêt** —
parce que sans ça, l'ASO seul est faible dans cet univers.

---

## 5. Le MVP (la SEULE chose à coder pour la v1)

1. Ajouter un animal (nom, espèce, photo, date de naissance, poids).
2. Ajouter des **traitements/médicaments** avec **rappels fiables** (cœur du produit).
3. **Log 1-tap** : "donné à 8h", dose, symptôme/note, poids/glycémie.
4. Historique + petit graphe (poids, glycémie).
5. **Export PDF** propre pour le véto.
6. 100 % local, **pas de compte, pas de cloud**.

**STOP.** Multi-animaux, sauvegarde cloud, partage = **premium / plus tard**. Ne jamais bloquer les données déjà
saisies derrière un paywall (l'erreur fatale de 11pets).

---

## 6. Prochaines étapes (avant de coder des semaines)

1. **Valider la douleur** : groupes FB FR "diabète chien/chat", "insuffisance rénale chat", forums Wamiz, r/cats.
   Lis aussi les **avis 1-2★ de 11pets/Zoovet**. Note 5 frustrations récurrentes.
2. **Décider du modèle** : achat unique niche (simple) OU gratuit + affiliation (vérifier ORIAS d'abord).
3. **Te tester côté distribution** : es-tu prêt à poster de la vidéo/du contenu régulièrement ? Si non →
   modèle achat unique + ASO, et revenus très modestes assumés.
4. Installer Flutter, coder le **MVP minuscule** ci-dessus, le montrer à 5 propriétaires concernés.

---

## Sources principales
- App Store / Google Play : 11pets, Mon Compagnon (Solly Azar), Zoovet, Animoo ; Kimola (analyse avis 11pets).
- PetDesk, Rover/Wag, Tractive/Whistle (catégories adjacentes).
- RevenueCat — State of Subscription Apps 2026 (médiane 72 $/mois, 4,6 % > 10k, conversion ~2 %).
- Assurance animale FR : marché 600 M€ / +8 %/an / ~5 % pénétration ; Dalma (37 M€, 60k+ animaux) ; SanteVet (~6 €/lead).
- Dépense animaux FR : Harris Interactive / Observatoire Cetelem (1 224 €/an).
- ICAD / Filalapat (réglementaire, non appropriable).

## Note de fiabilité
- "Les gens dépensent 1 224 €/an" est réel mais va à la nourriture/véto, **pas aux apps** — ne pas confondre.
- Pas de témoignage chiffré d'une app animal solo rentable trouvé (revenus indie non vérifiables).
- Commissions d'affiliation assurance FR exactes non publiques (CPL SanteVet ~6 € documenté ; CPA à négocier).
- Statut ORIAS pour l'affiliation assurance : à confirmer juridiquement avant de bâtir le business dessus.
