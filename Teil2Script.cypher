//Q1
MATCH (a:Author {name: "Erhard Rahm"})-[:AUTHOR_OF]->(p:Publication)
RETURN p;

//Q2
MATCH (a:Author {name: "Erhard Rahm"})-[:AUTHOR_OF]->(p:Publication)<-[:AUTHOR_OF]-(coAuthor:Author)
WHERE a <> coAuthor
RETURN DISTINCT coAuthor.name;

//Q3
MATCH (a:Author {name: "Wei Wang"})-[:AUTHOR_OF]->(p:Publication)<-[:CITES]-(citingPub:Publication)
RETURN DISTINCT citingPub.title;


//Q4
MATCH (v:Venue)<-[:PUBLISHED_IN]-(p:Publication)
WHERE toLower(p.title) CONTAINS 'graph' AND toLower(p.title) CONTAINS 'temporal'
RETURN v.name as Venue_Name, COLLECT(DISTINCT p.title) as Publication_Titles;


//Q5
MATCH (v:Venue {name: "Lecture Notes in Computer Science"})<-[:PUBLISHED_IN]-(p:Publication)<-[:AUTHOR_OF]-(a:Author)
RETURN p.year AS Year, COUNT(DISTINCT a) AS Authors
ORDER BY Year;


//Q6
MATCH path = (a1:Author {name: "Ioanna Tsalouchidou"})-[*4]-(a2:Author {name: "Charu C. Aggarwal"})
RETURN COUNT(path) AS NumberOfPaths;

//Q7
MATCH (a:Author {name: "Charu C. Aggarwal"})-[:AUTHOR_OF]->(p:Publication)-[:PUBLISHED_IN]->(v:Venue)
RETURN COLLECT(DISTINCT v.name) AS Venue_Names, COLLECT(DISTINCT p.year) AS Publication_Years;


//Q8
MATCH (a:Author {name: "Charu C. Aggarwal"})-[rel:AUTHOR_OF]->(p:Publication)-[:PUBLISHED_IN]->(v:Venue)
WHERE rel.position = 1
RETURN DISTINCT v.name;


//Q9
MATCH (a1:Author)-[:AUTHOR_OF]->(p1:Publication)<-[:AUTHOR_OF]-(a2:Author)
WITH a1, a2, COLLECT(p1) as commonPubs
WHERE size(commonPubs) >= 4
MATCH (a1)-[:AUTHOR_OF]->(pa:Publication)-[:CITES]->(pb:Publication)<-[:AUTHOR_OF]-(a2)
WHERE NOT pb in commonPubs AND NOT pa in commonPubs
RETURN a1.name as Author1, a2.name as Author2;

//Q10
CALL {
    WITH {year: 2016} as data
    MATCH (p:Publication {year: data.year})<-[:CITES]-(citingPub:Publication)
    WITH p, COUNT(citingPub) as citations
    ORDER BY citations DESC
    LIMIT 1
    RETURN p.id as mostCitedPaperId
}
MATCH (topPaper:Publication {id: mostCitedPaperId})<-[:CITES]-(citingPub:Publication)-[:PUBLISHED_IN]->(v:Venue)
RETURN v.name as Venue, COUNT(citingPub) as Number_of_Citations
ORDER BY Number_of_Citations DESC;



//Q11
MATCH (p:Publication)<-[:AUTHOR_OF]-(a:Author)
WITH p, COUNT(a) as authorCount
ORDER BY authorCount DESC
LIMIT 5
RETURN p.title as Title, authorCount as Author_Count;


//Q12
MATCH (a:Author)-[:AUTHOR_OF]->(p1:Publication)-[:CITES]->(p2:Publication)<-[:AUTHOR_OF]-(a)
WITH a, COUNT(p1) as selfCitations
ORDER BY selfCitations DESC
LIMIT 5
RETURN a.name as Author, selfCitations as Self_Citations;


//Q13
MATCH (p1:Publication)-[:CITES]->(p2:Publication)<-[:CITES]-(p1)
WHERE NOT EXISTS (
    (p1)<-[:AUTHOR_OF]-()-[:AUTHOR_OF]->(p2)
)
RETURN COUNT(*) / 2 as Publication_Pairs; 


//Q14
MATCH (p:Publication)
REMOVE p.n_citation
RETURN COUNT(*) as Publications_Updated;


//Q14.2
MATCH (p:Publication)<-[:CITES]-(citingPub:Publication)
WITH p, COUNT(citingPub) as citations
SET p.cite_count = citations
RETURN COUNT(*) as Publications_Updated;


//Q14.3
MATCH (p:Publication)
WHERE (p.cite_count) IS NOT NULL
RETURN p.id as Publication_ID, p.title as Title, p.cite_count as Cite_Count
ORDER BY p.cite_count DESC
LIMIT 10;


//Q15
MATCH (a1:Author)-[:AUTHOR_OF]->(p:Publication)<-[:AUTHOR_OF]-(a2:Author)
WHERE ID(a1) < ID(a2)
WITH a1, a2, MIN(p.year) as earliestYear
MERGE (a1)-[r:coAuthor {since: earliestYear}]->(a2)
RETURN COUNT(*) as CoAuthor_Relationships_Created;

