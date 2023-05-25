SELECT u.*
FROM Utilisateurs u
LEFT JOIN Participation p ON p.id_personne = u.id_user
GROUP BY u.id_user
HAVING COUNT(DISTINCT p.id_concert) = (
    SELECT COUNT(*) FROM Concert
);

SELECT *
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

SELECT Utilisateurs.pseudo FROM Utilisateurs
JOIN Participation ON Utilisateurs.id_user = Participation.id_personne
JOIN Concert ON Participation.id_concert = Concert.id_concert
JOIN Lieu_concert ON Concert.id_concert = Lieu_concert.id_concert
JOIN Lieu ON Lieu.id_lieu = Lieu_concert.id_lieu
WHERE Participation.est_interesse = True 
AND Lieu.pays != 'France';

SELECT u.pseudo FROM Utilisateurs u
WHERE NOT EXISTS (
    SELECT * FROM Concert c
    WHERE NOT EXISTS(
        SELECT * FROM Participation p
        WHERE p.id_personne = u.id_user
        AND p.id_concert = c.id_concert
    )
);
