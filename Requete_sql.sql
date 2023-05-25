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
WHERE p.a_participe = True
GROUP BY u.id_user
HAVING COUNT(p.id_concert) > 0
ORDER BY u.id_user ASC;

\! echo "Requête 12 : Les personnes qui ont assisté à un concert (corrélées) :"
SELECT u.pseudo,u.id_user
FROM Utilisateurs u
WHERE u.id_user IN (SELECT u.id_user 
                  FROM Participation p 
                  WHERE u.id_user = p.id_personne AND p.a_participe = True);

--Requête récursive : pas sûr du tout mais bon

\! echo "Requête 13 : Requête récursive : arbre généalogiques des genres "
SELECT a.nom AS nom_artiste,COUNT(DISTINCT l.id_concert) AS nombre_concerts
FROM Artiste a
JOIN Lineup l ON a.id_artiste = l.id_artiste
GROUP BY a.id_artiste, a.nom
ORDER BY COUNT(DISTINCT l.id_concert) DESC;

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

\! echo "Requête 15 : Récupère les utilisateurs qui ont participé à tout les concerts organisé dans une ville donnée :";

\prompt 'Tapez le nom de la ville -> ' v_ville
SELECT u.id_user, u.pseudo
FROM Utilisateurs u
JOIN Participation p ON u.id_user = p.id_personne
JOIN Concert c ON p.id_concert = c.id_concert
JOIN Lieu_concert lc ON lc.id_concert = c.id_concert
JOIN Lieu l ON l.id_lieu = lc.id_lieu
WHERE l.ville = :'v_ville'
GROUP BY u.id_user, u.pseudo
HAVING COUNT(DISTINCT c.id_concert) = (
    SELECT COUNT(*)
    FROM Concert JOIN Lieu_concert ON Lieu_concert.id_concert = Concert.id_concert
    JOIN Lieu ON Lieu.id_lieu = Lieu_concert.id_lieu
    WHERE ville = :'v_ville'
);


\! echo "Requête 16 : Calcule de la différence de prix entre chaque concert et le concert précédent dans une même ville :";
SELECT c.id_concert, c.nom, c.date_concert, l.ville, c.prix,
       prix - LAG(prix) OVER (PARTITION BY ville ORDER BY date_concert) AS diff_prix
FROM Concert c JOIN Lieu_concert lc ON c.id_concert = lc.id_concert
JOIN Lieu l ON lc.id_lieu = l.id_lieu
ORDER BY ville, date_concert;

\! echo "Requête 17 :La liste des villes qui ont une moyenne de prix de concert supérieur à la moyenne générale :";

WITH avg_prices AS (
    SELECT l.ville, AVG(prix) AS moyenne_prix
    FROM Concert c JOIN Lieu_concert lc ON lc.id_concert = c.id_concert
    JOIN Lieu l ON l.id_lieu = lc.id_lieu
    GROUP BY l.ville
), overall_avg AS (
    SELECT AVG(prix) AS moyenne_generale
    FROM Concert
)
SELECT a.ville, a.moyenne_prix
FROM avg_prices a
JOIN overall_avg o ON a.moyenne_prix > o.moyenne_generale
ORDER BY a.moyenne_prix DESC;

\i echo "Requête 18 : La liste des utilisateurs ayant des morceaux en commun dans leur playlist, ainsi que le nombre de morceaux en commun :";

SELECT DISTINCT p1.id_user AS utilisateur_1, p2.id_user AS utilisateur_2, COUNT(*) AS nombre_morceaux_communs
FROM Playlist p1
JOIN Contient c1 ON p1.id_playlist = c1.id_playlist
JOIN Contient c2 ON c1.id_morceau = c2.id_morceau
JOIN Playlist p2 ON c2.id_playlist = p2.id_playlist
WHERE p1.id_user < p2.id_user 
GROUP BY p1.id_user, p2.id_user;

\i echo "Requête 19 : Requête récursive qui va récupérer la liste de tous les utilisateurs qui sont suivis par un utilisateur donné";


\prompt 'Tapez l id de l utilisateur que vous souhaitez voir ->' c_user
WITH RECURSIVE SuivisUtilisateur(suiveur, suivi) AS (
  SELECT suiveur, suivi
  FROM Suivis
  WHERE suiveur = :c_user
  UNION ALL
  SELECT Suivis.suiveur, Suivis.suivi
  FROM SuivisUtilisateur
  JOIN Suivis ON SuivisUtilisateur.suivi = Suivis.suiveur
)
SELECT DISTINCT suivi
FROM SuivisUtilisateur;

\i echo "Requête 20 : Requête récursive qui va récupérer tout les parents d'un genre donné :";

\prompt 'Tapez l id du genre à celui dont vous souhaitez voir ses parents ->' c_genre
WITH RECURSIVE GenresParents(id_genre, id_parent) AS (
  SELECT id_fils, id_parent
  FROM Relation_genre
  WHERE id_fils = :c_genre
  UNION ALL
  SELECT Relation_genre.id_fils, Relation_genre.id_parent
  FROM GenresParents
  JOIN Relation_genre ON GenresParents.id_parent = Relation_genre.id_fils
)
SELECT id_parent
FROM GenresParents 
ORDER BY id_parent DESC;
