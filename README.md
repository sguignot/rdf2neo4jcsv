# rdf2neo4jcsv
```
args: <nt filename> <default neo4j node label> <options>

./rdf2neo4jcsv.rb yago_taxonomy.nt OntologyType '{"label_per_uri_prefix":{"http://dbpedia.org/class/yago/":"YagoType", "http://dbpedia.org/ontology/":"DBpediaType"}}'
```

Then you can import the generated csv files into a neo4j graph db:
```
./bin/neo4j-import --into data/graph.db/ --nodes yago_taxonomy_neo4j_nodes.csv --relationships yago_taxonomy_neo4j_edges.csv --bad bad.log
```
