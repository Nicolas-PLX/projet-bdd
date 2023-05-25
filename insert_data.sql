\i drop.sql
\i create_table.sql

/*
DROP TABLE IF EXISTS temp_Lineup,temp_Tag,temp_Relation_genre,temp_Genre,temp_Contient,temp_Morceau,temp_Playlist,temp_Auteur_avis,temp_Archive_avis,temp_Avis,temp_Artiste,temp_Lieu,temp_Archive,temp_Organisation,temp_Participation,temp_concerts,temp_personnes,temp_relations,temp_users,temp_groupes CASCADE;

CREATE TEMP TABLE temp_users
(
    id_user SERIAL PRIMARY KEY,
    pseudo VARCHAR(30) ,
    email varchar(30) ,
    pwd VARCHAR(30) ,
    pays VARCHAR(30),
    ville VARCHAR(30),
    date_creation DATE
);

\COPY temp_users(pseudo, email, pwd, pays, ville, date_creation) FROM 'CSV/Utilisateur.csv' DELIMITER ','  CSV HEADER;

INSERT INTO Utilisateurs(pseudo, email, pwd, pays, ville, date_creation)
SELECT pseudo,email,pwd,pays,ville,date_creation FROM temp_users;


CREATE TEMP TABLE temp_personnes
(
    id INTEGER,
    date_naissance DATE
);

CREATE TEMP TABLE temp_groupes
(
    id INTEGER,
    nom VARCHAR(30)
);
CREATE TEMP TABLE temp_relations
(
    id1 INTEGER,
    id2 INTEGER
);

CREATE TEMP TABLE temp_concerts
(
    nom VARCHAR(50),
    date_concert DATE,
    prix FLOAT,
    nb_places INTEGER,
    volontaires boolean,
    cause_soutien VARCHAR(100),
    enfants_admissibles BOOLEAN
);

CREATE TEMP TABLE temp_Participation
(
    id_personne INTEGER,
    id_concert INTEGER,
    est_interesse boolean,
    a_participe boolean
);
CREATE TEMP TABLE temp_Organisation
(
    id_user INTEGER,
    id_concert INTEGER
);

CREATE TEMP TABLE temp_Archive 
(
    id_concert INTEGER,
    nb_participant INTEGER,
    lien_photo VARCHAR(100),
    lien_video VARCHAR(100)
);

CREATE TEMP TABLE temp_Lieu
(
    adresse VARCHAR(50) NOT NULL,
    ville VARCHAR(50) NOT NULL,
    code_postal VARCHAR(10) NOT NULL,
    pays VARCHAR(20) NOT NULL
);

CREATE TEMP TABLE temp_Lieu_concert
(
    id_concert INTEGER,
    id_lieu INTEGER
);


\copy temp_personnes(id, date_naissance) FROM 'CSV/Personne.csv' DELIMITER ',' CSV HEADER;
INSERT INTO Personnes(id_personne, date_naissance)
SELECT id, date_naissance FROM temp_personnes;



\copy temp_groupes(id, nom) FROM 'CSV/Groupe.csv' DELIMITER ',' CSV HEADER;
INSERT INTO Groupe(id_groupe, nom)
SELECT id,nom  FROM temp_groupes;


\copy temp_relations(id1, id2) FROM 'CSV/Suivis.csv' DELIMITER ',' CSV HEADER;
INSERT INTO Amis(id_user, id_ami)
SELECT id1, id2 FROM temp_relations LIMIT 20;

INSERT INTO Suivis(suiveur, suivi)
SELECT id1, id2 FROM temp_relations OFFSET 20;


\copy temp_concerts(nom, date_concert, prix, nb_places, volontaires, cause_soutien, enfants_admissibles) FROM 'CSV/Concert.csv' DELIMITER ',' CSV HEADER;
INSERT INTO Concert(nom, date_concert, prix, nb_places, volontaires, cause_soutien, enfants_admissibles) 
SELECT nom, date_concert, prix, nb_places, volontaires, cause_soutien, enfants_admissibles FROM temp_concerts;

\copy temp_Participation(id_personne, id_concert, est_interesse, a_participe) FROM 'CSV/Participation.csv' DELIMITER ',' CSV HEADER;
INSERT INTO Participation(id_personne, id_concert, est_interesse, a_participe)
SELECT id_personne, id_concert, est_interesse, a_participe FROM temp_Participation;


\copy temp_Organisation(id_user, id_concert) FROM 'CSV/Organisation.csv' DELIMITER ',' CSV HEADER;
INSERT INTO Organisation(id_user, id_concert)
SELECT id_user, id_concert FROM temp_Organisation;


INSERT INTO Concert_prevu(id_concert, nb_places_restantes)
SELECT id_concert, nb_places-10 FROM Concert;

\copy temp_Archive(id_concert, nb_participant, lien_photo, lien_video) FROM 'CSV/Archive.csv' DELIMITER ',' CSV HEADER;
INSERT INTO Archive(id_concert, nb_participant, lien_photo, lien_video)
SELECT id_concert, nb_participant, lien_photo, lien_video FROM temp_Archive;


INSERT INTO Concert_fini(id_archive,id_concert)
SELECT id_archive,id_concert FROM Archive;

\copy temp_Lieu(adresse, ville,code_postal ,pays) FROM 'CSV/Lieu.csv' DELIMITER ',' CSV HEADER;
INSERT INTO Lieu(adresse, ville, code_postal,pays)
SELECT adresse, ville, code_postal,pays FROM temp_Lieu;

\copy temp_Lieu_concert(id_concert, id_lieu) FROM 'CSV/Lieu_concert.csv' DELIMITER ',' CSV HEADER;
INSERT INTO Lieu_concert(id_concert, id_lieu)
SELECT id_concert, id_lieu FROM temp_Lieu_concert;

CREATE TEMP TABLE temp_Artiste
(
    nom VARCHAR(30),
    id_groupe INTEGER
);
\copy temp_Artiste(nom, id_groupe) FROM 'CSV/Artiste.csv' DELIMITER ',' CSV HEADER;
INSERT INTO Artiste(nom, id_groupe)
SELECT nom, id_groupe FROM temp_Artiste;

CREATE TEMP TABLE temp_Avis
(
    type_avis type_avis,
    note INTEGER CHECK (note >= 0 AND note <= 10),
    commentaire VARCHAR(140),
    date_avis DATE
);
\copy temp_Avis(type_avis, note, commentaire, date_avis) FROM 'CSV/Avis.csv' DELIMITER ',' CSV HEADER;
INSERT INTO Avis(type_avis, note, commentaire, date_avis)
SELECT type_avis, note, commentaire, date_avis FROM temp_Avis;


CREATE TEMP TABLE temp_Archive_avis
(
    id_avis INTEGER,
    id_archive INTEGER
);
\copy temp_Archive_avis(id_avis, id_archive) FROM 'CSV/Archive_avis.csv' DELIMITER ',' CSV HEADER;
INSERT INTO Archive_avis(id_avis, id_archive)
SELECT id_avis, id_archive FROM temp_Archive_avis;


CREATE TEMP TABLE temp_Auteur_avis
(
    id_avis INTEGER,
    id_user INTEGER
);
\copy temp_Auteur_avis(id_avis, id_user) FROM 'CSV/Auteur_avis.csv' DELIMITER ',' CSV HEADER;
INSERT INTO Auteur_avis(id_avis, id_user)
SELECT id_avis, id_user FROM temp_Auteur_avis;

CREATE TEMP TABLE temp_Playlist
(
    id_user INTEGER,
    nom VARCHAR(30)
);
\copy temp_Playlist(id_user, nom) FROM 'CSV/Playlist.csv' DELIMITER ',' CSV HEADER;
INSERT INTO Playlist(id_user, nom)
SELECT id_user, nom FROM temp_Playlist;

CREATE TEMP TABLE temp_Morceau
(
    nom VARCHAR(30),
    id_artiste INTEGER,
    duree TIME
);
\copy temp_Morceau(nom, id_artiste, duree) FROM 'CSV/Morceau.csv' DELIMITER ',' CSV HEADER;
INSERT INTO Morceau(nom, id_artiste, duree)
SELECT nom, id_artiste, duree FROM temp_Morceau;

CREATE TEMP TABLE temp_Contient
(
    id_playlist INTEGER,
    id_morceau INTEGER
);

\copy temp_Contient(id_playlist, id_morceau) FROM 'CSV/Contient.csv' DELIMITER ',' CSV HEADER;

INSERT INTO Contient (id_playlist, id_morceau)
SELECT id_playlist, id_morceau FROM temp_Contient;

CREATE TEMP TABLE temp_Genre
(
    id_genre SERIAL,
    nom VARCHAR(30) NOT NULL
);

\copy temp_Genre(nom) FROM 'CSV/Genre.csv' DELIMITER ',' CSV HEADER;

INSERT INTO Genre (nom)
SELECT nom FROM temp_Genre;


CREATE TEMP TABLE temp_Relation_genre
(
    id_parent INTEGER NOT NULL,
    id_fils INTEGER NOT NULL
);

\copy temp_Relation_genre(id_parent, id_fils) FROM 'CSV/Relation_genre.csv' DELIMITER ',' CSV HEADER;

INSERT INTO Relation_genre (id_parent, id_fils)
SELECT id_parent, id_fils FROM temp_Relation_genre;


CREATE TEMP TABLE temp_Tag
(
    id_tag SERIAL PRIMARY KEY,
    id_type INTEGER NOT NULL,
    type_tag type_tag NOT NULL,
    valeur VARCHAR(30) NOT NULL
);

\copy temp_Tag(id_tag,id_type, type_tag, valeur) FROM 'CSV/Tag.csv' DELIMITER ',' CSV HEADER;

INSERT INTO Tag (id_tag,id_type, type_tag, valeur)
SELECT id_tag,id_type, type_tag, valeur FROM temp_Tag;

CREATE TEMP TABLE temp_Lineup
(
    id_concert INTEGER NOT NULL,
    id_artiste INTEGER NOT NULL,
    performance_index INTEGER NOT NULL,
    PRIMARY KEY(id_concert, id_artiste, performance_index)
);

\copy temp_Lineup(id_concert, id_artiste, performance_index) FROM 'CSV/Lineup.csv' DELIMITER ',' CSV HEADER;

INSERT INTO Lineup (id_concert, id_artiste, performance_index)
SELECT id_concert, id_artiste, performance_index FROM temp_Lineup;

-- select * from Groupe LIMIT 10;
-- select * from Personnes LIMIT 10;
-- select * from Suivis LIMIT 10;
-- select * from Amis LIMIT 10;
*/