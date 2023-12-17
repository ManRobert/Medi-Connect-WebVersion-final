import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:medi_connect_web_version/actions/index.dart';

import '../models/index.dart';

class AdminPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[900],
      appBar: AppBar(
        title: Text('Medi-Connect Admin Page'),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              StoreProvider.of<AppState>(context).dispatch(LogoutStart());
            },
            icon: Icon(
              Icons.logout,
            ),
          )
        ],
        backgroundColor: Colors.black38,
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: Card(
                elevation: 20,
                color: Colors.white60,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(Icons.person, size: 50, color: Colors.blue[900]),
                      SizedBox(height: 10),
                      Text(
                        'Create Doctor Account',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(height: 10),
                      DoctorForm(),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: 20),
            Expanded(
              child: Card(
                color: Colors.white60,
                elevation: 20,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(Icons.local_hospital, size: 50, color: Colors.blue[900]),
                      SizedBox(height: 10),
                      Text(
                        'Create Pharmacy Account',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(height: 10),
                      PharmacyForm(),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: 20),
            Expanded(
              child: Card(
                color: Colors.white60,
                elevation: 20,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(Icons.add_box, size: 50, color: Colors.blue[900]),
                      SizedBox(height: 10),
                      Text(
                        'Add Medicine',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(height: 10),
                      MedicineForm(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DoctorForm extends StatefulWidget {
  @override
  State<DoctorForm> createState() => _DoctorFormState();
}

class _DoctorFormState extends State<DoctorForm> {
  final TextEditingController _email = TextEditingController();

  final TextEditingController _password = TextEditingController();

  final TextEditingController _displayName = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          TextFormField(
            controller: _displayName,
            decoration: InputDecoration(labelText: 'Doctor Name'),
          ),
          TextFormField(
            controller: _email,
            decoration: InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
          ),
          TextFormField(
            controller: _password,
            decoration: InputDecoration(labelText: 'Password'),
            obscureText: true,
          ),
          SizedBox(height: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[900]),
            onPressed: () {
              final CreateUser action = CreateUser(
                  email: _email.text.contains(' ') ? _email.text.split(' ').first : _email.text,
                  password: _password.text,
                  response: _onResponse,
                  displayName: _displayName.text,
                  role: "Doctor");
              StoreProvider.of<AppState>(context).dispatch(action);
              _email.text = '';
              _password.text = '';
              _displayName.text = '';
            },
            child: Text('Create Doctor Account'),
          ),
        ],
      ),
    );
  }

  void _onResponse(dynamic action) {
    if (action is CreateUserError) {
      final Object error = action.error;
      if (error is FirebaseAuthException) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message ?? error.code)));
      }
    } else if (action is CreateUserSuccessful) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Account created!')));
    }
  }
}

class PharmacyForm extends StatefulWidget {
  @override
  State<PharmacyForm> createState() => _PharmacyFormState();
}

class _PharmacyFormState extends State<PharmacyForm> {
  final TextEditingController _email = TextEditingController();

  final TextEditingController _password = TextEditingController();

  final TextEditingController _displayName = TextEditingController();

  final TextEditingController _lat = TextEditingController();

  final TextEditingController _lng = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          TextFormField(
            controller: _displayName,
            decoration: InputDecoration(labelText: 'Pharmacy Name'),
          ),
          TextFormField(
            controller: _email,
            decoration: InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
          ),
          TextFormField(
            controller: _password,
            decoration: InputDecoration(labelText: 'Password'),
            obscureText: true,
          ),
          TextFormField(
            controller: _lat,
            decoration: InputDecoration(labelText: 'Latitude'),
          ),
          TextFormField(
            controller: _lng,
            decoration: InputDecoration(labelText: 'Longitude'),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[900]),
            onPressed: () {
              final CreateUser action = CreateUser(
                  email: _email.text.contains(' ') ? _email.text.split(' ').first : _email.text,
                  password: _password.text,
                  response: _onResponse,
                  displayName: _displayName.text,
                  role: "Pharmacist",
                  lat: _lat.text,
                  lng: _lng.text);
              StoreProvider.of<AppState>(context).dispatch(action);
              _email.text = '';
              _password.text = '';
              _displayName.text = '';
              _lng.text = '';
              _lat.text = '';
            },
            child: Text('Create Pharmacy Account'),
          ),
        ],
      ),
    );
  }

  void _onResponse(dynamic action) {
    if (action is CreateUserError) {
      final Object error = action.error;
      if (error is FirebaseAuthException) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message ?? error.code)));
      }
    } else if (action is CreateUserSuccessful) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Account created!')));
    }
  }
}

class MedicineForm extends StatefulWidget {
  @override
  _MedicineFormState createState() => _MedicineFormState();
}

class _MedicineFormState extends State<MedicineForm> {
  String _selectedMedicineType = 'Pill';
  final TextEditingController _name = TextEditingController();
  final TextEditingController _shortDescription = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          TextFormField(
            controller: _name,
            decoration: InputDecoration(labelText: 'Medicine Name'),
          ),
          TextFormField(
            controller: _shortDescription,
            decoration: InputDecoration(labelText: 'Short Description'),
          ),
          SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: _selectedMedicineType,
            onChanged: (newValue) {
              setState(() {
                _selectedMedicineType = newValue!;
              });
            },
            items: <String>['Pill', 'Bottle', 'Syringe'].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[900]),
            onPressed: () {
              StoreProvider.of<AppState>(context).dispatch(AddMedToSystemStart(
                  medFromDatabase: MedFromDatabase(
                      name: _name.text, medicineType: _selectedMedicineType, shortDescription: _shortDescription.text),
                  response: _onResponse));

              _name.text = '';
              _shortDescription.text = '';
              _selectedMedicineType = 'Pill';
            },
            child: Text('Add Medicine'),
          ),
        ],
      ),
    );
  }

  void _onResponse(dynamic action) {
    if (action is AddMedToSystemSuccessful) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Medicine added successfully!')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Something went wrong!')));
    }
  }
}
