import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() =>
      _ManageUsersScreenState();
}

class _ManageUsersScreenState
    extends State<ManageUsersScreen> {

  late Future<List<dynamic>> users;

  @override
  void initState() {
    super.initState();
    loadUsers();
  }


  void loadUsers() {
    users = ApiService.getAllUsers();
  }


  void refreshUsers() {
    setState(() {
      loadUsers();
    });
  }


  // ---------------- ADD / EDIT DIALOG ----------------

  void showUserDialog({
    Map<String, dynamic>? user,
  }) {

    final nameController =
    TextEditingController(text: user?["name"] ?? "");

    final emailController =
    TextEditingController(text: user?["email"] ?? "");

    final passwordController =
    TextEditingController();


    showDialog(
      context: context,
      builder: (_) {

        return AlertDialog(
          title: Text(
            user == null
                ? "Add User"
                : "Edit User",
          ),

          content: SingleChildScrollView(
            child: Column(
              children: [

                TextField(
                  controller: nameController,
                  decoration:
                  const InputDecoration(
                    labelText: "Name",
                  ),
                ),


                TextField(
                  controller: emailController,
                  decoration:
                  const InputDecoration(
                    labelText: "Email",
                  ),
                ),


                if (user == null)
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration:
                    const InputDecoration(
                      labelText: "Password",
                    ),
                  ),
              ],
            ),
          ),


          actions: [

            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),


            ElevatedButton(
              onPressed: () async {

                try {

                  if (user == null) {

                    await ApiService.addUser(
                      name: nameController.text,
                      email: emailController.text,
                      password:
                      passwordController.text,
                    );

                  } else {

                    await ApiService.updateUser(
                      userId: user["id"],
                      name:
                      nameController.text,
                      email:
                      emailController.text,
                    );

                  }


                  Navigator.pop(context);

                  refreshUsers();


                } catch(e) {

                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    SnackBar(
                      content:
                      Text(e.toString()),
                    ),
                  );

                }

              },
              child: const Text("Save"),
            ),

          ],
        );

      },
    );
  }



  // ---------------- DELETE ----------------

  void deleteUser(int id) async {

    try {

      await ApiService.deleteUser(id);

      refreshUsers();


    } catch(e) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
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
        title: const Text("Manage Users"),
      ),


      floatingActionButton:
      FloatingActionButton(
        onPressed: () {
          showUserDialog();
        },
        child: const Icon(Icons.add),
      ),


      body: FutureBuilder<List<dynamic>>(

        future: users,

        builder: (context, snapshot) {


          if(snapshot.connectionState ==
              ConnectionState.waiting) {

            return const Center(
              child:
              CircularProgressIndicator(),
            );

          }


          if(snapshot.hasError) {

            return Center(
              child:
              Text(snapshot.error.toString()),
            );

          }


          final data = snapshot.data!;


          return ListView.builder(

            itemCount: data.length,

            itemBuilder: (context,index) {

              final user = data[index];


              return Card(

                margin:
                const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),


                child: ListTile(

                  leading:
                  const CircleAvatar(
                    child:
                    Icon(Icons.person),
                  ),


                  title:
                  Text(user["name"]),


                  subtitle:
                  Text(user["email"]),


                  trailing:
                  Row(

                    mainAxisSize:
                    MainAxisSize.min,

                    children: [

                      IconButton(
                        icon:
                        const Icon(Icons.edit),
                        onPressed: () {
                          showUserDialog(
                            user: user,
                          );
                        },
                      ),


                      IconButton(
                        icon:
                        const Icon(Icons.delete),
                        onPressed: () {
                          deleteUser(
                            user["id"],
                          );
                        },
                      ),

                    ],

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