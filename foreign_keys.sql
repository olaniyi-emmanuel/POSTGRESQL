CREATE TABLE weather (
        city      varchar(80) references cities(name),
        temp_lo   int,