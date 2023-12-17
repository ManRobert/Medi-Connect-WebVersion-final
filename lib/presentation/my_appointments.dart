import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:medi_connect_web_version/presentation/containers/appointmentsContainer.dart';
import 'package:redux/redux.dart';
import '../actions/index.dart';
import '../models/index.dart';

class MyAppointmentsPage extends StatefulWidget {
  const MyAppointmentsPage({Key? key}) : super(key: key);

  @override
  State<MyAppointmentsPage> createState() => _MyAppointmentsPageState();
}

class _MyAppointmentsPageState extends State<MyAppointmentsPage> {
  late Store<AppState> _store;

  @override
  void initState() {
    _store = StoreProvider.of<AppState>(context, listen: false);

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppointmentsContainer(builder: (BuildContext context, List<Appointment> appointments) {
      return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.green[900],
            actions: <Widget>[
              IconButton(
                onPressed: () {
                  _store.dispatch(LogoutStart());
                },
                icon: Icon(
                  Icons.logout,
                ),
              )
            ],
          ),
          body: !_store.state.medicalComunicationState.needRefresh
              ? Builder(builder: (context) {
                  return Padding(
                    padding: EdgeInsets.all(2),
                    child: Column(
                      children: [
                        TopContainer(),
                        SizedBox(
                          height: 2,
                        ),
                        Expanded(child: BottomContainer()),
                      ],
                    ),
                  );
                })
              : Center(child: CircularProgressIndicator()));
    });
  }
}

class TopContainer extends StatefulWidget {
  TopContainer({Key? key}) : super(key: key);

  @override
  State<TopContainer> createState() => _TopContainerState();
}

class _TopContainerState extends State<TopContainer> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          alignment: Alignment.topLeft,
          padding: EdgeInsets.only(
            bottom: 1,
          ),
          child: Center(
            child: Text(
              'Your patients appointments:',
              textAlign: TextAlign.start,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
        ),
        SizedBox(
          height: 2,
        ),
      ],
    );
  }
}

class BottomContainer extends StatefulWidget {
  const BottomContainer({Key? key}) : super(key: key);

  @override
  State<BottomContainer> createState() => _BottomContainerState();
}

class _BottomContainerState extends State<BottomContainer> {
  late Store<AppState> _store;

  @override
  void initState() {
    _store = StoreProvider.of<AppState>(context, listen: false);
    _store.dispatch(GetMyAppointments(userId: _store.state.auth.user!.uid));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_store.state.medicalComunicationState.myAppointments.isEmpty) {
      return Center(
        child: Text(
          'There are no appointments',
          style: Theme.of(context).textTheme.displaySmall,
        ),
      );
    } else {
      return ListView.builder(
        itemCount: _store.state.medicalComunicationState.myAppointments.length,
        itemBuilder: (BuildContext context, int index) {
          String selectedDate =
              '${_store.state.medicalComunicationState.myAppointments[index].dateTime.day}-${_store.state.medicalComunicationState.myAppointments[index].dateTime.month}-${_store.state.medicalComunicationState.myAppointments[index].dateTime.year}';

          return Padding(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 100),
            child: Card(
              color: Colors.white60,
              elevation: 20,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                leading: Icon(Icons.schedule),
                title: Text(
                  selectedDate,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  'Time: ${_store.state.medicalComunicationState.myAppointments[index].ora.toString() + ":00"}',
                ),
                trailing: Text(_store.state.medicalComunicationState.myAppointments[index].patientName),
              ),
            ),
          );
        },
      );
    }
  }
}
