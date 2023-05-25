-- Requête qui porte sur au moins 3 tables VERIFIE
\! echo "Requête 1 : Les utilisateurs qui sont intéréssé à un concert qui à lieu en dehors de la France";

SELECT Utilisateurs.pseudo,Concert.nom FROM Utilisateurs
JOIN Participation ON Utilisateurs.id_user = Participation.id_personne
SELECT Utilisateurs.pseudo FROM Utilisateurs
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
ON Artiste.id_artiste = Morceau.id_artiste
GROUP BY Artiste.nom
HAVING COUNT(Morceau.id_morceau) >= 5
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
WHERE NOT EXISTS (
    SELECT *
    FROM Concert c
    WHERE NOT EXISTS (
        SELECT *
        FROM Participation p
        WHERE p.id_personne = u.id_user
        AND p.id_concert = c.id_concert
    )
);

--Requête récursive : pas sûr du tout mais bon

\! echo "Requête 13 : Requête récursive : arbre généalogiques des genres "

WITH RECURSIVE genre_hierarchy AS (
    SELECT g.id_genre, g.nom, g.id_genre AS root
    FROM Genre g
    WHERE NOT EXISTS (SELECT 1 FROM Relation_genre rg WHERE rg.id_fils = g.id_genre)
    
    UNION ALL
    
    SELECT g.id_genre, g.nom, h.root +1
    FROM Genre g
    JOIN Relation_genre rg ON g.id_genre = rg.id_fils
    JOIN genre_hierarchy h ON h.id_genre = rg.id_parent
)
SELECT * FROM genre_hierarchy ORDER BY root;


*/
-- Requête avec fenêtrage

\! echo "Requête 14 : Pour chaque mois de l'année 2022, les dix groupes dont les concerts ont eu le plus de succès en termes de nombres d'utilisateurs souhaitant y participer :";

--
WITH monthly_interest AS (
    SELECT 
        EXTRACT(MONTH FROM c.date_concert) AS month, 
        g.nom AS group_name, 
        COUNT(p.id_personne) AS interested_users_count,
        ROW_NUMBER() OVER (
            PARTITION BY EXTRACT(MONTH FROM c.date_concert)
            ORDER BY COUNT(p.id_personne) DESC
        ) as rn
    FROM  Concert c JOIN Lineup l ON c.id_concert = l.id_concert
    JOIN Groupe g ON l.id_artiste = g.id_groupe
    JOIN Participation p ON c.id_concert = p.id_concert
    WHERE EXTRACT(YEAR FROM c.date_concert) = 2022 AND p.est_interesse = true
    GROUP BY month, group_name
)
SELECT month, group_name, interested_users_count
FROM monthly_interest
WHERE rn <= 10
ORDER BY month, interested_users_count DESC;



\! echo "Requête 15 : la chaîne de suivis pour un utilisateur donné  exemple 1"


WITH RECURSIVE following_chain AS (
    SELECT suiveur, suivi
    FROM Suivis
    WHERE suiveur = 1

    UNION ALL

    SELECT s.suiveur, s.suivi
    FROM Suivis s
    JOIN following_chain fc ON s.suiveur = fc.suivi
)
SELECT * FROM following_chain;



\! echo "Requête 16 : La liste de tous les organismes et le nombre de concerts qu'ils ont organisés ordre decroissant."


SELECT o.nom AS nom_organisme, COUNT(c.id_concert) AS nombre_concerts
FROM Organisme o
JOIN Organisation org ON o.id_orga = org.id_orga
JOIN Concert c ON org.id_concert = c.id_concert
GROUP BY nom_organisme
ORDER BY nombre_concerts DESC;

\! echo "Requête 17 : La une liste de toutes les playlists et le nombre moyen de morceaux par playlist"
SELECT p.nom AS nom_playlist, AVG(COUNT(c.id_morceau)) AS moyenne_morceaux
FROM Playlist p
NATURAL JOIN Contient c
GROUP BY nom_playlist;



\! echo "Requête 18 : La liste des 5 paires d'artistes qui se produisent généralement le plus ensemble, avec le nombre de performances qu'ils ont faites ensemble."

SELECT a1.nom AS artiste_1, a2.nom AS artiste_2, COUNT(*) AS nombre_performances_ensemble
FROM Lineup l1
JOIN Lineup l2 ON l1.id_concert = l2.id_concert AND l1.id_artiste <> l2.id_artiste
JOIN Artiste a1 ON l1.id_artiste = a1.id_artiste
JOIN Artiste a2 ON l2.id_artiste = a2.id_artiste
GROUP BY artiste_1, artiste_2
ORDER BY nombre_performances_ensemble DESC LIMIT 5;


\! echo "Requête 19 : La liste des 3 morceaux les plus ajoutés aux playlists."

SELECT m.nom AS nom_morceau, COUNT(*) AS nombre_ajouts
FROM Morceau m
JOIN Contient c ON m.id_morceau = c.id_morceau
GROUP BY nom_morceau
ORDER BY nombre_ajouts DESC
LIMIT 3;

\! echo "Requête 20 : La liste des artistes qui ont joué plus de 2 fois dans des concerts dont le prix était supérieur à 120 euros."
SELECT a.nom AS nom_artiste, COUNT(*) AS nombre_concerts
FROM Artiste a
JOIN Lineup l ON a.id_artiste = l.id_artiste
JOIN Concert c ON l.id_concert = c.id_concert
WHERE 
    EXISTS (
        SELECT 1 
        FROM Concert c2 
        WHERE c2.id_concert = c.id_concert AND c2.prix > 120
    )
GROUP BY nom_artiste
HAVING COUNT(*) > 2
ORDER BY nombre_concerts DESC;



