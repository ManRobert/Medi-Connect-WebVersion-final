import 'package:redux_epics/redux_epics.dart';
import 'package:rxdart/transformers.dart';

import '../actions/index.dart';
import '../data/auth_api.dart';
import '../data/firestore_api.dart';
import '../models/index.dart';

class LogicEpics {
  const LogicEpics(this._api, this._firestoreApi);

  final AuthApi _api;
  final FirestoreApi _firestoreApi;

  Epic<AppState> get epic {
    return combineEpics(<Epic<AppState>>[
      TypedEpic<AppState, LoginStart>(_loginStart),
      TypedEpic<AppState, LogoutStart>(_logoutStart),
      TypedEpic<AppState, InitializeUserStart>(_initializeUserStart),
      TypedEpic<AppState, ResetPasswordStart>(_resetPassword),
      TypedEpic<AppState, SetDoctorIdToPatientStart>(_setDoctorIdToPatient),
      _listenForPacienti,
      _listenForSymptoms,
      TypedEpic<AppState, SendMedsStart>(_sendMedsStart),
      TypedEpic<AppState, GetMedsFromDatabaseStart>(_getMedsFromDatabaseStart),
      TypedEpic<AppState, HaveWeThisMedStart>(_haveWeThisMed),
      TypedEpic<AppState, AddToPharmacyStart>(_addMedToPharmacy),
      TypedEpic<AppState, RemoveMedFromPharmacyStart>(_removeMedFromPharmacy),
      TypedEpic<AppState, CreateUserStart>(_createUserStart),
      TypedEpic<AppState, AddMedToSystemStart>(_addMedToSystemStart),
      TypedEpic<AppState, GetMyAppointmentsStart>(_getMyAppointmentsStart),

    ]);
  }

  Stream<dynamic> _loginStart(Stream<LoginStart> actions, EpicStore<AppState> store) {
    return actions.flatMap(
      (LoginStart action) => Stream<void>.value(null)
          .asyncMap((_) => _api.login(email: action.email, password: action.password))
          .map((AppUser user) => Login.successful(user))
          .onErrorReturnWith((Object error, StackTrace stackTrace) => Login.error(error, stackTrace))
          .doOnData(action.response),
    );
  }

  Stream<dynamic> _haveWeThisMed(Stream<HaveWeThisMedStart> actions, EpicStore<AppState> store) {
    return actions.flatMap((HaveWeThisMedStart action) => Stream<void>.value(null)
        .asyncMap((_) => _firestoreApi.haveWeThisMed(action.pharmacyId, action.medId))
        .map((bool response) => HaveWeThisMed.successful(response))
        .onErrorReturnWith((Object error, StackTrace stackTrace) => HaveWeThisMed.error(error, stackTrace)));
  }

  Stream<dynamic> _addMedToPharmacy(Stream<AddToPharmacyStart> actions, EpicStore<AppState> store) {
    return actions.flatMap((AddToPharmacyStart action) => Stream<void>.value(null)
        .asyncMap((_) => _firestoreApi.addMedToPharmacy(action.pharmacyId, action.newMedId, action.medName))
        .map((_) => AddToPharmacy.successful())
        .onErrorReturnWith((Object error, StackTrace stackTrace) => AddToPharmacy.error(error, stackTrace)));
  }

  Stream<dynamic> _addMedToSystemStart(Stream<AddMedToSystemStart> actions, EpicStore<AppState> store) {
    return actions.flatMap(
      (AddMedToSystemStart action) => Stream<void>.value(null)
          .asyncMap((_) => _firestoreApi.addMed(action.medFromDatabase))
          .map((_) => AddMedToSystem.successful())
          .onErrorReturnWith((Object error, StackTrace stackTrace) => AddMedToSystem.error(error, stackTrace))
          .doOnData(action.response),
    );
  }

  Stream<dynamic> _getMyAppointmentsStart(Stream<GetMyAppointmentsStart> actions, EpicStore<AppState> store) {
    return actions.flatMap(
          (GetMyAppointmentsStart action) => Stream<void>.value(null)
          .asyncMap((_) => _firestoreApi.getMyAppointments(action.userId))
          .map((List<Appointment> appointments) => GetMyAppointments.successful(appointments))
          .onErrorReturnWith((Object error, StackTrace stackTrace) => GetMyAppointments.error(error, stackTrace)),
    );
  }

  Stream<dynamic> _sendMedsStart(Stream<SendMedsStart> actions, EpicStore<AppState> store) {
    return actions.flatMap((SendMedsStart action) => Stream<void>.value(null)
        .asyncMap((_) => _firestoreApi.sendMeds(action.medicineList, action.symptomId))
        .map((_) => SendMeds.successful())
        .onErrorReturnWith((Object error, StackTrace stackTrace) => SendMeds.error(error, stackTrace)));
  }

  Stream<dynamic> _setDoctorIdToPatient(Stream<SetDoctorIdToPatientStart> actions, EpicStore<AppState> store) {
    return actions.flatMap((SetDoctorIdToPatientStart action) => Stream<void>.value(null)
        .asyncMap((_) => _firestoreApi.setDoctorIdToPatient(action.doctorId, action.patientId))
        .map((_) => SetDoctorIdToPatient.successful())
        .onErrorReturnWith((Object error, StackTrace stackTrace) => SetDoctorIdToPatient.error(error, stackTrace)));
  }

  Stream<dynamic> _createUserStart(Stream<CreateUserStart> actions, EpicStore<AppState> store) {
    return actions.flatMap(
      (CreateUserStart action) => Stream<void>.value(null)
          .asyncMap((_) => _api.createUser(
              email: action.email,
              password: action.password,
              displayName: action.displayName,
              accountRole: action.role,
              lat: action.lat,
              lng: action.lng))
          .map((_) => CreateUser.successful())
          .onErrorReturnWith((Object error, StackTrace stackTrace) => CreateUser.error(error, stackTrace))
          .doOnData(action.response),
    );
  }

  Stream<dynamic> _logoutStart(Stream<LogoutStart> actions, EpicStore<AppState> store) {
    return actions.flatMap(
      (LogoutStart action) => Stream<void>.value(null)
          .asyncMap((_) => _api.logout())
          .map((_) => const Logout.successful())
          .onErrorReturnWith((Object error, StackTrace stackTrace) => Logout.error(error, stackTrace)),
    );
  }

  Stream<void> _initializeUserStart(Stream<InitializeUserStart> actions, EpicStore<AppState> store) {
    return actions.flatMap(
      (InitializeUserStart action) => Stream<void>.value(null)
          .asyncMap((_) => _api.initializeUser())
          .map((AppUser? user) => InitializeUser.successful(user))
          .onErrorReturnWith((Object error, StackTrace stackTrace) => InitializeUser.error(error, stackTrace)),
    );
  }

  Stream<void> _getMedsFromDatabaseStart(Stream<GetMedsFromDatabaseStart> actions, EpicStore<AppState> store) {
    return actions.flatMap(
      (GetMedsFromDatabaseStart action) => Stream<void>.value(null)
          .asyncMap((_) => _firestoreApi.getMedsFromDatabase())
          .map((List<MedFromDatabase> medsFromDatabase) => GetMedsFromDatabase.successful(medsFromDatabase))
          .onErrorReturnWith((Object error, StackTrace stackTrace) => GetMedsFromDatabase.error(error, stackTrace)),
    );
  }

  Stream<dynamic> _listenForPacienti(Stream<dynamic> actions, EpicStore<AppState> store) {
    return actions.whereType<ListenForPacientiStart>().flatMap(
          (ListenForPacientiStart action) => Stream<void>.value(null)
              .flatMap((_) => _firestoreApi.listenForPacienti(action.id))
              .map((List<Pacient> pacienti) => ListenForPacienti.event(pacienti))
              .takeUntil(actions.whereType<ListenForPacientiDone>())
              .onErrorReturnWith((Object error, StackTrace stackTrace) => ListenForPacienti.error(error, stackTrace)),
        );
  }

  Stream<dynamic> _listenForSymptoms(Stream<dynamic> actions, EpicStore<AppState> store) {
    return actions.whereType<ListenForSimptomeStart>().flatMap(
          (ListenForSimptomeStart action) => Stream<void>.value(null)
              .flatMap((_) => _firestoreApi.listenForSymptoms(action.doctorId))
              .map((List<Symptom> simptome) => ListenForSimptome.event(simptome))
              .takeUntil(actions.whereType<ListenForSimptomeDone>())
              .onErrorReturnWith((Object error, StackTrace stackTrace) => ListenForSimptome.error(error, stackTrace)),
        );
  }

  Stream<dynamic> _resetPassword(Stream<ResetPasswordStart> actions, EpicStore<AppState> store) {
    return actions.flatMap(
      (ResetPasswordStart action) => Stream<void>.value(null)
          .asyncMap((_) => _api.resetPassword(email: action.email))
          .map((_) => ResetPassword.successful())
          .onErrorReturnWith((Object error, StackTrace stackTrace) => ResetPassword.error(error, stackTrace))
          .doOnData(action.response),
    );
  }

  Stream<dynamic> _removeMedFromPharmacy(Stream<RemoveMedFromPharmacyStart> actions, EpicStore<AppState> store) {
    return actions.flatMap((RemoveMedFromPharmacyStart action) => Stream<void>.value(null)
        .asyncMap((_) => _firestoreApi.removeMedFromPharmacy(action.pharmacyId, action.medToRemove, action.medName))
        .map((_) => RemoveMedFromPharmacy.successful())
        .onErrorReturnWith((Object error, StackTrace stackTrace) => RemoveMedFromPharmacy.error(error, stackTrace)));
  }
}
