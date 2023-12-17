part of actions;

@freezed
class AddMedToSystem with _$AddMedToSystem {
  const factory AddMedToSystem({
    required MedFromDatabase medFromDatabase,
    required ActionResponse response,

  }) = AddMedToSystemStart;

  const factory AddMedToSystem.successful() = AddMedToSystemSuccessful;

  const factory AddMedToSystem.error(Object error, StackTrace stackTrace) = AddMedToSystemError;
}
