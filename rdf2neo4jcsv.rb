#!/usr/bin/env ruby
require 'rubygems'
require 'bundler/setup'

require 'rdf'
require 'rdf/ntriples'
require 'csv'
require 'json'

raise "expects args: <nt filename> <default neo4j node label> <options>" if ARGV.count != 3

# first arg
nt_filename = ARGV[0]
m = nt_filename.match(/^(..*)\.nt$/)
basename = m[1]
raise "expects a .nt file!" unless m

# second arg
default_node_label = ARGV[1]

# third arg
begin
  options = JSON.parse ARGV[2]
rescue
  raise "Third arg must be valid json!"
end
label_per_uri_prefix = options['label_per_uri_prefix'] || {}

nodes_csv = CSV.open "#{basename}_neo4j_nodes.csv", 'wb'
edges_csv = CSV.open "#{basename}_neo4j_edges.csv", 'wb'

nodes_csv << ['URI:ID', 'name', ':LABEL']
edges_csv << [':START_ID', 'uri', ':END_ID', ':TYPE']

Neo4jCSVElem = Struct.new :uri, :name
written_node_uris = {}

RDF::Reader.open(nt_filename) do |reader|
  reader.each_statement do |statement|
    subject, predicate, object = statement.to_a.map do |uri|
      name = uri.to_s.gsub(/.*[\/#]([^\/#]*)$/, '\1')
      name = uri if name.empty?
      Neo4jCSVElem.new uri.to_s, name
    end

    [subject, object].each do |node|
      next if written_node_uris.include? node.uri
      labels = label_per_uri_prefix.map do |uri_prefix, label|
        label if node.uri.start_with? uri_prefix
      end.compact
      labels << default_node_label if labels.empty?
      nodes_csv << [node.uri, node.name, labels.join(';')]
      written_node_uris[node.uri] = true
    end

    edges_csv << [subject.uri, predicate.uri, object.uri, predicate.name.upcase]
  end
end

nodes_csv.close
edges_csv.close

puts "Output: #{nodes_csv.path}"
puts "Output: #{edges_csv.path}"
