$env:PGPASSWORD=""
psql -h banco-de-dados.cle4wosckh1l.us-east-1.rds.amazonaws.com -U thiago -d postgres -c "CREATE DATABASE meu_site;"
