use admin;
db.createUser({ user: "admin", pwd: "alcatraz1400", roles: [ { role: "root", db: "admin" } ] } );
