CREATE INDEX publication_id_index IF NOT EXISTS FOR (p:Publication) ON (p.id);
CREATE INDEX venue_name_index IF NOT EXISTS FOR (v:Venue) ON (v.name);
CREATE INDEX author_name_index IF NOT EXISTS FOR (a:Author) ON (a.name);

CALL apoc.periodic.iterate(
    "CALL apoc.load.json('file:///dblp-ref-3.json') YIELD value RETURN value",
    MERGE (p:Publication {id: value.id})
     SET p.abstract = value.abstract,
         p.title = value.title,
         p.year = value.year,
         p.n_citation = value.n_citation
     MERGE (v:Venue {name: value.venue})
     CREATE (p)-[:PUBLISHED_IN]->(v)
     WITH value, p
     UNWIND value.authors AS authorName
     MERGE (a:Author {name: authorName})
     WITH a, p, value
     FOREACH (pos IN [i IN range(0, size(value.authors) - 1) | CASE WHEN value.authors[i] = authorName THEN i END] |
       CREATE (a)-[:AUTHOR_OF {position: pos}]->(p)
     )
     WITH value, p
     UNWIND value.references AS refId
     MERGE (ref:Publication {id: refId})
     CREATE (p)-[:CITES]->(ref),
    {batchSize:500, iterateList:true, parallel:false}
);



