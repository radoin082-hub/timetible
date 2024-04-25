import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timo/Services/cls.dart';
import 'package:timo/pages/LevelPage.dart';
import 'package:timo/pages/SpecialityPage.dart';

class CustomSpecialtySearchDelegate extends SearchDelegate {
  final Dio dio = Dio();
    Timer? _debounce;

  final List<String> departmentIds;

  CustomSpecialtySearchDelegate(this.departmentIds);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container();
  }

@override
Widget buildSuggestions(BuildContext context) {
  
  return FutureBuilder<List<dynamic>>(
    future: fetchSpecialties(query),
    builder: (context, snapshot) {
      if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
      var suggestions = snapshot.data!;
      return ListView.builder(
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          var specialty = suggestions[index];
          return ListTile(
            title: Text(specialty['Nom_spec']),
            subtitle: Text(specialty['name_spec_ar']),
            onTap: () {
              Provider.of<TimetableData>(context, listen: false).setSpecialtyId(specialty['id_specialty']);
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => LevelPage(id_specialty: specialty['id_specialty']),
              ));
            },
          );
        },
      );
    },
  );
}

  Future<List<dynamic>> fetchSpecialties(String query) async {
    List<dynamic> specialtiesResults = [];
    for (String departmentId in departmentIds) {
      try {
        final response = await dio.get('https://num.univ-biskra.dz/psp/pspapi/specialty?department=$departmentId&semester=2&key=appmob');
        if (response.statusCode == 200) {
          final List<dynamic> specialties = json.decode(response.data);
          specialtiesResults.addAll(specialties.where((specialty) =>
            specialty['AbrevFR'].toLowerCase().contains(query.toLowerCase()) ||
            specialty['name_spec_ar'].toLowerCase().contains(query.toLowerCase())));
        }
      } catch (e) {
        print("Error fetching specialties: $e");
      }
    }
    return specialtiesResults;
  }
}
