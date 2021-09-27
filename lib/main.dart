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

    return GraphQLProvider(
      client: client,
      child: const MaterialApp(
        title: 'Material App',
        home: Mainpage(),
      ),
    );
  }
}

class Mainpage extends StatefulWidget {
  const Mainpage({
    Key? key,
  }) : super(key: key);

  @override
  State<Mainpage> createState() => _MainpageState();
}

class _MainpageState extends State<Mainpage> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {};

  String characterName = "Poopybutthole";

  String rickCharacters = "";

  @override
  void initState() {
    rickCharacters = '''
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

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              child: Text('Sorry! no character with this name $characterName'),
            );
          } else {
            return Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    initialValue: characterName,
                    decoration: const InputDecoration(
                      labelText: 'Nome',
                    ),
                    validator: (value) {
                      if (value!.trim().isNotEmpty) {
                        return null;
                      } else {
                        return "Digite o nome";
                      }
                    },
                    onSaved: (value) => _formData['nome'] = value!,
                  ),
                  TextButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        characterName = _formData['nome'];
                        setState(() {
                          rickCharacters = '''
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
                        });
                      }
                    },
                    child: const Text('Pesquisar'),
                  ),
                  const SizedBox(
                    height: 16,
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
                    height: 16,
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: result.data!['characters']['results'].length,
                      itemBuilder: (context, index) {
                        return Wrap(
                          children: [
                            ListTile(
                              title: Text(
                                  "Name: ${result.data!['characters']['results'][index]['name']}"),
                              subtitle: Text(
                                  "Status: ${result.data!['characters']['results'][index]['status']} \nLocation: ${result.data!['characters']['results'][index]['location']['name']}"),
                            ),
                            const Divider(
                              thickness: 1,
                              indent: 16,
                              endIndent: 16,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
