import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/exercise.dart';

class ManageExercisesScreen extends StatefulWidget {
  const ManageExercisesScreen({super.key});

  @override
  State<ManageExercisesScreen> createState() =>
      _ManageExercisesScreenState();
}

class _ManageExercisesScreenState
    extends State<ManageExercisesScreen> {

  late Future<List<Exercise>> exercises;

  @override
  void initState() {
    super.initState();
    exercises = ApiService.getAdminExercises();
  }


  void refreshExercises() {
    setState(() {
      exercises = ApiService.getAdminExercises();
    });
  }


  Future<void> toggleExercise(int id) async {
    try {
      await ApiService.toggleExercise(id);

      refreshExercises();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Exercises"),
        backgroundColor: Colors.green,
      ),

      body: FutureBuilder<List<Exercise>>(
        future: exercises,
        builder: (context, snapshot) {

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }


          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          }


          final data = snapshot.data!;


          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {

              final exercise = data[index];


              return Card(
                margin: const EdgeInsets.all(10),

                child: ListTile(

                  leading: const CircleAvatar(
                    child: Icon(Icons.fitness_center),
                  ),

                  title: Text(exercise.name),

                  subtitle: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [

                      Text(
                        exercise.category,
                      ),

                      Text(
                        exercise.description,
                      ),
                    ],
                  ),


                  trailing: Switch(
                    value: exercise.isActive,

                    onChanged: (_) {
                      toggleExercise(
                        exercise.exerciseId,
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}