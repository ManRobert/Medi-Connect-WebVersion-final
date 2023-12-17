import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import '../../models/index.dart';

class AppointmentsContainer extends StatelessWidget {
  const AppointmentsContainer({Key? key, required this.builder});

  final ViewModelBuilder<List<Appointment>> builder;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, List<Appointment>>(
      builder: builder,
      converter: (Store<AppState> store) {
        List<Appointment> appointments = List.from(store.state.medicalComunicationState.myAppointments);
        return appointments;
      },
    );
  }
}
