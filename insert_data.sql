COPY Utilisateurs(id_user, pseudo, email, pwd, pays, ville, date_creation)
FROM 'CSV/Utilisateur.csv'
DELIMITER ',' 
CSV HEADER;