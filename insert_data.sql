
\copy Personnes(pseudo, email, pwd, pays, ville, date_creation,date_naissance) FROM 'CSV/Personnes.csv' DELIMITER ',' CSV HEADER;

\copy Concert(nom,date_concert,prix,nb_places,volontaires,cause_soutien,enfants_admissibles) FROM 'CSV/Concert.csv' DELIMITER ',' CSV HEADER;

\copy Lieu(adresse,ville,code_postal,pays) FROM 'CSV/Lieu.csv' DELIMITER ',' CSV HEADER;

INSERT INTO Participation(id_personne,id_concert,est_interesse)
VALUES(1,1,False),
(1,2,False),
(1,3,False),
(1,4,False),
(1,5,False),
(1,6,True),
(1,7,False),
(1,8,False),
(1,9,False),
(1,10,False),
(1,11,False),
(1,12,False),
(1,13,True),
(1,14,False),
(1,15,False),
(1,16,False),
(1,17,True),
(1,18,False),
(1,19,False),
(1,20,False),
(1,21,False),
(1,22,False),
(1,23,False),
(1,24,False),
(1,25,False),
(2,22,True);

INSERT INTO Lieu_concert(id_concert,id_lieu)
VALUES(1,1),
(2,1),
(3,2),
(4,4),
(6,5);
