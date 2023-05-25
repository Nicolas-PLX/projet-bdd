-- Requête qui porte sur au moins 3 tables VERIFIE
\! echo "Requête 1 : Les utilisateurs qui vont participé à un concert qui à lieu en dehors de la France";

SELECT Utilisateurs.pseudo,Concert.nom FROM Utilisateurs
JOIN Participation ON Utilisateurs.id_user = Participation.id_personne
JOIN Concert ON Participation.id_concert = Concert.id_concert
JOIN Lieu_concert ON Concert.id_concert = Lieu_concert.id_concert
JOIN Lieu ON Lieu.id_lieu = Lieu_concert.id_lieu
WHERE Participation.a_participe = True 
AND Lieu.pays != 'France';

-- auto jointure 
\! echo "Requête 2 : Les utilisateurs qui habitent dans la même ville :";


SELECT DISTINCT u1.pseudo AS utilisateur1, u2.pseudo AS utilisateur2, u1.ville
FROM Utilisateurs u1
JOIN Utilisateurs u2 ON u1.ville = u2.ville AND u1.id_user <> u2.id_user AND u1.id_user < u2.id_user
;


--Sous requête corrélée
\! echo "Requête 3 : Les utilisateurs qui participeront à tous les concert disponibles :";

SELECT u.pseudo FROM Utilisateurs u
WHERE NOT EXISTS (
    SELECT * FROM Concert c
    WHERE NOT EXISTS(
        SELECT * FROM Participation p
        WHERE p.id_personne = u.id_user
        AND p.id_concert = c.id_concert
        AND p.a_participe = true
    )
);


--Avec une sous requête dans le FROM
\! echo "Requête 4 : Moyenne des prix des concerts pour chaque ville dans l'ordre décroissant:";

SELECT DISTINCT avg_price.ville, avg_price.avg_price_concert
FROM (
    SELECT Lieu.ville, AVG(Concert.prix) AS avg_price_concert
    FROM Concert
    JOIN Lieu_concert ON Lieu_concert.id_concert = Concert.id_concert
    JOIN Lieu ON Lieu_concert.id_lieu = Lieu.id_lieu
    GROUP BY ville
) AS avg_price
ORDER BY avg_price.avg_price_concert DESC;

--Avec une sous requête dans le WHERE
\! echo "Requête 5 : Tout les artistes qui ont des concerts prévus à partir de la date actuelle :";

SELECT nom FROM Artiste
WHERE id_artiste IN (
    SELECT Lineup.id_artiste
    FROM Lineup
    JOIN Concert ON Lineup.id_concert = Concert.id_concert
    WHERE Concert.date_concert >= CURRENT_DATE
);


--Deux requêtes avec agregat + HAVING
\! echo "Requête 6 : Les artistes ayant une moyenne des avis leur concernant d'au moins 8/10 :";

SELECT Artiste.nom, AVG(Avis.note) AS moyenne_notes
FROM Artiste
JOIN Avis ON Artiste.id_artiste = Avis.id_type
GROUP BY Artiste.nom
HAVING AVG(Avis.note) > 8;

\! echo "Requête 7 : Les artistes avec au moins 3 morceaux sur la plateforme :";

SELECT A.nom, COUNT(M.id_morceau) AS nombre_de_morceaux
FROM Artiste A JOIN Morceau M
ON A.id_artiste = M.id_artiste
GROUP BY A.nom
HAVING COUNT(M.id_morceau) >= 3
ORDER BY nombre_de_morceaux DESC;


--Requête bonus intéressante pour le projet : les 50 morceaux les plus aimés, ainsi que l'artiste qui a réalisé le morceau, ranger dans l'ordre décroissant.

\! echo "Requête 8 : Les 10 morceaux les plus appréciés de la plateforme :";

SELECT Morceau.nom AS nom_morceau, Artiste.nom AS nom_artiste, AVG(Avis.note) AS note_moyenne
FROM Morceau
JOIN Artiste ON Morceau.id_artiste = Artiste.id_artiste
JOIN Avis ON Morceau.id_morceau = Avis.id_type AND Avis.type_avis = 'Morceau'
GROUP BY Morceau.id_morceau, Artiste.nom
ORDER BY note_moyenne DESC
LIMIT 10;


--Requête avec calcul de deux agrégats 

\! echo "Requête 9 : Le nombre total de concerts et le prix moyen des concerts où au moins une personne a participé.";

SELECT COUNT(DISTINCT c.id_concert) AS total_concerts, AVG(c.prix) AS average_price
FROM Concert c
JOIN Participation p ON c.id_concert = p.id_concert
WHERE p.a_participe = true;

--Requête avec une jointure externe

\! echo "Requête 10 : Les utilisateurs et nombre d'avis qu'ils ont publiés :";

SELECT Utilisateurs.pseudo, COUNT(Avis.id_avis) AS nombre_avis
FROM Utilisateurs
LEFT JOIN Auteur_avis ON Utilisateurs.id_user = Auteur_avis.id_user
LEFT JOIN Avis ON Auteur_avis.id_avis = Avis.id_avis
GROUP BY Utilisateurs.id_user, Utilisateurs.pseudo
HAVING COUNT(Avis.id_avis) > 0;


-- Deux requête équivalentes l'une avec des sous requêtes corrélées et l'autre avec de l'agrégation : VERIFIE

\! echo "Requête 11 : Les personnes qui ont assisté à un concert (agrégation):";
SELECT u.pseudo,u.id_user
FROM Utilisateurs u
JOIN Participation p ON u.id_user = p.id_personne
GROUP BY u.id_user
HAVING COUNT(p.id_concert) > 0
ORDER BY u.id_user ASC;

\! echo "Requête 12 : Les personnes qui ont assisté à un concert (corrélées) :"
SELECT u.pseudo,u.id_user
FROM Utilisateurs u
WHERE u.id_user IN (SELECT u.id_user 
                  FROM Participation p 
                  WHERE u.id_user = p.id_personne);

--Requête récursive : pas sûr du tout mais bon

\! echo "Requête 13 : Requête récursive : arbre généalogiques des genres "
/*
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

*/
-- Requête avec fenêtrage

\! echo "Requête 14 : Classement des utilisateurs en fonction de leur participation à des concerts:";


SELECT id_user, pseudo, participations,
       RANK() OVER (ORDER BY participations DESC) AS classement
FROM (
    SELECT u.id_user, u.pseudo, COUNT(p.id_personne) AS participations
    FROM Utilisateurs u
    LEFT JOIN Participation p ON u.id_user = p.id_personne
    WHERE p.a_participe = True
    GROUP BY u.id_user, u.pseudo
    HAVING COUNT(p.id_personne) > 0
) AS subquery;

\! echo "Requête 15 :"



