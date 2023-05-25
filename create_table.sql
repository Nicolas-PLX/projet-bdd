CREATE TABLE Utilisateurs
(
    id_user SERIAL PRIMARY KEY,
    pseudo VARCHAR(30) NOT NULL CHECK (LENGTH(pseudo) <= 20),
    email varchar(30) NOT NULL,
    pwd VARCHAR(30) NOT NULL CHECK (LENGTH(pwd) >= 8),
    pays VARCHAR(30),
    ville VARCHAR(30),
    date_creation DATE NOT NULL
);

CREATE TABLE Personnes
(
    id_personne INTEGER PRIMARY KEY,
    date_naissance DATE,
    FOREIGN KEY(id_personne) REFERENCES Utilisateurs(id_user)
) ;

CREATE TABLE Groupe
(
    id_groupe INTEGER PRIMARY KEY,
    nom VARCHAR(30) NOT NULL,
    FOREIGN KEY(id_groupe) REFERENCES Utilisateurs(id_user)
) ;

CREATE TABLE Suivis
(
    suiveur INTEGER NOT NULL,
    suivi INTEGER NOT NULL,
    PRIMARY KEY(suiveur, suivi),
    FOREIGN KEY (suiveur) REFERENCES Utilisateurs(id_user),
    FOREIGN KEY (suivi) REFERENCES Utilisateurs(id_user),
    CHECK (suiveur <> suivi)
);
CREATE TABLE Amis
(
    id_user INTEGER NOT NULL,
    id_ami INTEGER NOT NULL,
    PRIMARY KEY(id_user,id_ami),
    FOREIGN KEY(id_user) REFERENCES Utilisateurs(id_user),
    FOREIGN KEY(id_ami) REFERENCES Utilisateurs(id_user),
    CHECK (id_user <> id_ami)
);


CREATE TABLE Concert
(
    id_concert SERIAL PRIMARY KEY,
    nom VARCHAR(50) NOT NULL,
    date_concert DATE NOT NULL,
    prix FLOAT NOT NULL,
    nb_places INTEGER NOT NULL,
    volontaires boolean NOT NULL,
    cause_soutien VARCHAR(100),
    enfants_admissibles BOOLEAN NOT NULL
);

CREATE TABLE Participation
(
    id_personne INTEGER NOT NULL,
    id_concert INTEGER NOT NULL,
    est_interesse boolean NOT NULL,
    a_participe boolean NOT NULL,
    PRIMARY KEY(id_personne,id_concert),
    FOREIGN KEY(id_personne) REFERENCES Personnes(id_personne),
    FOREIGN KEY(id_concert) REFERENCES Concert(id_concert),
   CHECK ( a_participe <> est_interesse)
);

CREATE TABLE Organisation
(
    id_user INTEGER NOT NULL,
    id_concert INTEGER NOT NULL,
    PRIMARY KEY(id_user,id_concert),
    FOREIGN KEY(id_user) REFERENCES Utilisateurs(id_user),
    FOREIGN KEY(id_concert) REFERENCES Concert(id_concert)
);


CREATE TABLE Concert_prevu
(
    id_concert INTEGER PRIMARY KEY,
    nb_places_restantes INTEGER NOT NULL,
    FOREIGN KEY(id_concert) REFERENCES Concert(id_concert)
);
CREATE TABLE Archive
(
    id_archive SERIAL PRIMARY KEY,
    id_concert INTEGER NOT NULL,
    nb_participant INTEGER NOT NULL,
    lien_photo VARCHAR(100),
    lien_video VARCHAR(100),
    FOREIGN KEY(id_concert) REFERENCES Concert(id_concert)
);

CREATE TABLE Concert_fini
(
    id_archive INTEGER NOT NULL,
    id_concert INTEGER NOT NULL,
    PRIMARY KEY(id_concert,id_archive),
    FOREIGN KEY(id_concert) REFERENCES Concert(id_concert),
    FOREIGN KEY(id_archive) REFERENCES Archive(id_archive)
);


CREATE TABLE Lieu
(
    id_lieu SERIAL PRIMARY KEY,
    adresse VARCHAR(50) NOT NULL,
    ville VARCHAR(50) NOT NULL,
    code_postal VARCHAR(10) NOT NULL,
    pays VARCHAR(20) NOT NULL
);

CREATE TABLE Lieu_concert
(
    id_concert INTEGER NOT NULL,
    id_lieu INTEGER NOT NULL,
    FOREIGN KEY(id_concert) REFERENCES Concert(id_concert),
    FOREIGN KEY (id_lieu) REFERENCES Lieu(id_lieu) 
);

CREATE TABLE Artiste
(
    id_artiste SERIAL PRIMARY KEY,
    nom VARCHAR(30) NOT NULL,
    id_groupe INTEGER,
    FOREIGN KEY(id_groupe) REFERENCES Groupe(id_groupe)
);
CREATE TYPE type_avis AS ENUM ('Morceau', 'Artiste', 'Lieu', 'Concert');

CREATE TABLE Avis
(
    id_avis SERIAL PRIMARY KEY,
    -- id_type INTEGER NOT NULL,
    type_avis type_avis NOT NULL,
    note INTEGER NOT NULL CHECK (note >= 0 AND note <= 10),
    commentaire VARCHAR(140),
    date_avis DATE NOT NULL
);

CREATE TABLE Archive_avis
(
    id_avis INTEGER NOT NULL,
    id_archive INTEGER NOT NULL,
    PRIMARY KEY(id_avis,id_archive),
    FOREIGN KEY(id_avis) REFERENCES Avis(id_avis),
    FOREIGN KEY(id_archive) REFERENCES Archive(id_archive)   
);

CREATE TABLE Auteur_avis
(
    id_avis INTEGER NOT NULL,
    id_user INTEGER NOT NULL,
    PRIMARY KEY(id_avis,id_user),
    FOREIGN KEY(id_avis) REFERENCES Avis(id_avis),
    FOREIGN KEY(id_user) REFERENCES Utilisateurs(id_user)
);

CREATE TABLE Playlist
(
    id_playlist SERIAL PRIMARY KEY,
    id_user INTEGER NOT NULL,
    nom VARCHAR(30) NOT NULL,
    FOREIGN KEY(id_user) REFERENCES Utilisateurs(id_user)
    -- CHECK(
    --     SELECT COUNT(*) FROM Playlist WHERE id_user = {id_user} >=10
    -- )
);

CREATE TABLE Morceau
(
    id_morceau SERIAL PRIMARY KEY,
    nom VARCHAR(30) NOT NULL,
    id_artiste INTEGER NOT NULL,
    duree TIME NOT NULL,
    FOREIGN KEY(id_artiste) REFERENCES Artiste(id_artiste)
);

CREATE TABLE Contient
(
    id_playlist INTEGER NOT NULL,
    id_morceau INTEGER NOT NULL,
    PRIMARY KEY(id_playlist,id_morceau),
    FOREIGN KEY(id_playlist) REFERENCES Playlist(id_playlist),
    FOREIGN KEY(id_morceau) REFERENCES Morceau(id_morceau)
);

CREATE TABLE Genre
(
    id_genre SERIAL PRIMARY KEY,
    nom VARCHAR(30) NOT NULL
);

CREATE TABLE Relation_genre
(
    id_parent INTEGER NOT NULL,
    id_fils INTEGER NOT NULL,
    PRIMARY KEY(id_parent,id_fils),
    FOREIGN KEY(id_parent) REFERENCES Genre(id_genre),
    FOREIGN KEY(id_fils) REFERENCES Genre(id_genre)
);
CREATE TYPE type_tag AS ENUM('Groupe','Concert','Lieu','Playlist') ;

CREATE TABLE Tag
(
    id_tag SERIAL PRIMARY KEY,
    id_type INTEGER NOT NULL,
    type_tag type_tag NOT NULL,
    valeur VARCHAR(30) NOT NULL
);


CREATE TABLE Lineup
(
    id_concert INTEGER NOT NULL,
    id_artiste INTEGER NOT NULL,
    performance_index INTEGER NOT NULL,
    PRIMARY KEY(id_concert,id_artiste,performance_index),
    FOREIGN KEY(id_concert) REFERENCES Concert(id_concert),
    FOREIGN KEY(id_artiste) REFERENCES Artiste(id_artiste),
    UNIQUE(id_concert, performance_index)
);



