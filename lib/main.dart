import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final HttpLink rickAndMortyHttpLink =
        HttpLink('https://rickandmortyapi.com/graphql');
    ValueNotifier<GraphQLClient> client = ValueNotifier(
      GraphQLClient(
        link: rickAndMortyHttpLink,
        cache: GraphQLCache(
          store: InMemoryStore(),
        ),
      ),
    );

    String characterName = "Poopybutthole";

    final rickCharacters = '''
    query characters {
          characters(page: 1, filter: { name: "$characterName" }) {
            info {
              count
            }
            results {
              name
              status
              location{
                name
              }
            }
          }
      }
      ''';

    return GraphQLProvider(
      client: client,
      child: MaterialApp(
        title: 'Material App',
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Complete GraphQl Guide'),
            backgroundColor: Colors.black,
          ),
          body: Query(
            options: QueryOptions(
              document: gql(rickCharacters),
            ),
            builder: (result, {fetchMore, refetch}) {
              if (result.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (result.data == null) {
                return Center(
                  child:
                      Text('Sorry! no character with this name $characterName'),
                );
              } else {
                return Column(
                  children: [
                    const SizedBox(
                      height: 8,
                    ),
                    Text(
                      'Characters with name $characterName',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: result.data!['characters']['results'].length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(
                                "Name: ${result.data!['characters']['results'][index]['name']}"),
                            subtitle: Text(
                                "Status: ${result.data!['characters']['results'][index]['status']} \nLocation:${result.data!['characters']['results'][index]['location']['name']}"),
                          );
                        },
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
