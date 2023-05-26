
PREPARE location_score(text, text) AS
SELECT (u.pays = l.pays)::integer AS location_score
FROM Utilisateurs u ,Concert c
JOIN Lieu_concert lc ON lc.id_concert = c.id_concert
JOIN Lieu l ON lc.id_lieu = l.id_lieu
WHERE u.pseudo = $1 AND c.nom = $2;

EXECUTE location_score('Marthe_ini', 'The Formation World Tour');


PREPARE event_history_score(text, text) AS
SELECT 
    EXISTS (
        SELECT 1 
        FROM Participation p 
        JOIN Lineup l_past ON p.id_concert = l_past.id_concert
        JOIN Concert c_past ON p.id_concert = c_past.id_concert
        JOIN Artiste a_past ON l_past.id_artiste = a_past.id_artiste
        WHERE p.id_personne = 
        (SELECT id_user FROM Utilisateurs WHERE pseudo = $1) AND 
            a_past.nom = $2 AND
            p.a_participe = true
        )::integer AS event_history_score;

EXECUTE event_history_score('Marthe_ini', 'John Smith');



PREPARE friend_event_score(text, text) AS
WITH user_friends AS (
    SELECT DISTINCT suivi
    FROM Suivis 
    WHERE suiveur = (SELECT id_user FROM Utilisateurs WHERE pseudo = $1)
)
SELECT 
    EXISTS (
        SELECT 1 
        FROM Participation p 
        JOIN Lineup l_past ON p.id_concert = l_past.id_concert
        JOIN Utilisateurs u_friend ON p.id_personne = u_friend.id_user
        JOIN Suivis s ON u_friend.id_user = s.suiveur
        JOIN Lineup l_friend ON s.suivi = l_friend.id_concert
        JOIN Concert c_past ON p.id_concert = c_past.id_concert
        JOIN Artiste a_past ON l_past.id_artiste = a_past.id_artiste
        WHERE l_friend.id_concert = c_past.id_concert AND a_past.nom = $2 AND p.a_participe = true
    )::integer AS friend_event_score;

EXECUTE friend_event_score('Marthe_ini', 'John Smith');


PREPARE recommendation_score(text) AS
SELECT 
    c.id_concert,
    (
        (SELECT location_score(u.pseudo, c.nom)) +
        (SELECT event_history_score(u.pseudo, (SELECT nom FROM Artiste WHERE id_artiste = (SELECT id_artiste FROM Lineup WHERE id_concert = c.id_concert)))) +
        (SELECT friend_event_score(u.pseudo, (SELECT nom FROM Artiste WHERE id_artiste = (SELECT id_artiste FROM Lineup WHERE id_concert = c.id_concert))))    
    ) AS total_score
FROM Concert c
JOIN Utilisateurs u ON true;

EXECUTE recommendation_score('Marthe_ini');


DEALLOCATE location_score;
DEALLOCATE event_history_score;
DEALLOCATE friend_event_score;
DEALLOCATE recommendation_score;