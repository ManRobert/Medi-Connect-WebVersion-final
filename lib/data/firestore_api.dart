import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/index.dart';

class FirestoreApi {
  FirestoreApi({required this.firestore});

  final FirebaseFirestore firestore;

  Future<void> setDoctorIdToPatient(String doctorId, String patientId) async {
    await firestore.collection('users').doc(patientId).update({
      'doctorId': doctorId,
    });
  }

  Future<void> addMed(MedFromDatabase medFromDatabase) async {
    String id = await firestore.collection('systemMeds').doc().id; //set(medFromDatabase.toJson());
    await firestore.collection('systemMeds').doc(id).set(medFromDatabase.toJson());

    await firestore.collection('systemMeds').doc(id).update({
      'id': id,
    });
  }

  Future<List<Appointment>> getMyAppointments(String doctorId) async {
    QuerySnapshot<Map<String, dynamic>> snapshot =
        await firestore.collection('appointments').where('doctorId', isEqualTo: doctorId).get();
    List<Appointment> appointments = snapshot.docs
        .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) => Appointment.fromJson(doc.data()))
        .toList();

    List<Appointment> finalAppointments = [];
    for (Appointment appointment in appointments) {
      DateTime dateTime = appointment.dateTime;
      dateTime = dateTime.add(Duration(hours: appointment.ora));
      if (dateTime.isAfter(DateTime.now())) {
        finalAppointments.add(appointment);
      }
    }

    finalAppointments.sort((a, b) {
      int dateComparison = a.dateTime.compareTo(b.dateTime);
      if (dateComparison == 0) {
        return a.ora.compareTo(b.ora);
      }
      return dateComparison;
    });
    return finalAppointments;
  }

  Future<void> sendMeds(List<Medicine> medicineList, String symptomId) async {
    for (Medicine med in medicineList) {
      await firestore.collection('meds').doc().set(med.toJson());
    }

    await firestore.collection('symptoms').doc(symptomId).update({
      'handled': true,
    });
  }

  Future<bool> haveWeThisMed(String pharmacyId, String medId) async {
    final CollectionReference<Map<String, dynamic>> pharmaciesCollection =
        FirebaseFirestore.instance.collection('pharmacies');

    final DocumentSnapshot<Map<String, dynamic>> pharmacyDoc = await pharmaciesCollection.doc(pharmacyId).get();

    if (pharmacyDoc.exists) {
      final Map<String, dynamic>? data = pharmacyDoc.data();
      if (data != null && data.containsKey('medicines')) {
        final String medicinesString = data['medicines'];

        final List<String> medicinesList = medicinesString.split(';');
        if (medicinesList.contains(medId)) {
          return true;
        }
      }
    }

    return false;
  }

  Future<void> addMedToPharmacy(String pharmacyId, String newMedId, String medName) async {
    final CollectionReference<Map<String, dynamic>> pharmaciesCollection =
        FirebaseFirestore.instance.collection('pharmacies');

    final DocumentSnapshot<Map<String, dynamic>> pharmacyDoc = await pharmaciesCollection.doc(pharmacyId).get();

    final Map<String, dynamic>? data = pharmacyDoc.data();
    if (data != null && data.containsKey('medicines')) {
      String medicinesString = data['medicines'];
      String lat = data['lat'];
      String lng = data['lng'];
      String medicinesNamesString = data['medicinesNames'];
      String pharmacyName = data['name'];

      medicinesString += ";$newMedId";
      medicinesNamesString += ";$medName";

      await pharmaciesCollection
          .doc(pharmacyId)
          .update({'medicines': medicinesString, 'lat': lat, 'lng': lng, 'name':pharmacyName, 'medicinesNames': medicinesNamesString});
    } else {
      String lat = data!['lat'];
      String lng = data['lng'];
      String pharmacyName = data['name'];


      final String newMedicinesString = newMedId;
      await pharmaciesCollection.doc(pharmacyId).set({'medicines': newMedicinesString, 'name':pharmacyName, 'lat': lat, 'lng': lng, 'medicinesNames': medName});
    }
  }

  Future<void> removeMedFromPharmacy(String pharmacyId, String medToRemove, String medName) async {
    final CollectionReference<Map<String, dynamic>> pharmaciesCollection =
        FirebaseFirestore.instance.collection('pharmacies');

    final DocumentSnapshot<Map<String, dynamic>> pharmacyDoc = await pharmaciesCollection.doc(pharmacyId).get();

    if (pharmacyDoc.exists) {
      final Map<String, dynamic>? data = pharmacyDoc.data();
      if (data != null && data.containsKey('medicines')) {
        String medicinesString = data['medicines'];
        String medicinesNamesString = data['medicinesNames'];

        String lat = data['lat'];
        String lng = data['lng'];

        final List<String> medicinesList = medicinesString.split(';');
        final List<String> medicineNamesList = medicinesNamesString.split(';');


        if (medicinesList.contains(medToRemove)) {
          medicinesList.remove(medToRemove);

          medicinesString = medicinesList.join(';');

          await pharmaciesCollection.doc(pharmacyId).update({'medicines': medicinesString, 'lat': lat, 'lng': lng});
        }

        if (medicineNamesList.contains(medName)) {
          medicineNamesList.remove(medName);

          medicinesNamesString = medicineNamesList.join(';');

          await pharmaciesCollection.doc(pharmacyId).update({'medicinesNames': medicinesNamesString, 'lat': lat, 'lng': lng});
        }
      }
    }
  }

  Stream<List<Pacient>> listenForPacienti(String id) {
    return firestore
        .collection('users')
        .where('doctorId', isEqualTo: id)
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> snapshot) {
      List<Pacient> pacienti =
          snapshot.docs.map((QueryDocumentSnapshot<Map<String, dynamic>> doc) => Pacient.fromJson(doc.data())).toList();

      return pacienti;
    });
  }

  Future<List<MedFromDatabase>> getMedsFromDatabase() async {
    QuerySnapshot<Map<String, dynamic>> snapshot = await firestore.collection('systemMeds').get();
    List<MedFromDatabase> medsFromDatabase = snapshot.docs
        .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) => MedFromDatabase.fromJson(doc.data()))
        .toList();
    return medsFromDatabase;
  }

  Stream<List<Symptom>> listenForSymptoms(String doctorId) {
    return firestore
        .collection('symptoms')
        .where('doctorId', isEqualTo: doctorId)
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> snapshot) {
      List<Symptom> simptome =
          snapshot.docs.map((QueryDocumentSnapshot<Map<String, dynamic>> doc) => Symptom.fromJson(doc.data())).toList();

      return simptome;
    });
  }
}
