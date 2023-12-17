part of actions;

@freezed
class AddToPharmacy with _$AddToPharmacy {
  const factory AddToPharmacy({
    required String pharmacyId,
    required String newMedId,
    required String medName,
  }) = AddToPharmacyStart;

  const factory AddToPharmacy.successful() = AddToPharmacySuccessful;

  const factory AddToPharmacy.error(Object error, StackTrace stackTrace) = AddToPharmacyError;
}
