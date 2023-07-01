CALL apoc.periodic.iterate(
    "CALL apoc.load.json('file:///dblp-ref-3.json') YIELD value RETURN value",
    MERGE (p:Publication {id: value.id})
     SET p.abstract = value.abstract,
         p.title = value.title,
         p.year = value.year,
         p.n_citation = value.n_citation
     MERGE (v:Venue {name: value.venue})
     MERGE (p)-[:PUBLISHED_IN]->(v)
     WITH value, p
     UNWIND value.authors AS authorName
     MERGE (a:Author {name: authorName})
     WITH a, p, value
     FOREACH (i IN range(0, size(value.authors) - 1) |
       FOREACH (pos IN CASE WHEN value.authors[i] = authorName THEN [i] ELSE [] END |
         MERGE (a)-[r:AUTHOR_OF]->(p)
         SET r.position = pos
       )
     )
     WITH value, p
     UNWIND value.references AS refId
     MERGE (ref:Publication {id: refId})
     MERGE (p)-[:CITES]->(ref),
    {batchSize:500, iterateList:true, parallel:false}
);

