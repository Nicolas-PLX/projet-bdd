-- Requête qui porte sur au moins 3 tables
\! echo "Requête 1 : Les utilisateurs qui sont interessé par un concert qui à lieu en dehors de la France";

SELECT Utilisateurs.pseudo FROM Utilisateurs
JOIN Participation ON Utilisateurs.id_user = Participation.id_user
JOIN Concert ON Participation.id_concert = Concert.id_concert
JOIN Lieu_concert ON Concert.id_concert = Lieu_concert.id_concert
JOIN Lieu ON Lieu.id_lieu = Lieu_concert.id_lieu
WHERE Participation.est_interesse = TRUE 
AND Lieu.pays != 'France';

-- auto jointure 
\! echo "Requête 2 : Les Concert différent qui ont lieu dans la même ville à la même date :";


SELECT a1.suiveur AS Utilisateurs_1, a2.suiveur AS Utilisateurs_2
FROM Amis a1 JOIN Amis a2 ON a1.suivi = a2.suivi AND a1.suiveur <> a2.suiveur
WHERE a1.suiveur < a2.suiveur;


--Sous requête corrélée
\! echo "Requête 3 : Les utilisateurs qui souhaite participé à tous les concert disponibles :";

SELECT Utilisateurs.pseudo FROM Utilisateurs
WHERE NOT EXISTS (
    SELECT * FROM Concert
    WHERE NOT EXISTS(
        SELECT * FROM Participation p
        WHERE p.id_personne = u.id_user
        AND p.id_concert = c.id_concert
    )
);


--Avec une sous requête dans le FROM
-- Gros doute qu'elle marche
\! echo "Requête 4 : Moyenne des notes des avis pour chaque utilisateur :";

SELECT ssr.User, AVG(a.note) AS Notes_moyenne
FROM (
    SELECT u.id_user, u.pseudo AS User, aa.id_avis
    FROM Utilisateurs u 
    JOIN  Auteur_avis aa ON u.id_user = aa.id_user
) ssr
JOIN Avis a ON sub.id_avis = a.id_avis
GROUP BY sub.id_user, sub.Utilisateurs;


--Avec une sous requête dans le WHERE
--Un peu facile mais bon 
\! echo "Requête 5 : Tout les artistes qui ont des concerts prévus à partir de la date actuelle :";

SELECT nom FROM Artiste
WHERE id_artiste IN (
    SELECT id_artiste
    FROM Concert
    WHERE date_concert >= CURRENT_DATE
);


--Deux requêtes avec agregat + HAVING COUNT
\! echo "Requête 6 : Les artistes ayant une moyenne des avis leur concernant d'au moins 8/10 :";

SELECT Artiste.nom, AVG(Avis.note) AS moyenne_notes
FROM Artiste
JOIN Avis ON Artiste.id_artiste = Avis.id_type
GROUP BY Artiste.nom
HAVING AVG(Avis.note) > 8;

\! echo "Requête 7 : Les artistes avec au moins 5 morceaux sur la plateforme :";

SELECT A.nom, COUNT(M.id_morceau) AS nombre_de_morceaux
FROM Artiste A JOIN Morceau M
ON Artiste.id_artiste = Morceau.id_artiste
GROUP BY Artiste.nom
HAVING COUNT(Morceau.id_morceau) >= 5
ORDER BY nombre_de_morceaux DESC;


--Requête bonus intéressante pour le projet : les 50 morceaux les plus aimés, ainsi que l'artiste qui a réalisé le morceau, ranger dans l'ordre décroissant.

\! echo "Requête 8 : Les 50 morceaux les plus appréciés de la plateforme :";

SELECT Morceau.nom AS nom_morceau, Artiste.nom AS nom_artiste, AVG(Avis.note) AS note_moyenne
FROM Morceau
JOIN Artiste ON Morceau.id_artiste = Artiste.id_artiste
JOIN Avis ON Morceau.id_morceau = Avis.id_type AND Avis.type_avis = 'Morceau'
GROUP BY Morceau.id_morceau, Artiste.nom
ORDER BY note_moyenne DESC
LIMIT 50;


--Requête avec calcul de deux agrégats : pas encore fait 

\! echo "Requête 9 : Calcul du maximum des prix et des nombres de places des concert finis";

SELECT
    AVG(max_prix) AS moyenne_max_prix,
    AVG(max_nb_participants) AS moyenne_max_nb_participants
FROM
    (SELECT MAX(prix) AS max_prix,MAX(nb_participant) AS max_nb_participants
    FROM Concert_fini 
    JOIN Archive ON Archive.id_concert = Concert_fini.id_concert
    GROUP BY
        id_concert) AS subquery

--Requête avec une jointure externe

\! echo "Requête 10 : Les utilisateurs et nombre d'avis qu'ils ont publiés :";

SELECT Utilisateurs.pseudo, COUNT(Avis.id_avis) AS nombre_avis
FROM Utilisateurs
LEFT JOIN Auteur_avis ON Utilisateurs.id_user = Auteur_avis.id_user
LEFT JOIN Avis ON Auteur_avis.id_avis = Avis.id_avis
GROUP BY Utilisateurs.id_user, Utilisateurs.pseudo
HAVING COUNT(Avis.id_avis) > 0;

--Requête récursive : pas sûr du tout mais bon

\! echo "Requête 11 : Requête récursive : arbre généalogiques des genres "

WITH RECURSIVE Arborescence_Genres AS (
    SELECT id_genre, nom, ARRAY[id_genre] AS chemin
    FROM Genre
    WHERE id_genre = 1 -- Genre racine de départ
    UNION ALL
    SELECT g.id_genre, g.nom, ag.chemin || g.id_genre
    FROM Genre g
    INNER JOIN Arborescence_Genres ag ON g.id_genre = ANY(ag.chemin) -- Jointure récursive avec les genres parents déjà sélectionnés
)
SELECT id_genre, nom, chemin
FROM Arborescence_Genres
ORDER BY chemin;


-- Requête avec fenêtrage

\! echo "Requête 12 : Pour chaque mois de l'année 2022, les dix groupes dont les concerts ont eu le plus de succès en termes de nombres d'utilisateurs souhaitant y participer :";

--
WITH concerts_populaires AS (
    SELECT EXTRACT(MONTH FROM date_concert) AS mois,id_concert,COUNT(*) AS nombre_participants
    FROM Participation
    JOIN Concert ON Participation.id_concert = Concert.id_concert
    WHERE EXTRACT(YEAR FROM date_concert) = 2022
    GROUP BY mois, id_concert
),
classement_groupes AS (
    SELECT
        mois, id_concert, nombre_participants,
        ROW_NUMBER() OVER (PARTITION BY mois ORDER BY nombre_participants DESC) AS rang
    FROM concerts_populaires
)
SELECT C.mois,G.nom AS nom_groupe,C.nombre_participants
FROM classement_groupes C
JOIN Concert ON C.id_concert = Concert.id_concert
JOIN Groupe G ON Concert.id_groupe = G.id_groupe
WHERE C.rang <= 10
ORDER BY C.mois, C.rang;


\! echo "Requête 13 :"



